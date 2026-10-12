# Makefile shortly

## Prompt:
_Расскажи о Makefile. Его структуре. Кратко и емко. Предложи шаблон базового Makefile для сборки простого исполняемого файла, для сборки статической и динамической библиотеки. Как пример: в методе майн исполняемого файла вызывается единственный метод `hello` класса `myClass` из библиотеки `myLib` содержащий класс `myClass`._

### 🔧 Что такое Makefile?

`Makefile` — это файл, который управляет сборкой проекта. Он описывает, как из исходников (`.cpp`, `.h`) получить исполняемый файл или библиотеку с помощью утилиты `make`.

---

### 📌 Структура Makefile

```make
target: dependencies
	<табуляция>команды
```

* **target** — что собираем (например, `main`, `lib`, `all`).
* **dependencies** — от каких файлов зависит цель.
* **команды** — действия (например, компиляция с `g++`).

---

### 📁 Структура проекта (пример)

```
project/
├── Makefile
├── main.cpp
├── myLib/
│   ├── myClass.cpp
│   └── myClass.h
```

---

### 📄 Пример базового Makefile

```make
# Компилятор и флаги
CXX = g++
CXXFLAGS = -std=c++17 -Wall -I./myLib

# Файлы
SRC = main.cpp myLib/myClass.cpp
OBJ = $(SRC:.cpp=.o)
EXEC = myApp

# Цель по умолчанию
all: $(EXEC)

# Сборка исполняемого файла
$(EXEC): $(OBJ)
	$(CXX) $(OBJ) -o $(EXEC)

# Сборка объектных файлов
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Очистка
clean:
	rm -f $(OBJ) $(EXEC)
```

---

### 🏗️ Статическая библиотека (`.a`)

Добавим сборку `libmyLib.a`:

```make
STATIC_LIB = libmyLib.a
LIB_OBJ = myLib/myClass.o

static: $(STATIC_LIB)

$(STATIC_LIB): $(LIB_OBJ)
	ar rcs $(STATIC_LIB) $(LIB_OBJ)
```

Использование:

```make
$(EXEC): main.o $(STATIC_LIB)
	$(CXX) main.o -L. -lmyLib -o $(EXEC)
```

---

### 🧩 Динамическая библиотека (`.so`)

```make
SHARED_LIB = libmyLib.so

shared: $(SHARED_LIB)

$(SHARED_LIB): $(LIB_OBJ)
	$(CXX) -shared -fPIC -o $(SHARED_LIB) $(LIB_OBJ)
```

Использование:

```make
$(EXEC): main.o $(SHARED_LIB)
	$(CXX) main.o -L. -lmyLib -o $(EXEC) -Wl,-rpath=.
```

---

### ✅ В `main.cpp`:

```cpp
#include "myClass.h"

int main() {
    myClass obj;
    obj.hello();
    return 0;
}
```

---

### 💡 Команды:

* `make` — сборка по умолчанию.
* `make static` — сборка статической библиотеки.
* `make shared` — сборка динамической библиотеки.
* `make clean` — удалить `.o`, `.a`, `.so`, исполняемый файл.

Хочешь — могу сделать архив с примером проекта.

