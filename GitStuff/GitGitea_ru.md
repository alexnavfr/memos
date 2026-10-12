Давай подберем оптимальное решение под мои нужды: около 20 персональных небольших проектов ~5000 строк кода каждый. Утилиты CI/CD и issue tracking может быть минимальным, в большей степени для ознакомления, могут быть добавлены уже после настройки сервера git. Необходим webUI - доступ из локальной сети, простой в освоении который позволит работать через UI . На сервере установлен Xubuntu 24.04, git установлен и пока работает как клиент(git clone, git add . etc). Отдельно дай пошаговую инструкцию по установке Gitea и bare-репозиториев.

Для ваших потребностей я рекомендую **Gitea** - это оптимальное решение, которое отлично подойдет для ваших 20 небольших проектов.

## Почему Gitea идеально подходит:

**Преимущества для вашего случая:**
- Легкий и быстрый (написан на Go, один исполняемый файл)
- Простой веб-интерфейс, интуитивно понятный
- Минимальные системные требования
- Встроенный Git-сервер (не нужны bare-репозитории)
- Базовый CI/CD через Gitea Actions
- Простое управление пользователями и репозиториями
- Отличная поддержка локальных сетей

**Функциональность:**
- Git-репозитории с веб-интерфейсом
- Issue tracking (можно отключить при необходимости)
- Wiki для каждого проекта
- Markdown-рендеринг
- Простая система прав доступа

## Пошаговая инструкция установки Gitea

### Шаг 1: Подготовка системы

```bash
# Обновляем систему
sudo apt update && sudo apt upgrade -y

# Устанавливаем необходимые пакеты
sudo apt install wget curl sqlite3 -y

# Создаем пользователя для Gitea
sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
```

### Шаг 2: Скачивание и установка Gitea

```bash
# Переходим в домашнюю директорию git
sudo su - git

# Скачиваем последнюю версию Gitea
wget -O gitea https://dl.gitea.com/gitea/1.21.3/gitea-1.21.3-linux-amd64

# Делаем исполняемым
chmod +x gitea

# Проверяем версию
./gitea --version
```

### Шаг 3: Создание структуры директорий

```bash
# Создаем необходимые директории
mkdir -p /home/git/{custom,data,log}

# Выходим из пользователя git
exit
```

### Шаг 4: Создание systemd сервиса

```bash
# Создаем файл сервиса
sudo nano /etc/systemd/system/gitea.service
```

Вставляем следующее содержимое:

```ini
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target

[Service]
Type=simple
User=git
Group=git
WorkingDirectory=/home/git/
ExecStart=/home/git/gitea web --config /home/git/custom/conf/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/home/git

[Install]
WantedBy=multi-user.target
```

### Шаг 5: Настройка конфигурации

```bash
# Создаем директорию для конфигурации
sudo mkdir -p /home/git/custom/conf

# Создаем базовый конфигурационный файл
sudo nano /home/git/custom/conf/app.ini
```

Базовая конфигурация:

```ini
[server]
HTTP_PORT = 3000
DOMAIN = localhost
ROOT_URL = http://localhost:3000/

[database]
DB_TYPE = sqlite3
PATH = /home/git/data/gitea.db

[security]
INSTALL_LOCK = false
SECRET_KEY = 

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false

[log]
MODE = file
LEVEL = info
ROOT_PATH = /home/git/log
```

### Шаг 6: Установка прав доступа

```bash
# Устанавливаем правильные права
sudo chown -R git:git /home/git/
sudo chmod -R 755 /home/git/
```

### Шаг 7: Запуск Gitea

```bash
# Перезагружаем systemd
sudo systemctl daemon-reload

# Включаем автозапуск
sudo systemctl enable gitea

# Запускаем сервис
sudo systemctl start gitea

# Проверяем статус
sudo systemctl status gitea
```

### Шаг 8: Первоначальная настройка через веб-интерфейс

1. Откройте браузер и перейдите по адресу `http://YOUR_SERVER_IP:3000`
2. Вы увидите страницу первоначальной настройки
3. Настройте следующие параметры:
   - **Database Type**: SQLite3 (уже выбран)
   - **Application Name**: Ваше название
   - **Repository Root Path**: `/home/git/gitea-repositories`
   - **Git LFS Root Path**: `/home/git/data/lfs`
   - **Run As Username**: `git`
   - **SSH Server Domain**: IP вашего сервера
   - **HTTP Port**: `3000`
   - **Application URL**: `http://YOUR_SERVER_IP:3000/`

4. Создайте администраторского пользователя
5. Нажмите "Install Gitea"

### Шаг 9: Настройка файрвола (если необходимо)

```bash
# Открываем порт 3000
sudo ufw allow 3000
sudo ufw reload
```

### Шаг 10: Проверка работы

```bash
# Проверяем, что Gitea работает
sudo systemctl status gitea

# Проверяем логи при необходимости
sudo journalctl -u gitea -f
```

## Дополнительные настройки

### Изменение порта (если нужно)
Редактируем `/home/git/custom/conf/app.ini`:
```ini
[server]
HTTP_PORT = 8080
```

### Отключение регистрации новых пользователей
```ini
[service]
DISABLE_REGISTRATION = true
```

### Настройка SSH (опционально)
```bash
# Добавляем SSH ключ в конфигурацию
sudo nano /home/git/custom/conf/app.ini
```

```ini
[server]
SSH_DOMAIN = YOUR_SERVER_IP
SSH_PORT = 22
DISABLE_SSH = false
```

## Использование

После установки вы сможете:
1. Создавать репозитории через веб-интерфейс
2. Клонировать репозитории: `git clone http://YOUR_SERVER_IP:3000/username/repo.git`
3. Работать с обычными Git-командами
4. Управлять проектами через удобный веб-интерфейс

**Примечание**: Gitea автоматически создает и управляет Git-репозиториями, поэтому вам не нужно вручную создавать bare-репозитории. Все это делается через веб-интерфейс или Git-команды.

