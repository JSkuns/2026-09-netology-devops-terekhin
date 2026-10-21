Задача 0

    - Убедитесь что у вас НЕ(!) установлен docker-compose, для этого получите следующую ошибку от команды docker-compose --version
        
    Command 'docker-compose' not found, but can be installed with:
    sudo snap install docker          # version 24.0.5, or
    sudo apt  install docker-compose  # version 1.25.0-1
    See 'snap info docker' for additional versions.

    В случае наличия установленного в системе docker-compose - удалите его.

    - Убедитесь что у вас УСТАНОВЛЕН docker compose(без тире) версии не менее v2.24.X, для это выполните команду 
        docker compose version

    Своё решение к задачам оформите в вашем GitHub репозитории!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



# Проверка 1
docker-compose --version
docker compose version

Оказывается, что у меня docker-compose
Удалим его

# Чтобы перейти 
# со старой standalone-версии docker-compose (с дефисом) 
# на современный плагин docker compose (с пробелом) в Ubuntu

# Полное удаление старой версии docker-compose
Если устанавливалось через apt: (это сработало)

    sudo apt remove --purge docker-compose
    sudo apt autoremove

Если устанавливалось через pip (Python):

    sudo pip3 uninstall docker-compose
    # или просто pip, если использовался он:
    sudo pip uninstall docker-compose

Если скачивалось как бинарный файл вручную:

    sudo rm -f /usr/local/bin/docker-compose

# Установка современного плагина docker compose

    sudo apt update
    sudo apt install docker-compose-plugin



