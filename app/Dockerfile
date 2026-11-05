# 베이스: 공식 nginx:alpine 이미지 (방식 A - 웹 서버 베이스 + 정적 콘텐츠/설정 교체)
FROM nginx:1.27-alpine

# 이미지 메타데이터 (docker inspect 로 확인 가능)
LABEL org.opencontainers.image.title="my-custom-nginx" \
      org.opencontainers.image.description="Codyssey dev workstation mission"

# 실행 모드를 환경 변수로 노출 (설정과 코드 분리)
ENV APP_ENV=dev

# 기본 페이지 교체
COPY site/ /usr/share/nginx/html/

# 헬스체크: 컨테이너 상태를 docker ps 에서 healthy/unhealthy 로 확인
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost/ >/dev/null || exit 1

EXPOSE 80
