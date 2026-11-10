Задание 1

    - Изучите проект.
    - Инициализируйте проект, выполните код.
    - Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud.


terraform init
Error: Unsupported Terraform Core version

меняю версию в providers.tf на ~>1.17.0 которая у меня
terraform init
Terraform has been successfully initialized!
terraform apply
Начинает запрашивать cloud_id, folder_id, мы эту проблему решали в предыдущем ДЗ
скопируем terraform.tvars из предыдущего, также добавим в gitinore

terraform apply
var.token
OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
авторизация по oauth не поддерживается, у нас настроена авторизация по сервисному аккаунту

закомментировал в variables.tf значение token
добавил подключение через сервисный аккаунт

terraform apply

# screen_1

Закоммитил изменения
https://github.com/JSkuns/ter-homeworks/commit/d15864b8cb07a040650f95de18cbbd160f4059d2

