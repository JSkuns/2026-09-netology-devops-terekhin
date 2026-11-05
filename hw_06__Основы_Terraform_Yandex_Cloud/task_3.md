Задание 3

    - Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
    - Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: "netology-develop-platform-db" , 
        cores  = 2, memory = 2, core_fraction = 20. Объявите её переменные с префиксом vm_db_ в том же файле 
        ('vms_platform.tf'). ВМ должна работать в зоне "ru-central1-b"
    - Примените изменения.

Сделал изменения, согласно описанию

https://github.com/JSkuns/ter-homeworks/commit/d279b16ee224b477359209c12244db60adb7265b

    terraform fmt
    terraform plan
    terraform apply

Ошибка
Error: Error while requesting API to create instance: x-request-id = c90eb16e-c4d9-40d7-a017-33fd134b717a 
    x-server-trace-id = 70cded6a92fac97c:709dbea1ce9c0d67:d896ded3c9f176b2:1 x-client-trace-id = 
    d933ac44-cd0b-49fb-8e9d-82f2b81a4ee9 rpc error: code = FailedPrecondition desc = Zone ru-central1-b is not available

В UI облака написано было что зона b пока недоступна, тогда переделаем на d, названия не стал пеерименовывать

На облаке создались две ВМ, если старые удалить, если не удалять, то добавляется только ВМ БД