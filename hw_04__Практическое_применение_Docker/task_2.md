Задача 2 (*)

    - Создайте в yandex cloud container registry с именем "test" с помощью "yc tool" . Инструкция
    - Настройте аутентификацию вашего локального docker в yandex container registry.
    - Соберите и залейте в него образ с python приложением из задания №1.
    - Просканируйте образ на уязвимости.
    - В качестве ответа приложите отчет сканирования.



Для выполнения этой задачи вам потребуется установленный и настроенный интерфейс командной строки Yandex Cloud (yc)
Он у меня был ранее установлен

# Создание Container Registry с именем "test"
yc container registry create --name test

# Далее понадобится ID реестра (начинается с crp...). Чтобы его узнать
yc container registry list

Обозначим <registry-id> - взятый id из списка
У меня это - crp4gfl05qu1vuqr38p1


# Чтобы Docker мог отправлять (push) и получать (pull) образы из реестра, его нужно авторизовать
yc container registry configure-docker

# Далее в директории вашего проекта из Задачи 1 (где лежит Dockerfile.python).
Сборка образа с правильным тегом для Yandex Cloud:

    docker build -t cr.yandex/<registry-id>/python-app:v1 -f Dockerfile.python .
    docker build -t cr.yandex/crp4gfl05qu1vuqr38p1/python-app:v1 -f Dockerfile.python .

# Загрузка образа в реестр
docker push cr.yandex/<registry-id>/python-app:v1
docker push cr.yandex/crp4gfl05qu1vuqr38p1/python-app:v1

# Сканирование образа на уязвимости
Yandex Cloud имеет встроенный сканер уязвимостей (Container Vulnerability Assessment).
Запуск сканирования:

    yc container vulnerability-scan run --image-name cr.yandex/<registry-id>/python-app:v1
    yc container vulnerability-scan run --image-name cr.yandex/crp4gfl05qu1vuqr38p1/python-app:v1
      в моей версии yc не сработало, другой вариант
    yc container image scan --name cr.yandex/crp4gfl05qu1vuqr38p1/python-app:v1
      третий вариант
    yc container image scan cr.yandex/crp4gfl05qu1vuqr38p1/python-app:v1

# Запускаем сканирование 4 раз
yc container image scan crpp1018e94v44hgadpc   <- id уже другой, взят из таблицы
    по запросу yc container image list --registry-id crp4gfl05qu1vuqr38p1

# Получим результаты
# Получение полного отчета сканирования
yc container image get-last-scan-result --image-id crpp1018e94v44hgadpc

# Получение списка всех уязвимостей
yc container image list-vulnerabilities --scan-result-id checeb827iupvbha9f20

# Сохранение полного отчета в файл
# Сводка по сканированию
yc container image get-last-scan-result --image-id crpp1018e94v44hgadpc > scan_report.txt

# Детальный список уязвимостей
yc container image list-vulnerabilities --scan-result-id checeb827iupvbha9f20 >> scan_report.txt

# Просмотр отчета
cat scan_report.txt

В итоге из ВМ перенёс scan_report.txt в этот проект