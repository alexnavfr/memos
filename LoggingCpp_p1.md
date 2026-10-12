# Библиотеки логирования в С++
Выбери наиболее используемую библиотеку логирования c++. Интегрируй в проект
---
В C++ одной из самых популярных библиотек логирования является **spdlog**. Она быстрая, удобная и легко интегрируется в проекты.  

## Интеграция **spdlog** в твой проект на Qt (через CMake)

### 1. Добавь **spdlog** в `CMakeLists.txt`
Если используешь CMake, подключи spdlog через **FetchContent**:  

```cmake
include(FetchContent)

FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG v1.12.0 # Можно проверить последнюю версию на GitHub
)

FetchContent_MakeAvailable(spdlog)

target_link_libraries(YourTarget PRIVATE spdlog::spdlog)
```

Если подключаешь через пакетный менеджер **vcpkg**, установи spdlog:  
```sh
vcpkg install spdlog
```
и добавь в CMake:  
```cmake
find_package(spdlog CONFIG REQUIRED)
target_link_libraries(YourTarget PRIVATE spdlog::spdlog)
```

---

### 2. Использование в коде

Добавь в нужные файлы:  
```cpp
#include <spdlog/spdlog.h>

int main() {
    spdlog::info("Приложение запущено");
    spdlog::warn("Это предупреждение!");
    spdlog::error("Что-то пошло не так!");

    return 0;
}
```

Можно использовать форматирование:  
```cpp
spdlog::info("Читаем файл: {}", "example.txt");
```

Для Qt можно сделать интеграцию с `qDebug`:  
```cpp
#include <QDebug>
#include <spdlog/spdlog.h>

void logWithQt() {
    qDebug() << "Qt log message";
    spdlog::info("spdlog log message");
}
```

Если у тебя **qmake**, то лучше ставить `spdlog` через vcpkg и прописать в `.pro`:  
```pro
INCLUDEPATH += /path/to/spdlog/include
LIBS += -L/path/to/spdlog/lib -lspdlog
```

Готово! Теперь в приложении будет логирование.  
---
Какие уровни логирования в этой библиотеке существуют. Подготовь оба варианта: файл и асинхронное. 
---
### **Уровни логирования в spdlog**  
В `spdlog` есть 6 уровней логирования:  
1. **trace** – детальная отладка  
2. **debug** – отладочные сообщения  
3. **info** – стандартная информация  
4. **warn** – предупреждения  
5. **error** – ошибки  
6. **critical** – критические ошибки  

Использование:  
```cpp
spdlog::trace("Trace log");
spdlog::debug("Debug log");
spdlog::info("Info log");
spdlog::warn("Warning log");
spdlog::error("Error log");
spdlog::critical("Critical log");
```

---

## **1. Логирование в файл**
Чтобы записывать логи в файл, можно создать файл-логгер:  
```cpp
#include <spdlog/spdlog.h>
#include <spdlog/sinks/basic_file_sink.h>

int main() {
    auto file_logger = spdlog::basic_logger_mt("file_logger", "logs/app.log");
    file_logger->set_level(spdlog::level::trace); // Устанавливаем минимальный уровень логирования
    file_logger->info("Приложение запущено!");
    file_logger->warn("Это предупреждение!");
    file_logger->error("Ошибка!");

    return 0;
}
```
Файл **logs/app.log** будет содержать логи.  

---

## **2. Асинхронное логирование**
Асинхронное логирование выполняется в отдельном потоке, что увеличивает производительность.  

### **Простой асинхронный логгер**
```cpp
#include <spdlog/spdlog.h>
#include <spdlog/async.h>
#include <spdlog/sinks/basic_file_sink.h>

int main() {
    // Настраиваем асинхронное логирование с очередью на 8192 сообщений
    spdlog::init_thread_pool(8192, 1);

    auto async_logger = spdlog::create_async<spdlog::sinks::basic_file_sink_mt>("async_logger", "logs/async.log");
    async_logger->set_level(spdlog::level::debug);

    async_logger->info("Асинхронное логирование!");
    async_logger->debug("Это debug сообщение!");
    async_logger->error("Ошибка!");

    return 0;
}
```
Такой логгер работает в отдельном потоке и пишет в `logs/async.log`.  

---

## **Дополнительные настройки**
1. **Установка формата сообщений**  
```cpp
spdlog::set_pattern("[%Y-%m-%d %H:%M:%S] [%^%l%$] %v");
```
Выведет:  
```
[2025-02-17 12:34:56] [INFO] Приложение запущено!
```
2. **Ротация логов (разбиение на файлы)**  
```cpp
#include <spdlog/sinks/rotating_file_sink.h>

// Лог-файлы размером 5 МБ, максимум 3 файла
auto rotating_logger = spdlog::rotating_logger_mt("rot_logger", "logs/rotating.log", 5 * 1024 * 1024, 3);
```

3. **Многопоточный логгер**  
Если логгер используется в нескольких потоках:  
```cpp
#include <spdlog/sinks/daily_file_sink.h>

// Ежедневный лог-файл
auto daily_logger = spdlog::daily_logger_mt("daily_logger", "logs/daily.log", 0, 0);
```

---

### **Вывод**
- **Файл:** `basic_file_sink_mt`  
- **Асинхронное:** `spdlog::async_logger`  
- **Ротация:** `rotating_file_sink_mt`  
- **Формат:** `set_pattern`  

Какой вариант используешь в проекте?

