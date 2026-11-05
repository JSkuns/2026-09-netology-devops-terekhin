Задание 6

    Вместо использования трёх переменных ".._cores",".._memory",".._core_fraction" в блоке resources {...}, объедините 
        их в единую map-переменную vms_resources и внутри неё конфиги обеих ВМ в виде вложенного map(object).
    
    пример из terraform.tfvars:
    vms_resources = {
        web={
            cores=2
            memory=2
            core_fraction=5
            hdd_size=10
            hdd_type="network-hdd"
            ...
        },
        db= {
            cores=2
            memory=4
            core_fraction=20
            hdd_size=10
            hdd_type="network-ssd"
            ...
        }
    }
    Создайте и используйте отдельную map(object) переменную для блока metadata, она должна быть общая для всех ваших ВМ.
    
    пример из terraform.tfvars:
    metadata = {
        serial-port-enable = 1
        ssh-keys           = "ubuntu:ssh-ed25519 AAAAC..."
    }
    Найдите и закоментируйте все, более не используемые переменные проекта.
    
    Проверьте terraform plan. Изменений быть не должно.


Внёс изменения согласно описанию в main.tf, variables.tf, vms_platform.tf
проверил и закоммитил

https://github.com/JSkuns/ter-homeworks/commit/449b8da5e788b410828623ff8ae14f62ee90bbad