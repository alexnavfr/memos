# Возможные проблемы и решения для линковки с GTests

Сборка происходит с ошибкой. Не находится файл "gtest/gtest.h". Возможно не установлены пути к инклюдам. Какие модификации нужно сделать в CMakeFiles.
---
Ошибка `не находится файл "gtest/gtest.h"` возникает, если Google Test не установлен или CMake не может найти его заголовочные файлы и библиотеки. Давайте исправим это, добавив правильную настройку Google Test в `CMakeLists.txt`.

---

### Исправленный `CMakeLists.txt` (корневой)

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

# Ищем Google Test
find_package(GTest REQUIRED)
if (NOT GTest_FOUND)
    message(FATAL_ERROR "Google Test not found! Please install it.")
endif()

# Добавляем поддиректорию с тестами
add_subdirectory(tests)
```

---

### Исправленный `tests/CMakeLists.txt`

```cmake
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

### Установка Google Test

Если Google Test не установлен, выполните следующие шаги:

#### Для Linux (Ubuntu/Debian):
```bash
sudo apt-get install libgtest-dev
```

#### Для macOS (с использованием Homebrew):
```bash
brew install googletest
```

#### Для Windows (с использованием vcpkg):
1. Установите [vcpkg](https://vcpkg.io/).
2. Установите Google Test:
   ```bash
   vcpkg install gtest
   ```
3. Укажите путь к vcpkg в CMake:
   ```bash
   cmake -DCMAKE_TOOLCHAIN_FILE=<path-to-vcpkg>/scripts/buildsystems/vcpkg.cmake ..
   ```

---

### Указание путей к Google Test

Если Google Test установлен, но CMake не может его найти, укажите путь вручную. Например:

```cmake
# Указываем путь к Google Test вручную (если CMake не находит автоматически)
set(GTEST_ROOT "/usr/local/Cellar/googletest/1.12.1")  # Пример для macOS
find_package(GTest REQUIRED)
```

---

### Проверка сборки

1. Убедитесь, что Google Test установлен и доступен.
2. Пересоберите проект:
   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```
3. Запустите тесты:
   ```bash
   ctest
   ```

---

### Альтернативный подход: Использование FetchContent для Google Test

Если вы не хотите устанавливать Google Test в систему, можно использовать `FetchContent` для автоматической загрузки и сборки Google Test:

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

# Используем FetchContent для загрузки Google Test
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG release-1.12.1
)
FetchContent_MakeAvailable(googletest)

# Добавляем поддиректорию с тестами
add_subdirectory(tests)
```

---

### Итог

Теперь сборка должна проходить без ошибок. Если Google Test установлен, но CMake его не находит, укажите путь вручную или используйте `FetchContent`. Это обеспечит корректную работу тестов.
