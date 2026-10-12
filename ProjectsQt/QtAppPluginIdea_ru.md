# Первая итерация по проекту с плагинами на C++/Qt

## Prompt:
_Qt.C++. GUI Application. Plugins. CMake. Создай простое Qt приложение которое:_
_1. будет создано с возможностью подключения плагинов;
2. Структура классическая кроссплатформенная - верхний уровень - файл main.cpp и CMakeLists.txt.
3. Начальный и основной экран это классический "FileExplorer"/"Finder" в режиме readonly - просматривать иерархию можно, изменять нельзя. Показ скрытых файлов управляется кнопкой и работает для всех уровней сразу.
4. Первый и единственный пока плагин должен показывать окно в котором сообщается что в будущем это приложение будет работать с git.
Создай необходимые файлы, иерархию и дай мне пошаговое объяснение по каждому файлу._


----

Ниже — минимальный, но **правильный с архитектурной точки зрения** пример Qt‑приложения на C++ с поддержкой плагинов через `Qt Plugins`, сборкой через **CMake**, и главным экраном в виде **read‑only файлового менеджера**.

---

## 1. Общая структура проекта

```
QtFileExplorer/
├── CMakeLists.txt
├── main.cpp
├── app/
│   ├── CMakeLists.txt
│   ├── MainWindow.h
│   ├── MainWindow.cpp
│   └── PluginInterface.h
├── plugins/
│   ├── CMakeLists.txt
│   └── GitFuturePlugin/
│       ├── CMakeLists.txt
│       ├── GitFuturePlugin.h
│       └── GitFuturePlugin.cpp
```

---

## 2. Верхний уровень — `CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.16)
project(QtFileExplorer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

add_subdirectory(app)
add_subdirectory(plugins)
```

### Что здесь важно

* `AUTOMOC` — обязательно для Qt Plugins
* Плагины собираются **отдельно**, но в рамках одного проекта

---

## 3. Точка входа — `main.cpp`

```cpp
#include <QApplication>
#include "MainWindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    MainWindow w;
    w.show();

    return app.exec();
}
```

Классика. Никакой логики плагинов тут быть не должно.

---

## 4. Интерфейс плагинов — `PluginInterface.h`

```cpp
#pragma once

#include <QString>
#include <QWidget>

class PluginInterface
{
public:
    virtual ~PluginInterface() = default;

    virtual QString pluginName() const = 0;
    virtual void show(QWidget* parent) = 0;
};

#define PluginInterface_iid "org.example.QtFileExplorer.PluginInterface"
Q_DECLARE_INTERFACE(PluginInterface, PluginInterface_iid)
```

### Почему так

* **Чистый интерфейс** без Qt‑зависимостей кроме `QWidget`
* `Q_DECLARE_INTERFACE` — ключ к `QPluginLoader`

---

## 5. Главное окно — `MainWindow.h`

```cpp
#pragma once

#include <QMainWindow>
#include <QFileSystemModel>
#include <QTreeView>
#include <QToolBar>

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = nullptr);

private slots:
    void toggleHiddenFiles();
    void loadPlugins();

private:
    QFileSystemModel* model;
    QTreeView* view;
    bool showHidden = false;
};
```

---

## 6. Главное окно — `MainWindow.cpp`

```cpp
#include "MainWindow.h"
#include "PluginInterface.h"

#include <QDir>
#include <QPluginLoader>
#include <QAction>
#include <QMessageBox>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    model = new QFileSystemModel(this);
    model->setRootPath(QDir::rootPath());
    model->setFilter(QDir::AllDirs | QDir::Files | QDir::NoDotAndDotDot);

    view = new QTreeView(this);
    view->setModel(model);
    view->setRootIndex(model->index(QDir::rootPath()));
    view->setEditTriggers(QAbstractItemView::NoEditTriggers);

    setCentralWidget(view);

    auto* toolbar = addToolBar("Main");

    auto* toggleHiddenAction = toolbar->addAction("Show hidden");
    connect(toggleHiddenAction, &QAction::triggered,
            this, &MainWindow::toggleHiddenFiles);

    auto* loadPluginsAction = toolbar->addAction("Load plugins");
    connect(loadPluginsAction, &QAction::triggered,
            this, &MainWindow::loadPlugins);
}

void MainWindow::toggleHiddenFiles()
{
    showHidden = !showHidden;

    QDir::Filters filters = QDir::AllDirs | QDir::Files | QDir::NoDotAndDotDot;
    if (showHidden)
        filters |= QDir::Hidden;

    model->setFilter(filters);
}

void MainWindow::loadPlugins()
{
    QDir pluginsDir(qApp->applicationDirPath() + "/plugins");

    for (const QString& fileName : pluginsDir.entryList(QDir::Files)) {
        QPluginLoader loader(pluginsDir.absoluteFilePath(fileName));
        QObject* plugin = loader.instance();

        if (auto iface = qobject_cast<PluginInterface*>(plugin)) {
            iface->show(this);
        }
    }
}
```

### Ключевые моменты

* `QFileSystemModel` → read‑only explorer
* `Hidden` включается **глобально**, сразу для всех уровней
* Плагины загружаются динамически

---

## 7. Плагин: структура

```
plugins/GitFuturePlugin/
├── CMakeLists.txt
├── GitFuturePlugin.h
└── GitFuturePlugin.cpp
```

---

## 8. Плагин — `GitFuturePlugin.h`

```cpp
#pragma once

#include <QObject>
#include <QtPlugin>
#include "PluginInterface.h"

class GitFuturePlugin : public QObject, public PluginInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID PluginInterface_iid)
    Q_INTERFACES(PluginInterface)

public:
    QString pluginName() const override;
    void show(QWidget* parent) override;
};
```

---

## 9. Плагин — `GitFuturePlugin.cpp`

```cpp
#include "GitFuturePlugin.h"
#include <QMessageBox>

QString GitFuturePlugin::pluginName() const
{
    return "Git integration (future)";
}

void GitFuturePlugin::show(QWidget* parent)
{
    QMessageBox::information(parent,
        "Git Plugin",
        "В будущем это приложение будет работать с Git.");
}
```

---

## 10. `CMakeLists.txt` для приложения

```cmake
add_executable(QtFileExplorer
    main.cpp
    app/MainWindow.cpp
)

target_include_directories(QtFileExplorer PRIVATE app)

target_link_libraries(QtFileExplorer Qt5::Widgets)
```

---

## 11. `CMakeLists.txt` для плагина

```cmake
add_library(GitFuturePlugin SHARED
    GitFuturePlugin.cpp
)

target_include_directories(GitFuturePlugin PRIVATE ../../app)

target_link_libraries(GitFuturePlugin Qt5::Widgets)

set_target_properties(GitFuturePlugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
)
```

---

## Что ты получил

✔ Кроссплатформенную Qt‑архитектуру
✔ Настоящую plugin‑систему (через `.so/.dll`)
✔ Read‑only File Explorer
✔ Управление скрытыми файлами
✔ Плагин‑заглушку под Git

---

Если хочешь дальше:

* добавить **меню плагинов**
* авто‑загрузку при старте
* отдельный API для git‑плагина
* Qt6 вариант

скажи — пойдём дальше по шагам.


----






Я создал **полный рабочий скелет проекта** в canvas справа.

### Что важно понять концептуально (коротко)

* Это **настоящая plugin-архитектура Qt**, а не «плагины на словах»
* `QFileSystemModel + QTreeView` — ровно то, что используют реальные file-manager’ы
* Плагины — **отдельные shared-библиотеки** (`.so / .dll`)
* CMake-структура масштабируется без переделок

Ты сейчас находишься ровно в той точке, с которой:

* удобно добавлять новые плагины
* удобно развивать Git-интеграцию
* удобно перейти к Qt6
* удобно добавить тесты и CI

---

### Рекомендую следующий шаг (логичный)

1. **Автозагрузка плагинов при старте** (без кнопки)
2. **Меню “Plugins”** вместо тулбара
3. Выделить `PluginManager`
4. Добавить **контекстное меню файлов** → хуки для git-плагина

Если хочешь — можем идти **очень методично**:

> 1 шаг = 1 улучшение + объяснение + diff
> как ты любишь с AVL-проектом.

Скажи, что делаем следующим шагом 👌

---

_Для начала дай полный файл для плагинов "QtFileExplorer/plugins/CMakeLists.txt"_

Вот **полный и корректный** файл
`QtFileExplorer/plugins/CMakeLists.txt`, который можно **сразу положить в проект**.

```cmake
# QtFileExplorer/plugins/CMakeLists.txt

cmake_minimum_required(VERSION 3.16)

# Все плагины собираются как подпроекты
# Каждый плагин — отдельная shared-библиотека

add_subdirectory(GitFuturePlugin)
```

---

## Пошаговое объяснение

### 1. `cmake_minimum_required(VERSION 3.16)`

```cmake
cmake_minimum_required(VERSION 3.16)
```

* Совпадает с верхним `CMakeLists.txt`
* Гарантирует поддержку:

  * Qt5/Qt6
  * AUTOMOC
  * корректной сборки shared plugins

---

### 2. `add_subdirectory(GitFuturePlugin)`

```cmake
add_subdirectory(GitFuturePlugin)
```

Что происходит:

* CMake **заходит внутрь**:

  ```
  plugins/GitFuturePlugin/CMakeLists.txt
  ```
* Плагин собирается **как отдельная библиотека**
* Ты можешь:

  * добавить ещё плагины
  * выключать/включать их флагами
  * собирать выборочно

---

## Как это масштабируется дальше

Позже этот файл станет, например, таким:

```cmake
option(ENABLE_GIT_PLUGIN "Enable Git plugin" ON)
option(ENABLE_SVN_PLUGIN "Enable SVN plugin" OFF)

if (ENABLE_GIT_PLUGIN)
    add_subdirectory(GitFuturePlugin)
endif()

if (ENABLE_SVN_PLUGIN)
    add_subdirectory(SvnPlugin)
endif()
```

Или даже с авто-поиском:

```cmake
file(GLOB PLUGIN_DIRS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} */CMakeLists.txt)

foreach(plugin ${PLUGIN_DIRS})
    get_filename_component(plugin_dir ${plugin} DIRECTORY)
    add_subdirectory(${plugin_dir})
endforeach()
```

---

## Контрольный чек-лист

✔ Плагины не линкуются с основным приложением
✔ Загружаются только через `QPluginLoader`
✔ Кроссплатформенно (Linux / Windows / macOS)
✔ Подготовлено к CI и install-правилам

---

Следующий логичный файл:
👉 **`plugins/GitFuturePlugin/CMakeLists.txt`**
(там есть нюансы, которые важно сделать *правильно* для Qt-плагинов)

Говори — продолжаем.

--- 
step 3 
_В директории "QtFileExplorer/app" нам нужен свой файл CMAkeList.txt?_

Коротко: **да, нужен**.
И не «для красоты», а **архитектурно правильно и практически полезно**.

Ниже — *почему*, *как именно* и *какой файл должен быть*.

---

## Почему `QtFileExplorer/app/CMakeLists.txt` нужен

### 1️⃣ Разделение ответственности

* **корневой CMakeLists.txt**
  → управляет проектом целиком
* **`app/`**
  → GUI, окна, модели, интерфейсы плагинов
* **`plugins/`**
  → только плагины

Это стандарт **реальных Qt-проектов**, а не учебных примеров.

---

### 2️⃣ Плагины используют код `app`

Плагин уже зависит от:

```cpp
#include "PluginInterface.h"
```

Значит:

* `app` — это **отдельный модуль**
* его include-директории и зависимости **должны быть описаны один раз**

---

### 3️⃣ Без `app/CMakeLists.txt` дальше будет больно

Если не выделить `app` сейчас:

* при росте проекта начнётся копипаста
* сложно добавить unit-тесты
* сложно вынести core в библиотеку
* сложно переиспользовать код

---

## Как правильно сделать `app/CMakeLists.txt`

Есть **2 корректных варианта**.
Мы выбираем **правильный с запасом на рост**.

---

## ✅ РЕКОМЕНДОВАННЫЙ вариант (модуль как библиотека)

### 📄 `QtFileExplorer/app/CMakeLists.txt`

```cmake
# QtFileExplorer/app/CMakeLists.txt

add_library(app_core
    MainWindow.cpp
)

target_include_directories(app_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(app_core
    PUBLIC
        Qt5::Widgets
)
```

---

## Что это даёт

### 🔹 `app_core` — библиотека приложения

* содержит:

  * `MainWindow`
  * `PluginInterface`
  * будущие модели, менеджеры, сервисы
* используется:

  * главным exe
  * плагинами
  * тестами

---

## Как теперь выглядит корневой `CMakeLists.txt`

```cmake
add_subdirectory(app)
add_subdirectory(plugins)

add_executable(QtFileExplorer
    main.cpp
)

target_link_libraries(QtFileExplorer
    PRIVATE app_core
)
```

📌 **Обрати внимание**:
`main.cpp` — единственный файл exe, всё остальное — библиотека.

---

## Почему это *очень* хороший стиль

| Плюс                         | Почему важно               |
| ---------------------------- | -------------------------- |
| Чистая архитектура           | как в Qt Creator templates |
| Плагины не дублируют include | один источник правды       |
| Легко вынести core           | CLI / tests / tools        |
| Масштабируемость             | без рефакторинга           |

---

## ❌ Альтернатива (НЕ рекомендую тебе)

Можно было бы сделать:

```cmake
add_executable(QtFileExplorer
    main.cpp
    app/MainWindow.cpp
)
```

Но:

* плагины тогда **знают о структуре exe**
* невозможно вынести core
* боль при росте проекта

---

## Вывод

👉 **Да, `app/CMakeLists.txt` нужен**
👉 **Делай `app` библиотекой (`app_core`)**
👉 Ты сейчас закладываешь **архитектуру уровня production**

---

Следующий логичный шаг:

* полный **`plugins/GitFuturePlugin/CMakeLists.txt`** (с правильными target’ами)
* или **PluginManager** вместо загрузки из `MainWindow`

Скажи, куда идём дальше.

---

Step 4.

__





