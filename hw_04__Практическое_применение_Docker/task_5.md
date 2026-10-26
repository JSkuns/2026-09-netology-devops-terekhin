Задача 5 (*)

    - Напишите и задеплойте на вашу облачную ВМ bash скрипт, который произведет резервное копирование БД mysql 
        в директорию "/opt/backup" с помощью запуска в сети "backend" контейнера из образа schnitzler/mysqldump 
        при помощи docker run ... команды. Подсказка: "документация образа."
    - Протестируйте ручной запуск
    - Настройте выполнение скрипта раз в 1 минуту через cron, crontab или systemctl timer. Придумайте способ не 
        светить логин/пароль в git!!
    - Предоставьте скрипт, cron-task и скриншот с несколькими резервными копиями в "/opt/backup"




Мы не будем создавать этот скрипт на локальной машине и пушить его. 
Вместо этого мы создадим его прямо на облачной ВМ, и он будет безопасно читать пароли из уже существующего 
    файла .env, который находится в .gitignore

Подключаемся по SSH к ВМ

Создаём файл скрипта в директории проекта
sudo nano /opt/shvirtd-example-python/backup.sh

Вставим в него следующий код (он использует абсолютные пути, что критично для cron):

    #!/bin/bash
    
    # 1. Загружаем переменные окружения из существующего .env файла
    # Это гарантирует, что пароли не хранятся в самом скрипте и не попадут в Git
    source /opt/shvirtd-example-python/.env
    
    # 2. Определяем переменные для удобства
    BACKUP_DIR="/opt/backup"
    # Формируем уникальное имя файла с точностью до секунды
    TIMESTAMP=$(date +\%Y\%m\%d-\%H\%M\%S)
    BACKUP_FILE="${BACKUP_DIR}/${MYSQL_DATABASE}-${TIMESTAMP}.sql"
    
    # 3. Создаем директорию для бэкапов, если её нет
    mkdir -p "${BACKUP_DIR}"
    
    # 4. Запускаем контейнер schnitzler/mysqldump
    # --rm удаляет контейнер после выполнения
    # --network указывает на сеть, созданную docker compose (имя проекта + имя сети)
    # Вывод (stdout) перенаправляем в файл на хост-машине
    docker run --rm \
    --network shvirtd-example-python_backend \
    -e MYSQL_HOST=db \
    -e MYSQL_USER="${MYSQL_USER}" \
    -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
    -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
    schnitzler/mysqldump > "${BACKUP_FILE}"
    
    # 5. Проверяем, что файл создан и не пустой
    if [ -s "${BACKUP_FILE}" ]; then
    echo "Бэкап успешно создан: ${BACKUP_FILE}"
    else
    echo "Ошибка: файл бэкапа пуст или не создан!"
    rm -f "${BACKUP_FILE}"
    fi

Сделаем скрипт исполняемым:
sudo chmod +x /opt/shvirtd-example-python/backup.sh

Ручное тестирование скрипта
sudo /opt/shvirtd-example-python/backup.sh

Проверим, появился ли файл:
ls -la /opt/backup/
Должны увидеть файл вида virtd-20261007-193015.sql

# Настройка автоматического выполнения через Cron
Нам нужно, чтобы скрипт запускался каждую минуту

... не успеваю сделать

