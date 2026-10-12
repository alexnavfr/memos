# 

## Prompt:
_Давай подберем оптимальное решение под мои нужды: около 20 персональных небольших проектов ~5000 строк кода каждый. Утилиты CI/CD и issue tracking может быть минимальным, в большей степени для ознакомления, могут быть добавлены уже после настройки сервера git. Необходим webUI - доступ из локальной сети, простой в освоении который позволит работать через UI . На сервере установлен Xubuntu 24.04, git установлен и пока работает как клиент(git clone, git add . etc). Отдельно дай пошаговую инструкцию по установке Gitea и bare-репозиториев._

Для ваших нужд, учитывая количество проектов и необходимость простого веб-интерфейса для работы с Git, Gitea является отличным выбором. Gitea — это легковесная альтернатива GitLab и GitHub, которая легко устанавливается и настраивается. Она предоставляет все необходимые функции для управления Git-репозиториями через веб-интерфейс, включая базовые возможности CI/CD и отслеживания задач._

### Установка Gitea на Xubuntu 24.04

#### Шаг 1: Установка зависимостей

1. Обновите список пакетов и установите необходимые зависимости:
   ```bash
   sudo apt update
   sudo apt install -y git wget
   ```

#### Шаг 2: Создание пользователя для Gitea

1. Создайте пользователя `git` для запуска Gitea:
   ```bash
   sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
   ```

#### Шаг 3: Установка Gitea

1. Скачайте последнюю версию Gitea с [официального сайта](https://dl.gitea.io/gitea/):
   ```bash
   wget -O gitea https://dl.gitea.io/gitea/1.19.3/gitea-1.19.3-linux-amd64
   ```

2. Сделайте скачанный файл исполняемым и переместите его в `/usr/local/bin`:
   ```bash
   chmod +x gitea
   sudo mv gitea /usr/local/bin/
   ```

#### Шаг 4: Настройка Gitea

1. Создайте структуру каталогов для Gitea:
   ```bash
   sudo mkdir -p /var/lib/gitea/{custom,data,log}
   sudo chown git:git /var/lib/gitea/{custom,data,log}
   sudo chmod 750 /var/lib/gitea/{custom,data,log}
   ```

2. Создайте файл конфигурации для systemd, чтобы Gitea запускалась как сервис:
   ```bash
   sudo nano /etc/systemd/system/gitea.service
   ```

3. Добавьте в файл следующее содержимое:
   ```ini
   [Unit]
   Description=Gitea (Git with a cup of tea)
   After=syslog.target
   After=network.target

   [Service]
   User=git
   Group=git
   WorkingDirectory=/var/lib/gitea/
   ExecStart=/usr/local/bin/gitea web --config /var/lib/gitea/custom/conf/app.ini
   Restart=always
   Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

   [Install]
   WantedBy=multi-user.target
   ```

4. Загрузите и запустите сервис Gitea:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable gitea
   sudo systemctl start gitea
   ```

#### Шаг 5: Настройка веб-интерфейса

1. Откройте веб-браузер и перейдите по адресу `http://<ваш-сервер>:3000`, чтобы завершить настройку Gitea через веб-интерфейс.

2. Следуйте инструкциям на экране для настройки базы данных, параметров сервера и создания администратора.

### Создание bare-репозиториев

#### Шаг 1: Создание bare-репозитория

1. Перейдите в домашний каталог пользователя `git`:
   ```bash
   sudo su - git
   cd /home/git
   ```

2. Создайте новый bare-репозиторий:
   ```bash
   mkdir myproject.git
   cd myproject.git
   git init --bare
   ```

#### Шаг 2: Настройка доступа к репозиторию

1. Вернитесь к своему обычному пользователю и клонируйте репозиторий:
   ```bash
   exit
   git clone git@localhost:/home/git/myproject.git
   ```

2. Добавьте файлы в репозиторий и сделайте первый коммит:
   ```bash
   cd myproject
   touch README.md
   git add README.md
   git commit -m "Initial commit"
   git push origin master
   ```

Теперь у вас установлен и настроен Gitea, а также создан bare-репозиторий. Вы можете управлять своими проектами через веб-интерфейс Gitea и работать с репозиториями через Git.