FROM golang:1.12

RUN apt-get update && apt-get install -y --no-install-recommends \
  libmagickwand-dev \
  libraw-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /go/src/app
RUN git clone https://gitlab.com/fengshaun/redcarpet.git /go/src/app
RUN go get -d -v ./...
RUN go build -o redcarpet

FROM node:12.9.1-alpine
WORKDIR /usr/src/app
COPY --from=0 /go/src/app /usr/src/app
RUN npm ci
RUN npm run build
RUN find | grep -v node_modules | grep bundle


FROM golang:1.12
RUN apt-get update && apt-get install -y --no-install-recommends \
  libmagickwand-6.q16-6 \
  libraw19 \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local/redcarpet
COPY --from=0 /go/src/app ./
RUN { \
  echo 'Debug = true'; \
  echo 'BasePath = "/photos"'; \
  echo 'LogFile = "/dev/stderr"'; \
  echo 'BaseURL = "/"'; \
  echo 'ListenAddress = "0.0.0.0:3000"'; \
  } > ./config.toml
COPY --from=1 /usr/src/app/static/js/bundle.js ./static/js/
ENTRYPOINT ["./redcarpet"]
CMD ["-c", "./config.toml"]
