Разработка приложения на macOS Catalina с использованием Qt5, Visual Studio Code и Xcode требует некоторых изменений в подходе. Мы адаптируем структуру проекта и процесс сборки под macOS, а также учтём использование Visual Studio Code и Xcode.

---

### 1. **Установка зависимостей на macOS Catalina**

#### 1.1. Установка Qt5
Установите Qt5 с помощью [Homebrew](https://brew.sh/):
```bash
brew install qt@5
```

#### 1.2. Установка SQLite
SQLite уже предустановлен на macOS. Если требуется обновление:
```bash
brew install sqlite
```

#### 1.3. Установка CMake
Установите CMake:
```bash
brew install cmake
```

#### 1.4. Установка Visual Studio Code
Скачайте и установите [Visual Studio Code](https://code.visualstudio.com/).

#### 1.5. Установка Xcode
Установите Xcode из App Store. После установки выполните:
```bash
xcode-select --install
```

---

### 2. **Структура проекта**

Структура проекта будет выглядеть следующим образом:
```
TextReader/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   ├── TextReader.cpp
│   ├── TextReader.h
│   ├── Database.cpp
│   └── Database.h
├── resources/
│   └── example.txt
├── build/
└── .vscode/
    ├── c_cpp_properties.json
    ├── settings.json
    └── tasks.json
```

---

### 3. **Код приложения**

#### 3.1. **CMakeLists.txt**
```cmake
cmake_minimum_required(VERSION 3.14)
project(TextReader)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

# Поиск Qt5
find_package(Qt5 REQUIRED COMPONENTS Core Widgets)

# Добавление исполняемого файла
add_executable(TextReader src/main.cpp src/TextReader.cpp src/Database.cpp)

# Подключение библиотек
target_link_libraries(TextReader PRIVATE Qt5::Core Qt5::Widgets sqlite3)
```

#### 3.2. **src/main.cpp**
```cpp
#include <QApplication>
#include "TextReader.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    TextReader reader;
    reader.show();
    return app.exec();
}
```

#### 3.3. **src/TextReader.h**
```cpp
#ifndef TEXTREADER_H
#define TEXTREADER_H

#include <QMainWindow>
#include <QTextEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QFileDialog>
#include <QMessageBox>
#include "Database.h"

class TextReader : public QMainWindow {
    Q_OBJECT

public:
    TextReader(QWidget *parent = nullptr);
    ~TextReader();

private slots:
    void loadFile();
    void saveToDatabase();

private:
    QTextEdit *textEdit;
    QPushButton *loadButton;
    QPushButton *saveButton;
    Database db;
};

#endif // TEXTREADER_H
```

#### 3.4. **src/TextReader.cpp**
```cpp
#include "TextReader.h"

TextReader::TextReader(QWidget *parent) : QMainWindow(parent) {
    setWindowTitle("Text Reader");

    textEdit = new QTextEdit(this);
    textEdit->setReadOnly(true);

    loadButton = new QPushButton("Load File", this);
    saveButton = new QPushButton("Save to Database", this);

    QVBoxLayout *layout = new QVBoxLayout();
    layout->addWidget(textEdit);
    layout->addWidget(loadButton);
    layout->addWidget(saveButton);

    QWidget *centralWidget = new QWidget(this);
    centralWidget->setLayout(layout);
    setCentralWidget(centralWidget);

    connect(loadButton, &QPushButton::clicked, this, &TextReader::loadFile);
    connect(saveButton, &QPushButton::clicked, this, &TextReader::saveToDatabase);
}

TextReader::~TextReader() {}

void TextReader::loadFile() {
    QString filePath = QFileDialog::getOpenFileName(this, "Open Text File", "", "Text Files (*.txt)");
    if (filePath.isEmpty()) return;

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QMessageBox::warning(this, "Error", "Could not open file!");
        return;
    }

    QTextStream in(&file);
    textEdit->setText(in.readAll());
    file.close();
}

void TextReader::saveToDatabase() {
    QString content = textEdit->toPlainText();
    if (content.isEmpty()) {
        QMessageBox::warning(this, "Error", "No content to save!");
        return;
    }

    if (db.saveContent(content)) {
        QMessageBox::information(this, "Success", "Content saved to database!");
    } else {
        QMessageBox::warning(this, "Error", "Failed to save content!");
    }
}
```

#### 3.5. **src/Database.h**
```cpp
#ifndef DATABASE_H
#define DATABASE_H

#include <QString>
#include <sqlite3.h>

class Database {
public:
    Database();
    ~Database();
    bool saveContent(const QString &content);

private:
    sqlite3 *db;
};

#endif // DATABASE_H
```

#### 3.6. **src/Database.cpp**
```cpp
#include "Database.h"
#include <iostream>

Database::Database() {
    if (sqlite3_open("text_database.db", &db) != SQLITE_OK) {
        std::cerr << "Error opening database: " << sqlite3_errmsg(db) << std::endl;
    } else {
        const char *sql = "CREATE TABLE IF NOT EXISTS texts (id INTEGER PRIMARY KEY, content TEXT);";
        char *errMsg = nullptr;
        if (sqlite3_exec(db, sql, nullptr, nullptr, &errMsg) != SQLITE_OK) {
            std::cerr << "Error creating table: " << errMsg << std::endl;
            sqlite3_free(errMsg);
        }
    }
}

Database::~Database() {
    sqlite3_close(db);
}

bool Database::saveContent(const QString &content) {
    const char *sql = "INSERT INTO texts (content) VALUES (?);";
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        std::cerr << "Error preparing statement: " << sqlite3_errmsg(db) << std::endl;
        return false;
    }

    sqlite3_bind_text(stmt, 1, content.toStdString().c_str(), -1, SQLITE_STATIC);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        std::cerr << "Error executing statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_finalize(stmt);
        return false;
    }

    sqlite3_finalize(stmt);
    return true;
}
```

---

### 4. **Настройка Visual Studio Code**

#### 4.1. **.vscode/c_cpp_properties.json**
```json
{
    "configurations": [
        {
            "name": "Mac",
            "includePath": [
                "${workspaceFolder}/**",
                "/usr/local/Cellar/qt@5/5.15.2/include",
                "/usr/local/Cellar/sqlite/3.36.0/include"
            ],
            "defines": [],
            "macFrameworkPath": [
                "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks"
            ],
            "compilerPath": "/usr/bin/clang++",
            "cStandard": "c17",
            "cppStandard": "c++17",
            "intelliSenseMode": "macos-clang-x64"
        }
    ],
    "version": 4
}
```

#### 4.2. **.vscode/tasks.json**
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "cmake",
            "args": [
                "--build",
                "${workspaceFolder}/build"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
```

---

### 5. **Сборка и запуск**

#### 5.1. Сборка с помощью CMake
```bash
mkdir build
cd build
cmake ..
make
```

#### 5.2. Запуск приложения
```bash
./TextReader
```

---

### 6. **Использование Xcode**
1. Откройте терминал и перейдите в папку `build`.
2. Создайте Xcode-проект:
   ```bash
   cmake -G Xcode ..
   ```
3. Откройте сгенерированный файл `TextReader.xcodeproj` в Xcode.
4. Соберите и запустите проект через Xcode.

---

Теперь у вас есть приложение, разработанное на macOS Catalina с использованием Qt5, которое можно редактировать в Visual Studio Code и собирать в Xcode.
