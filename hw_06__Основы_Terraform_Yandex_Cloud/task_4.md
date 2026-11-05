Задание 4

    - Объявите в файле outputs.tf один output , содержащий: instance_name, external_ip, fqdn для каждой из ВМ в 
        удобном лично для вас формате.(без хардкода!!!)
    - Примените изменения.
    - В качестве решения приложите вывод значений ip-адресов команды terraform output.

Создал файл outputs.tf

yandex_compute_instance.platform и platform_db — это имена ресурсов из main.tf. 
    Terraform сам подставит их актуальные значения после применения.
network_interface[0].nat_ip_address — это внешний (публичный) IP-адрес. Мы берём [0], потому что у 
    каждой ВМ один сетевой интерфейс.
fqdn — полностью квалифицированное доменное имя машины внутри облака Yandex.

    terraform fmt
    terraform plan
    terraform apply
    terraform output

# screen_5

у меня были выключены ВМки,
удалил, пускай заново создадутся

    terraform apply
    terraform output

# screen_6, screen_7

Закоммитил изменения

https://github.com/JSkuns/ter-homeworks/commit/68fbe0a3e224d6c5126568d2ab9cb13c8d0c00aa

