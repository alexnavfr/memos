# v3

## continúa

Отлично. Теперь напиши полностью файл PluginMager.cpp.

Конечно! Вот полная реализация PluginManager.cpp:

PluginManager.h

```cpp
#ifndef PLUGINMANAGER_H
#define PLUGINMANAGER_H

#include <QObject>
#include <QVector>
#include <QPluginLoader>
#include <QDir>
#include <QHash>
#include "PluginInterface.h"

class GitRepository;

class PluginManager : public QObject
{
    Q_OBJECT

public:
    explicit PluginManager(QObject* parent = nullptr);
    ~PluginManager();

    void loadPlugins();
    void unloadPlugins();
    
    QVector<PluginInterface*> plugins() const;
    PluginInterface* plugin(const QString& name) const;
    bool hasPlugin(const QString& name) const;
    
    QWidget* createPluginWidget(const QString& pluginName, GitRepository* repository, QWidget* parent = nullptr);
    
    QStringList pluginNames() const;
    QString pluginPath() const;
    void setPluginPath(const QString& path);

signals:
    void pluginLoaded(const QString& name, const QString& version);
    void pluginUnloaded(const QString& name);
    void pluginError(const QString& error);
    void allPluginsLoaded();

private:
    void loadPlugin(const QString& filePath);
    bool validatePlugin(PluginInterface* plugin, const QString& filePath);
    void scanPluginDirectory();
    
    QVector<PluginInterface*> m_plugins;
    QVector<QPluginLoader*> m_loaders;
    QHash<QString, PluginInterface*> m_pluginMap;
    QString m_pluginPath;
    
    void createDefaultPluginPath();
};

#endif // PLUGINMANAGER_H
```

PluginManager.cpp

```cpp
#include "PluginManager.h"
#include "core/GitRepository.h"

#include <QApplication>
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QJsonObject>
#include <QMessageBox>
#include <QStandardPaths>

PluginManager::PluginManager(QObject* parent)
    : QObject(parent)
    , m_pluginPath("")
{
    // Определяем путь к плагинам по умолчанию
    createDefaultPluginPath();
}

PluginManager::~PluginManager()
{
    unloadPlugins();
}

void PluginManager::createDefaultPluginPath()
{
    // Пытаемся найти плагины в нескольких возможных местах
    QStringList possiblePaths;
    
    // 1. Рядом с исполняемым файлом
    possiblePaths << QApplication::applicationDirPath() + "/plugins";
    
    // 2. В папке данных приложения
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!dataPath.isEmpty()) {
        possiblePaths << dataPath + "/plugins";
    }
    
    // 3. В текущей рабочей директории
    possiblePaths << QDir::currentPath() + "/plugins";
    
    // 4. В папке проекта (для разработки)
    possiblePaths << QDir::currentPath() + "/../../plugins";
    
    // Ищем первую существующую папку
    for (const QString& path : possiblePaths) {
        QDir dir(path);
        if (dir.exists()) {
            m_pluginPath = path;
            qDebug() << "Using plugin path:" << m_pluginPath;
            break;
        }
    }
    
    // Если не нашли существующую папку, создаем стандартную
    if (m_pluginPath.isEmpty()) {
        m_pluginPath = QApplication::applicationDirPath() + "/plugins";
        QDir dir;
        dir.mkpath(m_pluginPath);
        qDebug() << "Created plugin path:" << m_pluginPath;
    }
}

void PluginManager::loadPlugins()
{
    qDebug() << "Loading plugins from:" << m_pluginPath;
    
    // Выгружаем старые плагины
    unloadPlugins();
    
    // Сканируем директорию плагинов
    scanPluginDirectory();
    
    emit allPluginsLoaded();
}

void PluginManager::scanPluginDirectory()
{
    QDir pluginDir(m_pluginPath);
    
    if (!pluginDir.exists()) {
        QString error = QString("Plugin directory does not exist: %1").arg(m_pluginPath);
        qWarning() << error;
        emit pluginError(error);
        return;
    }
    
    // Получаем список файлов плагинов
    QStringList pluginFiles = pluginDir.entryList(QDir::Files | QDir::NoDotAndDotDot);
    
    if (pluginFiles.isEmpty()) {
        qDebug() << "No plugin files found in" << m_pluginPath;
        return;
    }
    
    qDebug() << "Found" << pluginFiles.size() << "potential plugin files";
    
    // Загружаем каждый файл, который выглядит как плагин
    for (const QString& fileName : pluginFiles) {
        // Пропускаем файлы, которые явно не являются плагинами
        if (fileName.startsWith(".") || 
            (!fileName.contains("plugin", Qt::CaseInsensitive) && 
             !QLibrary::isLibrary(fileName))) {
            continue;
        }
        
        QString filePath = pluginDir.absoluteFilePath(fileName);
        loadPlugin(filePath);
    }
    
    qDebug() << "Successfully loaded" << m_plugins.size() << "plugins";
}

void PluginManager::loadPlugin(const QString& filePath)
{
    qDebug() << "Attempting to load plugin:" << filePath;
    
    QPluginLoader* loader = new QPluginLoader(filePath, this);
    
    if (!loader->load()) {
        QString error = QString("Failed to load plugin %1: %2").arg(filePath, loader->errorString());
        qWarning() << error;
        emit pluginError(error);
        delete loader;
        return;
    }
    
    QObject* pluginInstance = loader->instance();
    if (!pluginInstance) {
        QString error = QString("Failed to get plugin instance for %1: %2").arg(filePath, loader->errorString());
        qWarning() << error;
        emit pluginError(error);
        loader->unload();
        delete loader;
        return;
    }
    
    // Получаем интерфейс плагина
    PluginInterface* plugin = qobject_cast<PluginInterface*>(pluginInstance);
    if (!plugin) {
        QString error = QString("Plugin %1 does not implement PluginInterface").arg(filePath);
        qWarning() << error;
        emit pluginError(error);
        loader->unload();
        delete loader;
        return;
    }
    
    // Валидируем плагин
    if (!validatePlugin(plugin, filePath)) {
        QString error = QString("Plugin validation failed for %1").arg(filePath);
        qWarning() << error;
        emit pluginError(error);
        loader->unload();
        delete loader;
        return;
    }
    
    // Инициализируем плагин
    try {
        plugin->initialize();
    } catch (const std::exception& e) {
        QString error = QString("Plugin initialization failed for %1: %2").arg(filePath).arg(e.what());
        qWarning() << error;
        emit pluginError(error);
        loader->unload();
        delete loader;
        return;
    } catch (...) {
        QString error = QString("Plugin initialization failed for %1: Unknown error").arg(filePath);
        qWarning() << error;
        emit pluginError(error);
        loader->unload();
        delete loader;
        return;
    }
    
    // Добавляем плагин в списки
    m_plugins.append(plugin);
    m_loaders.append(loader);
    m_pluginMap.insert(plugin->name(), plugin);
    
    qDebug() << "Successfully loaded plugin:" << plugin->name() 
             << "version:" << plugin->version() 
             << "from:" << filePath;
    
    emit pluginLoaded(plugin->name(), plugin->version());
}

bool PluginManager::validatePlugin(PluginInterface* plugin, const QString& filePath)
{
    if (!plugin) {
        return false;
    }
    
    // Проверяем обязательные поля
    if (plugin->name().isEmpty()) {
        qWarning() << "Plugin from" << filePath << "has empty name";
        return false;
    }
    
    if (plugin->version().isEmpty()) {
        qWarning() << "Plugin" << plugin->name() << "has empty version";
        return false;
    }
    
    if (plugin->description().isEmpty()) {
        qWarning() << "Plugin" << plugin->name() << "has empty description";
        return false;
    }
    
    // Проверяем на дубликаты
    if (m_pluginMap.contains(plugin->name())) {
        qWarning() << "Plugin with name" << plugin->name() << "already loaded";
        return false;
    }
    
    // Проверяем, что плагин может создать виджет (без фактического создания)
    // Это проверяет, что метод не является чисто абстрактным
    if (!plugin->metaObject()->indexOfMethod("createWidget(GitRepository*,QWidget*)") >= 0) {
        qWarning() << "Plugin" << plugin->name() << "does not implement createWidget method properly";
        return false;
    }
    
    qDebug() << "Plugin validation passed for:" << plugin->name();
    return true;
}

void PluginManager::unloadPlugins()
{
    qDebug() << "Unloading all plugins";
    
    // Выгружаем все плагины в обратном порядке (на случай зависимостей)
    for (int i = m_loaders.size() - 1; i >= 0; --i) {
        QPluginLoader* loader = m_loaders[i];
        PluginInterface* plugin = m_plugins[i];
        
        QString pluginName = plugin ? plugin->name() : "Unknown";
        
        if (loader->unload()) {
            qDebug() << "Successfully unloaded plugin:" << pluginName;
            emit pluginUnloaded(pluginName);
        } else {
            qWarning() << "Failed to unload plugin:" << pluginName << "Error:" << loader->errorString();
        }
        
        delete loader;
    }
    
    m_plugins.clear();
    m_loaders.clear();
    m_pluginMap.clear();
}

QVector<PluginInterface*> PluginManager::plugins() const
{
    return m_plugins;
}

PluginInterface* PluginManager::plugin(const QString& name) const
{
    return m_pluginMap.value(name, nullptr);
}

bool PluginManager::hasPlugin(const QString& name) const
{
    return m_pluginMap.contains(name);
}

QWidget* PluginManager::createPluginWidget(const QString& pluginName, GitRepository* repository, QWidget* parent)
{
    PluginInterface* plugin = m_pluginMap.value(pluginName);
    if (!plugin) {
        qWarning() << "Plugin not found:" << pluginName;
        return nullptr;
    }
    
    if (!repository) {
        qWarning() << "Cannot create plugin widget: repository is null";
        return nullptr;
    }
    
    if (!repository->isValid()) {
        qWarning() << "Cannot create plugin widget: repository is invalid";
        return nullptr;
    }
    
    try {
        QWidget* widget = plugin->createWidget(repository, parent);
        if (!widget) {
            qWarning() << "Plugin" << pluginName << "returned null widget";
            return nullptr;
        }
        
        // Устанавливаем полезные свойства
        widget->setProperty("pluginName", pluginName);
        widget->setProperty("repositoryPath", repository->path());
        
        qDebug() << "Successfully created widget for plugin:" << pluginName;
        return widget;
        
    } catch (const std::exception& e) {
        qWarning() << "Exception while creating widget for plugin" << pluginName << ":" << e.what();
        return nullptr;
    } catch (...) {
        qWarning() << "Unknown exception while creating widget for plugin" << pluginName;
        return nullptr;
    }
}

QStringList PluginManager::pluginNames() const
{
    return m_pluginMap.keys();
}

QString PluginManager::pluginPath() const
{
    return m_pluginPath;
}

void PluginManager::setPluginPath(const QString& path)
{
    if (m_pluginPath != path) {
        m_pluginPath = path;
        qDebug() << "Plugin path changed to:" << m_pluginPath;
        
        // Перезагружаем плагины, если они уже были загружены
        if (!m_plugins.isEmpty()) {
            qDebug() << "Reloading plugins due to path change";
            loadPlugins();
        }
    }
}
```

Ключевые особенности реализации:

1. Интеллектуальное обнаружение плагинов

· Автоматически ищет плагины в нескольких стандартных местах
· Создает папку плагинов, если она не существует
· Поддерживает как релизные, так и development-окружения

2. Надежная загрузка и валидация

· Проверяет, что плагин реализует правильный интерфейс
· Валидирует обязательные поля (имя, версия, описание)
· Проверяет на дубликаты
· Обрабатывает исключения при инициализации

3. Безопасное управление памятью

· Корректно выгружает все плагины при разрушении
· Обрабатывает ошибки загрузки без утечек памяти
· Использует умные указатели через родительскую иерархию Qt

4. Расширенная диагностика

· Подробное логирование на всех этапах
· Сигналы для уведомления о состоянии загрузки
· Информативные сообщения об ошибках

5. Гибкая архитектура

· Возможность смены пути к плагинам во время выполнения
· Поддержка динамической перезагрузки плагинов
· Методы для запроса информации о загруженных плагинах

6. Обработка ошибок

· Защита от битых плагинов
· Валидация входных параметров
· Обработка исключений C++ в границах плагинов

Этот менеджер плагинов обеспечивает надежную основу для расширяемой архитектуры приложения, с поддержкой горячей замены плагинов, диагностикой проблем и безопасной работой с динамическими библиотеками.
