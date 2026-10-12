# NRVO and RAII

## Prompt
_расскажи что такое NRVO. и что такое RAII - просто и точно._

### NRVO (Named Return Value Optimization)

**NRVO** (Named Return Value Optimization) — это оптимизация, которую компилятор может применить для избежания лишнего копирования объектов при возврате их из функции. Если функция возвращает локальный объект по значению, компилятор может создать этот объект непосредственно в месте вызова функции, избегая копирования.

#### Пример:
```cpp
#include <iostream>

class MyClass {
public:
    MyClass() { std::cout << "Constructor" << std::endl; }
    MyClass(const MyClass&) { std::cout << "Copy Constructor" << std::endl; }
};

MyClass createObject() {
    MyClass obj; // Локальный объект
    return obj;  // NRVO может избежать копирования
}

int main() {
    MyClass obj = createObject();
    return 0;
}
```
В этом примере, благодаря NRVO, конструктор копирования может не вызываться, так как объект `obj` создается непосредственно в месте вызова функции `createObject`.

---

### RAII (Resource Acquisition Is Initialization)

**RAII** (Resource Acquisition Is Initialization) — это идиома программирования на C++, при которой управление ресурсами (память, файлы, сокеты и т.д.) связывается с временем жизни объектов. Ресурс приобретается в конструкторе объекта и освобождается в деструкторе. Это гарантирует, что ресурсы будут освобождены автоматически, когда объект выйдет из области видимости.

#### Пример:
```cpp
#include <iostream>
#include <memory>

class FileHandler {
public:
    FileHandler(const std::string& filename) {
        file = fopen(filename.c_str(), "r");
        if (!file) {
            throw std::runtime_error("Cannot open file");
        }
        std::cout << "File opened" << std::endl;
    }

    ~FileHandler() {
        if (file) {
            fclose(file);
            std::cout << "File closed" << std::endl;
        }
    }

    void readFile() {
        // Чтение файла
    }

private:
    FILE* file;
};

int main() {
    try {
        FileHandler handler("example.txt");
        handler.readFile();
    } catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
    }
    return 0;
}
```
В этом примере файл автоматически закрывается при выходе из области видимости объекта `handler`, благодаря вызову деструктора. Это гарантирует, что ресурсы будут освобождены даже в случае возникновения исключений.

### Итог
- **NRVO** — это оптимизация компилятора для избежания лишнего копирования объектов при возврате их из функции.
- **RAII** — это идиома программирования, которая связывает управление ресурсами с временем жизни объектов, обеспечивая автоматическое освобождение ресурсов.
