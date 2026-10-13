## Prompt:
_ _


Ниже приведён полный пример приложения на C++/Qt5, состоящего из трёх частей: **интерфейс плагина**, **сам плагин для поиска Git-репозиториев** и **основное приложение-файловый менеджер**, которое загружает плагин и отображает файловую систему.

---

## 1. Интерфейс плагина (общий заголовочный файл)

```cpp
// gitplugininterface.h
#ifndef GITPLUGININTERFACE_H
#define GITPLUGININTERFACE_H

#include <QObject>
#include <QStringList>

class GitPluginInterface : public QObject
{
    Q_OBJECT
public:
    virtual ~GitPluginInterface() = default;

    // Возвращает список абсолютных путей к найденным Git-репозиториям
    virtual QStringList findLocalRepositories(const QString &searchPath) = 0;
};

// Уникальный идентификатор интерфейса — обязателен для qobject_cast
#define GitPluginInterface_iid "com.example.GitPluginInterface/1.0"
Q_DECLARE_INTERFACE(GitPluginInterface, GitPluginInterface_iid)

#endif // GITPLUGININTERFACE_H
```

Ключевые моменты: интерфейс наследует `QObject`, содержит чисто виртуальный метод и макрос `Q_DECLARE_INTERFACE` с уникальным IID .

---

## 2. Плагин для поиска Git-репозиториев

```cpp
// gitplugin.h
#ifndef GITPLUGIN_H
#define GITPLUGIN_H

#include "gitplugininterface.h"

class GitPlugin : public QObject, public GitPluginInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID GitPluginInterface_iid)
    Q_INTERFACES(GitPluginInterface)

public:
    QStringList findLocalRepositories(const QString &searchPath) override;
};

#endif // GITPLUGIN_H
```

```cpp
// gitplugin.cpp
#include "gitplugin.h"
#include <QDir>
#include <QDirIterator>

QStringList GitPlugin::findLocalRepositories(const QString &searchPath)
{
    QStringList repos;
    QDirIterator it(searchPath, QDir::Dirs | QDir::NoDotAndDotDot,
                    QDirIterator::Subdirectories);

    while (it.hasNext()) {
        QString dirPath = it.next();
        QDir dir(dirPath);

        // Проверяем наличие папки .git (стандартный маркер репозитория)
        if (dir.exists(".git")) {
            repos.append(dirPath);
            // Пропускаем подкаталоги этого репозитория (опционально)
            it.skipCurrentDirectory();
        }
    }
    return repos;
}
```

```pro
# gitplugin.pro
QT += core
CONFIG += plugin
TEMPLATE = lib
TARGET = gitplugin
HEADERS = gitplugin.h \
          gitplugininterface.h
SOURCES = gitplugin.cpp
```

**Важно для macOS:** после сборки плагина файл `libgitplugin.dylib` нужно скопировать в директорию `plugins` внутри бандла приложения (см. раздел про .pro основного приложения) .

---

## 3. Основное приложение (файловый менеджер + загрузка плагина)

### 3.1 Основной файл

```cpp
// main.cpp
#include <QApplication>
#include <QMainWindow>
#include <QTreeView>
#include <QSplitter>
#include <QTextEdit>
#include <QFileSystemModel>
#include <QPluginLoader>
#include <QDir>
#include <QLabel>
#include "gitplugininterface.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // === Основное окно ===
    QMainWindow window;
    QSplitter *splitter = new QSplitter(Qt::Horizontal, &window);

    // Дерево файловой системы
    QFileSystemModel *fsModel = new QFileSystemModel;
    fsModel->setRootPath(QDir::rootPath());

    QTreeView *treeView = new QTreeView(splitter);
    treeView->setModel(fsModel);
    treeView->setRootIndex(fsModel->index(QDir::homePath()));
    treeView->setHeaderHidden(false);
    treeView->setColumnWidth(0, 300);

    // Панель с результатами поиска Git-репозиториев
    QTextEdit *resultView = new QTextEdit(splitter);
    resultView->setReadOnly(true);
    resultView->setPlaceholderText("Результаты поиска Git-репозиториев...");

    splitter->addWidget(treeView);
    splitter->addWidget(resultView);
    splitter->setStretchFactor(0, 2);
    splitter->setStretchFactor(1, 1);

    window.setCentralWidget(splitter);
    window.setWindowTitle("File Explorer + Git Plugin");
    window.resize(1200, 700);
    window.show();

    // === Загрузка плагина ===
    QDir pluginsDir(QApplication::applicationDirPath());

#ifdef Q_OS_MAC
    // В macOS исполняемый файл лежит в .app/Contents/MacOS/
    // Плагины размещаем в .app/Contents/PlugIns/
    pluginsDir.cdUp();          // выходим из MacOS
    pluginsDir.cd("PlugIns");   // заходим в PlugIns
#else
    pluginsDir.cd("plugins");
#endif

    QStringList pluginPaths;

    for (const QString &fileName : pluginsDir.entryList(QDir::Files)) {
        // На macOS расширение плагинов — .dylib
        if (fileName.startsWith("libgitplugin")) {
            pluginPaths.append(pluginsDir.absoluteFilePath(fileName));
        }
    }

    GitPluginInterface *gitPlugin = nullptr;

    for (const QString &path : pluginPaths) {
        QPluginLoader loader(path);
        QObject *plugin = loader.instance();

        if (plugin) {
            gitPlugin = qobject_cast<GitPluginInterface*>(plugin);
            if (gitPlugin) {
                break; // Плагин успешно загружен
            }
        }
    }

    if (gitPlugin) {
        // Ищем репозитории в домашней директории пользователя
        QStringList repos = gitPlugin->findLocalRepositories(QDir::homePath());

        QString output = QString("Найдено Git-репозиториев: %1\n\n").arg(repos.size());
        for (const QString &repo : repos) {
            output += repo + "\n";
        }
        resultView->setPlainText(output);
    } else {
        resultView->setPlainText("Плагин Git не загружен.\n"
                                 "Убедитесь, что libgitplugin.dylib находится в plugins/");
    }

    return app.exec();
}
```

### 3.2 Файл проекта (.pro) для основного приложения

```pro
# fileexplorer.pro
QT += widgets
TARGET = FileExplorer
TEMPLATE = app
SOURCES = main.cpp
HEADERS = gitplugininterface.h

# Копирование плагина в бандл на macOS
macx {
    plugins.path = Contents/PlugIns
    plugins.files = ../gitplugin-build/libgitplugin.dylib
    QMAKE_BUNDLE_DATA += plugins
}
```

---

## 4. Структура проекта и порядок сборки

```
project/
├── gitplugininterface.h          # общий интерфейс
├── gitplugin/                    # подпроект плагина
│   ├── gitplugin.pro
│   ├── gitplugin.h
│   └── gitplugin.cpp
└── fileexplorer/                 # основное приложение
    ├── fileexplorer.pro
    └── main.cpp
```

**Порядок действий:**

1. Соберите плагин (`gitplugin`) — получите `libgitplugin.dylib`.
2. Поместите `libgitplugin.dylib` в директорию, указанную в `plugins.files` (или скопируйте вручную в `FileExplorer.app/Contents/PlugIns/`).
3. Соберите основное приложение.
4. Запустите `FileExplorer.app`.

---

## Ключевые технические моменты

**Загрузка плагина на macOS:** исполняемый файл находится в `Contents/MacOS/`, а плагины принято размещать в `Contents/PlugIns/` или `Contents/plugins/`. Поэтому в коде используется `cdUp()` для выхода из `MacOS` и `cd("PlugIns")` для входа в директорию плагинов .

**Интерфейс плагина:** обязательны макросы `Q_DECLARE_INTERFACE` в заголовке и `Q_PLUGIN_METADATA` + `Q_INTERFACES` в классе реализации. Без этого `qobject_cast` вернёт `nullptr` .

**Файловая система:** `QFileSystemModel` — стандартный класс Qt для отображения дерева файлов в `QTreeView`. Модель автоматически следит за изменениями на диске .

**Поиск Git-репозиториев:** проверка наличия поддиректории `.git` — стандартный и быстрый способ идентификации репозитория. `QDirIterator` с флагом `Subdirectories` рекурсивно обходит дерево .