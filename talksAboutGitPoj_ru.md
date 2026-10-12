Эта ошибка **не связана с Qt-библиотеками**, она говорит совсем о другом:

➡️ **Компоновщик не может найти реализацию класса `MainWindow`**.
То есть декларирован `MainWindow`, но его **.cpp не включён в сборку**.

Именно поэтому:

```
Undefined symbols for architecture x86_64:
  "MainWindow::MainWindow(QWidget*)"
  "MainWindow::~MainWindow()"
```

Это 100% означает — **нет реализации в объектных файлах**, а значит:

* либо `MainWindow.cpp` отсутствует в `add_executable`,
* либо пустой (нет определения),
* либо ошибка имени,
* либо реализация в namespace, а заголовок — нет,
* либо неправильный конструктор.

---

# ✔ Как проверить

## 1. Посмотри CMakeLists:

У тебя в CMake сейчас:

```cmake
add_executable(GitViewer
    src/main.cpp
    #src/core/GitRepository.cpp
    #src/core/CommitModel.cpp
    #src/core/PluginManager.cpp
    #src/gui/MainWindow.cpp
    #src/gui/RepositoryWidget.cpp
    #src/gui/CommitTreeView.cpp
)
```

**Видишь? `src/gui/MainWindow.cpp` закомментирован.**

Поэтому линковщик не видит реализацию.

---

# ✔ Решение

Просто раскомментируй файл:

```cmake
add_executable(GitViewer
    src/main.cpp
    src/gui/MainWindow.cpp
)
```

или если у тебя есть другие классы — добавь тоже.

---

# ✔ Проверка на 100%

### В `MainWindow.h`

```cpp
class MainWindow : public QWidget {
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow();
};
```

### В `MainWindow.cpp`

```cpp
#include "MainWindow.h"

MainWindow::MainWindow(QWidget* parent)
    : QWidget(parent)
{
}

MainWindow::~MainWindow() = default;
```

Если сигнатуры совпадают — линковка пройдёт.

---

# ⚠️ Предупреждение

Если ты после запуска проекта убрал `MainWindow*` и сейчас используешь `QMainWindow`, убедись, что тип совпадает:

Если заголовок:

```cpp
class MainWindow : public QMainWindow
```

А реализация:

```cpp
MainWindow::MainWindow(QWidget* parent)
    : QWidget(parent)
```

— будет конфликт.

---

# ✔ Дополнительная рекомендация

Если проект растёт — лучше сделать `src/gui/CMakeLists.txt`:

```
set(GUI_SOURCES
    MainWindow.cpp
    RepoWidget.cpp
)

add_library(gui ${GUI_SOURCES})
target_link_libraries(gui Qt5::Widgets)
target_include_directories(gui PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```

И потом:

```
target_link_libraries(GitViewer gui)
```

Это правильнее, чем пихать всё в main.

---

Хочешь — давай сделаем **правильную архитектуру Qt-плагинов**, чтобы проект потом можно было расширять, как GitKraken или Fork 👍

---

Ок — сделаем **правильную архитектуру Qt-проекта с плагинами**, похожую на то, как это делается в GitKraken/Fork/QtCreator.
Ты получишь:

* чистую структуру каталогов,
* отдельную сборку GUI, Core, Plugins,
* поддержку плагинов `.so/.dylib`,
* автоматическую загрузку плагинов,
* правильный CMake с Qt5,
* возможность расширять интерфейс.

---

# 🎯 Цель

**GitViewer**

```
GitViewer (EXE)
 ├── core/        → GitRepository, CommitModel, PluginManager
 ├── gui/         → MainWindow, виджеты, ресурсы
 ├── plugins/     → плагины (fileexplorer, history, difftool)
 └── CMakeLists.txt
```

Идея — приложение знает только о `core` и `gui`.
`plugins` расширяют функционал динамически.

---

# 🏗️ Финальная структура проекта

```
GitViewer/
├─ CMakeLists.txt
├─ src/
│  ├─ core/
│  │   ├─ CMakeLists.txt
│  │   ├─ GitRepository.h/.cpp
│  │   ├─ CommitModel.h/.cpp
│  │   └─ PluginManager.h/.cpp
│  ├─ gui/
│  │   ├─ CMakeLists.txt
│  │   ├─ MainWindow.h/.cpp
│  │   ├─ RepositoryWidget.h/.cpp
│  │   └─ resources.qrc
│  ├─ plugins/
│  │   ├─ CMakeLists.txt
│  │   ├─ fileexplorer/
│  │   │    ├─ CMakeLists.txt
│  │   │    ├─ FileExplorerPlugin.h/.cpp
│  │   │    ├─ FileWidget.h/.cpp
│  │   │    └─ plugin.json
│  │   └─ history/
│  │        └─ ...
│  ├─ main.cpp
```

---

# 🔧 Корневой CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(GitViewer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 REQUIRED COMPONENTS Core Widgets)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBGIT2 REQUIRED libgit2)

include_directories(${LIBGIT2_INCLUDE_DIRS})
link_directories(${LIBGIT2_LIBRARY_DIRS})
add_definitions(${LIBGIT2_CFLAGS_OTHER})

add_subdirectory(src/core)
add_subdirectory(src/gui)
add_subdirectory(src/plugins)

add_executable(GitViewer
    src/main.cpp
)

target_link_libraries(GitViewer
    core
    gui
    Qt5::Core
    Qt5::Widgets
    ${LIBGIT2_LIBRARIES}
)

```

---

# 📦 src/core/CMakeLists.txt

```cmake
add_library(core
    GitRepository.cpp
    CommitModel.cpp
    PluginManager.cpp
)

target_link_libraries(core
    Qt5::Core
    ${LIBGIT2_LIBRARIES}
)

target_include_directories(core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
```

---

# 🖼️ src/gui/CMakeLists.txt

```cmake
add_library(gui
    MainWindow.cpp
    RepositoryWidget.cpp
    resources.qrc
)

target_link_libraries(gui
    Qt5::Core
    Qt5::Widgets
    core
)

target_include_directories(gui PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
```

---

# 🧩 src/plugins/CMakeLists.txt

```cmake
add_subdirectory(fileexplorer)
```

В будущем:

```
add_subdirectory(history)
add_subdirectory(difftool)
```

---

# 🧩 src/plugins/fileexplorer/CMakeLists.txt

```cmake
add_library(fileexplorerplugin MODULE
    FileExplorerPlugin.cpp
    FileWidget.cpp
    plugin.json
)

target_link_libraries(fileexplorerplugin
    Qt5::Core
    Qt5::Widgets
    core
    gui
)

set_target_properties(fileexplorerplugin PROPERTIES
    PREFIX ""
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
)
```

---

# 🔌 PluginManager API

## PluginManager.h

```cpp
#pragma once
#include <QObject>
#include <QPluginLoader>
#include <QDir>

class PluginManager : public QObject {
    Q_OBJECT
public:
    explicit PluginManager(QObject* parent = nullptr);
    void loadPlugins(const QString& path);

    QList<QObject*> plugins() const;

private:
    QList<QObject*> m_plugins;
};
```

## PluginManager.cpp

```cpp
#include "PluginManager.h"

PluginManager::PluginManager(QObject* parent)
    : QObject(parent)
{
}

void PluginManager::loadPlugins(const QString &path)
{
    QDir pluginsDir(path);
    for (auto& file : pluginsDir.entryList(QDir::Files)) {
        QPluginLoader loader(pluginsDir.absoluteFilePath(file));
        QObject* plugin = loader.instance();
        if(plugin)
            m_plugins.append(plugin);
    }
}

QList<QObject*> PluginManager::plugins() const {
    return m_plugins;
}
```

---

# 📌 Интерфейс плагина (опционально)

Чтобы плагины могли возвращать виджеты, сделаем интерфейс:

## IPlugin.h

```cpp
#pragma once
#include <QObject>

class QWidget;

class IPlugin {
public:
    virtual ~IPlugin() {}
    virtual QWidget* createWidget(QWidget* parent = nullptr) = 0;
};

#define IPlugin_iid "org.gitviewer.IPlugin"
Q_DECLARE_INTERFACE(IPlugin, IPlugin_iid)
```

---

# 🔧 FileExplorerPlugin

## FileExplorerPlugin.h

```cpp
#pragma once
#include <QObject>
#include "IPlugin.h"

class FileExplorerPlugin : public QObject, public IPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID IPlugin_iid)
    Q_INTERFACES(IPlugin)

public:
    QWidget* createWidget(QWidget* parent) override;
};
```

## FileExplorerPlugin.cpp

```cpp
#include "FileExplorerPlugin.h"
#include "FileWidget.h"

QWidget* FileExplorerPlugin::createWidget(QWidget* parent) {
    return new FileWidget(parent);
}
```

---

# 🖥️ MainWindow: загрузка плагинов

## MainWindow.cpp

```cpp
#include "MainWindow.h"
#include "core/PluginManager.h"

#include <QVBoxLayout>

MainWindow::MainWindow(QWidget* parent)
    : QWidget(parent)
{
    auto* layout = new QVBoxLayout(this);
    setLayout(layout);

    auto* pm = new PluginManager(this);
    pm->loadPlugins(qApp->applicationDirPath() + "/plugins");

    for(auto pluginObj : pm->plugins()) {
        auto plugin = qobject_cast<IPlugin*>(pluginObj);
        if(plugin) {
            QWidget* w = plugin->createWidget(this);
            layout->addWidget(w);
        }
    }
}
```

---

# 🚀 Результат

* `GitViewer` — это GUI-приложение
* плагин компилируется в `build/plugins/fileexplorerplugin.dylib`
* при запуске `GitViewer` подхватывает плагины
* каждый плагин добавляет свой виджет в MainWindow
* простая система расширения — добавил папку → появился функционал

---

# 🌟 Дальнейшее развитие

Хочешь — я могу:

✔ добавить API для меню/панелей,
✔ встроить GitRepository usage в виджеты,
✔ сделать FileExplorer реальным (QTreeView + QFileSystemModel),
✔ добавить логирование,
✔ добавить поддержку Git через libgit2,
✔ показать историю коммитов,
✔ фрейм для диффа,
✔ стиль как в Fork.

---

Если хочешь — скажи: **начинаем с FileExplorer полноценный?** или **идём сначала по CMake и сборке?**

