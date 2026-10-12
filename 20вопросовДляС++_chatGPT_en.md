# 20 вопросов для С++ собеса от chatGPT

**prompt**

Prepare the most common C++ questions for a technical interview.
The questions should cover most of the language.
Include the basics of the language. Key points of the language.
Multithreading questions.
Specify the difficulty level for each question.
Provide brief answers to each. An example of how to use each.
The number of questions is 20.

--- 

Here are **20 common C++ interview questions** covering the basics, key concepts, and multithreading, with difficulty levels and brief answers.  

---

### **1. What are the basic data types in C++?**
📌 *Difficulty: Easy*  
✅ **Answer:** The fundamental data types in C++ are:  
- `int` (integer)  
- `float` (floating point)  
- `double` (double precision floating point)  
- `char` (character)  
- `bool` (boolean)  
- `void` (empty type)  
- `wchar_t` (wide character)  

📌 **Example:**  
```cpp
int a = 10;  
float b = 5.5;  
char c = 'A';  
bool isTrue = true;
```

---

### **2. What is the difference between `struct` and `class`?**
📌 *Difficulty: Easy*  
✅ **Answer:**  
- In `struct`, members are **public** by default.  
- In `class`, members are **private** by default.  
- Both can have member functions, constructors, and access specifiers.  

📌 **Example:**  
```cpp
struct A { int x; };  // x is public  
class B { int y; };   // y is private  
```

---

### **3. What is a reference in C++? How is it different from a pointer?**
📌 *Difficulty: Easy*  
✅ **Answer:**  
- A **reference** is an alias for another variable and must be initialized at declaration.  
- A **pointer** is a variable that holds the memory address of another variable.  

📌 **Example:**  
```cpp
int a = 10;  
int& ref = a;  // Reference  
int* ptr = &a; // Pointer  
```

---

### **4. What is function overloading?**
📌 *Difficulty: Easy*  
✅ **Answer:** Function overloading allows multiple functions with the same name but different parameters.  

📌 **Example:**  
```cpp
void print(int a) { cout << a; }  
void print(double a) { cout << a; }  
void print(string a) { cout << a; }
```

---

### **5. What is operator overloading?**
📌 *Difficulty: Medium*  
✅ **Answer:** Operator overloading allows defining how operators work with user-defined types.  

📌 **Example:**  
```cpp
class Complex {  
public:  
    int real, imag;  
    Complex operator+(const Complex& obj) {  
        return {real + obj.real, imag + obj.imag};  
    }  
};  
```

---

### **6. What are the four pillars of OOP in C++?**
📌 *Difficulty: Medium*  
✅ **Answer:**  
1. **Encapsulation** – Hiding implementation details.  
2. **Abstraction** – Showing only essential features.  
3. **Inheritance** – Code reusability through parent-child relationships.  
4. **Polymorphism** – The ability to take many forms (`function overloading` and `virtual functions`).  

📌 **Example:**  
```cpp
class Base { public: virtual void show() { cout << "Base"; } };  
class Derived : public Base { public: void show() override { cout << "Derived"; } };  
```

---

### **7. What is the difference between deep copy and shallow copy?**
📌 *Difficulty: Medium*  
✅ **Answer:**  
- **Shallow Copy:** Copies only the reference, not the actual data.  
- **Deep Copy:** Creates a new copy of the data.  

📌 **Example:**  
```cpp
class A {  
    int* ptr;  
public:  
    A(int val) { ptr = new int(val); }  
    A(const A& obj) { ptr = new int(*obj.ptr); } // Deep Copy  
};  
```

---

### **8. What is the Rule of Three in C++?**
📌 *Difficulty: Medium*  
✅ **Answer:** If a class manages dynamic memory, it should define:  
1. **Destructor** (`~ClassName()`)  
2. **Copy Constructor** (`ClassName(const ClassName&)`)  
3. **Copy Assignment Operator** (`operator=`)  

📌 **Example:**  
```cpp
class MyClass {  
    int* data;  
public:  
    ~MyClass() { delete data; }  
    MyClass(const MyClass& obj) { data = new int(*obj.data); }  
    MyClass& operator=(const MyClass& obj) { delete data; data = new int(*obj.data); return *this; }  
};  
```

---

### **9. What is a smart pointer?**
📌 *Difficulty: Medium*  
✅ **Answer:** A smart pointer is a C++ object that manages the lifetime of dynamically allocated objects.  
Types: `unique_ptr`, `shared_ptr`, `weak_ptr`.  

📌 **Example:**  
```cpp
#include <memory>  
std::unique_ptr<int> p = std::make_unique<int>(10);
```

---

### **10. What is an abstract class in C++?**
📌 *Difficulty: Medium*  
✅ **Answer:** A class that contains at least one pure virtual function.  

📌 **Example:**  
```cpp
class Abstract { public: virtual void show() = 0; };  
class Derived : public Abstract { public: void show() override { cout << "Derived"; } };  
```

---

### **11. What is a lambda function in C++?**
📌 *Difficulty: Medium*  
✅ **Answer:** An anonymous function that can capture variables.  

📌 **Example:**  
```cpp
auto add = [](int a, int b) { return a + b; };  
cout << add(5, 3);
```

---

### **12. What is the `volatile` keyword?**
📌 *Difficulty: Hard*  
✅ **Answer:** It prevents the compiler from optimizing a variable, ensuring it is read from memory each time.  

📌 **Example:**  
```cpp
volatile int flag = 0;
```

---

### **13. What is a race condition?**
📌 *Difficulty: Hard*  
✅ **Answer:** A situation where multiple threads access shared data simultaneously, leading to unpredictable results.  

📌 **Solution Example (Mutex):**  
```cpp
std::mutex mtx;  
void safeFunction() { std::lock_guard<std::mutex> lock(mtx); /* critical section */ }
```

---

### **14. What is deadlock in multithreading?**
📌 *Difficulty: Hard*  
✅ **Answer:** When two or more threads wait for each other indefinitely.  

📌 **Example:**  
```cpp
std::mutex m1, m2;  
void func1() { std::lock(m1, m2); }  
void func2() { std::lock(m2, m1); }  // Can cause deadlock
```

---

### **15. What is `std::async`?**
📌 *Difficulty: Hard*  
✅ **Answer:** Runs a function asynchronously in a separate thread.  

📌 **Example:**  
```cpp
std::future<int> result = std::async([] { return 42; });  
cout << result.get();
```

---

### **16. What is move semantics?**
📌 *Difficulty: Hard*  
✅ **Answer:** Transfers ownership of resources instead of copying.  

📌 **Example:**  
```cpp
class A {  
    int* data;  
public:  
    A(A&& obj) noexcept : data(obj.data) { obj.data = nullptr; }  
};
```

---

### **17. What is `std::condition_variable`?**
📌 *Difficulty: Hard*  
✅ **Answer:** Used for thread synchronization.  

📌 **Example:**  
```cpp
std::condition_variable cv;  
std::mutex mtx;  
bool ready = false;  
cv.wait(std::unique_lock<std::mutex>(mtx), [] { return ready; });
```

---

### **18. What is `constexpr`?**
📌 *Difficulty: Hard*  
✅ **Answer:** Used to compute values at compile time.  

📌 **Example:**  
```cpp
constexpr int square(int x) { return x * x; }
```

---

### **19. What is the difference between `new` and `malloc`?**
📌 *Difficulty: Medium*  
✅ **Answer:**  
- `new` calls constructor, `malloc` does not.  
- `new` returns typed pointer, `malloc` returns `void*`.  

📌 **Example:**  
```cpp
int* p1 = new int(10);  
int* p2 = (int*)malloc(sizeof(int));
```

---

### **20. What is `std::thread::join()` vs. `std::thread::detach()`?**
📌 *Difficulty: Hard*  
✅ **Answer:**  
- `join()`: Waits for the thread to finish.  
- `detach()`: Runs thread independently.  

📌 **Example:**  
```cpp
std::thread t([] { cout << "Hello"; });  
t.join();  
```

---

Would you like more questions on a specific topic? 🚀