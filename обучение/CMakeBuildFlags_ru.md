# Добавить флаги компиляции и линковки через CMakeLists.txt

## Prompt:
_Как при необходимости добавить новые флаги компиляции и линковки в файле CMakeLists.txt.  А так же устанавливать переменные которые могут быть использованы пир припроцессорной обработке исходников_

В CMakeLists.txt можно добавлять флаги компиляции и линковки, а также устанавливать переменные для препроцессора, используя следующие методы:

---

### 1. **Добавление флагов компиляции**
Для добавления флагов компиляции (например, `-Wall`, `-O3`) используйте:
- `target_compile_options()` (предпочтительно для современных CMake)
- `add_compile_options()` (глобально для всех целей)
- `set(CMAKE_CXX_FLAGS ...)` (менее предпочтительно, но иногда нужно)

#### Пример:
```cmake
# Для конкретного таргета (рекомендуется)
target_compile_options(my_target PRIVATE -Wall -Wextra -O3)

# Глобально для всех целей
add_compile_options(-Wall -Wextra)

# Через переменные (если нужно переопределить)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
```

---

### 2. **Добавление флагов линковки**
Для флагов линковки (`-lm`, `-pthread` и т. д.) используйте:
- `target_link_options()` (CMake 3.13+)
- `target_link_libraries()` (можно передавать флаги как строки)
- `set(CMAKE_EXE_LINKER_FLAGS ...)` (глобально)

#### Пример:
```cmake
# Для конкретного таргета
target_link_options(my_target PRIVATE -pthread)

# Через target_link_libraries
target_link_libraries(my_target PRIVATE "-lm")

# Глобально
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread")
```

---

### 3. **Установка переменных для препроцессора**
Чтобы передать определения в код (например, `-DVAR=value`), используйте:
- `target_compile_definitions()` (лучший способ)
- `add_definitions()` (устаревший, но работает)
- `configure_file()` (для сложных случаев)

#### Пример:
```cmake
# Для конкретного таргета
target_compile_definitions(my_target PRIVATE
    MY_DEFINITION=1
    "OTHER_DEF=Hello"
)

# Глобально для всех целей
add_definitions(-DMY_GLOBAL_DEF=42)

# Через конфигурационный файл (если нужно сгенерировать .h)
configure_file(config.h.in config.h)
```

---

### 4. **Пример полного CMakeLists.txt**
```cmake
cmake_minimum_required(VERSION 3.10)
project(MyProject)

add_executable(my_program main.cpp)

# Флаги компиляции
target_compile_options(my_program PRIVATE -Wall -O2)

# Флаги линковки
target_link_libraries(my_program PRIVATE m pthread)

# Определения для препроцессора
target_compile_definitions(my_program PRIVATE
    USE_FEATURE_X
    VERSION="1.0"
)
```

---

### 5. **Проверка поддержки флагов**
Если флаг зависит от компилятора, можно использовать `check_cxx_compiler_flag`:
```cmake
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++17" HAS_CXX17)
if (HAS_CXX17)
    target_compile_options(my_target PRIVATE -std=c++17)
endif()
```

---

### 6. **Условные флаги (например, для Debug/Release)**
```cmake
target_compile_options(my_target PRIVATE
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3>
)
```

---

### Итог:
- Для **флагов компиляции** → `target_compile_options()`
- Для **флагов линковки** → `target_link_options()` или `target_link_libraries()`
- Для **препроцессора** → `target_compile_definitions()`
- Старайтесь избегать глобальных методов (`add_compile_options`, `add_definitions`), если не нужно применять настройки ко всем таргетам.
