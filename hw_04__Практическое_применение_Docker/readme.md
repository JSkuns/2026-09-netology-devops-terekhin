Схема

    Curl request
    ↓
    network: host (порт 8090)
    ↓
    ingress-proxy
    ↓
    Port mapping (127.0.0.1:8080)
    ↓
    reverse-proxy
    ↓
    web python (172.20.0.5:5000)
    ↓
    db mysql (172.20.0.10:3306)