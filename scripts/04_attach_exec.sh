#!/usr/bin/env bash
# ubuntu 컨테이너 내부 진입 + attach/exec 차이 관찰. 실행: bash scripts/04_attach_exec.sh
# 대화형 터미널(TTY)이 없는 환경이라 -i 로 표준입력을 열고 명령을 셸에 직접 전달한다.
# 직접 손으로 하려면: docker run -it ubuntu:24.04 bash (Git Bash 는 앞에 winpty)
cd "$(dirname "$0")/.."
LOG="$(pwd)/logs/04_attach_exec.txt"
: > "$LOG"
run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }
docker rm -f ubuntu-it ubuntu-ae >/dev/null 2>&1

echo "## 1. 컨테이너 내부 진입 후 명령 실행 → exit" | tee -a "$LOG"
run 'printf "hostname\nls /\necho hello-inside\nexit\n" | docker run -i --name ubuntu-it ubuntu:24.04 bash'
run 'docker ps -a --filter name=ubuntu-it'    # 메인 셸이 끝났으므로 Exited

echo "## 2. exec: 새 프로세스로 들어갔다 나오기" | tee -a "$LOG"
run 'docker run -di --name ubuntu-ae ubuntu:24.04 bash'
run 'printf "echo inside-via-exec\nps -e -o pid,cmd\nexit\n" | docker exec -i ubuntu-ae bash'
run 'docker ps --filter name=ubuntu-ae'       # exec 셸만 끝남 → 컨테이너는 Up

echo "## 3. attach: 메인 프로세스(PID 1)에 붙었다 나오기" | tee -a "$LOG"
run 'printf "echo inside-via-attach; echo PID=\$\$\nexit\n" | docker attach ubuntu-ae'
run 'docker logs ubuntu-ae'                 # attach 로 보낸 명령이 PID 1 셸에서 실행된 결과
run 'docker ps -a --filter name=ubuntu-ae'    # PID 1 이 끝남 → Exited

docker rm -f ubuntu-it ubuntu-ae >/dev/null 2>&1
