Задача 4

    - Запустите в Yandex Cloud ВМ (вам хватит 2 Гб Ram).
    - Подключитесь к Вм по ssh и установите docker.
    - Напишите bash-скрипт, который скачает ваш fork-репозиторий в каталог /opt и запустит проект целиком.
    - Зайдите на сайт проверки http подключений, например(или аналогичный): https://check-host.net/check-http 
        и запустите проверку вашего сервиса http://<внешний_IP-адрес_вашей_ВМ>:8090. Таким образом трафик будет 
        направлен в ingress-proxy. Трафик должен пройти через цепочки: Пользователь → Internet → Nginx → HAProxy → 
        FastAPI(запись в БД) → HAProxy → Nginx → Internet → Пользователь
    - (Необязательная часть) Дополнительно настройте remote ssh context к вашему серверу. Отобразите список
            контекстов и результат удаленного выполнения docker ps -a
    - Повторите SQL-запрос на сервере и приложите скриншот и ссылку на fork.



# В UI Яндекс Cloud пытался создать новую ВМ с названием "test04"
08.10.2026 - Яндекс Cloud не работал целый день, написал на продление дедлайна

# Создание нового ssh ключа
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_new -C "comment"
Использовал старый

# Подключиться к ВМ в облаке
ssh yc-user@<ПУБЛИЧНЫЙ_IP_ВМ>

Если ключ лежит не в стандартной папке
ssh -i /путь/к/ключу id_rsa yc-user@<ПУБЛИЧНЫЙ_IP_ВМ>

# После входа выполните установку Docker и добавление пользователя в группу docker
# (чтобы не писать sudo перед каждой командой):

sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER

# После добавления в группу нужно переподключиться к ВМ, чтобы изменения вступили в силу:

exit
ssh yc-user@<ПУБЛИЧНЫЙ_IP_ВМ>

Проверить установку: 
docker --version

# Bash-скрипт для деплоя
Находясь на ВМ, создадим скрипт, который сделает всё автоматически

Создадим deploy.sh
nano deploy.sh

    #!/bin/bash
    set -e # Остановить скрипт при ошибке
    
    echo "Обновление системы и установка git и docker-compose-plugin..."
    sudo apt update
    sudo apt install -y git docker-compose-plugin
    
    echo "Клонирование репозитория в /opt..."
    sudo git clone https://github.com/JSkuns/shvirtd-example-python.git /opt/shvirtd-example-python
    
    echo "Запуск проекта..."
    cd /opt/shvirtd-example-python
    
    # Запускаем от имени root через sudo, чтобы избежать проблем с правами на /opt
    sudo docker compose down -v
    sudo docker compose up -d --build
    
    echo "✅ Деплой завершен! Проверьте статус: sudo docker compose ps"

Сделаем файл исполняемым
chmod +x deploy.sh

Запускаем скрипт
./deploy.sh


# Внешняя проверка через check-host.net
Открываем
https://check-host.net/check-http

В поле ввода вводим адрес сервиса, обязательно с http:// (не https):
http://<ПУБЛИЧНЫЙ_IP_ВМ>:8090

Нажимаем Check
200 OK и в ответе виден текст "TIME: ..., IP: ...".


# Настройка Remote SSH Context
Эту часть выполняем на локальном компьютере, не на ВМ. Это позволит управлять докером на сервере с компа.

Создаём контекст
docker context create yc-vm --docker "host=ssh://yc-user@<ПУБЛИЧНЫЙ_IP_ВМ>"

Переключимся на этот контекст
docker context use yc-vm

Проверим, что вы видим контейнеры с ВМ
docker ps -a

Чтобы вернуться к управлению локальным докером
docker context use default

# SQL-запрос на сервере и скриншот
Подключится к ВМ по SSH
Перейти в папку проекта
cd /opt/shvirtd-example-python

Подключимся к базе данных (используем sudo, так как файлы в /opt, и заменим пароль на тот, что в .env):
sudo docker exec -ti shvirtd-example-python-db-1 mysql -uroot -pQwErTy1234

В консоли MySQL вводим команды по очереди
show databases;
use virtd;
show tables;
SELECT * from requests LIMIT 10;

Делаем скриншот и сохраняем

Выходим из БД
exit