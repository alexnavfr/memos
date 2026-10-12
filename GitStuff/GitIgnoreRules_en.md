# Git Ignore

## Prompt:
_различие и похожесть файлов `.gitignore_global`в корне пользователя и `.gitignore`в корне проекта. как их правильно использовать вместе. Предложи сценарии. Напиши краткое руководство по настройке. язык русский. комментарии в файлах на английском_

Отличный вопрос 👍
В Git действительно есть два уровня **игнорирования файлов**:

* **`.gitignore` (локальный для проекта)** — лежит в корне репозитория. Содержит правила, относящиеся **только к этому проекту**. Обычно коммитится вместе с кодом, чтобы все участники проекта игнорировали одно и то же.
* **`.gitignore_global` (глобальный)** — лежит в **домашней директории пользователя**. Применяется ко всем репозиториям на данной машине. Обычно не коммитится. Используется для личных или системных файлов (например, IDE, ОС).

---

## Краткое руководство по настройке

1. **Создать глобальный файл игнорирования** (обычно в `$HOME`):

   ```bash
   touch ~/.gitignore_global
   git config --global core.excludesfile ~/.gitignore_global
   ```

2. **Заполнить `.gitignore_global`** типичными правилами:

   ```gitignore
   # IDE files
   .vscode/
   .idea/

   # OS files
   .DS_Store
   Thumbs.db

   # Compiled files
   *.obj
   *.o
   *.log
   ```

3. **Создать `.gitignore` в проекте** (если его ещё нет):

   ```gitignore
   # Build artifacts
   /build/
   /dist/

   # Project-specific configs
   config/local.env
   ```

4. **Добавить и закоммитить `.gitignore` проекта**, но **НЕ коммитить** `.gitignore_global` — он остаётся только у вас.

---

## Как использовать вместе

* **Глобальный** (`.gitignore_global`) — для всего, что не зависит от конкретного проекта, а связано с вашей системой, IDE, общими временными файлами.
* **Локальный** (`.gitignore`) — для специфики проекта: артефакты сборки, временные конфиги, папки зависимостей.

---

## Сценарии использования

### Сценарий 1. Разные IDE у команды

* У вас VSCode, у коллеги CLion.
* В `.gitignore_global` указываете `.vscode/`, `.idea/`.
* В проекте — этого нет, чтобы не навязывать IDE.

### Сценарий 2. Общие бинарные артефакты

* У проекта есть `/build/`, `/bin/`.
* Это в `.gitignore` проекта, потому что всем это актуально.

### Сценарий 3. Секреты и конфиги

* У вас есть `~/.ssh/`, `config/local.env`.
* Первое — глобально, второе — в `.gitignore` проекта, если оно создаётся внутри проекта.

---

✅ В итоге:

* **`.gitignore_global`** = личные правила (IDE, ОС, личные временные файлы).
* **`.gitignore`** = правила, которые нужны **всем участникам проекта**.

Хотите, я сделаю для вас готовые **шаблоны** для C++/Qt-проектов: один глобальный (`.gitignore_global`), другой проектный (`.gitignore`)?

---

_Создавай. Среды разработки Clion, VSCode, Visual studio 2017/2022. Os - Windows и Linux._


Отлично 👌
Тогда соберём два файла:

1. **`.gitignore_global`** — для IDE и ОС (общий, личный, не коммитится).
2. **`.gitignore`** — для C++/Qt проекта (коммитится).

---

## 📄 Глобальный `.gitignore_global`

```gitignore
# -------------------------
# IDE-specific files
# -------------------------

# VSCode
.vscode/

# CLion (JetBrains)
.idea/

# Visual Studio
*.suo
*.user
*.userosscache
*.sln.docstates

# -------------------------
# OS-specific files
# -------------------------

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Linux
*~
.nfs*

# -------------------------
# Generic temporary files
# -------------------------

*.log
*.tmp
*.bak
*.swp
*.lock
```

> 💡 Этот файл хранится в `~/.gitignore_global` и подключается командой:
>
> ```bash
> git config --global core.excludesfile ~/.gitignore_global
> ```

---

## 📄 Локальный `.gitignore` (для C++/Qt проекта)

```gitignore
# -------------------------
# Build directories
# -------------------------
/build/
/bin/
/dist/
/out/

# -------------------------
# Qt specific
# -------------------------
*.pro.user        # Qt Creator user-specific
*.pro.user.*      
*.qmake.stash     
*.qmake.cache     

# -------------------------
# C++ build artifacts
# -------------------------
*.o
*.obj
*.lo
*.la
*.a
*.lib
*.so
*.so.*
*.dylib
*.dll
*.exe
*.out

# -------------------------
# CMake
# -------------------------
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
Makefile
compile_commands.json

# -------------------------
# Visual Studio build artifacts
# -------------------------
*.idb
*.pdb
*.ipdb
*.iobj
*.tlog
*.lastbuildstate
*.sdf
*.opendb
*.VC.db
*.VC.VC.opendb
*.ilk

# -------------------------
# Backup and temp files
# -------------------------
*.tmp
*.bak
*.swp
```

---

### 🔑 Правила применения

* В **`.gitignore_global`** — только личные IDE/OS файлы (чтобы не мешать команде).
* В **`.gitignore` проекта** — всё, что связано с **сборкой проекта и его артефактами** (чтобы у всех были одинаковые правила).

---

Хотите, я ещё добавлю в проектный `.gitignore` правила для **тестовых файлов и данных** (например, `*.txt`, `*.csv`, `*.dat`), чтобы случайные большие тестовые данные не попадали в репозиторий?

Хорошо 👍
Тогда дополним проектный `.gitignore`, чтобы защититься от случайных загрузок **тестовых файлов и данных**, которые часто создаются при отладке.

---

## 📄 Обновлённый `.gitignore` для C++/Qt проекта

```gitignore
# -------------------------
# Build directories
# -------------------------
/build/
/bin/
/dist/
/out/

# -------------------------
# Qt specific
# -------------------------
*.pro.user        # Qt Creator user-specific
*.pro.user.*      
*.qmake.stash     
*.qmake.cache     

# -------------------------
# C++ build artifacts
# -------------------------
*.o
*.obj
*.lo
*.la
*.a
*.lib
*.so
*.so.*
*.dylib
*.dll
*.exe
*.out

# -------------------------
# CMake
# -------------------------
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
Makefile
compile_commands.json

# -------------------------
# Visual Studio build artifacts
# -------------------------
*.idb
*.pdb
*.ipdb
*.iobj
*.tlog
*.lastbuildstate
*.sdf
*.opendb
*.VC.db
*.VC.VC.opendb
*.ilk

# -------------------------
# Backup and temp files
# -------------------------
*.tmp
*.bak
*.swp

# -------------------------
# Test and debug data
# -------------------------
*.log
*.csv
*.tsv
*.dat
*.tmp.*
*.test
*.txt
*.json
*.xml
/test/
/tests-output/
/debug/
/tmp/
```

---

### 💡 Логика

* **Текстовые файлы (`*.txt`, `*.csv`, `*.dat`, `*.json`, `*.xml`)** — часто создаются при тестах → лучше игнорировать.
* **Отдельные папки** `/test/`, `/tests-output/`, `/debug/`, `/tmp/` — типичные места для временных данных.
* Если нужен **образцовый тестовый файл**, лучше положить его в `tests/examples/` и **прописать исключение**:

  ```gitignore
  !/tests/examples/*
  ```

---

Хотите, я сделаю **два варианта** `.gitignore` проекта:

* **минимальный** (только сборка и IDE),
* **расширенный** (с тестовыми файлами и папками, как выше)?

Так будет удобнее выбирать в зависимости от проекта.

---
Отлично 👍 Сделаем два готовых варианта `.gitignore` для C++/Qt-проекта:

---

# 📄 Вариант 1. **Минимальный** `.gitignore`

(только сборка и IDE – подходит, если тестовые данные нужны в репозитории)

```gitignore
# -------------------------
# Build directories
# -------------------------
/build/
/bin/
/dist/
/out/

# -------------------------
# Qt specific
# -------------------------
*.pro.user        # Qt Creator user-specific
*.pro.user.*      
*.qmake.stash     
*.qmake.cache     

# -------------------------
# C++ build artifacts
# -------------------------
*.o
*.obj
*.lo
*.la
*.a
*.lib
*.so
*.so.*
*.dylib
*.dll
*.exe
*.out

# -------------------------
# CMake
# -------------------------
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
Makefile
compile_commands.json

# -------------------------
# Visual Studio build artifacts
# -------------------------
*.idb
*.pdb
*.ipdb
*.iobj
*.tlog
*.lastbuildstate
*.sdf
*.opendb
*.VC.db
*.VC.VC.opendb
*.ilk

# -------------------------
# Backup and temp files
# -------------------------
*.tmp
*.bak
*.swp
```

---

# 📄 Вариант 2. **Расширенный** `.gitignore`

(включает игнорирование временных и тестовых файлов – подходит для большинства случаев)

```gitignore
# -------------------------
# Build directories
# -------------------------
/build/
/bin/
/dist/
/out/

# -------------------------
# Qt specific
# -------------------------
*.pro.user        # Qt Creator user-specific
*.pro.user.*      
*.qmake.stash     
*.qmake.cache     

# -------------------------
# C++ build artifacts
# -------------------------
*.o
*.obj
*.lo
*.la
*.a
*.lib
*.so
*.so.*
*.dylib
*.dll
*.exe
*.out

# -------------------------
# CMake
# -------------------------
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
Makefile
compile_commands.json

# -------------------------
# Visual Studio build artifacts
# -------------------------
*.idb
*.pdb
*.ipdb
*.iobj
*.tlog
*.lastbuildstate
*.sdf
*.opendb
*.VC.db
*.VC.VC.opendb
*.ilk

# -------------------------
# Backup and temp files
# -------------------------
*.tmp
*.bak
*.swp

# -------------------------
# Test and debug data
# -------------------------
*.log
*.csv
*.tsv
*.dat
*.tmp.*
*.test
*.txt
*.json
*.xml

/test/
/tests-output/
/debug/
/tmp/

# Keep example test files
!/tests/examples/*
```

---

👉 Вариант 1 стоит использовать в проектах, где:

* тестовые входные/выходные данные **хранятся в репозитории** (например, учебные задачи).

👉 Вариант 2 лучше для проектов, где:

* тестовые файлы **генерируются автоматически** и не должны засорять репозиторий.

---

Хочешь, я сделаю ещё **шаблон для `.gitattributes`**, чтобы управлять концами строк (Windows/Linux) и кодировками? Это тоже часто полезно, если работаешь на разных ОС.


