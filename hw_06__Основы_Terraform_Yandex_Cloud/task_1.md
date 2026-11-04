Задание 1

    В качестве ответа всегда полностью прикладывайте ваш terraform-код в git. 
        Убедитесь что ваша версия Terraform ~>1.12.0
    
    Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.

    - Создайте сервисный аккаунт и ключ. service_account_key_file.
    - Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в 
        переменную vms_ssh_public_root_key.
    - Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите 
        внимательно, посимвольно. Ответьте, в чём заключается их суть.
    - Подключитесь к консоли ВМ через ssh и выполните команду  curl ifconfig.me. 
        Примечание: К OS ubuntu "out of a box, те из коробки" необходимо подключаться под пользователем 
        ubuntu: "ssh ubuntu@vm_ip_address". Предварительно убедитесь, что ваш ключ добавлен в 
        ssh-агент: eval $(ssh-agent) && ssh-add Вы познакомитесь с тем как при создании ВМ создать своего 
        пользователя в блоке metadata в следующей лекции.;
    - Ответьте, как в процессе обучения могут пригодиться параметры preemptible = true 
        и core_fraction=5 в параметрах ВМ.

    В качестве решения приложите:
    
    - скриншот ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес;
    - скриншот консоли, curl должен отобразить тот же внешний ip-адрес;
    - ответы на вопросы.

___

Проверим синтаксис
    terraform fmt -check
Попробуем инициализировать
    terraform init
Вышла ошибка по версии
У меня стоит версия v1.17.1, значит нужно поправить в providers.tf
    required_version = "~>1.12.0" 
    на
    required_version = "~>1.17.0"
Запускаем ещё раз
    terraform init
Выходит ошибка связанная видимо с service_account_key_file
Судя по providers.tf нам нужен файл "~/.authorized_key.json"

https://yandex.cloud/ru/docs/iam/operations/sa/create

Что такое сервисный аккаунт
Сервисный аккаунт — это специальный аккаунт, который используется для безопасного управления ресурсами облачной 
    платформы от имени приложения, скрипта или другого сервиса, а не от имени пользователя. В отличие от обычного 
    аккаунта, он не имеет прямого доступа к вашему рабочему столу, что повышает безопасность.

Создание сервисного аккаунта и ключа

    # Авторизация в Yandex Cloud
    yc init
    # Проверка списка профилей, если уже авторизован
    yc config profile list
    # Создание сервисного аккаунта
    yc iam service-account create --name terraform-user
    yc iam service-account create --name admin2 // для себя взял это имя
        subject-id 'aje7elvvoop2vtpqicq1'

id: ajek...
folder_id: b1gs...
created_at: "2026-11-04T10:42:51Z"
name: admin2
status: ACTIVE

    # Получить ID сервисного аккаунта
    yc iam service-account get --name terraform-user
    yc iam service-account get --name admin2

    yc iam service-account list

Создаём файл ".authorized_key.json" и размещаем в нашем проекте
    yc iam key create --service-account-id <ВАШ_ID_АККАУНТА> --output /home/.../.authorized_key.json

Добавил файл .authorized_key.json в .gitignore

Проверим что у меня есть ssh ключ
    ls -al ~/.ssh
Выведем его значение, так как он у меня есть
    cat ~/.ssh/id_ed25519.pub

Пишут что добавлять в файл variables.tf переменную vms_ssh_public_root_key плохая идея и нужно создать файл
    terraform.tfvars
в нём

    cloud_id    = "b1g..."
    folder_id   = "b1g."
    
    vms_ssh_root_key = "ssh-ed25519 ... admin1@Ubuntu"

Добавил .terraform.tfvars в gitignore

Пробуем запускать
    terraform init

Ошибка
Error: Invalid provider registry host

Помог перенос файла
    mv ./.terraformrc ~/.terraformrc

Далее выполняем
    terraform plan

Ошибка
Error: Invalid function argument

Ошибка потому что, я положил authorized_key.json в папку home/ter-homeworks/02/src
значит нужно прописать путь в providers.tf

# Было (неправильно):
service_account_key_file = file("~/.authorized_key.json")

# Стало (правильно - полный путь к файлу в папке проекта):
service_account_key_file = file("/home/admin1/ter-homeworks/02/src/.authorized_key.json")

Теперь plan заработал
Далее выполним
    terraform apply
    yes

Ошибка
yandex_vpc_network.develop: Creating...
╷
│ Error: Error while requesting API to create network: x-request-id = 1058a372-9c1b-436a-84a0-3ed187ef039c 
    x-server-trace-id = ecb1c584485e0ebe:0e3cf25e296a18a0:9a7fe1355fcb67b0:1 x-client-trace-id = 3e3fb0d5-d3f9-4f97-8808-8c4c9655f50b 
    rpc error: code = PermissionDenied desc = Operation is not permitted in the folder
│
│   with yandex_vpc_network.develop,
│   on main.tf line 1, in resource "yandex_vpc_network" "develop":
│    1: resource "yandex_vpc_network" "develop" {

Получается у сервисного аккаунта нет прав на работу с папкой
Добавим права

    yc resource-manager folder add-access-binding b1g... --role editor --subject serviceAccount:aje...

Выполним apply

Ошибка 1: Опечатка в названии платформы
# Было:
platform_id = "standart-v4"
# Стало, с 4 версией тоже ошибка
platform_id = "standard-v3"

Ошибка 2: я назвал .terraform.tfvars с точкой впереди, переименовал


Информация
Блок resources — вычислительные ресурсы ВМ:

    cores = 1 — количество vCPU (1 ядро).
    memory = 1 — объём RAM в ГБ (1 ГБ).
    core_fraction = 5 — доля выделенного CPU в процентах (burstable-машина). 5 означает, что ядро получает 
        только 5% мощности физического ядра — это самый дешёвый вариант, подходит для учебных и слабонагруженных задач.

Блок boot_disk — загрузочный диск:

    initialize_params { image_id = ... } — диск создаётся заново из образа. В image_id подставляется результат 
        data-источника data.yandex_compute_image.ubuntu.image_id — то есть ID актуального образа Ubuntu (обычно
        последней версии), который Terraform найдёт по запросу. Диск создаётся с размером по умолчанию из образа, 
        если не указан size.

Блок scheduling_policy:

    preemptible = true — ВМ создаётся прерываемой. Яндекс может в любой момент её остановить (при нехватке ресурсов) 
        или по истечении 24 часов, а вы платите за неё заметно меньше. Хорошо для тестов и обучения, плохо для продакшена.

Блок network_interface — сетевая настройка:

    subnet_id = yandex_vpc_subnet.develop.id — ВМ подключается к подсети из другого ресурса Terraform 
        (yandex_vpc_subnet.develop). Так связываются ресурсы между собой: Terraform сам вычислит ID подсети.
    nat = true — ВМ получает публичный IPv4-адрес (NAT в интернете). Без этого машина будет доступна только внутри 
        сети.

Блок metadata — метаданные, передаваемые ВМ:

    serial-port-enable = 1 — включает доступ к последовательному порту (полезно для отладки загрузки через консоль
        облака).
    ssh-keys = "ubuntu:${var.vms_ssh_root_key}" — ключ для входа по SSH. Формат: имя_пользователя:открытый_ключ. Ключ 
        берётся из переменной var.vms_ssh_root_key — она должна быть объявлена где-то в variables.tf (или передана 
        через terraform.tfvars / -var). Утилита cloud-init на Ubuntu при загрузке добавит этот ключ в 
        ~/.ssh/authorized_keys пользователя ubuntu.


Error: Error while requesting API to create instance: x-request-id = ab6f3289-17c5-4a9b-88b3-72923cd4805a 
    x-server-trace-id = 40826fae0b7ddae3:f4f10835e4c8273d:1eb604a89d318cee:1 x-client-trace-id = 
    513f0936-76ac-4b72-a1b9-7ebf16653a7c rpc error: code = InvalidArgument desc = the specified core fraction is 
    not available on platform "standard-v3"; allowed core fractions: 20, 50, 100

Доступны fractions: 20, 50, 100, значит заменим на 20

apply

│ Error: Error while requesting API to create instance: x-request-id = 6aa41392-06b0-4882-8355-098fbd510716 
    x-server-trace-id = c3ef8d67788e58a4:143ad9555b61de32:ac5ea7549a5670c9:1 x-client-trace-id =
    39920a7c-3184-49d6-bfba-8cb9daeeffb7 rpc error: code = InvalidArgument desc = the specified number of cores
    is not available on platform "standard-v3"; allowed core number: 2, 4

Доступны core number: 2, 4, значит заменим на 2

apply

Ура, создалась ВМ в облаке

# screen_1

Подключимся к ВМ
    ssh -l ubuntu 51.250.5.13
Выполним
    curl ifconfig.me

# screen_2


Вопрос 1: В чём заключалась суть намеренно допущенных синтаксических/логических ошибок?

    Ответ: В коде было допущено несколько ошибок, которые мешали инициализации и созданию ресурсов:

        Некорректное использование тильды ~ в функции file(): Было указано file("~/.authorized_key.json"). Terraform 
            не раскрывает тильду как домашнюю директорию в этой функции, он ищет буквальную папку с именем ~, что 
            приводило к ошибке "no file exists". Исправлено на абсолютный путь: 
            file("/home/admin1/ter-homeworks/02/src/.authorized_key.json").
        Опечатка в имени платформы и несовместимость параметров: Было указано platform_id = "standart-v4" (опечатка 
            в слове standard). При исправлении на standard-v3 возникла ошибка, так как эта платформа не 
            поддерживает core_fraction = 5, core number: 1. Исправлено на platform_id = "standard-v3", 
        core_fraction = 20 и core number: 2

Вопрос 2: Как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction = 5?

    Ответ: 

        preemptible = true (прерываемая ВМ): Такие виртуальные машины стоят до 80% дешевле обычных. Yandex Cloud 
            может остановить их в любой момент (максимум через 24 часа). Для обучения это идеальный вариант, так как 
            позволяет дешево создавать и уничтожать стенды для экспериментов, не требуя круглосуточной доступности
            (High Availability).
        core_fraction = 5 (или 20 для standard-v3): Этот параметр задает гарантированную минимальную долю 
            производительности vCPU. Это самый бюджетный тариф вычислительных ресурсов. Для учебных задач (написание 
            скриптов, развертывание легких веб-серверов, тесты) этой производительности вполне достаточно, что 
            позволяет существенно снизить стоимость обучения.

Закоммитил изменения в github
https://github.com/JSkuns/ter-homeworks/commit/631dd0c66e4a8fa1c247fb5c01f03b2618b2baff
