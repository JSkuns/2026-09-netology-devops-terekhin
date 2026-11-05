Задание 2

    - Замените все хардкод-значения для ресурсов yandex_compute_image и yandex_compute_instance на отдельные 
        переменные. К названиям переменных ВМ добавьте в начало префикс vm_web_ . Пример: vm_web_name.
    - Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их default 
        прежними значениями из main.tf.
    - Проверьте terraform plan. Изменений быть не должно.

В файл variables.tf добавил

    ### Переменные для ВМ (vm_web_)
    
    variable "vm_web_name" {
        type        = string
        default     = "netology-develop-platform-web"
        description = "Имя виртуальной машины"
    }
    
    variable "vm_web_platform_id" {
        type        = string
        default     = "standard-v3"
        description = "Платформа виртуальной машины"
    }
    
    variable "vm_web_cores" {
        type        = number
        default     = 2
        description = "Количество ядер vCPU"
    }
    
    variable "vm_web_memory" {
        type        = number
        default     = 1
        description = "Объем оперативной памяти в ГБ"
    }
    
    variable "vm_web_core_fraction" {
        type        = number
        default     = 20
        description = "Гарантированная доля vCPU"
    }
    
    variable "vm_web_preemptible" {
        type        = bool
        default     = true
        description = "Флаг прерываемой виртуальной машины"
    }
    
    variable "vm_web_image_family" {
        type        = string
        default     = "ubuntu-2004-lts"
        description = "Семейство образов для ВМ"
    }

В main.tf заменил значения на переменные

Выполним форматирование кода
    terraform fmt
Проверим план
    terraform plan
Получили
    No changes. Your infrastructure matches the configuration.

# screen_3

Закоммитил изменения
https://github.com/JSkuns/ter-homeworks/commit/eda1f773cc733d08ff5b1428adedfab96f6d3aca
