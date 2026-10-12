# Code Review Short Check list

## Prompt
_Подготовь краткий check list для Code Review с примерами на С++ до и после код ревью._

### **Checklist для Code Review на C++**

#### **1. Читаемость и стиль**
- **Имена переменных/функций** – осмысленные, в camelCase или snake_case.  
- **Отступы и форматирование** – единообразие (фигурные скобки, пробелы).  
- **Комментарии** – объясняют сложную логику, но не очевидные вещи.  

**До:**  
```cpp
int a = 10; // Что это?
void f(int x) { cout<<x; }
```  
**После:**  
```cpp
int maxRetryAttempts = 10;
void printValue(int value) { 
    std::cout << value; 
}
```  

---  

#### **2. Обработка ошибок и исключения**
- **Проверка входных параметров** – валидация `nullptr`, некорректных значений.  
- **Использование исключений** – только для исключительных ситуаций.  

**До:**  
```cpp
void divide(int a, int b) {
    cout << a / b; // Упадет при b = 0
}
```  
**После:**  
```cpp
void divide(int a, int b) {
    if (b == 0) {
        throw std::invalid_argument("Division by zero");
    }
    std::cout << a / b;
}
```  

---  

#### **3. Утечки памяти и управление ресурсами**
- **Умные указатели** – `unique_ptr`, `shared_ptr` вместо `new`/`delete`.  
- **RAII** – ресурсы в конструкторе/деструкторе.  

**До:**  
```cpp
void loadData() {
    int* arr = new int[100];
    // ... забыли delete[]
}
```  
**После:**  
```cpp
void loadData() {
    auto arr = std::make_unique<int[]>(100);
    // Автоматическая очистка
}
```  

---  

#### **4. Производительность**
- **Избегание копирования** – передача по ссылке (`const&`), `std::move`.  
- **Резервирование памяти** – `reserve()` для `std::vector`.  

**До:**  
```cpp
std::vector<int> process(std::vector<int> data) { // Копирование
    return data; // Еще копирование
}
```  
**После:**  
```cpp
std::vector<int> process(const std::vector<int>& data) {
    std::vector<int> result;
    result.reserve(data.size());
    // ... обработка
    return result; // move-семантика
}
```  

---  

#### **5. Безопасность**
- **Переполнение буфера** – проверка границ (`std::vector.at()` вместо `[]`).  
- **const-корректность** – `const` методы, неизменяемые параметры.  

**До:**  
```cpp
char buffer[10];
strcpy(buffer, userInput); // Опасно!
```  
**После:**  
```cpp
std::string buffer;
buffer.resize(10);
std::copy_n(userInput, 10, buffer.begin());
```  

---  

#### **6. Многопоточность**
- **Гонки данных** – `std::mutex`, `std::atomic`.  
- **Deadlocks** – избегать вложенных блокировок.  

**До:**  
```cpp
int counter = 0;
// Поток 1: counter++;
// Поток 2: counter--;
```  
**После:**  
```cpp
std::atomic<int> counter = 0;
// Поток 1: counter.fetch_add(1);
// Поток 2: counter.fetch_sub(1);
```  

---  

#### **7. Тестируемость**
- **Связность (cohesion)** – функции делают одну вещь.  
- **Зависимости** – Dependency Injection, а не жесткие связи.  

**До:**  
```cpp
class Logger {
    void log() { 
        std::cout << "Error!"; // Жестко закодированный вывод
    }
};
```  
**После:**  
```cpp
class Logger {
public:
    Logger(std::ostream& output) : out(output) {}
    void log(const std::string& msg) { out << msg; }
private:
    std::ostream& out;
};
```  

---  

**Итог:**  
✅ Читаемость  
✅ Безопасность  
✅ Производительность  
✅ Отсутствие утечек  
✅ Многопоточность  
✅ Тестируемость  

Этот чеклист можно адаптировать под конкретный проект и код-стайл команды.
