Задача 2

    - Запустите ваш образ custom-nginx:1.0.0 командой docker run в соответвии с требованиями:
    - имя контейнера "ФИО-custom-nginx-t2"
    - контейнер работает в фоне
    - контейнер опубликован на порту хост системы 127.0.0.1:8080
    
    - Не удаляя, переименуйте контейнер в "custom-nginx-t2"
    
    - Выполните команду date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080  ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
    
    - Убедитесь с помощью curl или веб браузера, что индекс-страница доступна.
    
В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.




# Запуск контейнера с требуемыми параметрами
docker run -d --name "Terekhin-Vladimir-Vladimirovich-custom-nginx-t2" -p 127.0.0.1:8080:80 custom-nginx:1.0.0

# Переименование контейнера
docker rename "Terekhin-Vladimir-Vladimirovich-custom-nginx-t2" custom-nginx-t2

# Выполнение комплексной диагностической команды
date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n 1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html

# Проверка доступности страницы через curl
curl http://127.0.0.1:8080

# В итоге сохранил
screen1.png
screen2.png
screen3.png
screen4.png