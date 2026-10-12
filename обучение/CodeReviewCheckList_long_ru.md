# Code Review Long Check list

## Prompt
_В таком же формате подготовь развернутый чек лист для  Code Review._

### **Развернутый Checklist для Code Review на C++**

Этот чеклист охватывает ключевые аспекты Code Review с примерами "до" и "после" для каждого пункта.  

---

## **1. Читаемость и стиль кода**  
### **1.1. Именование переменных, функций и классов**  
- **Проблема:** Неочевидные имена усложняют понимание кода.  
- **Решение:** Использовать осмысленные имена в едином стиле (`camelCase`, `snake_case`).  

**До:**  
```cpp
int a;  
void f(int x) { ... }  
```  
**После:**  
```cpp
int connectionTimeoutMs;  
void sendMessage(const std::string& message) { ... }  
```  

### **1.2. Форматирование и отступы**
- **Проблема:** Несогласованные отступы и стиль скобок.  
- **Решение:** Следовать единому стилю (K&R, Allman, Google Style).  

**До:**  
```cpp
if (condition){
doSomething();}  
```  
**После:**  
```cpp
if (condition) {  
    doSomething();  
}  
```  

### **1.3. Комментарии и документация**
- **Проблема:** Избыточные или отсутствующие комментарии.  
- **Решение:** Комментировать сложную логику, избегать очевидного.  

**До:**  
```cpp
x = x + 1; // Увеличиваем x на 1  
```  
**После:**  
```cpp
// Корректировка индекса из-за смещения в API  
currentIndex = currentIndex + 1;  
```  

---

## **2. Безопасность и обработка ошибок**  
### **2.1. Проверка входных параметров**  
- **Проблема:** Отсутствие валидации входящих данных.  
- **Решение:** Проверка `nullptr`, диапазонов значений.  

**До:**  
```cpp
void print(int* data) {  
    std::cout << *data;  
}  
```  
**После:**  
```cpp
void print(const int* data) {  
    if (data == nullptr) {  
        throw std::invalid_argument("Data cannot be null");  
    }  
    std::cout << *data;  
}  
```  

### **2.2. Исключения vs. Коды ошибок**
- **Проблема:** Игнорирование ошибок или неявные сбои.  
- **Решение:** Использовать исключения для критичных ошибок.  

**До:**  
```cpp
bool divide(int a, int b, int& result) {  
    if (b == 0) return false;  
    result = a / b;  
    return true;  
}  
```  
**После:**  
```cpp
int divide(int a, int b) {  
    if (b == 0) {  
        throw std::runtime_error("Division by zero");  
    }  
    return a / b;  
}  
```  

### **2.3. `const`-корректность**
- **Проблема:** Изменяемые параметры, которые не должны меняться.  
- **Решение:** Использовать `const` для неизменяемых данных.  

**До:**  
```cpp
void process(std::string& text) { ... }  
```  
**После:**  
```cpp
void process(const std::string& text) { ... }  
```  

---

## **3. Управление памятью и ресурсами**  
### **3.1. Умные указатели вместо `new`/`delete`**  
- **Проблема:** Утечки памяти из-за ручного управления.  
- **Решение:** Использовать `unique_ptr`, `shared_ptr`.  

**До:**  
```cpp
void loadData() {  
    int* buffer = new int[100];  
    // ... забыли delete[]  
}  
```  
**После:**  
```cpp
void loadData() {  
    auto buffer = std::make_unique<int[]>(100);  
    // Память освободится автоматически  
}  
```  

### **3.2. RAII (Resource Acquisition Is Initialization)**
- **Проблема:** Незакрытые файлы, сокеты, мьютексы.  
- **Решение:** Использовать деструкторы для освобождения ресурсов.  

**До:**  
```cpp
void writeFile() {  
    FILE* file = fopen("data.txt", "w");  
    // ... если вылетит исключение - утечка  
    fclose(file);  
}  
```  
**После:**  
```cpp
class FileHandler {  
public:  
    FileHandler(const std::string& path) { file_ = fopen(path.c_str(), "w"); }  
    ~FileHandler() { if (file_) fclose(file_); }  
private:  
    FILE* file_;  
};  
```  

---

## **4. Производительность**  
### **4.1. Избегание лишних копий**  
- **Проблема:** Ненужное копирование больших объектов.  
- **Решение:** Передача по ссылке (`const&`), `std::move`.  

**До:**  
```cpp
std::vector<int> filter(const std::vector<int> data) {  
    std::vector<int> result;  
    // ... копирование data  
    return result;  
}  
```  
**После:**  
```cpp
std::vector<int> filter(const std::vector<int>& data) {  
    std::vector<int> result;  
    result.reserve(data.size());  
    // ... обработка без копирования  
    return result; // move-семантика  
}  
```  

### **4.2. Оптимизация работы с контейнерами**
- **Проблема:** Медленные вставки из-за реаллокаций.  
- **Решение:** `reserve()`, `emplace_back()`.  

**До:**  
```cpp
std::vector<std::string> names;  
for (int i = 0; i < 1000; ++i) {  
    names.push_back("Name_" + std::to_string(i)); // Реаллокации  
}  
```  
**После:**  
```cpp
std::vector<std::string> names;  
names.reserve(1000);  
for (int i = 0; i < 1000; ++i) {  
    names.emplace_back("Name_" + std::to_string(i)); // Без реаллокаций  
}  
```  

---

## **5. Многопоточность**  
### **5.1. Гонки данных (Race Conditions)**  
- **Проблема:** Несинхронизированный доступ к общим данным.  
- **Решение:** `std::mutex`, `std::atomic`.  

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

### **5.2. Deadlocks**
- **Проблема:** Взаимная блокировка при множественных `lock()`.  
- **Решение:** Использовать `std::lock()` или `std::scoped_lock`.  

**До:**  
```cpp
std::mutex m1, m2;  
// Поток 1: m1.lock(); m2.lock();  
// Поток 2: m2.lock(); m1.lock();  
```  
**После:**  
```cpp
std::mutex m1, m2;  
// Поток 1: std::scoped_lock lock(m1, m2);  
// Поток 2: std::scoped_lock lock(m1, m2);  
```  

---

## **6. Тестируемость и архитектура**  
### **6.1. Связность (Cohesion) и слабое зацепление (Low Coupling)**  
- **Проблема:** Монолитные функции, которые трудно тестировать.  
- **Решение:** Разделение логики на небольшие модули.  

**До:**  
```cpp
class Processor {  
public:  
    void process() {  
        loadData();  
        parseData();  
        saveToDB();  
    }  
};  
```  
**После:**  
```cpp
class DataLoader { ... };  
class DataParser { ... };  
class DatabaseWriter { ... };  

// Теперь можно тестировать каждый компонент отдельно  
```  

### **6.2. Dependency Injection**
- **Проблема:** Жесткие зависимости, усложняющие тестирование.  
- **Решение:** Внедрение зависимостей через интерфейсы.  

**До:**  
```cpp
class Logger {  
    void log() { std::cout << "Error!"; }  
};  
```  
**После:**  
```cpp
class ILogger {  
public:  
    virtual void log(const std::string&) = 0;  
};  

class ConsoleLogger : public ILogger { ... };  
class FileLogger : public ILogger { ... };  

// Теперь можно подменить логгер в тестах  
```  

---

### **Итоговый чеклист для Code Review**
| Категория            | Проверяемые аспекты                          |  
|----------------------|---------------------------------------------|  
| **Читаемость**       | Именование, форматирование, комментарии     |  
| **Безопасность**     | Валидация входных данных, `const`, исключения |  
| **Память/ресурсы**   | Умные указатели, RAII, отсутствие утечек    |  
| **Производительность** | Избегание копий, оптимизация контейнеров  |  
| **Многопоточность**  | Атомарные операции, мьютексы, deadlocks    |  
| **Тестируемость**    | Разделение логики, Dependency Injection    |  

Этот развернутый чеклист поможет проводить более детальный и качественный Code Review. 🚀

