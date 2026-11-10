Задание 3

    - Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента 
        count в файле disk_vm.tf .
    - Создайте в том же файле одиночную (использовать count или for_each запрещено из-за задания №4) ВМ c именем 
        "storage" . Используйте блок dynamic secondary_disk{..} и мета-аргумент for_each для подключения созданных 
        вами дополнительных дисков.


По условию задания — ВМ должна быть одиночной с фиксированным именем "storage". Если бы мы использовали count, имя 
    стало бы массивом, а если for_each — имя зависело бы от ключа. Поэтому пишем просто resource 
    "yandex_compute_instance" "storage" без мета-аргументов.

В dynamic блоке итератор называется по имени блока (в нашем случае secondary_disk), а не each. Это важное отличие 
    от обычного for_each на уровне ресурса

terraform fmt
terraform plan
terraform apply


Выходит такая же ошибка как и в 2 задании


│ Error: Error while requesting API to create instance: x-request-id = 2b99029f-1d82-47d3-ad7e-06fc8a8f7bfe x-server-trace-id = bb3f847fa4f58e9d:07381b94d1c20afd:137eb970aa33c63f:1 x-client-trace-id = ff92dd4a-5749-4d45-890f-bb197e27d9d5 rpc error: code = ResourceExhausted desc = The limit on total size of network-hdd disks has exceeded for zone "ru-central1-a".
│
│   with yandex_compute_instance.web[1],
│   on count-vm.tf line 1, in resource "yandex_compute_instance" "web":
│    1: resource "yandex_compute_instance" "web" {
│
╵
╷
│ Error: Error while requesting API to create instance: x-request-id = 742588a4-22ab-4e20-8c27-08d5001319d3 x-server-trace-id = 2ce48f0791e63627:4572b15cfa1e7920:d2f750411056c128:1 x-client-trace-id = ff92dd4a-5749-4d45-890f-bb197e27d9d5 rpc error: code = ResourceExhausted desc = The limit on total size of network-hdd disks has exceeded for zone "ru-central1-a".
│
│   with yandex_compute_instance.web[0],
│   on count-vm.tf line 1, in resource "yandex_compute_instance" "web":
│    1: resource "yandex_compute_instance" "web" {


Пробовал экспериментировать с размером дисков, всё равно не укладываюсь в ограничения
Убрал for_each-vm.tf, переименовал в .bak

Закоммитил изменения
https://github.com/JSkuns/ter-homeworks/commit/2ba86bd77e98ab1759978aab94a4dd3062baf2e3
