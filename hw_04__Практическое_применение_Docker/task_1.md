Задача 1

    - Сделайте в своем GitHub пространстве fork репозитория.

    - Создайте файл Dockerfile.python на основе существующего Dockerfile:

    - Используйте базовый образ python:3.12-slim
    - Обязательно используйте конструкцию COPY . . в Dockerfile
    - Создайте .dockerignore файл для исключения ненужных файлов
    - Используйте CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"] для запуска
    - Протестируйте корректность сборки 2.1 Используйте multistage сборку вместо single stage.
    
    - (Необязательная часть, *) Изучите инструкцию в проекте и запустите web-приложение без использования docker, с 
        помощью venv. (Mysql БД можно запустить в docker run).

    - (Необязательная часть, *) Изучите код приложения и добавьте управление названием таблицы через ENV переменную.

ВНИМАНИЕ!
!!! В процессе последующего выполнения ДЗ НЕ изменяйте содержимое файлов в fork-репозитории! Ваша задача 
    ДОБАВИТЬ 5 файлов: Dockerfile.python, compose.yaml, .gitignore, .dockerignore,bash-скрипт. Если вам 
    понадобилось внести иные изменения в проект - вы что-то делаете неверно!




# В браузере в gihub сделал fork репозитория, далее
git clone https://github.com/JSkuns/shvirtd-example-python.git


Многоступенчатая сборка позволяет установить зависимости в первом этапе (builder), а во второй этап (final) 
    скопировать только нужные пакеты и исходный код, что делает финальный образ легким и безопасным.

    # ЭТАП 1: Сборщик зависимостей
    FROM python:3.12-slim AS builder
    
    WORKDIR /app
    
    # Копируем только файл зависимостей для кэширования слоя
    COPY requirements.txt .
    
    # Устанавливаем зависимости в специальную папку /install, а не в системную
    RUN pip install --no-cache-dir --target=/install -r requirements.txt
    
    # ЭТАП 2: Финальный легкий образ
    FROM python:3.12-slim AS final
    
    WORKDIR /app
    
    # Копируем установленные зависимости из этапа builder
    COPY --from=builder /install /usr/local/lib/python3.12/site-packages/
    
    # ОБЯЗАТЕЛЬНОЕ ТРЕБОВАНИЕ: копируем исходный код
    COPY . .
    
    # Открываем порт для uvicorn
    EXPOSE 5000
    
    # ОБЯЗАТЕЛЬНОЕ ТРЕБОВАНИЕ: команда запуска
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]

.dockerignore
Этот файл предотвращает попадание мусора в Docker-образ (что особенно важно при использовании COPY . .).

    __pycache__/
    *.pyc
    *.pyo
    *.pyd
    .Python
    venv/
    .venv/
    env/
    ENV/
    .git/
    .gitignore
    .idea/
    .vscode/
    *.md
    *.log
    .DS_Store

.gitignore
Стандартный файл для исключения локальных файлов разработчика из git-репозитория.

    # Byte-compiled / optimized / DLL files
    __pycache__/
    *.py[cod]
    *$py.class
    
    # Virtual environments
    venv/
    .venv/
    env/
    
    # IDEs
    .idea/
    .vscode/
    *.swp
    *.swo
    
    # OS generated files
    .DS_Store
    Thumbs.db

compose.yaml
Оркестрирует запуск базы данных и вашего Python-приложения.

    services:
        db:
            image: mysql:8.0
            restart: always
            environment:
                MYSQL_ROOT_PASSWORD: root
                MYSQL_DATABASE: app_db
                MYSQL_USER: app
                MYSQL_PASSWORD: very_strong
            ports:
                - "3306:3306"
            volumes:
                - mysql_data:/var/lib/mysql
            healthcheck:                        <- нужен чтобы web запускался после поднятия БД
                test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "app", "-pvery_strong"]
                interval: 5s
                timeout: 5s
                retries: 5


        web:
            build:
                context: .
                dockerfile: Dockerfile.python
            restart: always
            ports:
                - "5000:5000"
            environment:
              - DB_HOST=db
              - DB_PORT=3306
              - DB_USER=app
              - DB_PASSWORD=very_strong
              - DB_NAME=app_db
            depends_on:
              db:
                condition: service_healthy

        ingress-proxy:                      <- позже добавил, чтобы приложение web работало согласно схеме
            image: nginx:latest
            restart: always
            ports:
              - "8090:80"  # Слушаем 8090 на хосте, перенаправляем на 80 внутри контейнера nginx
            volumes:
              - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
            depends_on:
              - web

    volumes:
        mysql_data:

run.sh (bash-скрипт)
Скрипт для быстрой сборки и запуска проекта через Docker Compose 

    #!/bin/bash
    
    echo "Остановка старых контейнеров (если есть)..."
    docker compose down
    
    echo "Сборка образов..."
    docker compose build
    
    echo "Запуск приложения..."
    docker compose up -d
    
    echo "✅ Готово! Приложение доступно по адресу: http://localhost:5000"
    echo "Для просмотра логов используйте: docker compose logs -f web"

сделать его исполняемым после создания: chmod +x run.sh

Добавил сервис ingress-proxy, чтобы работал web согласно схеме, пришлось добавить nginx.conf

    server {
        listen 80;
        server_name localhost;
    
        location / {
            # Перенаправляем все запросы на сервис 'web' внутри docker-сети на порт 5000
            proxy_pass http://web:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }


# Запуск без Docker через venv
Сделал скрипт run_venv.sh:

    #!/bin/bash
    
    echo " Удаление старого контейнера MySQL (если есть)..."
    docker rm -f local_mysql 2>/dev/null || true
    
    echo "Запуск MySQL в Docker..."
    docker run --name local_mysql \
    -e MYSQL_ROOT_PASSWORD=root \
    -e MYSQL_DATABASE=example \                 <- ожидается именно такое имя БД, как и юзер с паролем согласно main.py
    -e MYSQL_USER=app \
    -e MYSQL_PASSWORD=very_strong \
    -p 3306:3306 \
    -d mysql:8.0
    
    echo "Ожидание инициализации MySQL (20 секунд)..."
    sleep 20
    
    echo "Активация виртуального окружения..."
    source venv/bin/activate
    
    echo "Запуск приложения через uvicorn..."
    uvicorn main:app --host 0.0.0.0 --port 5000

сделать его исполняемым после создания: chmod +x run_venv.sh
запуск
    ./run_venv.sh

У меня в ВМ Ubuntu не установлен пакет python3-venv, значит нужно установить
    sudo apt update
    sudo apt install python3-venv -y


# запуск без Docker через venv, но с заменой имени БД
Сделал скрипт run_venv_db_name.sh:

    #!/bin/bash
    
    # Задаем переменные окружения в текущей сессии терминала
    export DB_HOST=127.0.0.1
    export DB_USER=app
    export DB_PASSWORD=very_strong
    export DB_NAME=my_custom_database  # <-- Меняем имя БД здесь
    
    echo " Удаление старого контейнера MySQL (если есть)..."
    docker rm -f local_mysql 2>/dev/null || true
    
    echo "Запуск MySQL в Docker..."
    docker run --name local_mysql \
    -e MYSQL_ROOT_PASSWORD=root \
    -e MYSQL_DATABASE=my_custom_database \
    -e MYSQL_USER=app \
    -e MYSQL_PASSWORD=very_strong \
    -p 3306:3306 \
    -d mysql:8.0
    
    echo "Ожидание инициализации MySQL (20 секунд)..."
    sleep 20
    
    echo "Активация виртуального окружения..."
    source venv/bin/activate
    
    echo "Запуск приложения через uvicorn..."
    uvicorn main:app --host 0.0.0.0 --port 5000

сделать его исполняемым после создания: chmod +x run_venv_db_name.sh
запуск
    ./run_venv_db_name.sh

Решение залил в https://github.com/JSkuns/shvirtd-example-python



