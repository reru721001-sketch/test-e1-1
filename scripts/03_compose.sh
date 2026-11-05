#!/usr/bin/env bash
# 보너스: Compose up/ps/logs/네트워크 통신/down. 실행: bash scripts/03_compose.sh
cd "$(dirname "$0")/.."
LOG="$(pwd)/logs/03_compose.txt"
: > "$LOG"
run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }
export MSYS_NO_PATHCONV=1

run 'docker compose version'
run 'WEB_PORT=8090 docker compose up -d --build'
sleep 3
run 'docker compose ps'
run 'curl -s http://localhost:8090'
# 서비스 이름(cache)으로 컨테이너 간 통신 확인 (서비스 디스커버리)
run 'docker compose exec web sh -c "nc -zv cache 6379"'
run 'docker compose exec cache redis-cli ping'
run 'docker compose exec web sh -c "echo APP_ENV=\$APP_ENV"'
run 'docker compose logs --tail 5'
run 'docker compose down'
