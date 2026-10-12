# Гит Гуи

## Промпт
_Git, Qt5, C++. Давай напишем графическое приложение которое работает и расширяется системой plugins. Основа предлагает подключать несколько репозиториев. Для каждого позволяет выбрать ветку и в графическом виде(дерево) увидеть историю комитов( полная информафия о комите видна при выборе узла дерева) . Первый плагин позволит работать с каждым файлом отдельно._

Я помогу вам создать графическое приложение на C++ с Qt5 и системой плагинов для работы с Git репозиториями. Вот структура проекта:

Структура проекта

```
GitViewer/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   ├── core/
│   │   ├── GitRepository.h
│   │   ├── GitRepository.cpp
│   │   ├── CommitModel.h
│   │   ├── CommitModel.cpp
│   │   ├── PluginInterface.h
│   │   └── PluginManager.h
│   ├── gui/
│   │   ├── MainWindow.h
│   │   ├── MainWindow.cpp
│   │   ├── RepositoryWidget.h
│   │   ├── RepositoryWidget.cpp
│   │   ├── CommitTreeView.h
│   │   └── CommitTreeView.cpp
│   └── plugins/
│       └── fileexplorer/
│           ├── FileExplorerPlugin.h
│           ├── FileExplorerPlugin.cpp
│           └── FileWidget.h
└── resources/
```

Основные компоненты

1. Интерфейс плагина (PluginInterface.h)

```cpp
#ifndef PLUGININTERFACE_H
#define PLUGININTERFACE_H

#include <QObject>
#include <QWidget>
#include <QString>

class GitRepository;

class PluginInterface
{
public:
    virtual ~PluginInterface() = default;
    
    virtual QString name() const = 0;
    virtual QString version() const = 0;
    virtual QString description() const = 0;
    
    virtual QWidget* createWidget(GitRepository* repository, QWidget* parent = nullptr) = 0;
    virtual void initialize() = 0;
};

#define PluginInterface_iid "com.gitviewer.PluginInterface/1.0"
Q_DECLARE_INTERFACE(PluginInterface, PluginInterface_iid)

#endif // PLUGININTERFACE_H
```

2. Менеджер плагинов (PluginManager.h)

```cpp
#ifndef PLUGINMANAGER_H
#define PLUGINMANAGER_H

#include <QObject>
#include <QVector>
#include <QPluginLoader>
#include <QDir>
#include "PluginInterface.h"

class GitRepository;

class PluginManager : public QObject
{
    Q_OBJECT
public:
    explicit PluginManager(QObject* parent = nullptr);
    ~PluginManager();
    
    void loadPlugins();
    QVector<PluginInterface*> plugins() const;
    QWidget* createPluginWidget(const QString& pluginName, GitRepository* repository, QWidget* parent = nullptr);
    
signals:
    void pluginLoaded(const QString& name);
    void pluginError(const QString& error);
    
private:
    QVector<PluginInterface*> m_plugins;
    QVector<QPluginLoader*> m_loaders;
};

#endif // PLUGINMANAGER_H
```

3. Модель Git репозитория (GitRepository.h)

```cpp
#ifndef GITREPOSITORY_H
#define GITREPOSITORY_H

#include <QObject>
#include <QString>
#include <QVector>
#include <git2.h>

struct GitCommit
{
    QString hash;
    QString author;
    QString email;
    QDateTime date;
    QString message;
    QStringList parents;
};

class GitRepository : public QObject
{
    Q_OBJECT
public:
    explicit GitRepository(const QString& path, QObject* parent = nullptr);
    ~GitRepository();
    
    bool isValid() const;
    QString path() const;
    QString currentBranch() const;
    QStringList branches() const;
    
    QVector<GitCommit> commitHistory() const;
    GitCommit getCommit(const QString& hash) const;
    QStringList getChangedFiles(const QString& commitHash) const;
    
    bool checkoutBranch(const QString& branchName);
    
signals:
    void repositoryUpdated();
    void errorOccurred(const QString& error);
    
private:
    QString m_path;
    git_repository* m_repo;
    bool m_isValid;
    
    void initializeLibGit2();
    static QString errorMessage(int error);
};

#endif // GITREPOSITORY_H
```

4. Модель для дерева коммитов (CommitModel.h)

```cpp
#ifndef COMMITMODEL_H
#define COMMITMODEL_H

#include <QAbstractItemModel>
#include <QVector>
#include "GitRepository.h"

class CommitModel : public QAbstractItemModel
{
    Q_OBJECT
public:
    explicit CommitModel(QObject* parent = nullptr);
    
    void setRepository(GitRepository* repository);
    void refresh();
    
    // QAbstractItemModel interface
    QModelIndex index(int row, int column, const QModelIndex& parent) const override;
    QModelIndex parent(const QModelIndex& child) const override;
    int rowCount(const QModelIndex& parent) const override;
    int columnCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;
    
    GitCommit commitAt(const QModelIndex& index) const;
    
private:
    GitRepository* m_repository;
    QVector<GitCommit> m_commits;
    
    void buildCommitTree();
};

#endif // COMMITMODEL_H
```

5. Главное окно (MainWindow.h)

```cpp
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTabWidget>
#include <QTreeView>
#include <QSplitter>
#include "GitRepository.h"
#include "PluginManager.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    MainWindow(QWidget* parent = nullptr);
    ~MainWindow();
    
private slots:
    void addRepository();
    void removeRepository();
    void onRepositorySelected(int index);
    void onCommitSelected(const QModelIndex& index);
    void onBranchChanged(int index);
    void onPluginActionTriggered();
    
private:
    void setupUI();
    void setupMenu();
    void loadPlugins();
    
    QTabWidget* m_repoTabs;
    QComboBox* m_branchCombo;
    QTreeView* m_commitTree;
    QTextEdit* m_commitDetails;
    QTabWidget* m_pluginTabs;
    
    QVector<GitRepository*> m_repositories;
    PluginManager* m_pluginManager;
    
    void showCommitDetails(const GitCommit& commit);
    void updatePluginsForRepository(GitRepository* repo);
};

#endif // MAINWINDOW_H
```

6. Плагин для работы с файлами (FileExplorerPlugin.h)

```cpp
#ifndef FILEEXPLORERPLUGIN_H
#define FILEEXPLORERPLUGIN_H

#include "PluginInterface.h"
#include <QWidget>
#include <QTreeWidget>

class GitRepository;

class FileExplorerPlugin : public QObject, public PluginInterface
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID PluginInterface_iid)
    Q_INTERFACES(PluginInterface)
    
public:
    FileExplorerPlugin(QObject* parent = nullptr);
    
    // PluginInterface implementation
    QString name() const override { return "File Explorer"; }
    QString version() const override { return "1.0"; }
    QString description() const override { return "Browse files in Git repository"; }
    
    QWidget* createWidget(GitRepository* repository, QWidget* parent = nullptr) override;
    void initialize() override {}
};

class FileWidget : public QWidget
{
    Q_OBJECT
public:
    FileWidget(GitRepository* repository, QWidget* parent = nullptr);
    
private slots:
    void onCommitSelected(const QString& commitHash);
    void onFileSelected(QTreeWidgetItem* item, int column);
    
private:
    void setupUI();
    void loadFiles(const QString& commitHash);
    
    GitRepository* m_repository;
    QTreeWidget* m_fileTree;
    QTextEdit* m_fileContent;
};

#endif // FILEEXPLORERPLUGIN_H
```

CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(GitViewer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 REQUIRED COMPONENTS Core Widgets)
find_package(LibGit2 REQUIRED)

# Основное приложение
add_executable(GitViewer
    src/main.cpp
    src/core/GitRepository.cpp
    src/core/CommitModel.cpp
    src/core/PluginManager.cpp
    src/gui/MainWindow.cpp
    src/gui/RepositoryWidget.cpp
    src/gui/CommitTreeView.cpp
)

# Плагин
add_library(fileexplorerplugin MODULE
    src/plugins/fileexplorer/FileExplorerPlugin.cpp
    src/plugins/fileexplorer/FileWidget.cpp
)

target_link_libraries(GitViewer
    Qt5::Core
    Qt5::Widgets
    ${LIBGIT2_LIBRARIES}
)

target_link_libraries(fileexplorerplugin
    Qt5::Core
    Qt5::Widgets
    GitViewer
)

set_target_properties(fileexplorerplugin PROPERTIES
    PREFIX ""
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
)
```

Основная логика приложения

MainWindow.cpp (фрагмент)

```cpp
void MainWindow::setupUI()
{
    // Создание основного интерфейса
    QSplitter* mainSplitter = new QSplitter(Qt::Horizontal, this);
    
    // Левая панель: репозитории и коммиты
    QWidget* leftPanel = new QWidget(this);
    QVBoxLayout* leftLayout = new QVBoxLayout(leftPanel);
    
    m_repoTabs = new QTabWidget(this);
    m_branchCombo = new QComboBox(this);
    m_commitTree = new QTreeView(this);
    m_commitDetails = new QTextEdit(this);
    m_commitDetails->setReadOnly(true);
    
    leftLayout->addWidget(new QLabel("Repositories:"));
    leftLayout->addWidget(m_repoTabs);
    leftLayout->addWidget(new QLabel("Branch:"));
    leftLayout->addWidget(m_branchCombo);
    leftLayout->addWidget(new QLabel("Commits:"));
    leftLayout->addWidget(m_commitTree);
    leftLayout->addWidget(new QLabel("Commit Details:"));
    leftLayout->addWidget(m_commitDetails);
    
    // Правая панель: плагины
    m_pluginTabs = new QTabWidget(this);
    
    mainSplitter->addWidget(leftPanel);
    mainSplitter->addWidget(m_pluginTabs);
    mainSplitter->setSizes({400, 600});
    
    setCentralWidget(mainSplitter);
    resize(1200, 800);
}
```

FileExplorerPlugin.cpp

```cpp
FileWidget::FileWidget(GitRepository* repository, QWidget* parent)
    : QWidget(parent), m_repository(repository)
{
    setupUI();
    if (repository && repository->isValid()) {
        loadFiles("HEAD");
    }
}

void FileWidget::setupUI()
{
    QSplitter* splitter = new QSplitter(Qt::Horizontal, this);
    
    m_fileTree = new QTreeWidget(this);
    m_fileTree->setHeaderLabels({"File", "Status"});
    m_fileTree->setColumnWidth(0, 300);
    
    m_fileContent = new QTextEdit(this);
    m_fileContent->setReadOnly(true);
    
    splitter->addWidget(m_fileTree);
    splitter->addWidget(m_fileContent);
    splitter->setSizes({300, 500});
    
    QVBoxLayout* layout = new QVBoxLayout(this);
    layout->addWidget(splitter);
    
    connect(m_fileTree, &QTreeWidget::itemClicked, 
            this, &FileWidget::onFileSelected);
}

void FileWidget::loadFiles(const QString& commitHash)
{
    m_fileTree->clear();
    QStringList files = m_repository->getChangedFiles(commitHash);
    
    for (const QString& file : files) {
        QTreeWidgetItem* item = new QTreeWidgetItem(m_fileTree);
        item->setText(0, file);
        item->setData(0, Qt::UserRole, file);
    }
}
```

Это основа приложения, которое:

1. Поддерживает несколько Git репозиториев
2. Показывает историю коммитов в виде дерева
3. Отображает полную информацию о выбранном коммите
4. Имеет систему плагинов
5. Включает плагин для работы с файлами репозитория

Для сборки потребуются:

· Qt5 (Core, Widgets)
· libgit2
· Компилятор с поддержкой C++17

Плагины автоматически загружаются из папки plugins и могут быть легко расширены дополнительной функциональностью
.