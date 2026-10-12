# Advanced C++ Questions

---

### **1. What is the difference between `inline` and `constexpr`?**
- **Answer:**  
  - `inline`: Suggests to the compiler to replace the function call with its code to reduce overhead.  
  - `constexpr`: Ensures the function or variable is evaluated at compile time.  

- **Extended Answer:**  
  Both keywords optimize performance but serve different purposes. `inline` reduces function call overhead, while `constexpr` ensures a value or function is resolved at compile time for efficiency and correctness in contexts requiring constant expressions.  

- **Short Example:**  
  ```cpp
  inline int square_inline(int x) { return x * x; }
  constexpr int square_constexpr(int x) { return x * x; }

  constexpr int compile_time = square_constexpr(5); // Evaluated at compile time
  int runtime = square_inline(5);                  // Evaluated at runtime
  ```

---

### **2. What are the key differences between `std::unique_ptr` and `std::shared_ptr`?**
- **Answer:**  
  - `std::unique_ptr`: Exclusive ownership of a resource.  
  - `std::shared_ptr`: Shared ownership of a resource.  

- **Extended Answer:**  
  `std::unique_ptr` is lightweight, and only one pointer can own the resource. Ownership can be transferred using `std::move`. `std::shared_ptr` allows multiple pointers to share ownership, and the resource is destroyed only when the last owner releases it.  

- **Short Example:**  
  ```cpp
  std::unique_ptr<int> uniquePtr = std::make_unique<int>(42); // Exclusive ownership
  std::shared_ptr<int> sharedPtr1 = std::make_shared<int>(42);
  std::shared_ptr<int> sharedPtr2 = sharedPtr1;               // Shared ownership
  ```

---

### **3. How does `std::move` work, and when should it be used?**
- **Answer:**  
  `std::move` is used to enable move semantics by casting an object to an rvalue reference.  

- **Extended Answer:**  
  It is used when transferring ownership of resources is preferred over copying to improve performance. For instance, moving large containers avoids deep copies.  

- **Short Example:**  
  ```cpp
  std::vector<int> v1 = {1, 2, 3};
  std::vector<int> v2 = std::move(v1); // v1 is now empty
  ```

---

### **4. What is the purpose of the `noexcept` keyword?**
- **Answer:**  
  Declares that a function does not throw exceptions.  

- **Extended Answer:**  
  `noexcept` helps the compiler optimize code by avoiding exception-handling overhead in certain contexts. Functions marked `noexcept` that throw an exception will call `std::terminate`.  

- **Short Example:**  
  ```cpp
  void func() noexcept {
      // Guaranteed not to throw
  }
  ```

---

### **5. What are variadic templates, and how are they used?**
- **Answer:**  
  Variadic templates allow a template to accept a variable number of arguments.  

- **Extended Answer:**  
  Variadic templates are used for scenarios like logging, serialization, or creating type-safe containers. `sizeof...(Args)` can determine the number of template arguments. Recursive unpacking or fold expressions are often used to process arguments.  

- **Short Example:**  
  ```cpp
  template<typename... Args>
  void print(Args... args) {
      (std::cout << ... << args) << '\n'; // Fold expression
  }
  print(1, "Hello", 3.14);
  ```

---

### **6. How does `std::enable_if` work, and when is it useful?**
- **Answer:**  
  `std::enable_if` conditionally enables a template specialization based on a compile-time condition.  

- **Extended Answer:**  
  It is often used in template metaprogramming to constrain templates, enabling certain overloads or instantiations only when a specific condition is met.  

- **Short Example:**  
  ```cpp
  template<typename T>
  typename std::enable_if<std::is_integral<T>::value>::type
  print(T value) {
      std::cout << "Integral: " << value << '\n';
  }
  print(42); // Works
  // print(3.14); // Compilation error
  ```

---

### **7. What are explicit constructors, and why are they needed?**
- **Answer:**  
  Explicit constructors prevent implicit type conversions.  

- **Extended Answer:**  
  By marking a constructor `explicit`, you avoid unintentional conversions that might lead to bugs or unexpected behavior in the code.  

- **Short Example:**  
  ```cpp
  class A {
  public:
      explicit A(int x) {}
  };
  A obj1(42);   // Works
  // A obj2 = 42; // Error due to explicit
  ```

---

### **8. What is the difference between `decltype` and `auto`?**
- **Answer:**  
  - `auto`: Deduces type based on initializer.  
  - `decltype`: Extracts the type from an expression.  

- **Extended Answer:**  
  Use `decltype` when you need to refer to the type of a variable or expression without initializing it. `auto` requires an initializer to deduce the type.  

- **Short Example:**  
  ```cpp
  int x = 5;
  decltype(x) y = 10; // y is int
  auto z = 15;        // z is int
  ```

---

### **9. How does the `override` keyword improve code reliability?**
- **Answer:**  
  Ensures a function is overriding a base class's virtual function.  

- **Extended Answer:**  
  Without `override`, a typo in a derived class function name would create a new function rather than overriding the base class function. Using `override` forces the compiler to check for an existing base class function signature.  

- **Short Example:**  
  ```cpp
  class Base {
      virtual void func();
  };
  class Derived : public Base {
      void func() override; // Enforced override
  };
  ```

---

### **10. What is the difference between `std::map` and `std::unordered_map`?**
- **Answer:**  
  - `std::map`: Ordered, implemented as a balanced tree (O(log n)).  
  - `std::unordered_map`: Unordered, implemented as a hash table (O(1) average).  

- **Extended Answer:**  
  Use `std::map` when order is important or when frequently iterating in sorted order. Use `std::unordered_map` for faster lookups when order does not matter.  

- **Short Example:**  
  ```cpp
  std::map<int, std::string> ordered;
  std::unordered_map<int, std::string> unordered;
  ```

---

### **11. What is the difference between lvalue, rvalue, and xvalue in C++?**
- **Answer:**  
  - **lvalue**: Objects with a persistent address (e.g., variables).  
  - **rvalue**: Temporary objects without a persistent address (e.g., literals).  
  - **xvalue**: Expiring values (e.g., returned by `std::move`).  

- **Extended Answer:**  
  - **lvalue**: Can appear on the left-hand side of an assignment.  
  - **rvalue**: Typically exists for the duration of the expression.  
  - **xvalue**: A special case of rvalue used for move semantics.  

- **Short Example:**  
  ```cpp
  int x = 10;       // x is an lvalue
  int y = x + 5;    // (x + 5) is an rvalue
  int&& z = std::move(x); // z is an xvalue
  ```

---

### **12. What is the difference between `virtual` inheritance and regular inheritance?**
- **Answer:**  
  `virtual` inheritance prevents multiple copies of a base class in a derived class.  

- **Extended Answer:**  
  When using multiple inheritance, `virtual` ensures a single instance of the shared base class is created to avoid ambiguity or redundancy.  

- **Short Example:**  
  ```cpp
  class A {};
  class B : virtual public A {};
  class C : virtual public A {};
  class D : public B, public C {}; // Only one instance of A in D
  ```

---

### **13. What is a lambda capture, and what are the different types?**
- **Answer:**  
  A lambda capture allows a lambda function to access variables from its enclosing scope.  

- **Extended Answer:**  
  - `=`: Captures all variables by value.  
  - `&`: Captures all variables by reference.  
  - `[x]`: Captures `x` by value.  
  - `[&x]`: Captures `x` by reference.  
  - `[=, &x]`: Captures all variables by value except `x` by reference.  

- **Short Example:**  
  ```cpp
  int a = 5, b = 10;
  auto lambda = [=, &b]() { return a + b++; };
  ```

---

### **14. How does `std::atomic` ensure thread safety?**
- **Answer:**  
  `std::atomic` provides operations that are atomic, meaning they are completed without interruption.  

- **Extended Answer:**  
  It ensures safe concurrent access to variables by providing lock-free and hardware-supported atomic operations.  

- **Short Example:**  
  ```cpp
  std::atomic<int> counter = 0;
  counter.fetch_add(1); // Thread-safe increment
  ```

---

### **15. How does `std::function` differ from a regular function pointer?**
- **Answer:**  
  `std::function` can hold any callable object (lambdas, functors, or function pointers).  

- **Extended Answer:**  
  It is more flexible than function pointers and allows dynamic allocation of callable objects at runtime.  

- **Short Example:**  
  ```cpp
  std::function<int(int, int)> add = [](int a, int b) { return a + b; };
  std::cout << add(2, 3); // Output: 5
  ```

---

### **16. What is the purpose of `std::aligned_storage`?**
- **Answer:**  
  Provides uninitialized memory with specified size and alignment.  

- **Extended Answer:**  
  Useful when dealing with objects requiring special memory alignment or avoiding initialization costs.  

- **Short Example:**  
  ```cpp
  std::aligned_storage<sizeof(int), alignof(int)>::type data;
  new (&data) int(42); // Placement new
  ```

---

### **17. What is type erasure in C++?**
- **Answer:**  
  A technique to provide a unified interface for different types while hiding their specific implementations.  

- **Extended Answer:**  
  Type erasure is used in `std::any`, `std::function`, and polymorphic classes to abstract details of types, enabling runtime flexibility.  

- **Short Example:**  
  ```cpp
  std::any value = 10;  // Can hold any type
  std::cout << std::any_cast<int>(value);
  ```

---

### **18. How is memory alignment achieved in C++?**
- **Answer:**  
  By ensuring data is stored at addresses divisible by its alignment requirement.  

- **Extended Answer:**  
  Proper alignment is crucial for performance and to avoid undefined behavior. Use `alignas` for specifying alignment explicitly.  

- **Short Example:**  
  ```cpp
  alignas(16) int arr[4]; // Ensures alignment to 16 bytes
  ```

---

### **19. What is the difference between `std::optional` and a raw pointer?**
- **Answer:**  
  - `std::optional`: A type-safe wrapper that may or may not contain a value.  
  - Raw pointer: Can also be `nullptr`, but lacks type safety.  

- **Extended Answer:**  
  `std::optional` improves code readability and safety by explicitly indicating optionality without requiring null checks.  

- **Short Example:**  
  ```cpp
  std::optional<int> opt = 42;
  if (opt) std::cout << opt.value();
  ```

---

### **20. What is the difference between `reinterpret_cast` and `dynamic_cast`?**
- **Answer:**  
  - `reinterpret_cast`: Converts between incompatible types.  
  - `dynamic_cast`: Performs runtime type checking and casts only polymorphic types.  

- **Extended Answer:**  
  Use `reinterpret_cast` cautiously, as it bypasses type safety. `dynamic_cast` is safer but requires RTTI and works only with polymorphic base classes.  

- **Short Example:**  
  ```cpp
  class Base { virtual void func() {} };
  class Derived : public Base {};
  Base* b = new Derived;
  Derived* d = dynamic_cast<Derived*>(b); // Safe downcast
  ```  

---



