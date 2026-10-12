# Внешние USB диски на Mac OS Catalina. Копирование.

## Prompt:
_bash. Mac os Catalina. Как скопировать рекурсивно директорию на внешний USB ключ. Как найти и перейти в корень подключенного USB ключа._

Вот полное руководство для **macOS Catalina**:

## 1. Найти корень подключенного USB-ключа в macOS

### Автоматический поиск (рекомендуемый)
```bash
# Найти все смонтированные внешние тома (USB)
ls /Volumes/

# Или с подробной информацией
ls -la /Volumes/

# Найти только внешние диски (USB)
lsblk  # Если установлен
# Или
diskutil list external

# Найти по типу файловой системы (обычно FAT/NTFS/exFAT)
find /Volumes -maxdepth 1 -type d -not -name "Macintosh HD" -not -name "*.timemachine" 2>/dev/null
```

### Через diskutil (родная утилита macOS)
```bash
# Показать все диски
diskutil list

# Показать только внешние диски
diskutil list external

# Найти информацию о конкретном USB
diskutil info /dev/disk2s1  # замените на ваш диск

# Найти смонтированные тома
diskutil list | grep -E "^/dev/disk" | grep -v "internal"
```

### Быстрый скрипт для поиска USB
```bash
#!/bin/bash
# Найти первый USB том (исключая системный диск)
USB_PATH=$(find /Volumes -maxdepth 1 -type d -not -name "Macintosh HD" -not -name ".*" 2>/dev/null | head -1)

if [ -n "$USB_PATH" ]; then
    echo "Найден USB: $USB_PATH"
    cd "$USB_PATH" || exit
    echo "Текущая директория: $(pwd)"
else
    echo "USB не найден в /Volumes"
    echo "Доступные тома:"
    ls /Volumes/
fi
```

## 2. Переход в корень USB

```bash
# Все USB монтируются в /Volumes/
cd /Volumes/ИМЯ_ФЛЕШКИ/

# Или найти автоматически и перейти
cd $(find /Volumes -maxdepth 1 -type d -not -name "Macintosh HD" | head -1)

# Проверить что вы на USB
pwd
ls -la
df -h .
```

## 3. Рекурсивное копирование на USB в macOS

### Базовое копирование (cp)
```bash
# Скопировать директорию рекурсивно
cp -r /путь/к/исходной/директории /Volumes/ИМЯ_USB/

# Пример
cp -r ~/Documents/Projects /Volumes/MY_USB/

# С сохранением атрибутов (рекомендуется для macOS)
cp -Rp /исходная/директория /Volumes/ИМЯ_USB/
# -R: рекурсивно (работает с символическими ссылками)
# -p: сохранить права, владельца, временные метки
```

### С подробным выводом
```bash
cp -Rv /исходная/директория /Volumes/ИМЯ_USB/
# -v: показать что копируется
```

### Полный вариант для macOS
```bash
cp -Rpv /исходная/директория /Volumes/ИМЯ_USB/
# -R: рекурсивно с сохранением структуры
# -p: сохранить атрибуты macOS (resource forks, extended attributes)
# -v: подробный вывод
```

## 4. Использование rsync (рекомендуется для больших файлов)

```bash
# Базовое копирование с прогрессом
rsync -avh --progress /исходная/директория /Volumes/ИМЯ_USB/

# С сохранением всех метаданных macOS
rsync -avhE --progress /исходная/директория /Volumes/ИМЯ_USB/
# -E: сохранить extended attributes (resource forks)

# С удалением файлов, которых нет в источнике (синхронизация)
rsync -avhE --delete --progress /исходная/директория /Volumes/ИМЯ_USB/
```

## 5. Практические примеры для macOS Catalina

### Пример 1: Полный скрипт копирования с проверкой
```bash
#!/bin/bash

# Найти USB (исключая системный диск)
USB_MOUNT=$(find /Volumes -maxdepth 1 -type d -not -name "Macintosh HD" -not -name ".*" 2>/dev/null | head -1)

if [ -z "$USB_MOUNT" ]; then
    echo "Ошибка: USB не найден"
    echo "Доступные тома:"
    ls /Volumes/
    exit 1
fi

echo "USB найден в: $USB_MOUNT"

# Исходная директория
SOURCE_DIR="$HOME/Важная_папка"

# Проверка существования источника
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: исходная директория не найдена: $SOURCE_DIR"
    exit 1
fi

# Проверка свободного места
SOURCE_SIZE=$(du -sk "$SOURCE_DIR" | cut -f1)
USB_FREE=$(df -k "$USB_MOUNT" | tail -1 | awk '{print $4}')

if [ "$SOURCE_SIZE" -gt "$USB_FREE" ]; then
    echo "Ошибка: Недостаточно места на USB"
    echo "Нужно: $(($SOURCE_SIZE / 1024)) MB"
    echo "Свободно: $(($USB_FREE / 1024)) MB"
    exit 1
fi

# Копирование с прогрессом через rsync
echo "Начинаю копирование..."
rsync -avhE --progress "$SOURCE_DIR/" "$USB_MOUNT/$(basename "$SOURCE_DIR")/"

if [ $? -eq 0 ]; then
    echo "Копирование успешно завершено!"
    echo "Размер скопированных данных:"
    du -sh "$USB_MOUNT/$(basename "$SOURCE_DIR")"
else
    echo "Ошибка при копировании"
    exit 1
fi
```

### Пример 2: Копирование с индикатором прогресса (альтернатива rsync)
```bash
#!/bin/bash

SOURCE="$HOME/Downloads/Project"
USB=$(find /Volumes -maxdepth 1 -type d -not -name "Macintosh HD" | head -1)

echo "Копирую с использованием pv (индикатор прогресса)..."

# Установка pv если нет: brew install pv
if command -v pv &> /dev/null; then
    tar cf - "$SOURCE" | pv -s $(du -sb "$SOURCE" | awk '{print $1}') | (cd "$USB" && tar xf -)
else
    echo "pv не установлен, использую rsync"
    rsync -avh --progress "$SOURCE" "$USB/"
fi
```

### Пример 3: Копирование с проверкой целостности
```bash
#!/bin/bash

SOURCE="$HOME/Фотографии"
USB="/Volumes/USB_DRIVE"

# Копирование
echo "Копирование..."
rsync -avhE --progress "$SOURCE" "$USB/"

# Проверка (сравнение хешей)
echo "Проверка целостности..."
find "$SOURCE" -type f -exec md5 {} \; > /tmp/source_md5.txt
find "$USB/$(basename "$SOURCE")" -type f -exec md5 {} \; > /tmp/usb_md5.txt

diff /tmp/source_md5.txt /tmp/usb_md5.txt
if [ $? -eq 0 ]; then
    echo "✅ Копирование выполнено без ошибок"
else
    echo "❌ Обнаружены различия"
fi
```

## 6. Особенности macOS Catalina

### Проблемы с разрешениями
```bash
# Если получаете ошибки разрешений, используйте
sudo rsync -avhE --progress /исходная/директория /Volumes/USB/

# Или предоставьте доступ в System Preferences > Security & Privacy > Full Disk Access
```

### Работа с .DS_Store и служебными файлами
```bash
# Исключить служебные файлы macOS
rsync -avhE --progress --exclude=".DS_Store" --exclude=".Spotlight-V100" --exclude=".Trashes" /исходная/директория /Volumes/USB/

# Полное исключение системных файлов
rsync -avhE --progress --exclude-from=<(cat <<EOF
.DS_Store
.Spotlight-V100
.Trashes
._*
*.tmp
*.temp
EOF
) /исходная/директория /Volumes/USB/
```

### Для файловой системы FAT32 (ограничение 4GB)
```bash
# Если файлы больше 4GB, скопировать не получится
# Используйте exFAT или NTFS (с установленным ntfs-3g)

# Проверить файловую систему USB
diskutil info /Volumes/ИМЯ_USB | grep "File System"

# Для exFAT/NTFS используйте:
cp -Rpv /исходная/директория /Volumes/ИМЯ_USB/
```

## 7. Безопасное извлечение USB

```bash
# Узнать идентификатор диска
diskutil list

# Извлечь (размонтировать)
diskutil unmountDisk /dev/disk2  # замените на ваш диск

# Или эжектировать полностью
diskutil eject /dev/disk2
```

## 8. Полезные команды для macOS

```bash
# Посмотреть информацию о USB
diskutil info /Volumes/ИМЯ_USB

# Проверить свободное место
df -h /Volumes/ИМЯ_USB/

# Показать скрытые файлы на USB
ls -la /Volumes/ИМЯ_USB/

# Открыть USB в Finder
open /Volumes/ИМЯ_USB/

# Создать директорию и скопировать в неё
mkdir -p "/Volumes/USB/Backup" && cp -Rp ~/Documents "/Volumes/USB/Backup/"
```

## Быстрый чек-лист для копирования

```bash
# 1. Подключите USB и найдите его
ls /Volumes/

# 2. Проверьте свободное место
df -h /Volumes/ИМЯ_USB/

# 3. Выполните копирование
rsync -avhE --progress ~/Важная_папка /Volumes/ИМЯ_USB/

# 4. Проверьте результат
ls -la /Volumes/ИМЯ_USB/Важная_папка

# 5. Безопасно извлеките
diskutil eject /Volumes/ИМЯ_USB
```

**Важно для macOS Catalina:**
- Все внешние диски монтируются в `/Volumes/`
- Используйте `rsync` вместо `cp` для больших копий (лучший прогресс-бар)
- Опция `-E` в rsync сохраняет метаданные macOS
- Для работы с NTFS нужен драйвер (ntfs-3g или Paragon/Tuxera)