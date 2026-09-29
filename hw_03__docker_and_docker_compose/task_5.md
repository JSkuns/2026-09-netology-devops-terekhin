Задача 5

    - Создайте отдельную директорию(например /tmp/netology/docker/task5) и 2 файла внутри него. "compose.yaml" 
        с содержимым:

    version: "3"
    services:
        portainer:
            network_mode: host
            image: portainer/portainer-ce:latest
            volumes:
                - /var/run/docker.sock:/var/run/docker.sock

    "docker-compose.yaml" с содержимым:
    
    version: "3"
    services:
        registry:
            image: registry:2
        
            ports:
            - "5000:5000"

    И выполните команду "docker compose up -d". Какой из файлов был запущен и почему? 
        (подсказка: https://docs.docker.com/compose/compose-application-model/#the-compose-file )
    
    - Отредактируйте файл compose.yaml так, чтобы были запущенны оба файла. 
        (подсказка: https://docs.docker.com/compose/compose-file/14-include/)
    
    - Выполните в консоли вашей хостовой ОС необходимые команды чтобы залить образ custom-nginx как 
        custom-nginx:latest в запущенное вами, локальное registry. Дополнительная документация:
        https://distribution.github.io/distribution/about/deploying/
    
    - Откройте страницу "https://127.0.0.1:9000" и произведите начальную настройку portainer.(логин и 
        пароль адмнистратора)
    
    - Откройте страницу "http://127.0.0.1:9000/#!/home", выберите ваше local окружение. Перейдите на вкладку 
        "stacks" и в "web editor" задеплойте следующий компоуз:
    
    version: '3'
    
    services:
        nginx:
            image: 127.0.0.1:5000/custom-nginx
            ports:
                - "9090:80"

    - Перейдите на страницу "http://127.0.0.1:9000/#!/2/docker/containers", выберите контейнер с nginx и нажмите 
        на кнопку "inspect". В представлении <> Tree разверните поле "Config" и сделайте скриншот от поля 
        "AppArmorProfile" до "Driver".
    
    - Удалите любой из манифестов компоуза(например compose.yaml). Выполните команду "docker compose up -d". 
        Прочитайте warning, объясните суть предупреждения и выполните предложенное действие. Погасите 
        compose-проект ОДНОЙ(обязательно!!) командой.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод, файл compose.yaml,
    скриншот portainer c задеплоенным компоузом.



# Создание директории и файлов
# Создаем директорию и переходим в нее
mkdir -p /tmp/netology/docker/task5
cd /tmp/netology/docker/task5

# Создаем compose.yaml
cat <<EOF > compose.yaml
version: "3"
services:
    portainer:
        network_mode: host
        image: portainer/portainer-ce:latest
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
EOF

# Создаем docker-compose.yaml
cat <<EOF > docker-compose.yaml
version: "3"
services:
    registry:
        image: registry:2
        ports:
            - "5000:5000"
EOF


# Запуск и ответ на теоретический вопрос
docker compose up -d

Какой файл был запущен и почему?:

    Был запущен файл compose.yaml. Согласно документации Docker Compose, при выполнении команды docker compose 
        без явного указания файла через флаг -f, движок ищет конфигурационные файлы в строгом порядке приоритета:

        compose.yaml
        compose.yml
        docker-compose.yaml
        docker-compose.yml

    Поскольку файл compose.yaml существует и имеет наивысший приоритет, Docker Compose игнорирует 
        docker-compose.yaml и запускает только сервис Portainer.

# Редактирование compose.yaml для запуска обоих файлов
Чтобы запустить оба сервиса из разных файлов, используем директиву include (доступна в Docker Compose V2).
Отредактируем compose.yaml

cat <<EOF > compose.yaml
include:
    - docker-compose.yaml

services:
    portainer:
        network_mode: host
        image: portainer/portainer-ce:latest
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
EOF

Атрибут version: "3" мы убрали, так как в современных версиях Compose он считается устаревшим и вызывает предупреждения.

Теперь запустим оба сервиса:
docker compose up -d


# Загрузка образа custom-nginx в локальный registry
# Проверим наличие образа custom-nginx
docker images

Далее
# Тегирование образа для локального реестра
docker tag custom-nginx:1.0.0 127.0.0.1:5000/custom-nginx:latest

# Отправка (push) образа в локальный registry
docker push 127.0.0.1:5000/custom-nginx:latest


# Настройка Portainer и деплой стека
Открыть https://127.0.0.1:9000
Создать "Create the first administrator user".

Деплой стека (Stack) через Web Editor

    В левом боковом меню Portainer раздел Stacks.
    Кнопка Add stack (в правом верхнем углу).
    В поле Name имя стека, например: my-nginx-stack.
    В поле Web editor (большое текстовое поле) код из задания:

version: '3'
services:
    nginx:
        image: 127.0.0.1:5000/custom-nginx
        ports:
            - "9090:80"

    Прокрутить страницу вниз и нажать синюю кнопку Deploy the stack.

# Скриншот Inspect контейнера
В левом боковом меню в раздел Containers
В списке контейнер, имя которого начинается с my-nginx-stack-nginx-...
На странице деталей этого контейнера нажать кнопку Inspect

# Удаление манифеста и анализ Warning
rm compose.yaml
docker compose up -d

После удаления compose.yaml Docker Compose автоматически взял следующий файл по 
    приоритету – docker-compose.yaml. В нем указана устаревшая директива version: "3". В современных 
    версиях Docker Compose (V2) эта директива игнорируется, так как формат определяется автоматически 
    по содержимому файла. Система выдает warning, рекомендуя удалить эту строку, чтобы избежать путаницы.
Предложенное действие: открыть файл docker-compose.yaml и удалить из него строку version: "3".

# Остановка проекта ОДНОЙ командой
docker compose down

# В итоге сохранил
screen40.png - screen49.png