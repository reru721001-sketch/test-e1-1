#!/usr/bin/env bash
# Docker 점검/운영/Dockerfile/포트/마운트/볼륨 실습 전체를 실행하고 로그로 남긴다.
# 전제: Docker(Desktop/OrbStack) 실행 중. 실행: bash scripts/02_docker.sh
cd "$(dirname "$0")/.."
ROOT="$(pwd)"
LOG="$(pwd)/logs/02_docker.txt"
: > "$LOG"
run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }
export MSYS_NO_PATHCONV=1   # Git Bash 에서 /data 같은 경로가 C:/... 로 변환되는 문제 방지

# 이전 실행 잔여물 정리
docker rm -f my-web-8080 my-web-8081 bind-test vol-test vol-test2 ubuntu-keep >/dev/null 2>&1
docker volume rm mydata >/dev/null 2>&1

echo "## 1. 설치 점검" | tee -a "$LOG"
run 'docker --version'
run 'docker info | sed -n "/^Server:/,/^ Server Version/p"'

echo "## 2. 이미지/컨테이너 기본" | tee -a "$LOG"
run 'docker pull hello-world'
run 'docker pull ubuntu:24.04'
run 'docker images'
run 'docker run --rm hello-world'
run 'docker run --rm ubuntu:24.04 bash -c "ls / && echo hello-from-ubuntu"'

echo "## 3. attach vs exec" | tee -a "$LOG"
run 'docker run -dit --name ubuntu-keep ubuntu:24.04 bash'
run 'docker exec ubuntu-keep bash -c "echo exec-run; ls /root"'
run 'docker ps --filter name=ubuntu-keep'   # exec 종료 후에도 컨테이너 유지됨
run 'docker stop ubuntu-keep'
run 'docker ps -a --filter name=ubuntu-keep'

echo "## 3-1. 권한 실습 (Linux 파일시스템, Windows NTFS 대체)" | tee -a "$LOG"
run 'docker run --rm ubuntu:24.04 bash -c "cd /tmp && touch f.txt && mkdir d && ls -l f.txt && chmod 755 f.txt && ls -l f.txt && chmod 644 f.txt && ls -l f.txt && ls -ld d && chmod 700 d && ls -ld d && chmod 755 d && ls -ld d"'

echo "## 4. Dockerfile 빌드 + 포트 매핑 (2회)" | tee -a "$LOG"
run 'docker build -t my-web:1.0 ./app'
run 'docker run -d -p 8080:80 --name my-web-8080 my-web:1.0'
run 'docker run -d -p 8081:80 --name my-web-8081 my-web:1.0'
sleep 3
run 'curl -s http://localhost:8080'
run 'curl -s http://localhost:8081'
sleep 12
run 'docker ps'
run 'docker logs my-web-8080 | tail -n 10'
run 'docker stats --no-stream'
run 'docker inspect --format "{{.Config.Env}} {{.Config.Labels}}" my-web:1.0'

echo "## 5. 바인드 마운트" | tee -a "$LOG"
mkdir -p bind-site && cp app/site/index.html bind-site/
run "docker run -d -p 8082:80 --name bind-test -v \"$ROOT/bind-site\":/usr/share/nginx/html nginx:1.27-alpine"
sleep 2
run 'curl -s http://localhost:8082 | grep version'
run 'sed -i "s/version: v1/version: v2 (changed on host)/" bind-site/index.html'
run 'curl -s http://localhost:8082 | grep version'

echo "## 6. 볼륨 영속성" | tee -a "$LOG"
run 'docker volume create mydata'
run 'docker volume ls'
run 'docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity'
run 'docker exec vol-test bash -lc "echo hi > /data/hello.txt && cat /data/hello.txt"'
run 'docker rm -f vol-test'
run 'docker ps -a --filter name=vol-test'
run 'docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity'
run 'docker exec vol-test2 bash -lc "cat /data/hello.txt"'
run 'docker volume inspect mydata'

echo "## 7. 정리 전 상태" | tee -a "$LOG"
run 'docker ps -a'
