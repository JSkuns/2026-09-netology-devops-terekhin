Задача 1

Сценарий выполнения задачи:

    Установите docker и docker compose plugin на свою linux рабочую станцию или ВМ.
    Если dockerhub недоступен создайте файл /etc/docker/daemon.json с содержимым: 
        {"registry-mirrors": ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]}
    Зарегистрируйтесь и создайте публичный репозиторий с именем "custom-nginx" на https://hub.docker.com 
        (ТОЛЬКО ЕСЛИ У ВАС ЕСТЬ ДОСТУП);
    скачайте образ nginx:1.29.0;
    Создайте Dockerfile и реализуйте в нем замену дефолтной индекс-страницы(/usr/share/nginx/html/index.html), на 
        файл index.html с содержимым:

    <html>
        <head>
            Hey, Netology
        </head>
        <body>
            <h1>I will be DevOps Engineer!</h1>
        </body>
    </html>

Соберите и отправьте созданный образ в свой dockerhub-репозитории c tag 1.0.0 (ТОЛЬКО ЕСЛИ ЕСТЬ ДОСТУП).
Предоставьте ответ в виде ссылки на https://hub.docker.com/<username_repo>/custom-nginx/general .



# Добавляем официальный GPG-ключ Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Добавляем репозиторий Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновляем и устанавливаем Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Добавляем пользователя в группу docker, чтобы не писать sudo перед каждой командой
sudo usermod -aG docker $USER

# Перезагружаем систему или выходим и заходим в терминал заново, чтобы применились права
# (можно просто выполнить: newgrp docker)

# Перезапустите Docker, чтобы настройки применились:
sudo systemctl restart docker

# Установил Docker Compose при помощи
sudo apt install docker-compose                        <-- устаревшая...

# Проверил версию docker-compose
docker-compose --version

# Вошёл в Docker hub, через веб
docker login

# Сделал тег на Docker hub
docker tag custom-nginx:1.0.0 jskuns/custom-nginx:1.0.0

# 1. Создаем кастомный HTML-файл
cat <<EOF > index.html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
EOF

# 2. Создаем Dockerfile
cat <<EOF > Dockerfile
FROM nginx:1.29.0
COPY index.html /usr/share/nginx/html/index.html
EOF

# Создаём образ
docker build -t custom-nginx:1.0.0 .

# Проверим работоспособность
docker run -d --name test-nginx -p 8080:80 custom-nginx:1.0.0
curl http://localhost:8080

# Должна отобразиться кастомная страница, остановим
docker stop test-nginx && docker rm test-nginx

# Отправим изменения в хаб
docker push jskuns/custom-nginx:1.0.0

# Итоговая ссылка
https://hub.docker.com/repository/docker/jskuns/custom-nginx/general
Без авторизации - https://hub.docker.com/r/jskuns/custom-nginx

