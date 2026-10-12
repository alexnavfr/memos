Для того чтобы встроить модульные тесты на основе Google Test в существующий проект с использованием CMake, нужно выполнить несколько шагов. Предположим, что у вас уже есть проект с библиотекой классов `customClasses`, и вы хотите создать отдельную библиотеку `customClasses_test` для тестирования.

### Шаги для настройки:

1. **Установите Google Test**:
   Если у вас еще не установлен Google Test, вы можете добавить его как подмодуль в ваш проект или установить в систему. В этом примере мы будем использовать подмодуль.

   ```bash
   git submodule add https://github.com/google/googletest.git extern/googletest
   ```

2. **Структура проекта**:
   Предположим, что структура вашего проекта выглядит следующим образом:

   ```
   app/
   ├── CMakeLists.txt
   ├── customClasses/
   │   ├── CMakeLists.txt
   │   ├── include/
   │   │   └── customClasses/
   │   │       └── MyClass.h
   │   └── src/
   │       └── MyClass.cpp
   ├── customClasses_test/
   │   ├── CMakeLists.txt
   │   └── test_MyClass.cpp
   └── extern/
       └── googletest/
   ```

3. **Настройка `CMakeLists.txt` для `customClasses`**:
   Убедитесь, что ваш `CMakeLists.txt` для библиотеки `customClasses` выглядит примерно так:

   ```cmake
   cmake_minimum_required(VERSION 3.14)
   project(customClasses)

   set(CMAKE_CXX_STANDARD 14)

   # Добавляем библиотеку
   add_library(customClasses
       src/MyClass.cpp
   )

   # Публичные заголовки
   target_include_directories(customClasses PUBLIC
       ${CMAKE_CURRENT_SOURCE_DIR}/include
   )
   ```

4. **Настройка `CMakeLists.txt` для `customClasses_test`**:
   Создайте `CMakeLists.txt` в папке `customClasses_test`:

   ```cmake
   cmake_minimum_required(VERSION 3.14)
   project(customClasses_test)

   set(CMAKE_CXX_STANDARD 14)

   # Добавляем Google Test как подмодуль
   add_subdirectory(${CMAKE_SOURCE_DIR}/extern/googletest)

   # Добавляем тестовый исполняемый файл
   add_executable(customClasses_test
       test_MyClass.cpp
   )

   # Линкуем Google Test и нашу библиотеку
   target_link_libraries(customClasses_test
       PRIVATE
       customClasses
       gtest
       gtest_main
   )

   # Добавляем директорию с заголовками
   target_include_directories(customClasses_test PRIVATE
       ${CMAKE_SOURCE_DIR}/customClasses/include
   )

   # Добавляем тест
   include(GoogleTest)
   gtest_discover_tests(customClasses_test)
   ```

5. **Настройка основного `CMakeLists.txt`**:
   В основном `CMakeLists.txt` проекта добавьте подпроекты:

   ```cmake
   cmake_minimum_required(VERSION 3.14)
   project(app)

   # Добавляем библиотеку customClasses
   add_subdirectory(customClasses)

   # Добавляем тесты
   add_subdirectory(customClasses_test)
   ```

6. **Напишите тесты**:
   В файле `test_MyClass.cpp` напишите тесты для вашего класса:

   ```cpp
   #include "gtest/gtest.h"
   #include "customClasses/MyClass.h"

   TEST(MyClassTest, ExampleTest) {
       MyClass obj;
       EXPECT_EQ(obj.someMethod(), 42);
   }
   ```

7. **Соберите и запустите тесты**:
   Теперь вы можете собрать проект и запустить тесты:

   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ctest
   ```

### Итог:
Теперь у вас есть отдельная библиотека `customClasses_test`, которая использует Google Test для тестирования вашей библиотеки `customClasses`. Вы можете добавлять новые тесты в `customClasses_test` и запускать их с помощью `ctest`.