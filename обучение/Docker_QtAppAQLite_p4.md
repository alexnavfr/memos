_Вот какие ошибки я получил: " => [5/6] RUN mkdir build && cd build                                                                                          0.3s
 => ERROR [6/6] RUN cmake .. && make                                                                                           0.3s
------
 > [6/6] RUN cmake .. && make:
#11 0.295 CMake Error: The source directory "/" does not appear to contain CMakeLists.txt.
#11 0.295 Specify --help for usage, or press the help button on the CMake GUI."_
Ошибка, которую вы получили, указывает на то, что команда `cmake ..` выполняется в неправильной директории. Это происходит потому, что после выполнения команды `cd build` в предыдущем шаге (`RUN mkdir build && cd build`) контекст текущей директории не сохраняется для следующей команды `RUN`. В Docker каждая команда `RUN` выполняется в отдельном слое, и изменения текущей директории (`cd`) не сохраняются между командами.

---

### Исправление Dockerfile

Чтобы исправить эту проблему, нужно объединить команды `cd` и `cmake` в одной инструкции `RUN`. Вот исправленный `Dockerfile`:

```Dockerfile
# Используем официальный образ Ubuntu 22.04 как базовый
FROM ubuntu:22.04

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем необходимые зависимости
RUN apt-get update && apt-get install -y \
    build-essential \           # Компилятор C++ и базовые инструменты
    cmake \                     # CMake для сборки проекта
    qt6-base-dev \              # Библиотеки Qt6 (или qt5-base-dev для Qt5)
    libsqlite3-dev \            # Библиотека SQLite
    git \                       # Git для клонирования репозитория (если нужно)
    && rm -rf /var/lib/apt/lists/*  # Очистка кэша для уменьшения размера образа

# Копируем исходный код проекта в контейнер
COPY . .

# Создаем директорию для сборки и собираем проект
RUN mkdir -p build && \
    cd build && \
    cmake .. && \
    make

# Команда для запуска приложения
CMD ["./TextReader"]
```

---

### Что изменилось

1. **Объединение команд `cd` и `cmake`**:
   Вместо того чтобы выполнять `cd build` в одной команде `RUN`, а затем `cmake ..` в другой, мы объединяем их в одну команду:
   ```Dockerfile
   RUN mkdir -p build && \
       cd build && \
       cmake .. && \
       make
   ```
   Это гарантирует, что `cmake ..` выполняется внутри директории `build`.

2. **Использование `mkdir -p`**:
   Мы используем `mkdir -p`, чтобы избежать ошибок, если директория `build` уже существует.

---

### Почему это работает

- В Docker каждая команда `RUN` выполняется в отдельном слое, и изменения текущей директории (`cd`) не сохраняются между командами.
- Объединение команд в одной инструкции `RUN` позволяет сохранить контекст текущей директории.

---

### Проверка сборки

1. **Сборка образа**:
   Перейдите в директорию с `Dockerfile` и выполните команду:
   ```bash
   docker build -t textreader .
   ```

2. **Запуск контейнера**:
   Запустите контейнер с помощью команды:
   ```bash
   docker run -it --rm textreader
   ```

---

### Дополнительные советы

1. **Проверка содержимого контейнера**:
   Если сборка завершается успешно, но приложение не запускается, вы можете войти в контейнер для отладки:
   ```bash
   docker run -it --rm --entrypoint /bin/bash textreader
   ```
   Это откроет интерактивную оболочку внутри контейнера, где вы сможете вручную проверить, что все файлы на месте и приложение работает.

2. **Проверка `CMakeLists.txt`**:
   Убедитесь, что ваш `CMakeLists.txt` правильно настроен. Например:
   ```cmake
   cmake_minimum_required(VERSION 3.10)
   project(TextReader)

   set(SOURCES
       src/Database.cpp
       src/TextReader.cpp
       src/main.cpp
   )

   add_executable(TextReader ${SOURCES})

   target_include_directories(TextReader PRIVATE src)

   find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)
   target_link_libraries(TextReader PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)

   find_package(SQLite3 REQUIRED)
   target_link_libraries(TextReader PRIVATE SQLite::SQLite3)
   ```

3. **Проверка ресурсов**:
   Если ваше приложение использует файлы из директории `resources/`, убедитесь, что они скопированы в контейнер и доступны во время выполнения.

---

Теперь ваш `Dockerfile` должен работать корректно. Если у вас остались вопросы или возникли новые проблемы, дайте знать! 😊