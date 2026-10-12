# 20 вопросов для С++ собеса от DeepSeek

**prompt**

Prepare the most common C++ questions for a technical interview.
The questions should cover most of the language.
Include the basics of the language. Key points of the language.
Multithreading questions.
Specify the difficulty level for each question.
Provide brief answers to each. An example of how to use each.
The number of questions is 20.

---

Here’s a curated list of 20 common C++ interview questions, covering the basics, key points, and multithreading concepts. Each question includes a difficulty level, a brief answer, and an example where applicable.

---

### **Basics of C++**
1. **What is the difference between `struct` and `class` in C++?**  
   - **Difficulty**: Easy  
   - **Answer**: The default access specifier for `struct` is `public`, while for `class` it is `private`. Otherwise, they are functionally similar.  
   - **Example**:  
     ```cpp
     struct MyStruct { int x; }; // x is public by default
     class MyClass { int x; };   // x is private by default
     ```

2. **What is the difference between `new` and `malloc()`?**  
   - **Difficulty**: Easy  
   - **Answer**: `new` is an operator that calls the constructor and returns a typed pointer, while `malloc()` is a function that allocates raw memory and returns a `void*`. `new` also throws an exception on failure, whereas `malloc()` returns `NULL`.  
   - **Example**:  
     ```cpp
     int* p = new int(10); // allocates and initializes memory
     int* q = (int*)malloc(sizeof(int)); // allocates raw memory
     ```

3. **What is the `const` keyword used for?**  
   - **Difficulty**: Easy  
   - **Answer**: `const` is used to define constants or to indicate that a function does not modify the state of an object.  
   - **Example**:  
     ```cpp
     const int x = 10; // x cannot be modified
     void print() const { /* this function does not modify the object */ }
     ```

4. **What is the difference between `pass by value` and `pass by reference`?**  
   - **Difficulty**: Easy  
   - **Answer**: Pass by value creates a copy of the argument, while pass by reference uses the original variable.  
   - **Example**:  
     ```cpp
     void byValue(int x) { x = 10; } // x is a copy
     void byRef(int& x) { x = 10; }  // x is the original variable
     ```

5. **What is a `namespace` in C++?**  
   - **Difficulty**: Easy  
   - **Answer**: A `namespace` is used to group related entities and avoid name collisions.  
   - **Example**:  
     ```cpp
     namespace MyNamespace { int x = 10; }
     int x = 20; // No conflict
     ```

---

### **Key Points of C++**
6. **What is the Rule of Three/Five/Zero?**  
   - **Difficulty**: Medium  
   - **Answer**: The Rule of Three states that if a class defines a destructor, copy constructor, or copy assignment operator, it should define all three. The Rule of Five adds move constructor and move assignment operator. The Rule of Zero suggests using smart pointers and standard library types to avoid manual resource management.  
   - **Example**:  
     ```cpp
     class MyClass {
     public:
         MyClass() { /* constructor */ }
         ~MyClass() { /* destructor */ }
         MyClass(const MyClass& other) { /* copy constructor */ }
         MyClass& operator=(const MyClass& other) { /* copy assignment */ }
     };
     ```

7. **What is RAII (Resource Acquisition Is Initialization)?**  
   - **Difficulty**: Medium  
   - **Answer**: RAII is a programming idiom where resource management is tied to object lifetime. Resources are acquired during object construction and released during destruction.  
   - **Example**:  
     ```cpp
     class File {
     public:
         File(const std::string& filename) { /* open file */ }
         ~File() { /* close file */ }
     };
     ```

8. **What is a `virtual` function?**  
   - **Difficulty**: Medium  
   - **Answer**: A `virtual` function allows a derived class to override the base class implementation. It enables runtime polymorphism.  
   - **Example**:  
     ```cpp
     class Base {
     public:
         virtual void print() { std::cout << "Base"; }
     };
     class Derived : public Base {
     public:
         void print() override { std::cout << "Derived"; }
     };
     ```

9. **What is the difference between `override` and `final`?**  
   - **Difficulty**: Medium  
   - **Answer**: `override` ensures that a function is overriding a virtual function in the base class. `final` prevents further overriding in derived classes.  
   - **Example**:  
     ```cpp
     class Base {
     public:
         virtual void print() { std::cout << "Base"; }
     };
     class Derived : public Base {
     public:
         void print() override final { std::cout << "Derived"; }
     };
     ```

10. **What is a `lambda` function?**  
    - **Difficulty**: Medium  
    - **Answer**: A lambda is an anonymous function that can capture variables from its surrounding scope.  
    - **Example**:  
      ```cpp
      auto lambda = [](int x) { return x * 2; };
      std::cout << lambda(5); // Output: 10
      ```

---

### **Advanced C++**
11. **What is a `smart pointer`?**  
    - **Difficulty**: Medium  
    - **Answer**: Smart pointers (`unique_ptr`, `shared_ptr`, `weak_ptr`) automatically manage memory and prevent memory leaks.  
    - **Example**:  
      ```cpp
      std::unique_ptr<int> ptr = std::make_unique<int>(10);
      ```

12. **What is the difference between `std::unique_ptr` and `std::shared_ptr`?**  
    - **Difficulty**: Medium  
    - **Answer**: `std::unique_ptr` enforces single ownership, while `std::shared_ptr` allows multiple owners through reference counting.  
    - **Example**:  
      ```cpp
      std::unique_ptr<int> uPtr = std::make_unique<int>(10);
      std::shared_ptr<int> sPtr = std::make_shared<int>(20);
      ```

13. **What is `std::move` and when is it used?**  
    - **Difficulty**: Medium  
    - **Answer**: `std::move` casts an object to an rvalue reference, enabling move semantics. It is used to transfer ownership of resources.  
    - **Example**:  
      ```cpp
      std::string str1 = "Hello";
      std::string str2 = std::move(str1); // str1 is now empty
      ```

14. **What is `std::forward` and when is it used?**  
    - **Difficulty**: Hard  
    - **Answer**: `std::forward` is used in perfect forwarding to preserve the value category (lvalue/rvalue) of a function argument.  
    - **Example**:  
      ```cpp
      template<typename T>
      void wrapper(T&& arg) {
          func(std::forward<T>(arg));
      }
      ```

15. **What is a `template` in C++?**  
    - **Difficulty**: Medium  
    - **Answer**: A template allows writing generic code that works with any data type.  
    - **Example**:  
      ```cpp
      template<typename T>
      T add(T a, T b) { return a + b; }
      ```

---

### **Multithreading**
16. **What is a `thread` in C++?**  
    - **Difficulty**: Medium  
    - **Answer**: A `thread` is a sequence of instructions that can be executed concurrently.  
    - **Example**:  
      ```cpp
      #include <thread>
      void task() { std::cout << "Hello from thread!"; }
      std::thread t(task);
      t.join();
      ```

17. **What is a `mutex` and why is it used?**  
    - **Difficulty**: Medium  
    - **Answer**: A `mutex` is used to synchronize access to shared resources between threads to prevent race conditions.  
    - **Example**:  
      ```cpp
      std::mutex mtx;
      mtx.lock();
      // Critical section
      mtx.unlock();
      ```

18. **What is a `deadlock` and how can it be avoided?**  
    - **Difficulty**: Hard  
    - **Answer**: A deadlock occurs when two or more threads are waiting for each other to release resources. It can be avoided by locking mutexes in a consistent order or using `std::lock`.  
    - **Example**:  
      ```cpp
      std::mutex mtx1, mtx2;
      std::lock(mtx1, mtx2); // Avoids deadlock
      ```

19. **What is `std::async`?**  
    - **Difficulty**: Medium  
    - **Answer**: `std::async` is used to run a function asynchronously and returns a `std::future` to hold the result.  
    - **Example**:  
      ```cpp
      auto future = std::async([]() { return 42; });
      std::cout << future.get(); // Output: 42
      ```

20. **What is a `condition variable`?**  
    - **Difficulty**: Hard  
    - **Answer**: A `condition variable` is used to block a thread until a condition is met. It is often used with a mutex.  
    - **Example**:  
      ```cpp
      std::condition_variable cv;
      std::mutex mtx;
      bool ready = false;
      std::unique_lock<std::mutex> lock(mtx);
      cv.wait(lock, []() { return ready; });
      ```

---

This list covers a broad range of C++ topics, from basics to advanced concepts, and includes multithreading, which is critical for modern C++ development.
