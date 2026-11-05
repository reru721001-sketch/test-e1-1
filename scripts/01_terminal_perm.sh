#!/usr/bin/env bash
# 터미널 기본 조작 + 권한 실습. 실행: bash scripts/01_terminal_perm.sh
# 결과는 logs/01_terminal_perm.txt 에 "명령 + 출력" 형태로 저장된다.
cd "$(dirname "$0")/.."
LOG="$(pwd)/logs/01_terminal_perm.txt"
: > "$LOG"
run() { echo "\$ $*" | tee -a "$LOG"; eval "$@" 2>&1 | tee -a "$LOG"; echo | tee -a "$LOG"; }

# --- 터미널 조작 ---
run 'cd practice 2>/dev/null || { mkdir -p practice && cd practice; }'
cd practice
run 'pwd'
run 'mkdir -p docs backup'
run 'echo "hello codyssey" > note.txt'
run 'touch empty.txt'
run 'ls -la'
run 'cat note.txt'
run 'cp note.txt backup/note_copy.txt'
run 'mv empty.txt docs/renamed.txt'
run 'ls -la docs backup'
run 'cd docs && pwd && cd ..'
run 'cd ../practice && pwd'          # 상대 경로 이동
run "cd \"$(pwd)\" && pwd"            # 절대 경로 이동
run 'rm backup/note_copy.txt && rmdir backup'
run 'ls -la'

# --- 권한 실습 (파일 1개, 디렉토리 1개) ---
run 'ls -l note.txt'
run 'chmod 644 note.txt && ls -l note.txt'
run 'chmod 755 note.txt && ls -l note.txt'
run 'ls -ld docs'
run 'chmod 700 docs && ls -ld docs'
run 'chmod 755 docs && ls -ld docs'
