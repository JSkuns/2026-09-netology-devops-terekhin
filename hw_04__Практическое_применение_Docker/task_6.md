Задача 6

    Скачайте docker образ hashicorp/terraform:latest и скопируйте бинарный файл /bin/terraform на свою локальную 
        машину, используя dive и docker save. Предоставьте скриншоты действий.


Установка dive 

sudo apt-get install -y wget
wget https://github.com/wagoodman/dive/releases/download/v0.12.0/dive_0.12.0_linux_amd64.deb
sudo dpkg -i dive_0.12.0_linux_amd64.deb

Проверка установки:

dive --version

Скачивание образа

docker pull hashicorp/terraform:latest

Сохранение образа в tar-архив (docker save)

docker save hashicorp/terraform:latest -o terraform-image.tar
ls -lh terraform-image.tar

Исследование образа через dive

dive terraform-image.tar

Загрузить образ из tar-файла в Docker:

docker load -i terraform-image.tar

Запустить dive, указав имя образа:

dive hashicorp/terraform:latest

Создаём временный контейнер (не запуская его)

CONTAINER_ID=$(docker create hashicorp/terraform:latest)

Скопируем бинарный файл из этого контейнера в текущую папку:

docker cp $CONTAINER_ID:/bin/terraform ./terraform

Удалим временный контейнер:

docker rm $CONTAINER_ID

Проверим файл

chmod +x ./terraform
./terraform --version