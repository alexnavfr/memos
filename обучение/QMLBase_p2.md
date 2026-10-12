### Пример простого приложения с анимированным GUI на QML

В этом примере мы создадим простое приложение с анимированным прямоугольником, который меняет цвет и размер при нажатии на кнопку. Проект будет собран с использованием CMake и будет работать на macOS Catalina.

---

### Структура проекта

```
SimpleQMLApp/
├── CMakeLists.txt
├── main.cpp
├── qml/
│   └── main.qml
└── resources.qrc
```

---

### 1. `CMakeLists.txt`

Этот файл описывает сборку проекта с использованием CMake.

```cmake
cmake_minimum_required(VERSION 3.14)
project(SimpleQMLApp)

# Настройка Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)

# Поиск необходимых модулей Qt
find_package(Qt6 REQUIRED COMPONENTS Core Quick)

# Создание исполняемого файла
add_executable(SimpleQMLApp
    main.cpp
    resources.qrc
)

# Подключение Qt модулей
target_link_libraries(SimpleQMLApp
    PRIVATE Qt6::Core Qt6::Quick
)
```

---

### 2. `main.cpp`

Этот файл содержит точку входа в приложение.

```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
```

---

### 3. `qml/main.qml`

Этот файл описывает интерфейс и анимацию.

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Simple QML App"

    Rectangle {
        id: box
        width: 100
        height: 100
        color: "blue"
        anchors.centerIn: parent

        Behavior on color {
            ColorAnimation { duration: 500 }
        }

        Behavior on width {
            NumberAnimation { duration: 500 }
        }

        Behavior on height {
            NumberAnimation { duration: 500 }
        }
    }

    Button {
        text: "Animate"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            box.color = Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
            box.width = 50 + Math.random() * 150
            box.height = 50 + Math.random() * 150
        }
    }
}
```

---

### 4. `resources.qrc`

Этот файл описывает ресурсы проекта, включая QML-файлы.

```xml
<RCC>
    <qresource prefix="/">
        <file>qml/main.qml</file>
    </qresource>
</RCC>
```

---

### Сборка и запуск на macOS Catalina

1. Убедитесь, что у вас установлены:
   - Qt 6 (с модулями `QtCore` и `QtQuick`).
   - CMake (версия 3.14 или выше).
   - Компилятор C++ (например, Clang).

2. Откройте терминал и перейдите в папку проекта.

3. Создайте папку для сборки и выполните команды:

   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```

4. Запустите приложение:

   ```bash
   ./SimpleQMLApp
   ```

---

### Что делает приложение:
- Отображает окно с синим прямоугольником и кнопкой.
- При нажатии на кнопку прямоугольник меняет цвет и размер с анимацией.

---

### Примечания:
- Убедитесь, что Qt установлен и настроен в вашей системе.
- Если вы используете Qt Creator, можно открыть проект через `.pro` файл или напрямую через CMake.
- Для macOS Catalina может потребоваться настроить подпись приложения, если вы планируете распространять его.