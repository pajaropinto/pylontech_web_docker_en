# Etapa de compilación
FROM alpine:latest AS builder

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache g++ make curl

WORKDIR /app
RUN mkdir -p src && \
    cd src && \
    curl -L https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp -o json.hpp && \
    curl -L https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.h -o mongoose.h && \
    curl -L https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.c -o mongoose.c

COPY src/main.cpp src/
RUN g++ -static -std=c++17 -O2 -pthread src/main.cpp src/mongoose.c -o pylontech_monitor


# Etapa final
FROM alpine:latest

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache mosquitto-clients tini

WORKDIR /app
COPY --from=builder /app/pylontech_monitor ./
COPY www/ ./www/
COPY config/ ./config/

EXPOSE 61616

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./pylontech_monitor"]
