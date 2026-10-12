# Тестовые задания: Указатели и ссылки в C/C++

## Теоретическая основа

### Указатели (Pointers)
**Указатель** - это переменная, которая хранит адрес другой переменной в памяти.

**Основные операции:**
- `&` - операция взятия адреса
- `*` - операция разыменования (получение значения по адресу)
- Объявление: `type* ptr` или `type *ptr`

**Пример:**
```cpp
int x = 42;
int* ptr = &x;  // ptr хранит адрес x
cout << *ptr;   // выведет 42
```

### Ссылки (References)
**Ссылка** - это псевдоним (alias) для уже существующей переменной.

**Особенности:**
- Должны быть инициализированы при объявлении
- Нельзя переназначить на другую переменную
- Не могут быть NULL
- Объявление: `type& ref = variable`

**Пример:**
```cpp
int x = 42;
int& ref = x;   // ref - это другое имя для x
ref = 100;      // x теперь равно 100
```

---

## ЗАДАНИЯ НАЧАЛЬНОГО И СРЕДНЕГО УРОВНЯ (1-10)

### Задание 1: Базовые операции с указателями
```cpp
int main() {
    int a = 10;
    int* p = &a;
    
    cout << "a = " << a << endl;
    cout << "p = " << p << endl;
    cout << "*p = " << *p << endl;
    cout << "&a = " << &a << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет данная программа? Объясните каждую строку вывода.

### Задание 2: Изменение значения через указатель
```cpp
void modify(int* ptr) {
    *ptr = 20;
}

int main() {
    int x = 10;
    modify(&x);
    cout << x << endl;
    return 0;
}
```
**Вопрос:** Что выведет программа и почему?

### Задание 3: Ссылки как параметры функции
```cpp
void swap(int& a, int& b) {
    int temp = a;
    a = b;
    b = temp;
}

int main() {
    int x = 5, y = 10;
    swap(x, y);
    cout << "x = " << x << ", y = " << y << endl;
    return 0;
}
```
**Вопрос:** Что выведет программа? Чем отличается передача по ссылке от передачи по значению?

### Задание 4: Указатель на указатель
```cpp
int main() {
    int x = 42;
    int* p = &x;
    int** pp = &p;
    
    cout << x << endl;
    cout << *p << endl;
    cout << **pp << endl;
    
    return 0;
}
```
**Вопрос:** Объясните, что происходит в каждой строке и что выведет программа.

### Задание 5: Массивы и указатели
```cpp
int main() {
    int arr[] = {1, 2, 3, 4, 5};
    int* ptr = arr;
    
    cout << *ptr << endl;
    cout << *(ptr + 2) << endl;
    cout << ptr[3] << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните связь между массивами и указателями.

### Задание 6: Константные указатели
```cpp
int main() {
    int x = 10, y = 20;
    
    const int* ptr1 = &x;      // указатель на константу
    int* const ptr2 = &x;      // константный указатель
    const int* const ptr3 = &x; // константный указатель на константу
    
    // Какие из следующих операций допустимы?
    // *ptr1 = 30;
    // ptr1 = &y;
    // *ptr2 = 30;
    // ptr2 = &y;
    // *ptr3 = 30;
    // ptr3 = &y;
    
    return 0;
}
```
**Вопрос:** Определите, какие операции допустимы для каждого типа указателя.

### Задание 7: Возвращение ссылки из функции
```cpp
int& getElement(int arr[], int index) {
    return arr[index];
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    
    getElement(numbers, 2) = 99;
    
    cout << numbers[2] << endl;
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните механизм возврата ссылки.

### Задание 8: Указатели на функции
```cpp
int add(int a, int b) { return a + b; }
int multiply(int a, int b) { return a * b; }

int main() {
    int (*operation)(int, int) = add;
    cout << operation(3, 4) << endl;
    
    operation = multiply;
    cout << operation(3, 4) << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните синтаксис указателей на функции.

### Задание 9: Динамическое выделение памяти
```cpp
int main() {
    int* ptr = new int(42);
    cout << *ptr << endl;
    
    int* arr = new int[5]{1, 2, 3, 4, 5};
    cout << arr[2] << endl;
    
    delete ptr;
    delete[] arr;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните разницу между `new`/`delete` и `new[]`/`delete[]`.

### Задание 10: Ссылки и указатели в классах
```cpp
class Point {
public:
    int x, y;
    Point(int x, int y) : x(x), y(y) {}
    
    Point& move(int dx, int dy) {
        x += dx;
        y += dy;
        return *this;
    }
};

int main() {
    Point p(1, 2);
    p.move(3, 4).move(1, 1);
    cout << p.x << ", " << p.y << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните паттерн method chaining.

---

## ЗАДАНИЯ ЭКСПЕРТНОГО УРОВНЯ (11-40)

### Задание 11: Указатели на члены класса
```cpp
class MyClass {
public:
    int value;
    void print() { cout << value << endl; }
};

int main() {
    MyClass obj;
    obj.value = 42;
    
    int MyClass::*ptr_member = &MyClass::value;
    void (MyClass::*ptr_method)() = &MyClass::print;
    
    obj.*ptr_member = 100;
    (obj.*ptr_method)();
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните синтаксис указателей на члены класса.

### Задание 12: Rvalue ссылки и move семантика
```cpp
class Resource {
public:
    int* data;
    
    Resource(int size) : data(new int[size]) { cout << "Constructor\n"; }
    ~Resource() { delete[] data; cout << "Destructor\n"; }
    
    Resource(const Resource& other) {
        data = new int[100];
        cout << "Copy constructor\n";
    }
    
    Resource(Resource&& other) noexcept {
        data = other.data;
        other.data = nullptr;
        cout << "Move constructor\n";
    }
};

Resource createResource() {
    return Resource(100);
}

int main() {
    Resource r1 = createResource();
    Resource r2 = std::move(r1);
    return 0;
}
```
**Вопрос:** Какие конструкторы будут вызваны и в каком порядке?

### Задание 13: Perfect forwarding
```cpp
template<typename T>
void wrapper(T&& arg) {
    func(std::forward<T>(arg));
}

void func(int& x) { cout << "lvalue reference\n"; }
void func(const int& x) { cout << "const lvalue reference\n"; }
void func(int&& x) { cout << "rvalue reference\n"; }

int main() {
    int x = 42;
    const int y = 42;
    
    wrapper(x);
    wrapper(y);
    wrapper(42);
    wrapper(std::move(x));
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните universal references и perfect forwarding.

### Задание 14: Указатели в наследовании
```cpp
class Base {
public:
    virtual void print() { cout << "Base\n"; }
    virtual ~Base() = default;
};

class Derived : public Base {
public:
    void print() override { cout << "Derived\n"; }
};

int main() {
    Base* ptr1 = new Derived();
    Derived* ptr2 = static_cast<Derived*>(ptr1);
    Base* ptr3 = dynamic_cast<Base*>(ptr2);
    
    ptr1->print();
    ptr2->print();
    ptr3->print();
    
    delete ptr1;
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните разницу между static_cast и dynamic_cast.

### Задание 15: Указатели на виртуальные функции
```cpp
class Base {
public:
    virtual void func() { cout << "Base::func\n"; }
};

class Derived : public Base {
public:
    void func() override { cout << "Derived::func\n"; }
};

int main() {
    Base* obj = new Derived();
    
    void (Base::*ptr)() = &Base::func;
    (obj->*ptr)();
    
    delete obj;
    return 0;
}
```
**Вопрос:** Что выведет программа? Как работают указатели на виртуальные функции?

### Задание 16: Проблема висячих ссылок
```cpp
int& createDanglingReference() {
    int local = 42;
    return local;  // Опасно!
}

string& getString() {
    return string("Hello");  // Опасно!
}

int main() {
    int& ref1 = createDanglingReference();
    string& ref2 = getString();
    
    cout << ref1 << endl;  // Undefined behavior
    cout << ref2 << endl;  // Undefined behavior
    
    return 0;
}
```
**Вопрос:** Объясните, почему этот код опасен и что может произойти при его выполнении.

### Задание 17: Указатели в шаблонах
```cpp
template<typename T>
class SmartPointer {
private:
    T* ptr;
    
public:
    SmartPointer(T* p) : ptr(p) {}
    ~SmartPointer() { delete ptr; }
    
    T& operator*() { return *ptr; }
    T* operator->() { return ptr; }
    
    SmartPointer(const SmartPointer&) = delete;
    SmartPointer& operator=(const SmartPointer&) = delete;
};

int main() {
    SmartPointer<int> sp(new int(42));
    cout << *sp << endl;
    
    SmartPointer<string> sp2(new string("Hello"));
    cout << sp2->length() << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните принцип работы RAII.

### Задание 18: Указатели и исключения
```cpp
class Resource {
public:
    Resource() { cout << "Resource created\n"; }
    ~Resource() { cout << "Resource destroyed\n"; }
};

void riskyFunction() {
    Resource* ptr = new Resource();
    throw std::runtime_error("Error occurred");
    delete ptr;  // Недостижимый код
}

int main() {
    try {
        riskyFunction();
    } catch (const std::exception& e) {
        cout << "Caught: " << e.what() << endl;
    }
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Какая проблема с управлением памятью?

### Задание 19: Указатели на массивы
```cpp
int main() {
    int arr[3][4] = {{1,2,3,4}, {5,6,7,8}, {9,10,11,12}};
    
    int (*ptr)[4] = arr;
    
    cout << ptr[1][2] << endl;
    cout << (*(ptr + 1))[2] << endl;
    cout << *(*(ptr + 1) + 2) << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните различные способы доступа к элементам.

### Задание 20: Указатели и const correctness
```cpp
class String {
private:
    char* data;
    size_t length;
    
public:
    String(const char* str) {
        length = strlen(str);
        data = new char[length + 1];
        strcpy(data, str);
    }
    
    ~String() { delete[] data; }
    
    char& operator[](size_t index) { return data[index]; }
    const char& operator[](size_t index) const { return data[index]; }
    
    const char* c_str() const { return data; }
};

int main() {
    String s("Hello");
    const String cs("World");
    
    s[0] = 'h';
    // cs[0] = 'w';  // Ошибка компиляции
    
    cout << s.c_str() << endl;
    cout << cs.c_str() << endl;
    
    return 0;
}
```
**Вопрос:** Объясните const correctness и почему закомментированная строка вызовет ошибку.

### Задание 21: Указатели и выравнивание памяти
```cpp
struct Aligned {
    char c;
    int i;
    char c2;
    double d;
};

int main() {
    Aligned obj;
    
    cout << "Size: " << sizeof(Aligned) << endl;
    cout << "Offset of c: " << offsetof(Aligned, c) << endl;
    cout << "Offset of i: " << offsetof(Aligned, i) << endl;
    cout << "Offset of c2: " << offsetof(Aligned, c2) << endl;
    cout << "Offset of d: " << offsetof(Aligned, d) << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните концепцию выравнивания памяти.

### Задание 22: Указатели на функции-члены и std::function
```cpp
class Calculator {
public:
    int add(int a, int b) { return a + b; }
    int multiply(int a, int b) { return a * b; }
};

int main() {
    Calculator calc;
    
    int (Calculator::*ptr)(int, int) = &Calculator::add;
    cout << (calc.*ptr)(3, 4) << endl;
    
    std::function<int(int, int)> func = std::bind(&Calculator::multiply, calc, std::placeholders::_1, std::placeholders::_2);
    cout << func(3, 4) << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните разницу между указателями на функции-члены и std::function.

### Задание 23: Указатели и множественное наследование
```cpp
class A {
public:
    int a;
    A() : a(1) {}
    virtual void printA() { cout << "A: " << a << endl; }
};

class B {
public:
    int b;
    B() : b(2) {}
    virtual void printB() { cout << "B: " << b << endl; }
};

class C : public A, public B {
public:
    int c;
    C() : c(3) {}
    void printC() { cout << "C: " << c << endl; }
};

int main() {
    C obj;
    
    A* ptrA = &obj;
    B* ptrB = &obj;
    C* ptrC = &obj;
    
    cout << "A ptr: " << ptrA << endl;
    cout << "B ptr: " << ptrB << endl;
    cout << "C ptr: " << ptrC << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Почему адреса могут отличаться?

### Задание 24: Указатели и виртуальное наследование
```cpp
class Base {
public:
    int base_value;
    Base() : base_value(42) {}
};

class Left : virtual public Base {
public:
    int left_value;
    Left() : left_value(1) {}
};

class Right : virtual public Base {
public:
    int right_value;
    Right() : right_value(2) {}
};

class Derived : public Left, public Right {
public:
    int derived_value;
    Derived() : derived_value(3) {}
};

int main() {
    Derived obj;
    Base* ptr = &obj;
    
    cout << ptr->base_value << endl;
    cout << sizeof(Derived) << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните виртуальное наследование.

### Задание 25: Указатели и метафункции
```cpp
template<typename T>
struct is_pointer {
    static const bool value = false;
};

template<typename T>
struct is_pointer<T*> {
    static const bool value = true;
};

template<typename T>
struct remove_pointer {
    using type = T;
};

template<typename T>
struct remove_pointer<T*> {
    using type = T;
};

int main() {
    cout << is_pointer<int>::value << endl;
    cout << is_pointer<int*>::value << endl;
    cout << is_pointer<int**>::value << endl;
    
    remove_pointer<int*>::type x = 42;
    cout << x << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните template specialization.

### Задание 26: Указатели и placement new
```cpp
class MyClass {
public:
    int value;
    MyClass(int v) : value(v) { cout << "Constructor: " << value << endl; }
    ~MyClass() { cout << "Destructor: " << value << endl; }
};

int main() {
    char buffer[sizeof(MyClass)];
    
    MyClass* ptr = new(buffer) MyClass(42);
    cout << ptr->value << endl;
    
    ptr->~MyClass();  // Явный вызов деструктора
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните placement new.

### Задание 27: Указатели и thread safety
```cpp
class Counter {
private:
    int* count;
    mutable std::mutex mtx;
    
public:
    Counter() : count(new int(0)) {}
    ~Counter() { delete count; }
    
    void increment() {
        std::lock_guard<std::mutex> lock(mtx);
        (*count)++;
    }
    
    int getValue() const {
        std::lock_guard<std::mutex> lock(mtx);
        return *count;
    }
};

int main() {
    Counter counter;
    
    std::thread t1([&counter]() {
        for(int i = 0; i < 1000; ++i) {
            counter.increment();
        }
    });
    
    std::thread t2([&counter]() {
        for(int i = 0; i < 1000; ++i) {
            counter.increment();
        }
    });
    
    t1.join();
    t2.join();
    
    cout << counter.getValue() << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните thread safety.

### Задание 28: Указатели и SFINAE
```cpp
template<typename T>
auto hasSize(T* t) -> decltype(t->size(), std::true_type{});

std::false_type hasSize(...);

template<typename T>
void printSize(T& obj) {
    if constexpr (decltype(hasSize(&obj))::value) {
        cout << "Size: " << obj.size() << endl;
    } else {
        cout << "No size method" << endl;
    }
}

int main() {
    std::vector<int> vec{1, 2, 3};
    int x = 42;
    
    printSize(vec);
    printSize(x);
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните SFINAE.

### Задание 29: Указатели и lambda
```cpp
int main() {
    int x = 10;
    
    auto lambda1 = [&x]() { x++; };
    auto lambda2 = [x]() mutable { x++; };
    
    lambda1();
    lambda2();
    
    cout << x << endl;
    
    auto lambda3 = [](int* ptr) { (*ptr)++; };
    lambda3(&x);
    
    cout << x << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните capture modes в lambda.

### Задание 30: Указатели и type erasure
```cpp
class Any {
private:
    struct Base {
        virtual ~Base() = default;
        virtual Base* clone() const = 0;
    };
    
    template<typename T>
    struct Derived : Base {
        T value;
        Derived(T v) : value(v) {}
        Base* clone() const override { return new Derived(value); }
    };
    
    Base* ptr;
    
public:
    template<typename T>
    Any(T value) : ptr(new Derived<T>(value)) {}
    
    Any(const Any& other) : ptr(other.ptr->clone()) {}
    
    ~Any() { delete ptr; }
    
    template<typename T>
    T& get() {
        return static_cast<Derived<T>*>(ptr)->value;
    }
};

int main() {
    Any a(42);
    Any b(std::string("Hello"));
    
    cout << a.get<int>() << endl;
    cout << b.get<std::string>() << endl;
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните паттерн type erasure.

### Задание 31: Указатели и memory ordering
```cpp
std::atomic<int*> ptr{nullptr};
std::atomic<bool> ready{false};

void producer() {
    int* data = new int(42);
    ptr.store(data, std::memory_order_release);
    ready.store(true, std::memory_order_release);
}

void consumer() {
    while (!ready.load(std::memory_order_acquire)) {
        std::this_thread::yield();
    }
    
    int* data = ptr.load(std::memory_order_acquire);
    cout << *data << endl;
    delete data;
}

int main() {
    std::thread t1(producer);
    std::thread t2(consumer);
    
    t1.join();
    t2.join();
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните memory ordering.

### Задание 32: Указатели и alignment
```cpp
struct alignas(64) CacheLineAligned {
    int data[16];
};

int main() {
    CacheLineAligned* ptr = new CacheLineAligned;
    
    cout << "Address: " << ptr << endl;
    cout << "Alignment: " << alignof(CacheLineAligned) << endl;
    cout << "Size: " << sizeof(CacheLineAligned) << endl;
    
    // Проверка выравнивания
    cout << "Aligned: " << (reinterpret_cast<uintptr_t>(ptr) % 64 == 0) << endl;
    
    delete ptr;
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните alignas и alignof.

### Задание 33: Указатели и custom allocators
```cpp
template<typename T>
class PoolAllocator {
private:
    static std::vector<T> pool;
    static std::stack<T*> free_list;
    
public:
    static T* allocate() {
        if (free_list.empty()) {
            pool.emplace_back();
            return &pool.back();
        }
        
        T* ptr = free_list.top();
        free_list.pop();
        return ptr;
    }
    
    static void deallocate(T* ptr) {
        free_list.push(ptr);
    }
};

template<typename T>
std::vector<T> PoolAllocator<T>::pool;

template<typename T>
std::stack<T*> PoolAllocator<T>::free_list;

int main() {
    int* ptr1 = PoolAllocator<int>::allocate();
    int* ptr2 = PoolAllocator<int>::allocate();
    
    *ptr1 = 42;
    *ptr2 = 24;
    
    cout << *ptr1 << " " << *ptr2 << endl;
    
    PoolAllocator<int>::deallocate(ptr1);
    PoolAllocator<int>::deallocate(ptr2);
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните custom allocators.

### Задание 34: Указатели и coroutines
```cpp
#include <coroutine>

struct Generator {
    struct promise_type {
        int value;
        
        std::suspend_always initial_suspend() { return {}; }
        std::suspend_always final_suspend() noexcept { return {}; }
        std::suspend_always yield_value(int val) {
            value = val;
            return {};
        }
        Generator get_return_object() {
            return Generator{std::coroutine_handle<promise_type>::from_promise(*this)};
        }
        void unhandled_exception() {}
    };
    
    std::coroutine_handle<promise_type> coro;
    
    Generator(std::coroutine_handle<promise_type> h) : coro(h) {}
    ~Generator() { if (coro) coro.destroy(); }
    
    bool next() {
        coro.resume();
        return !coro.done();
    }
    
    int value() {
        return coro.promise().value;
    }
};

Generator counter() {
    for (int i = 0; i < 3; ++i) {
        co_yield i;
    }
}

int main() {
    auto gen = counter();
    
    while (gen.next()) {
        cout << gen.value() << " ";
    }
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните coroutines.

### Задание 35: Указатели и reflection
```cpp
template<typename T>
class TypeInfo {
public:
    static const char* name() {
        return typeid(T).name();
    }
    
    static bool isPointer() {
        return std::is_pointer_v<T>;
    }
    
    static bool isReference() {
        return std::is_reference_v<T>;
    }
};

template<typename T>
void analyzeType(T&& value) {
    cout << "Type: " << TypeInfo<T>::name() << endl;
    cout << "Is pointer: " << TypeInfo<T>::isPointer() << endl;
    cout << "Is reference: " << TypeInfo<T>::isReference() << endl;
    cout << "Is rvalue reference: " << std::is_rvalue_reference_v<T> << endl;
    cout << "---" << endl;
}

int main() {
    int x = 42;
    int* ptr = &x;
    
    analyzeType(x);
    analyzeType(ptr);
    analyzeType(std::move(x));
    
    return 0;
}
```
**Вопрос:** Что выведет программа? Объясните type traits.

### Задание 36: Указатели и weak references
```cpp
class Node {
public:
    std::shared_ptr<Node> next;
    std::weak_ptr<Node> parent;
    int value;
    
    Node(int v) : value(v) {}
    ~Node() { cout << "Node " << value << " destroyed" << endl; }
};

int main() {
    auto root = std::make_shared<Node>(1);
    auto child = std::make_shared<Node>(2);
    
    root->next = child;
    child->parent = root;
    
    cout << "Root use count
    