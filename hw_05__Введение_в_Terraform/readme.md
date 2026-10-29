https://github.com/netology-code/ter-homeworks/blob/main/01/hw-01.md

    - Скачайте и установите Terraform версии >=1.12.0 . Приложите скриншот вывода команды terraform --version.
    - Скачайте на свой ПК этот git-репозиторий. Исходный код для выполнения задания расположен в директории 01/src.
    - Убедитесь, что в вашей ОС установлен docker.

https://hashicorp-releases.yandexcloud.net/terraform/
https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart?utm_referrer=https%3A%2F%2Fgithub.com%2F
https://developer.hashicorp.com/terraform

sudo snap install terraform --classic

git clone https://github.com/netology-code/ter-homeworks.git


Задание 1

1.1 
Заменил в main.tf, т.к. установил 1.16.7
    required_version = "~>1.16.0"

    terraform init
Не нашёлся провайдер random?
Добавил
    random = {
    source  = "hashicorp/random"
    version = "~> 3.5.1"
    }
Не помогло

Выходит ошибка
    terraform init
    Initializing the backend...
    
    Initializing provider plugins...
    Finding latest version of kreuzwerker/docker...
    Finding hashicorp/random versions matching "~> 3.5.1"...
      ╷
      │ Error: Invalid provider registry host
      │
      │ The host "registry.terraform.io" given in provider source address
      │ "registry.terraform.io/kreuzwerker/docker" does not offer a Terraform
      │ provider registry.
      ╵
      ╷
      │ Error: Invalid provider registry host
      │
      │ The host "registry.terraform.io" given in provider source address
      │ "registry.terraform.io/hashicorp/random" does not offer a Terraform provider
      │ registry.
Эта ошибка означает, что Terraform не может получить доступ к реестру провайдеров. Это происходит по одной из двух причин:
    Зеркало Яндекса (terraform-mirror.yandexcloud.net) временно недоступно или отдает некорректный ответ.
    Сетевые ограничения блокируют прямой доступ к registry.terraform.io, а настройка зеркала при этом сбоит.
Временно отключим использование зеркала и позволим Terraform скачать провайдеры напрямую
    # Блок provider_installation закомментируем
Не помогло
Пробую
rm -rf .terraform .terraform.lock.hcl
Не помогло
Проверка доступности
curl -I https://registry.terraform.io/v1/providers/hashicorp/random/versions
Выдаёт ошибку 404 и с зеркалом и без
curl -I https://terraform-mirror.yandexcloud.net/v1/providers/hashicorp/random/versions
В итоге окольными путями скачал zip файлы hashicorp/random и kreuzwerker/docker и сложил в нужные папки на ВМ
Запустил
    terraform init
И всё заработало

1.2
Согласно представленному файлу .gitignore, допустимо сохранить личную, секретную информацию в файле:
personal.auto.tfvars

1.3
terraform apply
выдаёт ошибку
Error: Failed to load plugin schemas
Даем права на исполнение всем бинарникам провайдеров в папке проекта
find .terraform/providers -type f -name "terraform-provider-*" -exec chmod +x {} \;

На всякий случай, делаем то же самое для глобальной папки плагинов (откуда мы их клали)
find ~/.terraform.d/plugins -type f -name "terraform-provider-*" -exec chmod +x {} \;

Теперь apply сработал

Ищем секрет
Просто открыл как текстовый файл

Нашёл
"result": "tA4JEdi1lomIGbfg",

1.4
Судя по описанию resource должен иметь тип и имя, добавим имя
resource "docker_image" "nginx" {
Второе исправление имя ресурса не должно начианться с цифры "1"
resource "docker_container" "nginx" {
Третье исправление, нет такой переменной random_password.random_string_FAKE.resulT, а есть
random_password.random_string.result

1.5
terraform apply
docker ps
см. скрин №6

    resource "docker_image" "nginx" {
        name         = "nginx:latest"
        keep_locally = true
    }
    
    resource "docker_container" "nginx" {
        image = docker_image.nginx.image_id
        name  = "example_${random_password.random_string.result}"
    
        ports {
            internal = 80
            external = 9090

1.6
resource "docker_container" "hello_world" {

terraform apply -auto-approve
Получили ошибку
Error: Unable to create container: Error response from daemon: Conflict. The container name "/example_tA4JEdi1lomIGbfg" 
    is already in use by container "2e76ad594cd6feebcada425949e3f8dc3cdf7faf264f8a491813efa70db2f0d4". You have to 
    remove (or rename) that container to be able to reuse that name.

Удалим докер контейнер
docker ps -a
docker rm -f 9b61975d0b5b

terraform apply -auto-approve

Ключ -auto-approve полностью отключает интерактивное подтверждение операций. Terraform не показывает план 
    изменений (terraform plan) и не спрашивает у пользователя yes/no перед применением. Это опасно по нескольким 
    причинам:

    - Невозможность визуальной проверки. Вы не видите, что именно собирается сделать Terraform: какие ресурсы будут 
        созданы, изменены или удалены. В сложных инфраструктурах одна опечатка может привести к удалению 
        продакшн-базы данных или балансировщика.
    - Риск случайного запуска. Если вы перепутали ветку, рабочую директорию или файл переменных, Terraform молча 
        применит неверную конфигурацию.
    - Отсутствие "точки остановки". В обычном режиме у инженера есть несколько секунд, чтобы посмотреть на план, 
        заметить аномалию (например, 35 resources to destroy) и нажать Ctrl+C. С -auto-approve этой страховки нет.

Зачем может пригодиться этот ключ:
Ключ -auto-approve необходим для автоматизации в CI/CD-пайплайнах (GitLab CI, GitHub Actions, Jenkins, ArgoCD). В 
    этих системах нет интерактивного терминала — скрипт должен выполниться от начала до конца без ожидания ввода 
    от пользователя. Также он удобен при разработке и тестировании, когда вы уверены в изменениях и не хотите каждый 
    раз вводить yes.

1.7
terraform destroy
Скрин №11

1.8
docker images
docker images | grep nginx

В файле main.tf в ресурсе docker_image явно указан параметр:
keep_locally = true
Атрибут keep_locally = true прямо говорит провайдеру: "при удалении ресурса не удаляй сам образ из локального 
    хранилища Docker". Поэтому после terraform destroy контейнер исчез, а образ nginx:latest остался лежать на диске.

Образы весят сотни мегабайт и скачиваются долго.
При частых terraform apply / destroy (например, в CI) постоянное скачивание одного и того же nginx:latest тратило
    бы время и трафик.
Образ можно удалить вручную командой docker rmi nginx:latest, когда он точно не нужен.

https://library.tf/providers/kreuzwerker/docker/latest/docs/resources/image
keep_locally (Boolean) Если значение true, то образ Docker не будет удален при выполнении операции уничтожения. Если 
    значение false, то при выполнении операции уничтожения образ будет удален из локального хранилища Docker.