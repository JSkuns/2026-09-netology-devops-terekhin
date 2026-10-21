Задача 3

    - Изучите файл "proxy.yaml"
    - Создайте в репозитории с проектом файл compose.yaml. С помощью директивы "include" подключите к нему 
        файл "proxy.yaml".
    - Опишите в файле compose.yaml следующие сервисы:

    - web. Образ приложения должен ИЛИ собираться при запуске compose из файла Dockerfile.python ИЛИ скачиваться 
        из yandex cloud container registry(из задание №2 со *). Контейнер должен работать в bridge-сети с названием 
        backend и иметь фиксированный ipv4-адрес 172.20.0.5. Сервис должен всегда перезапускаться в случае ошибок. 
        Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса web

    - db. image=mysql:8. Контейнер должен работать в bridge-сети с названием backend и иметь фиксированный 
        ipv4-адрес 172.20.0.10. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для 
        создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения. 
        Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!

    - Запустите проект локально с помощью docker compose , добейтесь его стабильной работы: команда 
        curl -L http://127.0.0.1:8090 должна возвращать в качестве ответа время и локальный IP-адрес. Если 
        сервисы не стартуют воспользуйтесь командами: docker ps -a  и docker logs <container_name> . Если вместо 
        IP-адреса вы получаете информационную ошибку --убедитесь, что вы шлете запрос на порт 8090, а не 5000.

    - Подключитесь к БД mysql с помощью команды docker exec -ti <имя_контейнера> mysql -uroot -p<пароль root-пользователя>
        (обратите внимание что между ключем -u и логином root нет пробела. это важно!!! тоже самое с паролем) . Введите 
        последовательно команды (не забываем в конце символ ; ): show databases; use <имя вашей базы данных(по-умолчанию 
        virtd, как это указано в .env)>; show tables; SELECT * from requests LIMIT 10;. Примечание: таблица в БД 
        создается после первого поступившего запроса к приложению.

    - Остановите проект. В качестве ответа приложите скриншот sql-запроса.



# Так как у меня уже есть compose.yaml, буду его модифицировать под новые требования
Изменил compose:

    include:
        - proxy.yaml

    services:
        db:
            image: mysql:8.0
            restart: always
            environment:
                - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
                - MYSQL_DATABASE=${MYSQL_DATABASE}
                - MYSQL_USER=${MYSQL_USER}
                - MYSQL_PASSWORD=${MYSQL_PASSWORD}
            ports:
                - "3306:3306"
            networks:
                backend:
                    ipv4_address: 172.20.0.10
            volumes:
                - mysql_data:/var/lib/mysql
            healthcheck:
                test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "app", "-pvery_strong"]
                interval: 5s
                timeout: 5s
                retries: 5

        web:
            build:
                context: .
                dockerfile: Dockerfile.python
            restart: always
            networks:
                backend:
                    ipv4_address: 172.20.0.5
            environment:
                - DB_HOST=db
                - DB_PORT=3306
                - DB_USER=${MYSQL_USER}
                - DB_PASSWORD=${MYSQL_PASSWORD}
                - DB_NAME=${MYSQL_DATABASE}
            depends_on:
                db:
                    condition: service_healthy

    volumes:
        mysql_data:



# Дальше
docker compose down -v
docker compose up -d --build

Проверим работу
curl -L http://127.0.0.1:8090

# Запросы в БД
docker ps
У нас есть контейнер shvirtd-example-python-db-1

Подключаемся к БД
docker exec -ti shvirtd-example-python-db-1 mysql -uroot -p...

Вводим построчно

    show databases;
    use virtd;
    show tables;
    SELECT * from requests LIMIT 10;

Делаем скриншот 

Выходим
exit

Останавливаем всё
docker compose down