# Home server
## Что потребуется для создание дома локально немножко серверов.

### Prompt:
_Исходные данные: старая модель ноутбука, 2гб ram, 100gb hdd, ubuntu. Создать домашний сервер:git server, cloud, file server._

Создание домашнего сервера на старой модели ноутбука с ограниченными ресурсами (2 ГБ RAM, 100 ГБ HDD, Ubuntu) возможно, но требует оптимизации и выбора легковесных решений. Вот пошаговое руководство по настройке Git-сервера, облачного хранилища и файлового сервера:

### 1. Подготовка системы

1. **Обновите систему**:
   - Убедитесь, что ваша система обновлена:
     ```bash
     sudo apt update && sudo apt upgrade -y
     ```

2. **Установите необходимые пакеты**:
   - Установите `openssh-server`, если он еще не установлен, для удаленного доступа:
     ```bash
     sudo apt install openssh-server
     ```

### 2. Настройка Git-сервера

1. **Создайте пользователя для Git**:
   - Создайте нового пользователя, который будет использоваться для доступа к Git-репозиториям:
     ```bash
     sudo adduser git
     ```

2. **Настройте SSH-доступ**:
   - Сгенерируйте SSH-ключи на вашем локальном компьютере (если они еще не сгенерированы):
     ```bash
     ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
     ```
   - Добавьте публичный ключ в `~/.ssh/authorized_keys` для пользователя `git` на сервере.

3. **Установите Git**:
   - Установите Git, если он еще не установлен:
     ```bash
     sudo apt install git
     ```

4. **Создайте репозиторий**:
   - Создайте каталог для репозитория и инициализируйте его:
     ```bash
     sudo -u git mkdir -p /home/git/myrepo.git
     sudo -u git git init --bare /home/git/myrepo.git
     ```

5. **Настройте права доступа**:
   - Убедитесь, что пользователь `git` владеет всеми файлами в репозитории:
     ```bash
     sudo chown -R git:git /home/git/myrepo.git
     ```

### 3. Настройка облачного хранилища с Nextcloud

1. **Установите необходимые пакеты**:
   - Установите Apache, MariaDB и PHP:
     ```bash
     sudo apt install apache2 mariadb-server libapache2-mod-php7.4
     sudo apt install php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring
     sudo apt install php7.4-intl php-imagick php7.4-xml php7.4-zip
     ```
[06.03.2025 by NAV] версия php теперь 8.3...

2. **Настройте базу данных**:
   - Войдите в MariaDB и создайте базу данных и пользователя для Nextcloud:
     ```bash
     sudo mysql -u root -p
     CREATE DATABASE nextcloud;
     CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY 'password';
     GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextclouduser'@'localhost';
     FLUSH PRIVILEGES;
     EXIT;
     ```

3. **Скачайте и установите Nextcloud**:
   - Скачайте последнюю версию Nextcloud:
     ```bash
     wget https://download.nextcloud.com/server/releases/latest.zip
     sudo unzip latest.zip -d /var/www/
     sudo chown -R www-data:www-data /var/www/nextcloud/
     sudo chmod -R 755 /var/www/nextcloud/
     ```

4. **Настройте Apache**:
   - Создайте конфигурационный файл для Nextcloud:
     ```bash
     sudo nano /etc/apache2/sites-available/nextcloud.conf
     ```
   - Добавьте следующую конфигурацию:
     ```apache
     <VirtualHost *:80>
         DocumentRoot /var/www/nextcloud/
         ServerName your_domain_or_IP

         <Directory /var/www/nextcloud/>
             Options +FollowSymlinks
             AllowOverride All

             <IfModule mod_dav.c>
                 Dav off
             </IfModule>

             SetEnv HOME /var/www/nextcloud
             SetEnv HTTP_HOME /var/www/nextcloud

         </Directory>

         ErrorLog ${APACHE_LOG_DIR}/error.log
         CustomLog ${APACHE_LOG_DIR}/access.log combined

     </VirtualHost>
     ```
   - Активируйте сайт и необходимые модули:
     ```bash
     sudo a2ensite nextcloud.conf
     sudo a2enmod rewrite headers env dir mime setenvif ssl
     sudo systemctl restart apache2
     ```

5. **Завершите установку Nextcloud**:
   - Откройте браузер и перейдите по адресу вашего сервера. Следуйте инструкциям на экране для завершения установки.

### 4. Настройка файлового сервера с Samba

1. **Установите Samba**:
   - Установите Samba для совместного использования файлов:
     ```bash
     sudo apt install samba
     ```

2. **Настройте Samba**:
   - Отредактируйте конфигурационный файл Samba:
     ```bash
     sudo nano /etc/samba/smb.conf
     ```
   - Добавьте следующую конфигурацию в конец файла:
     ```ini
     [shared]
         path = /srv/samba/shared
         available = yes
         valid users = your_username
         read only = no
         browsable = yes
         public = yes
         writable = yes
     ```

3. **Создайте директорию для общих файлов**:
   - Создайте директорию и настройте права доступа:
     ```bash
     sudo mkdir -p /srv/samba/shared
     sudo chown -R your_username:your_username /srv/samba/shared
     ```

4. **Перезапустите Samba**:
   - Перезапустите службу Samba для применения изменений:
     ```bash
     sudo systemctl restart smbd
     ```

### Заключение

Эти шаги помогут вам настроить базовый домашний сервер с Git-сервером, облачным хранилищем Nextcloud и файловым сервером Samba на старом ноутбуке с Ubuntu. Учитывая ограниченные ресурсы, вы можете столкнуться с ограничениями по производительности, но эти решения должны работать для базовых нужд.

