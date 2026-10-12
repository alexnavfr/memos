Создание простого приложения на C++, которое читает текстовый файл, отображает его постранично в графическом интерфейсе с использованием Qt, сохраняет данные о файле в базе SQLite и упаковывает всё в Docker-образ, требует нескольких шагов. Давайте разберём процесс пошагово.

---

### 1. **Создание проекта на C++ с использованием Qt и SQLite**

#### 1.1. Установка зависимостей
Для начала установите необходимые зависимости:
- **Qt**: библиотека для создания графического интерфейса.
- **SQLite**: встроенная база данных.
- **CMake**: для сборки проекта.

На Ubuntu:
```bash
sudo apt update
sudo apt install qt6-base-dev sqlite3 libsqlite3-dev cmake
```

#### 1.2. Структура проекта
Создайте структуру проекта:
```
text_reader/
├── CMakeLists.txt
├── main.cpp
├── TextReader.cpp
├── TextReader.h
├── database.cpp
├── database.h
├── resources/
│   └── example.txt
```

#### 1.3. Код приложения

**CMakeLists.txt**:
```cmake
cmake_minimum_required(VERSION 3.14)
project(TextReader)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

add_executable(TextReader main.cpp TextReader.cpp database.cpp)

target_link_libraries(TextReader PRIVATE Qt6::Core Qt6::Widgets sqlite3)
```

**main.cpp**:
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

**TextReader.h**:
```cpp
#ifndef TEXTREADER_H
#define TEXTREADER_H

#include <QMainWindow>
#include <QTextEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QFile>
#include <QMessageBox>
#include "database.h"

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

**TextReader.cpp**:
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

**database.h**:
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

**database.cpp**:
```cpp
#include "database.h"
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

### 2. **Сборка проекта**
Соберите проект с помощью CMake:
```bash
mkdir build
cd build
cmake ..
make
```

---

### 3. **Создание Docker-образа**

#### 3.1. Dockerfile
Создайте файл `Dockerfile` в корне проекта:
```Dockerfile
FROM ubuntu:22.04

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    qt6-base-dev \
    sqlite3 \
    libsqlite3-dev \
    cmake \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Копирование исходного кода
COPY . /app
WORKDIR /app/build

# Сборка проекта
RUN cmake .. && make

# Запуск приложения
CMD ["./TextReader"]
```

#### 3.2. Сборка Docker-образа
Соберите Docker-образ:
```bash
docker build -t text-reader .
```

#### 3.3. Запуск контейнера
Запустите контейнер:
```bash
docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix text-reader
```

---

### 4. **Объяснение**
1. **Qt**: Используется для создания графического интерфейса.
2. **SQLite**: Встроенная база данных для хранения данных.
3. **Docker**: Контейнеризация приложения для удобства развёртывания.
4. **CMake**: Упрощает сборку проекта.

---

Теперь у вас есть простое приложение на C++, которое читает текстовый файл, отображает его в GUI, сохраняет данные в SQLite и упаковано в Docker-образ.
