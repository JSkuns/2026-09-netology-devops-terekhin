Задание 5

    - В файле locals.tf опишите в одном local-блоке имя каждой ВМ, используйте интерполяцию ${..} с 
        НЕСКОЛЬКИМИ переменными по примеру из лекции.
    - Замените переменные внутри ресурса ВМ на созданные вами local-переменные.
    - Примените изменения.

Добавил переменную в variables.tf
variable "project_prefix" {

Создал locals.tf и сделал составное имя из переменных

Поменял в main.tf значения name переменных на local.

В vms_platform.tf убрал переменные с именами

terraform fmt
terraform plan
terraform apply

Закоммитил изменения
https://github.com/JSkuns/ter-homeworks/commit/5593ac6453f8b60482e4309b8c2c7dd0653c5dcf