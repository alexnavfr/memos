Создание приложения на C++ с использованием Qt5, которое читает и записывает состояние системы (дата, время, память, свободное место на диске) каждую минуту, сохраняет таймкоды в SQLite и ведет журнал исполнения, требует нескольких шагов. Ниже приведен пошаговый план и пример кода.

---

### Шаг 1: Настройка проекта
1. **Создайте проект с использованием CMake**:
   - Создайте директорию для проекта, например, `SystemMonitor`.
   - Внутри создайте файл `CMakeLists.txt` для настройки сборки.

   ```cmake
   cmake_minimum_required(VERSION 3.14)
   project(SystemMonitor)

   # Настройка Qt5
   set(CMAKE_AUTOMOC ON)
   set(CMAKE_AUTORCC ON)
   set(CMAKE_AUTOUIC ON)

   find_package(Qt5 REQUIRED Core Widgets)

   # Добавление SQLite
   find_package(SQLite3 REQUIRED)

   # Исходные файлы
   set(SOURCES
       src/main.cpp
       src/mainwindow.cpp
       src/systemmonitor.cpp
   )

   # Заголовочные файлы
   set(HEADERS
       include/mainwindow.h
       include/systemmonitor.h
   )

   # Ресурсы
   set(RESOURCES
       resources/resources.qrc
   )

   # Создание исполняемого файла
   add_executable(SystemMonitor ${SOURCES} ${HEADERS} ${RESOURCES})

   # Подключение библиотек
   target_link_libraries(SystemMonitor Qt5::Core Qt5::Widgets SQLite::SQLite3)
   ```

2. **Создайте структуру проекта**:
   ```
   SystemMonitor/
   ├── CMakeLists.txt
   ├── include/
   │   ├── mainwindow.h
   │   └── systemmonitor.h
   ├── src/
   │   ├── main.cpp
   │   ├── mainwindow.cpp
   │   └── systemmonitor.cpp
   ├── resources/
   │   └── resources.qrc
   └── database/
       └── system_monitor.db
   ```

---

### Шаг 2: Реализация логики приложения

#### 1. **Файл `systemmonitor.h`**:
   ```cpp
   #ifndef SYSTEMMONITOR_H
   #define SYSTEMMONITOR_H

   #include <QObject>
   #include <QTimer>
   #include <QString>
   #include <sqlite3.h>

   class SystemMonitor : public QObject
   {
       Q_OBJECT

   public:
       explicit SystemMonitor(QObject *parent = nullptr);
       ~SystemMonitor();

   private slots:
       void updateSystemInfo();

   private:
       QTimer *timer;
       sqlite3 *db;

       void log(const QString &message);
       void saveToDatabase(const QString &timestamp, const QString &memoryUsage, const QString &diskSpace);
       QString getCurrentTimestamp();
       QString getMemoryUsage();
       QString getDiskSpace();
       bool openDatabase();
       void closeDatabase();
   };

   #endif // SYSTEMMONITOR_H
   ```

#### 2. **Файл `systemmonitor.cpp`**:
   ```cpp
   #include "systemmonitor.h"
   #include <QDebug>
   #include <QFile>
   #include <QTextStream>
   #include <QDateTime>
   #include <sys/sysctl.h>
   #include <sys/types.h>
   #include <mach/mach.h>
   #include <mach/mach_host.h>
   #include <sys/mount.h>

   SystemMonitor::SystemMonitor(QObject *parent) : QObject(parent)
   {
       if (!openDatabase()) {
           qWarning() << "Failed to open database!";
       }

       timer = new QTimer(this);
       connect(timer, &QTimer::timeout, this, &SystemMonitor::updateSystemInfo);
       timer->start(60000); // 1 минута
   }

   SystemMonitor::~SystemMonitor()
   {
       closeDatabase();
   }

   void SystemMonitor::updateSystemInfo()
   {
       QString timestamp = getCurrentTimestamp();
       QString memoryUsage = getMemoryUsage();
       QString diskSpace = getDiskSpace();

       log("Updating system info: " + timestamp + ", Memory: " + memoryUsage + ", Disk: " + diskSpace);
       saveToDatabase(timestamp, memoryUsage, diskSpace);
   }

   QString SystemMonitor::getCurrentTimestamp()
   {
       return QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
   }

   QString SystemMonitor::getMemoryUsage()
   {
       vm_size_t page_size;
       mach_port_t mach_port;
       mach_msg_type_number_t count;
       vm_statistics64_data_t vm_stats;

       mach_port = mach_host_self();
       count = sizeof(vm_stats) / sizeof(natural_t);
       if (KERN_SUCCESS == host_page_size(mach_port, &page_size) &&
           KERN_SUCCESS == host_statistics64(mach_port, HOST_VM_INFO,
                                             (host_info64_t)&vm_stats, &count)) {
           long long used_memory = ((int64_t)vm_stats.active_count +
                                   (int64_t)vm_stats.inactive_count +
                                   (int64_t)vm_stats.wire_count) *
                                  (int64_t)page_size;
           long long total_memory = [[NSProcessInfo processInfo] physicalMemory];
           double memoryUsage = (double)used_memory / total_memory * 100.0;
           return QString::number(memoryUsage, 'f', 2) + "%";
       }
       return "N/A";
   }

   QString SystemMonitor::getDiskSpace()
   {
       struct statfs stat;
       if (statfs("/", &stat) == 0) {
           long long freeSpace = stat.f_bavail * stat.f_bsize;
           long long totalSpace = stat.f_blocks * stat.f_bsize;
           double diskUsage = (double)(totalSpace - freeSpace) / totalSpace * 100.0;
           return QString::number(diskUsage, 'f', 2) + "%";
       }
       return "N/A";
   }

   void SystemMonitor::log(const QString &message)
   {
       QFile file("system_monitor.log");
       if (file.open(QIODevice::Append | QIODevice::Text)) {
           QTextStream stream(&file);
           stream << message << "\n";
           file.close();
       }
   }

   bool SystemMonitor::openDatabase()
   {
       int rc = sqlite3_open("database/system_monitor.db", &db);
       if (rc != SQLITE_OK) {
           qWarning() << "Cannot open database:" << sqlite3_errmsg(db);
           return false;
       }

       const char *sql = "CREATE TABLE IF NOT EXISTS system_info ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                         "timestamp TEXT NOT NULL, "
                         "memory_usage TEXT NOT NULL, "
                         "disk_space TEXT NOT NULL);";
       char *errMsg = nullptr;
       rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);
       if (rc != SQLITE_OK) {
           qWarning() << "SQL error:" << errMsg;
           sqlite3_free(errMsg);
           return false;
       }

       return true;
   }

   void SystemMonitor::closeDatabase()
   {
       if (db) {
           sqlite3_close(db);
       }
   }

   void SystemMonitor::saveToDatabase(const QString &timestamp, const QString &memoryUsage, const QString &diskSpace)
   {
       const char *sql = "INSERT INTO system_info (timestamp, memory_usage, disk_space) VALUES (?, ?, ?);";
       sqlite3_stmt *stmt;

       int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr);
       if (rc != SQLITE_OK) {
           qWarning() << "Failed to prepare statement:" << sqlite3_errmsg(db);
           return;
       }

       sqlite3_bind_text(stmt, 1, timestamp.toStdString().c_str(), -1, SQLITE_STATIC);
       sqlite3_bind_text(stmt, 2, memoryUsage.toStdString().c_str(), -1, SQLITE_STATIC);
       sqlite3_bind_text(stmt, 3, diskSpace.toStdString().c_str(), -1, SQLITE_STATIC);

       rc = sqlite3_step(stmt);
       if (rc != SQLITE_DONE) {
           qWarning() << "Failed to execute statement:" << sqlite3_errmsg(db);
       }

       sqlite3_finalize(stmt);
   }
   ```

---

### Шаг 3: Создание графического интерфейса

#### 1. **Файл `mainwindow.h`**:
   ```cpp
   #ifndef MAINWINDOW_H
   #define MAINWINDOW_H

   #include <QMainWindow>
   #include <QTextEdit>

   class MainWindow : public QMainWindow
   {
       Q_OBJECT

   public:
       MainWindow(QWidget *parent = nullptr);
       ~MainWindow();

   private:
       QTextEdit *logViewer;
   };

   #endif // MAINWINDOW_H
   ```

#### 2. **Файл `mainwindow.cpp`**:
   ```cpp
   #include "mainwindow.h"
   #include <QFile>
   #include <QTextStream>

   MainWindow::MainWindow(QWidget *parent)
       : QMainWindow(parent)
   {
       logViewer = new QTextEdit(this);
       logViewer->setReadOnly(true);
       setCentralWidget(logViewer);

       // Чтение логов
       QFile file("system_monitor.log");
       if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
           QTextStream stream(&file);
           logViewer->setPlainText(stream.readAll());
           file.close();
       }
   }

   MainWindow::~MainWindow() {}
   ```

---

### Шаг 4: Запуск приложения

#### 1. **Файл `main.cpp`**:
   ```cpp
   #include <QApplication>
   #include "mainwindow.h"
   #include "systemmonitor.h"

   int main(int argc, char *argv[])
   {
       QApplication app(argc, argv);

       SystemMonitor monitor;
       MainWindow window;
       window.show();

       return app.exec();
   }
   ```

---

### Шаг 5: Сборка и запуск
1. Создайте директорию для сборки:
   ```bash
   mkdir build
   cd build
   ```

2. Соберите проект с помощью CMake:
   ```bash
   cmake ..
   make
   ```

3. Запустите приложение:
   ```bash
   ./SystemMonitor
   ```

---

Теперь ваше приложение будет собирать данные о системе каждую минуту, сохранять их в SQLite и отображать логи в графическом интерфейсе.


