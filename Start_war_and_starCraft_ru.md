# War & Star Craft на Linux 

## Prompt:
_Как играть и запустить старый warcraft и starcraft на xubuntu 24.04 lts_


Чтобы запустить старые версии *Warcraft* (например, *Warcraft II*) и *StarCraft* (включая *StarCraft: Brood War*) на *Xubuntu 24.04 LTS*, можно использовать эмуляцию Windows через *Wine* или альтернативные движки, такие как *Stratagus* (*Stargus* для *StarCraft* и *Wargus* для *Warcraft II*). Вот пошаговая инструкция:

---

### **1. Подготовка системы**
1. **Обновите систему**:
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. **Установите Wine**:
   Wine позволяет запускать Windows-приложения на Linux. Для Xubuntu 24.04 LTS рекомендуется использовать последнюю версию Wine:
   ```bash
   sudo dpkg --add-architecture i386
   sudo mkdir -pm755 /etc/apt/keyrings
   sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
   sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
   sudo apt update
   sudo apt install --install-recommends winehq-stable
   ```

3. **Установите winetricks** (для настройки библиотек):
   ```bash
   sudo apt install winetricks
   ```

---

### **2. Запуск StarCraft и StarCraft: Brood War**

#### **Вариант 1: Через Wine**
1. **Получите игру**:
   - *StarCraft* и *Brood War* стали бесплатными с патчем 1.18. Скачайте установщик с официального сайта Blizzard через приложение *Battle.net*:
     - Установите *Battle.net* через Wine:
       ```bash
       wine ~/Downloads/Battle.net-Setup.exe
       ```
     - Авторизуйтесь и выберите *StarCraft* для установки.
   - Если у вас есть старый CD или образ игры, смонтируйте его:
     ```bash
     sudo mount -o loop /path/to/starcraft.iso /mnt
     ```

2. **Настройте Wine**:
   - Запустите конфигурацию Wine:
     ```bash
     winecfg
     ```
   - Установите версию Windows (например, Windows XP или 7) для совместимости.
   - Установите необходимые библиотеки через *winetricks*:
     ```bash
     winetricks d3dx9 vcrun2015
     ```

3. **Запустите игру**:
   ```bash
   wine /path/to/StarCraft.exe
   ```
   Если возникают проблемы с разрешением экрана (например, чёрные полосы), используйте команду:
   ```bash
   wine StarCraft.exe & sleep 5; xrandr -r 60
   ```

4. **Решение проблем**:
   - Если игра лагает, проверьте настройки графики в Wine (отключите шейдеры).
   - Для старых версий (до 1.18) используйте *no-CD патчи* или лоадеры, но это может нарушать лицензию.
   - Если *Battle.net* не запускается, удалите файл `qwindows.dll`:
     ```bash
     setfattr -x user.DOSATTRIB ~/.wine/drive_c/Program\ Files\ \(x86\)/Battle.net/Battle.net.XXXXX/platforms/qwindows.dll
     ```

#### **Вариант 2: Через Stargus (Stratagus)**
*Stargus* — это порт *StarCraft* на движок *Stratagus*, но он требует оригинальных файлов игры и больше не активно поддерживается.

1. **Установите Stratagus**:
   ```bash
   sudo apt install stratagus
   ```
   Если репозиторий устарел, скачайте и соберите из исходников:
   ```bash
   sudo apt install build-essential cmake libsdl2-dev
   git clone https://github.com/Wargus/stratagus.git
   cd stratagus
   mkdir build && cd build
   cmake ..
   make
   sudo make install
   ```

2. **Установите Stargus**:
   ```bash
   git clone https://github.com/Wargus/stargus.git
   cd stargus
   mkdir build && cd build
   cmake ..
   make
   sudo make install
   ```

3. **Подготовьте файлы игры**:
   - Скопируйте файлы данных (*StarCraft* CD или образ) в папку, например, `~/.stargus`.
   - Убедитесь, что файлы `starcraft.mpq` и `broodwar.mpq` доступны.

4. **Запустите Stargus**:
   ```bash
   stargus
   ```
   Укажите путь к файлам игры при первом запуске.

**Примечание**: Stargus может быть глючным, особенно на современных системах. Используйте Wine для большей стабильности.

---

### **3. Запуск Warcraft II**

#### **Вариант 1: Через Wine**
1. **Получите игру**:
   - Если у вас есть CD *Warcraft II* (Battle.net Edition или Tides of Darkness), смонтируйте его или используйте образ.
   - Лицензионную версию можно приобрести через *Battle.net* или использовать старые диски.

2. **Установите игру**:
   ```bash
   wine /path/to/Warcraft2-Setup.exe
   ```

3. **Настройте Wine**:
   - Установите Windows XP в `winecfg`.
   - Установите библиотеки:
     ```bash
     winetricks d3dx9
     ```

4. **Запустите игру**:
   ```bash
   wine /path/to/Warcraft2.exe
   ```

5. **Решение проблем**:
   - Если требуется диск, используйте *no-CD патч* (осторожно, это может быть незаконно).
   - Для корректного отображения используйте:
     ```bash
     wine Warcraft2.exe & sleep 5; xrandr -r 60
     ```

#### **Вариант 2: Через Wargus (Stratagus)**
*Wargus* — это порт *Warcraft II* на движок *Stratagus*.

1. **Установите Stratagus** (см. выше).

2. **Установите Wargus**:
   ```bash
   git clone https://github.com/Wargus/wargus.git
   cd wargus
   mkdir build && cd build
   cmake ..
   make
   sudo make install
   ```

3. **Подготовьте файлы игры**:
   - Скопируйте данные с CD *Warcraft II* (например, файлы `.mpq`) в `~/.wargus`.
   - Используйте утилиту Wargus для извлечения данных:
     ```bash
     wargus-extractor /path/to/warcraft2.iso
     ```

4. **Запустите Wargus**:
   ```bash
   wargus
   ```

**Примечание**: Wargus работает лучше, чем Stargus, и имеет меньше глюков.

---

### **4. Общие рекомендации**
- **Разрешение экрана**: Старые игры рассчитаны на 640x480 или 800x600. Если возникают чёрные полосы, используйте `xrandr` для изменения частоты обновления или настройте виртуальный рабочий стол в `winecfg`.
- **Производительность**: Отключите эффекты рабочего стола (Compiz, анимации) в Xfce для лучшей производительности.
- **Сеть**: Для мультиплеера через *Battle.net* используйте Wine с установленным *Battle.net*. Для локальной сети старые версии могут требовать настройки IPX-протокола через Wine.
- **Резервные копии**: Сохраните образы дисков и настройки Wine перед экспериментами.

---

### **5. Альтернативы**
- **Lutris**: Упрощает установку игр через Wine. Установите:
  ```bash
  sudo apt install lutris
  ```
  Найдите *StarCraft* или *Warcraft II* в каталоге Lutris и следуйте инструкциям.
- **StarCraft: Remastered**: Если вы хотите современную версию, купите *StarCraft: Remastered* через *Battle.net*. Она лучше оптимизирована, но требует Wine для запуска.

---

### **Источники**
- Установка Wine: https://wiki.winehq.org/Ubuntu
- Stratagus и порты: https://github.com/Wargus
- Форумы Linux-гейминга:,,[](https://www.linux.org.ru/forum/games/13364199)[](https://www.reddit.com/r/linux_gaming/comments/11s4pkd/how_to_run_battlenet_on_linux/?tl=ru)[](https://unixforum.org/viewtopic.php?t=81371)

Если возникнут конкретные ошибки, напишите, и я помогу их решить!
