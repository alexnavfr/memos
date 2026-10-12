Для проекта, который позволит использовать большинство наиболее распространённых возможностей C++, я предлагаю создать **консольное приложение для управления библиотекой книг**. Этот проект будет включать в себя:

1. **ООП (классы, наследование, полиморфизм)**
2. **STL (контейнеры, алгоритмы, итераторы)**
3. **Работу с файлами (чтение/запись)**
4. **Исключения**
5. **Лямбда-выражения**
6. **Шаблоны**
7. **Умные указатели**
8. **Многопоточность (опционально)**

---

### Структура проекта для CMake

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
└── data/
    └── books.txt
```

---

### 1. Файл `CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.14)
project(BookLibrary)

# Настройка стандарта C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Включаем директории с исходниками и заголовками
include_directories(include)
file(GLOB SOURCES "src/*.cpp")

# Создаем исполняемый файл
add_executable(BookLibrary ${SOURCES})

# Подключаем дополнительные библиотеки (если нужно)
# find_package(Threads REQUIRED)
# target_link_libraries(BookLibrary Threads::Threads)
```

---

### 2. Заголовочные файлы

#### `include/Book.h`

```cpp
#ifndef BOOK_H
#define BOOK_H

#include <string>
#include <iostream>

class Book {
public:
    Book(const std::string& title, const std::string& author, int year);
    std::string getTitle() const;
    std::string getAuthor() const;
    int getYear() const;
    void print() const;

private:
    std::string title;
    std::string author;
    int year;
};

#endif // BOOK_H
```

#### `include/Library.h`

```cpp
#ifndef LIBRARY_H
#define LIBRARY_H

#include <vector>
#include <memory>
#include "Book.h"

class Library {
public:
    void addBook(const Book& book);
    void removeBook(const std::string& title);
    void listBooks() const;
    void saveToFile(const std::string& filename) const;
    void loadFromFile(const std::string& filename);

private:
    std::vector<Book> books;
};

#endif // LIBRARY_H
```

#### `include/Utils.h`

```cpp
#ifndef UTILS_H
#define UTILS_H

#include <string>
#include <vector>

namespace Utils {
    std::vector<std::string> split(const std::string& str, char delimiter);
}

#endif // UTILS_H
```

---

### 3. Исходные файлы

#### `src/Book.cpp`

```cpp
#include "Book.h"

Book::Book(const std::string& title, const std::string& author, int year)
    : title(title), author(author), year(year) {}

std::string Book::getTitle() const {
    return title;
}

std::string Book::getAuthor() const {
    return author;
}

int Book::getYear() const {
    return year;
}

void Book::print() const {
    std::cout << "Title: " << title << ", Author: " << author << ", Year: " << year << std::endl;
}
```

#### `src/Library.cpp`

```cpp
#include "Library.h"
#include "Utils.h"
#include <fstream>
#include <algorithm>

void Library::addBook(const Book& book) {
    books.push_back(book);
}

void Library::removeBook(const std::string& title) {
    books.erase(std::remove_if(books.begin(), books.end(),
        [&title](const Book& book) { return book.getTitle() == title; }),
        books.end());
}

void Library::listBooks() const {
    for (const auto& book : books) {
        book.print();
    }
}

void Library::saveToFile(const std::string& filename) const {
    std::ofstream file(filename);
    for (const auto& book : books) {
        file << book.getTitle() << "," << book.getAuthor() << "," << book.getYear() << "\n";
    }
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
}
```

#### `src/Utils.cpp`

```cpp
#include "Utils.h"
#include <sstream>

std::vector<std::string> Utils::split(const std::string& str, char delimiter) {
    std::vector<std::string> tokens;
    std::string token;
    std::istringstream tokenStream(str);
    while (std::getline(tokenStream, token, delimiter)) {
        tokens.push_back(token);
    }
    return tokens;
}
```

#### `src/main.cpp`

```cpp
#include "Library.h"
#include <iostream>

int main() {
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

### 4. Направления развития

1. **Добавление графического интерфейса**:
   - Использование Qt или другой библиотеки для создания GUI.

2. **Многопоточность**:
   - Добавление асинхронной загрузки данных из файла.

3. **Сетевое взаимодействие**:
   - Возможность загружать книги из онлайн-источников.

4. **Расширение функционала**:
   - Добавление поиска по книгам, сортировки, фильтрации.

5. **Тестирование**:
   - Написание unit-тестов с использованием Google Test или Catch2.

6. **База данных**:
   - Интеграция с SQLite или другой базой данных для хранения книг.

---

### 5. Сборка и запуск

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
   ./BookLibrary
   ```

---

Этот проект охватывает множество аспектов C++ и может быть расширен в зависимости от ваших интересов и задач.
---
# Добавь в этот проект модульное тестирование. Используй фреймворки google test и CppUnit
---
Для добавления модульного тестирования в проект с использованием Google Test и CppUnit, нужно расширить структуру проекта и добавить соответствующие файлы. Я покажу, как интегрировать Google Test, так как он более популярен и прост в настройке. Если нужно, позже можно добавить CppUnit.

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
└── data/
    └── books.txt
```

---

### 1. Обновлённый `CMakeLists.txt` (корневой)

```cmake
cmake_minimum_required(VERSION 3.14)
project(BookLibrary)

# Настройка стандарта C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Включаем директории с исходниками и заголовками
include_directories(include)
file(GLOB SOURCES "src/*.cpp")

# Создаем исполняемый файл
add_executable(BookLibrary ${SOURCES})

# Подключаем Google Test
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
add_executable(BookLibraryTests ${TEST_SOURCES})

# Линкуем Google Test и основной проект
target_link_libraries(BookLibraryTests GTest::GTest GTest::Main BookLibrary)

# Добавляем тесты
add_test(NAME BookLibraryTests COMMAND BookLibraryTests)
```

---

### 3. Тесты

#### `tests/test_book.cpp`

```cpp
#include "Book.h"
#include <gtest/gtest.h>

TEST(BookTest, ConstructorAndGetters) {
    Book book("1984", "George Orwell", 1949);
    EXPECT_EQ(book.getTitle(), "1984");
    EXPECT_EQ(book.getAuthor(), "George Orwell");
    EXPECT_EQ(book.getYear(), 1949);
}

TEST(BookTest, PrintMethod) {
    Book book("To Kill a Mockingbird", "Harper Lee", 1960);
    testing::internal::CaptureStdout();
    book.print();
    std::string output = testing::internal::GetCapturedStdout();
    EXPECT_TRUE(output.find("To Kill a Mockingbird") != std::string::npos);
    EXPECT_TRUE(output.find("Harper Lee") != std::string::npos);
    EXPECT_TRUE(output.find("1960") != std::string::npos);
}
```

#### `tests/test_library.cpp`

```cpp
#include "Library.h"
#include <gtest/gtest.h>

TEST(LibraryTest, AddAndListBooks) {
    Library library;
    library.addBook(Book("1984", "George Orwell", 1949));
    library.addBook(Book("To Kill a Mockingbird", "Harper Lee", 1960));

    testing::internal::CaptureStdout();
    library.listBooks();
    std::string output = testing::internal::GetCapturedStdout();

    EXPECT_TRUE(output.find("1984") != std::string::npos);
    EXPECT_TRUE(output.find("To Kill a Mockingbird") != std::string::npos);
}

TEST(LibraryTest, RemoveBook) {
    Library library;
    library.addBook(Book("1984", "George Orwell", 1949));
    library.addBook(Book("To Kill a Mockingbird", "Harper Lee", 1960));

    library.removeBook("1984");

    testing::internal::CaptureStdout();
    library.listBooks();
    std::string output = testing::internal::GetCapturedStdout();

    EXPECT_TRUE(output.find("1984") == std::string::npos);
    EXPECT_TRUE(output.find("To Kill a Mockingbird") != std::string::npos);
}
```

#### `tests/test_utils.cpp`

```cpp
#include "Utils.h"
#include <gtest/gtest.h>

TEST(UtilsTest, SplitString) {
    std::string input = "one,two,three";
    auto result = Utils::split(input, ',');

    ASSERT_EQ(result.size(), 3);
    EXPECT_EQ(result[0], "one");
    EXPECT_EQ(result[1], "two");
    EXPECT_EQ(result[2], "three");
}

TEST(UtilsTest, SplitStringWithEmptyTokens) {
    std::string input = "one,,three";
    auto result = Utils::split(input, ',');

    ASSERT_EQ(result.size(), 3);
    EXPECT_EQ(result[0], "one");
    EXPECT_EQ(result[1], "");
    EXPECT_EQ(result[2], "three");
}
```

---

### 4. Сборка и запуск тестов

1. Убедитесь, что Google Test установлен. Если нет, установите его:
   - Для macOS: `brew install googletest`
   - Для Linux: `sudo apt-get install libgtest-dev`

2. Создайте директорию для сборки:
   ```bash
   mkdir build
   cd build
   ```

3. Запустите CMake:
   ```bash
   cmake ..
   ```

4. Соберите проект:
   ```bash
   make
   ```

5. Запустите тесты:
   ```bash
   ctest
   ```

---

### 5. Направления развития

1. **Добавление большего количества тестов**:
   - Покрытие всех методов классов `Book`, `Library` и `Utils`.

2. **Интеграция с CI/CD**:
   - Настройка автоматического запуска тестов в GitHub Actions, GitLab CI или Travis CI.

3. **Использование CppUnit**:
   - Если требуется, можно добавить поддержку CppUnit, создав аналогичные тесты и настроив CMake для работы с этим фреймворком.

4. **Моки и стабы**:
   - Использование библиотек для создания моков (например, Google Mock) для тестирования сложных зависимостей.

5. **Тестирование исключений**:
   - Добавление тестов для проверки корректности обработки исключений.

---

Теперь ваш проект поддерживает модульное тестирование с использованием Google Test. Это обеспечивает надёжность и упрощает дальнейшее развитие проекта.

