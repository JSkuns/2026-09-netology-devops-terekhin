Задача 4

    - Запустите первый контейнер из образа centos c любым тегом в фоновом режиме, подключив папку текущий рабочий 
        каталог $(pwd) на хостовой машине в /data контейнера, используя ключ -v.
    - Запустите второй контейнер из образа debian в фоновом режиме, подключив текущий рабочий каталог $(pwd) в 
        /data контейнера.
    - Подключитесь к первому контейнеру с помощью docker exec и создайте текстовый файл любого содержания в /data.
    - Добавьте ещё один файл в текущий каталог $(pwd) на хостовой машине.
    - Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /data контейнера.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.




# Использую centos:7 — последнюю стабильную версию.
docker pull centos:7

# Скачаем debian
docker pull debian:latest

# Образы CentOS и Debian по умолчанию сразу завершают работу, если им не дать команду. Поэтому мы добавляем 
# sleep infinity, чтобы контейнер работал в фоне постоянно.
docker run -d --name centos-t4 -v $(pwd):/data centos:7 sleep infinity
docker run -d --name debian-t4 -v $(pwd):/data debian:latest sleep infinity

# Создание файла внутри контейнера CentOS
docker exec centos-t4 sh -c 'echo "Этот файл создан из контейнера CentOS" > /data/centos_file.txt'

# Создание файла на хост-машине
echo "Этот файл создан напрямую на хостовой машине" > host_file.txt

# Проверка из контейнера Debian
docker exec debian-t4 ls -la /data
docker exec debian-t4 cat /data/centos_file.txt
docker exec debian-t4 cat /data/host_file.txt

# В итоге сохранил
screen30.png - screen32.png
