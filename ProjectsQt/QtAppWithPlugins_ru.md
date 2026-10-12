# Приложение с поддержской плагинов.

## Prompt:
_Qt5,C++,CMake. Необходимо написать базовое приложение с поддержкой плагинов. Пример плагина необходим._

Я создам для вас базовое Qt5 приложение с системой плагинов, включая пример плагина.

Структура проекта

```
plugin-app/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   ├── mainwindow.h
│   ├── mainwindow.cpp
│   └── plugininterface.h
└── plugins/
    └── exampleplugin/
        ├── CMakeLists.txt
        ├── exampleplugin.h
        └── exampleplugin.cpp
```

1. Главный CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.10)
project(PluginApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

# Директория для плагинов
set(PLUGIN_DIR "${CMAKE_BINARY_DIR}/plugins")
file(MAKE_DIRECTORY ${PLUGIN_DIR})

# Подключаем поддиректории
add_subdirectory(src)
add_subdirectory(plugins/exampleplugin)

# Копируем плагины в выходную директорию
add_custom_command(TARGET pluginapp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${PLUGIN_DIR} $<TARGET_FILE_DIR:pluginapp>/plugins)
```

2. Интерфейс плагина (src/plugininterface.h)

```cpp
#ifndef PLUGININTERFACE_H
#define PLUGININTERFACE_H

#include <QString>
#include <QtPlugin>

class PluginInterface
{
public:
    virtual ~PluginInterface() = default;
    
    // Имя плагина
    virtual QString name() const = 0;
    
    // Версия плагина
    virtual QString version() const = 0;
    
    // Описание плагина
    virtual QString description() const = 0;
    
    // Выполнить действие плагина
    virtual void execute() = 0;
};

#define PLUGIN_INTERFACE_IID "com.example.PluginInterface/1.0"
Q_DECLARE_INTERFACE(PluginInterface, PLUGIN_INTERFACE_IID)

#endif // PLUGININTERFACE_H
```

3. Главное окно (src/mainwindow.h)

```cpp
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPluginLoader>
#include <QListWidget>
#include <QTextEdit>
#include <QVBoxLayout>
#include <QPushButton>
#include <QLabel>
#include "plugininterface.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void loadPlugins();
    void executePlugin();

private:
    void scanPlugins();
    void clearPlugins();

    QListWidget *pluginList;
    QTextEdit *infoText;
    QPushButton *loadButton;
    QPushButton *executeButton;
    QLabel *statusLabel;
    
    QList<QPluginLoader*> pluginLoaders;
    QMap<QString, PluginInterface*> plugins;
    QString pluginsDirectory;
};

#endif // MAINWINDOW_H
```

4. Реализация главного окна (src/mainwindow.cpp)

```cpp
#include "mainwindow.h"
#include <QDir>
#include <QPluginLoader>
#include <QMessageBox>
#include <QApplication>
#include <QStandardPaths>
#include <QDebug>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setWindowTitle("Plugin Manager");
    resize(600, 400);

    auto *centralWidget = new QWidget(this);
    auto *layout = new QVBoxLayout(centralWidget);

    // Заголовок
    statusLabel = new QLabel("Plugins not loaded", centralWidget);
    layout->addWidget(statusLabel);

    // Список плагинов
    pluginList = new QListWidget(centralWidget);
    layout->addWidget(pluginList);

    // Кнопки
    auto *buttonLayout = new QHBoxLayout();
    loadButton = new QPushButton("Load Plugins", centralWidget);
    executeButton = new QPushButton("Execute Plugin", centralWidget);
    executeButton->setEnabled(false);
    
    buttonLayout->addWidget(loadButton);
    buttonLayout->addWidget(executeButton);
    layout->addLayout(buttonLayout);

    // Информационное поле
    infoText = new QTextEdit(centralWidget);
    infoText->setReadOnly(true);
    layout->addWidget(infoText);

    setCentralWidget(centralWidget);

    // Определяем директорию плагинов
    pluginsDirectory = QCoreApplication::applicationDirPath() + "/plugins";
    
    // Если директория не существует, создаем
    QDir().mkpath(pluginsDirectory);

    // Подключаем сигналы
    connect(loadButton, &QPushButton::clicked, this, &MainWindow::loadPlugins);
    connect(executeButton, &QPushButton::clicked, this, &MainWindow::executePlugin);
    connect(pluginList, &QListWidget::itemSelectionChanged, [this]() {
        if (pluginList->currentItem()) {
            executeButton->setEnabled(true);
            QString pluginName = pluginList->currentItem()->text();
            if (plugins.contains(pluginName)) {
                PluginInterface *plugin = plugins[pluginName];
                infoText->setText(QString("Plugin: %1\nVersion: %2\nDescription: %3")
                    .arg(plugin->name())
                    .arg(plugin->version())
                    .arg(plugin->description()));
            }
        } else {
            executeButton->setEnabled(false);
            infoText->clear();
        }
    });

    infoText->setText("Click 'Load Plugins' to scan for available plugins.");
}

MainWindow::~MainWindow()
{
    clearPlugins();
}

void MainWindow::clearPlugins()
{
    foreach (QPluginLoader *loader, pluginLoaders) {
        loader->unload();
        delete loader;
    }
    pluginLoaders.clear();
    plugins.clear();
    pluginList->clear();
}

void MainWindow::loadPlugins()
{
    clearPlugins();
    
    QDir dir(pluginsDirectory);
    if (!dir.exists()) {
        QMessageBox::warning(this, "Warning", "Plugins directory does not exist!");
        return;
    }

    QStringList filters;
    filters << "*.so" << "*.dylib" << "*.dll";
    dir.setNameFilters(filters);

    int loadedCount = 0;
    
    foreach (QString fileName, dir.entryList(QDir::Files)) {
        QString pluginPath = dir.absoluteFilePath(fileName);
        QPluginLoader *loader = new QPluginLoader(pluginPath);
        
        if (loader->load()) {
            QObject *plugin = loader->instance();
            if (plugin) {
                PluginInterface *pluginInterface = qobject_cast<PluginInterface*>(plugin);
                if (pluginInterface) {
                    pluginLoaders.append(loader);
                    plugins[pluginInterface->name()] = pluginInterface;
                    pluginList->addItem(pluginInterface->name());
                    loadedCount++;
                    
                    qDebug() << "Loaded plugin:" << pluginInterface->name() 
                             << "from" << fileName;
                } else {
                    qDebug() << "Plugin does not implement interface:" << fileName;
                    loader->unload();
                    delete loader;
                }
            } else {
                qDebug() << "Failed to instantiate plugin:" << fileName 
                         << "Error:" << loader->errorString();
                loader->unload();
                delete loader;
            }
        } else {
            qDebug() << "Failed to load plugin:" << fileName 
                     << "Error:" << loader->errorString();
            delete loader;
        }
    }

    statusLabel->setText(QString("Loaded %1 plugins from %2").arg(loadedCount).arg(pluginsDirectory));
    
    if (loadedCount == 0) {
        infoText->setText("No plugins found. Place plugin files (.so, .dll, or .dylib) in the plugins directory.");
    } else {
        infoText->setText(QString("Found %1 plugin(s). Select a plugin to see details.").arg(loadedCount));
    }
}

void MainWindow::executePlugin()
{
    QListWidgetItem *currentItem = pluginList->currentItem();
    if (!currentItem) {
        return;
    }

    QString pluginName = currentItem->text();
    if (plugins.contains(pluginName)) {
        PluginInterface *plugin = plugins[pluginName];
        qDebug() << "Executing plugin:" << plugin->name();
        plugin->execute();
    }
}
```

5. Главная функция (src/main.cpp)

```cpp
#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // Устанавливаем информацию о приложении
    QCoreApplication::setApplicationName("Plugin Manager");
    QCoreApplication::setOrganizationName("Example");
    QCoreApplication::setApplicationVersion("1.0.0");
    
    MainWindow window;
    window.show();
    
    return app.exec();
}
```

6. CMakeLists.txt для src

```cmake
add_executable(pluginapp
    main.cpp
    mainwindow.cpp
    mainwindow.h
    plugininterface.h
)

target_link_libraries(pluginapp PRIVATE Qt5::Widgets)

# Устанавливаем RPATH для поиска плагинов
set_target_properties(pluginapp PROPERTIES
    BUILD_RPATH "${CMAKE_BINARY_DIR}"
)
```

7. Пример плагина (plugins/exampleplugin/exampleplugin.h)

```cpp
#ifndef EXAMPLEPLUGIN_H
#define EXAMPLEPLUGIN_H

#include <QObject>
#include "../../src/plugininterface.h"

class ExamplePlugin : public QObject, public PluginInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID PLUGIN_INTERFACE_IID)
    Q_INTERFACES(PluginInterface)

public:
    explicit ExamplePlugin(QObject *parent = nullptr);
    
    QString name() const override;
    QString version() const override;
    QString description() const override;
    void execute() override;
};

#endif // EXAMPLEPLUGIN_H
```

8. Реализация примера плагина (plugins/exampleplugin/exampleplugin.cpp)

```cpp
#include "exampleplugin.h"
#include <QDebug>
#include <QMessageBox>

ExamplePlugin::ExamplePlugin(QObject *parent)
    : QObject(parent)
{
}

QString ExamplePlugin::name() const
{
    return "Example Plugin";
}

QString ExamplePlugin::version() const
{
    return "1.0.0";
}

QString ExamplePlugin::description() const
{
    return "A simple example plugin that demonstrates the plugin system.";
}

void ExamplePlugin::execute()
{
    qDebug() << "ExamplePlugin::execute() called";
    QMessageBox::information(nullptr, 
        "Example Plugin", 
        "Hello from Example Plugin!\n\nThis plugin was successfully loaded and executed.");
}
```

9. CMakeLists.txt для примера плагина

```cmake
add_library(exampleplugin SHARED
    exampleplugin.cpp
    exampleplugin.h
    ${CMAKE_SOURCE_DIR}/src/plugininterface.h
)

target_link_libraries(exampleplugin PRIVATE Qt5::Widgets)

# Устанавливаем выходную директорию для плагина
set_target_properties(exampleplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${PLUGIN_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "${PLUGIN_DIR}"
)

# Устанавливаем PREFIX для плагинов (на некоторых платформах)
if(UNIX)
    set_target_properties(exampleplugin PROPERTIES PREFIX "")
endif()
```

Сборка и запуск

На Linux/macOS:

```bash
mkdir build
cd build
cmake ..
make
./pluginapp
```

На Windows (с MinGW):

```bash
mkdir build
cd build
cmake .. -G "MinGW Makefiles"
mingw32-make
pluginapp.exe
```

Особенности

1. Динамическая загрузка: Плагины загружаются во время выполнения
2. Автоматическое обнаружение: Система сканирует директорию плагинов
3. Интерфейс плагина: Единый интерфейс для всех плагинов
4. Обработка ошибок: Проверка на ошибки загрузки и несовместимость
5. Информация о плагине: Отображение метаданных плагина

Создание собственного плагина

Для создания нового плагина:

1. Создайте новую директорию в plugins/
2. Скопируйте структуру exampleplugin
3. Измените реализацию методов интерфейса
4. Обновите CMakeLists.txt в корне проекта
5. Пересоберите проект

Это базовая, но полнофункциональная система плагинов для Qt5 приложений. Вы можете расширить её дополнительными функциями, такими как горячая перезагрузка плагинов, управление зависимостями и т.д.
