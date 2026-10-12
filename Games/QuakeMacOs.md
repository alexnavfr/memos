# Install Quake macOs Catalina

## Prompt:
_Расскажи по шагам как можно установить Quake на macOs Catalina_

Чтобы установить **Quake** (оригинальную игру 1996 года от id Software) на **macOS Catalina**, тебе нужно использовать один из современных портов движка Quake, так как оригинальная игра не поддерживает современные системы напрямую. Вот пошаговое руководство:

---

### ✅ Что нужно:

1. **Файлы оригинальной игры Quake** (особенно `PAK0.PAK` и `PAK1.PAK`)
2. Современный порт движка, например:

   * [**QuakeSpasm**](https://sourceforge.net/projects/quake-spasm/)
   * [**vkQuake**](https://github.com/Novum/vkQuake)
   * [**DarkPlaces**](https://icculus.org/twilight/darkplaces/)

---

## 🪜 Пошаговая инструкция:

---

### **Шаг 1: Получи игровые файлы Quake**

Если у тебя есть оригинальный Quake:

* Файлы `PAK0.PAK` и `PAK1.PAK` находятся в папке `ID1` в установленной игре.
* Например, если ты купил Quake в Steam:

  * Установи его через Steam на Windows (или с помощью Wine/Crossover).
  * Зайди в папку:

    ```
    C:\Program Files (x86)\Steam\steamapps\common\Quake\Id1
    ```
  * Скопируй файлы `PAK0.PAK` и `PAK1.PAK` на свой Mac.

> ❗ Если у тебя только `PAK0.PAK`, ты получишь демо-версию.

---

### **Шаг 2: Установи QuakeSpasm (рекомендуемый порт)**

#### Вариант 1: Установка через Homebrew (удобно)

Если у тебя установлен [Homebrew](https://brew.sh/), введи в терминале:

```bash
brew install quake
```

> Это установит **QuakeSpasm** и создаст структуру папок.

#### Вариант 2: Установка вручную

1. Скачай QuakeSpasm с [официальной страницы на SourceForge](https://sourceforge.net/projects/quake-spasm/)
2. Распакуй архив, например, в `~/Games/QuakeSpasm/`
3. Создай в папке `QuakeSpasm` папку `id1`
4. Помести туда файлы `PAK0.PAK` и `PAK1.PAK`

---

### **Шаг 3: Запусти игру**

1. Открой терминал и перейди в папку:

   ```bash
   cd ~/Games/QuakeSpasm
   ```
2. Запусти QuakeSpasm:

   ```bash
   ./quake
   ```

> На macOS Catalina может потребоваться разрешить запуск приложения через **System Preferences → Security & Privacy → General**.

---

### 🎮 Готово!

Теперь ты можешь играть в оригинальный Quake на macOS с современным движком и поддержкой OpenGL.

---

## 💡 Дополнительно:

* **QuakeSpasm** очень близок к оригинальному движку, но с улучшениями (поддержка широкого экрана, стабильность, аудио и т.п.)
* Можешь добавить **саундтрек** (если у тебя есть оригинальные аудио-треки с CD)
* Есть также моды и HD-текстуры, если хочешь улучшить графику

---

## Prompt:
_Спасибо. Хочу. Подготовь ответ по обоим темам: автоматизацию установки через скрипт и  созданию .app для удобного запуска._
Отлично, давай сделаем твой Quake удобным и нативным для macOS Catalina: сначала напишем **скрипт для автоматической установки**, а затем создадим **.app-файл**, чтобы запускать Quake как обычное приложение из Finder.

---

## ✅ Часть 1: Автоматизация установки через скрипт

Вот скрипт `install_quake.sh`, который:

* Устанавливает Homebrew (если нужно)
* Ставит QuakeSpasm через `brew`
* Запрашивает путь к `PAK0.PAK`/`PAK1.PAK`
* Копирует их в нужную папку

### 🔧 Скрипт `install_quake.sh`

```bash
#!/bin/bash

echo "=== Установка Quake на macOS Catalina ==="

# Проверим наличие brew
if ! command -v brew &> /dev/null; then
    echo "Homebrew не установлен. Устанавливаю..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Обновляем brew и ставим quake (QuakeSpasm)..."
brew update
brew install quake

# Определим папку с игрой
QUAKE_DIR="$HOME/Library/Application Support/QuakeSpasm/id1"
mkdir -p "$QUAKE_DIR"

# Попросим указать путь к .PAK файлам
echo "Пожалуйста, укажи путь к файлам PAK0.PAK и PAK1.PAK (или только PAK0.PAK для демо)"
read -p "Путь к папке с .PAK файлами: " PAK_PATH

# Проверим и скопируем
if [ -f "$PAK_PATH/PAK0.PAK" ]; then
    cp "$PAK_PATH/PAK0.PAK" "$QUAKE_DIR"
    echo "PAK0.PAK скопирован ✅"
else
    echo "⚠️ Не найден PAK0.PAK"
fi

if [ -f "$PAK_PATH/PAK1.PAK" ]; then
    cp "$PAK_PATH/PAK1.PAK" "$QUAKE_DIR"
    echo "PAK1.PAK скопирован ✅"
else
    echo "⚠️ Не найден PAK1.PAK — будет установлена демо-версия"
fi

echo "✅ Установка завершена. Запустить можно командой: quake"
```

### 📦 Как использовать:

1. Сохрани файл как `install_quake.sh`
2. Сделай исполняемым:

   ```bash
   chmod +x install_quake.sh
   ```
3. Запусти:

   ```bash
   ./install_quake.sh
   ```

---

## ✅ Часть 2: Создание Quake.app для запуска из Finder

Для этого создадим простой `.app`, который будет запускать `quake` (QuakeSpasm).

### 📁 Структура:

```
Quake.app
└── Contents
    ├── Info.plist
    └── MacOS
        └── QuakeLauncher (исполняемый скрипт)
```

### 🔨 Шаги:

#### 1. Создай структуру

```bash
mkdir -p ~/Applications/Quake.app/Contents/MacOS
```

#### 2. Создай файл `Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Quake</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.quake</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>QuakeLauncher</string>
</dict>
</plist>
```

Сохрани как:

```bash
nano ~/Applications/Quake.app/Contents/Info.plist
```

#### 3. Добавь скрипт запуска `QuakeLauncher`

```bash
#!/bin/bash
open -a Terminal.app -n --args quake
```

Сохрани как:

```bash
nano ~/Applications/Quake.app/Contents/MacOS/QuakeLauncher
```

Сделай исполняемым:

```bash
chmod +x ~/Applications/Quake.app/Contents/MacOS/QuakeLauncher
```

---

## 🧪 Проверка

Теперь ты можешь открыть Finder → `~/Applications` → дважды кликнуть `Quake.app`, и он запустит игру в терминале.

---

## 🎁 Бонус: Иконка

Если хочешь иконку:

1. Найди PNG или ICNS-иконку (например, отсюда: [iconarchive](https://iconarchive.com/))
2. Преобразуй PNG в ICNS:

   ```bash
   sips -s format icns quake.png --out quake.icns
   ```
3. Помести в `Quake.app/Contents/Resources/quake.icns`
4. Добавь в `Info.plist`:

```xml
<key>CFBundleIconFile</key>
<string>quake.icns</string>
```

---

Хочешь, я соберу всё это в архив `.zip`, чтобы можно было просто разархивировать и запустить?



