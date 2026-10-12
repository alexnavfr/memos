Для разделения приложения `BookLibrary` на консольное приложение `BookApp` и динамическую библиотеку `BookLib`, а также добавления логирования, выполним следующие шаги:

---

### Обновлённая структура проекта

```
BookLibrary/
├── CMakeLists.txt
├── include/
│   ├── Book.h
│   ├── Library.h
│   └── Utils.h
├── src/
│   ├── Book.cpp
│   ├── Library.cpp
│   ├── Utils.cpp
│   └── main.cpp
├── tests/
│   ├── CMakeLists.txt
│   ├── test_book.cpp
│   ├── test_library.cpp
│   └── test_utils.cpp
├── data/
│   └── books.txt
└── lib/
    └── Logger.h
```

---

### 1. Основной `CMakeLists.txt` (корневой)

```cmake
cmake_minimum_required(VERSION 3.14)
project(BookLibrary)

# Настройка стандарта C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Включаем директории с исходниками и заголовками
include_directories(include)

# Создаем динамическую библиотеку BookLib
add_library(BookLib SHARED src/Book.cpp src/Library.cpp src/Utils.cpp)

# Создаем консольное приложение BookApp
add_executable(BookApp src/main.cpp)
target_link_libraries(BookApp BookLib)

# Подключаем Google Test для тестирования библиотеки
enable_testing()
add_subdirectory(tests)
```

---

### 2. Файл `tests/CMakeLists.txt`

```cmake
# Ищем Google Test
find_package(GTest REQUIRED)

# Файлы с тестами
set(TEST_SOURCES
    test_book.cpp
    test_library.cpp
    test_utils.cpp
)

# Создаем тестовый исполняемый файл
add_executable(BookLibTests ${TEST_SOURCES})

# Линкуем Google Test и библиотеку BookLib
target_link_libraries(BookLibTests GTest::GTest GTest::Main BookLib)

# Добавляем тесты
add_test(NAME BookLibTests COMMAND BookLibTests)
```

---

### 3. Логирование

Для логирования выберем библиотеку **spdlog**, так как она проста в использовании и широко распространена.

#### Установка spdlog

1. Установите spdlog через менеджер пакетов:
   - Для macOS: `brew install spdlog`
   - Для Linux: `sudo apt-get install libspdlog-dev`

2. Добавьте spdlog в `CMakeLists.txt`:

```cmake
# Ищем spdlog
find_package(spdlog REQUIRED)

# Линкуем spdlog к библиотеке BookLib
target_link_libraries(BookLib PRIVATE spdlog::spdlog)
```

---

### 4. Добавление логирования в библиотеку

#### `lib/Logger.h`

```cpp
#ifndef LOGGER_H
#define LOGGER_H

#include <spdlog/spdlog.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <memory>

class Logger {
public:
    static void init(const std::string& logFilePath = "logs/log.txt") {
        auto logger = spdlog::basic_logger_mt("file_logger", logFilePath);
        spdlog::set_default_logger(logger);
        spdlog::set_level(spdlog::level::info);
    }
};

#endif // LOGGER_H
```

#### Использование логирования в `Library.cpp`

```cpp
#include "Library.h"
#include "Utils.h"
#include <fstream>
#include <algorithm>
#include "Logger.h"

void Library::addBook(const Book& book) {
    books.push_back(book);
    spdlog::info("Added book: {}", book.getTitle());
}

void Library::removeBook(const std::string& title) {
    books.erase(std::remove_if(books.begin(), books.end(),
        [&title](const Book& book) { return book.getTitle() == title; }),
        books.end());
    spdlog::info("Removed book: {}", title);
}

void Library::listBooks() const {
    for (const auto& book : books) {
        book.print();
    }
    spdlog::info("Listed all books");
}

void Library::saveToFile(const std::string& filename) const {
    std::ofstream file(filename);
    for (const auto& book : books) {
        file << book.getTitle() << "," << book.getAuthor() << "," << book.getYear() << "\n";
    }
    spdlog::info("Saved library to file: {}", filename);
}

void Library::loadFromFile(const std::string& filename) {
    std::ifstream file(filename);
    std::string line;
    while (std::getline(file, line)) {
        auto parts = Utils::split(line, ',');
        if (parts.size() == 3) {
            addBook(Book(parts[0], parts[1], std::stoi(parts[2])));
        }
    }
    spdlog::info("Loaded library from file: {}", filename);
}
```

---

### 5. Обновлённый `main.cpp`

```cpp
#include "Library.h"
#include "Logger.h"
#include <iostream>

int main() {
    // Инициализация логгера
    Logger::init();

    Library library;

    library.addBook(Book("1984", "George Orwell", 1949));
    library.addBook(Book("To Kill a Mockingbird", "Harper Lee", 1960));

    std::cout << "Books in library:" << std::endl;
    library.listBooks();

    library.saveToFile("data/books.txt");

    Library newLibrary;
    newLibrary.loadFromFile("data/books.txt");

    std::cout << "\nBooks loaded from file:" << std::endl;
    newLibrary.listBooks();

    return 0;
}
```

---

### 6. Сборка и запуск

1. Создайте директорию для сборки:
   ```bash
   mkdir build
   cd build
   ```

2. Запустите CMake:
   ```bash
   cmake ..
   ```

3. Соберите проект:
   ```bash
   make
   ```

4. Запустите приложение:
   ```bash
   ./BookApp
   ```

5. Проверьте логи в файле `logs/log.txt`.

---

### 7. Тестирование библиотеки

1. Перейдите в директорию `build/tests`:
   ```bash
   cd tests
   ```

2. Запустите тесты:
   ```bash
   ctest
   ```

---

### 8. Направления развития

1. **Добавление большего количества тестов**:
   - Покрытие всех методов библиотеки `BookLib`.

2. **Интеграция с CI/CD**:
   - Настройка автоматического запуска тестов в GitHub Actions, GitLab CI или Travis CI.

3. **Расширение логирования**:
   - Добавление различных уровней логирования (debug, warning, error).

4. **Конфигурация логгера**:
   - Возможность настройки формата логов и их ротации.

5. **Добавление GUI**:
   - Использование Qt или другой библиотеки для создания графического интерфейса.

---

Теперь проект разделён на консольное приложение и динамическую библиотеку, покрыт тестами и оснащён логированием. Это обеспечивает модульность, удобство тестирования и отладки.