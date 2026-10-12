# Реализация Deque при помощи 2х `std::stack`

## Prompt:
_Давай разберем пошагово следующий код_

--- Код ---
```cpp
template<typename T>
class TwoStackDeque {
private:
    std::stack<T> front_stack;
    std::stack<T> back_stack;
    
    void balance() {
        if (front_stack.empty()) {
            size_t half = back_stack.size() / 2;
            std::stack<T> temp;
            for (size_t i = 0; i < half; ++i) {
                temp.push(back_stack.top());
                back_stack.pop();
            }
            while (!temp.empty()) {
                front_stack.push(temp.top());
                temp.pop();
            }
        }
    }

public:
    void push_front(T value) {
        front_stack.push(value);
    }
    
    void push_back(T value) {
        back_stack.push(value);
    }
    
    T pop_front() {
        if (front_stack.empty()) balance();
        T val = front_stack.top();
        front_stack.pop();
        return val;
    }
    
    T pop_back() {
        if (back_stack.empty()) {
            // Аналогично balance(), но для back_stack
        }
        T val = back_stack.top();
        back_stack.pop();
        return val;
    }
    
    bool empty() {
        return front_stack.empty() && back_stack.empty();
    }
};
```
Код представляет реализацию двусторонней очереди (`Deque`) на основе двух стеков (`TwoStackDeque`) в C++. Двусторонняя очередь позволяет добавлять и удалять элементы как с начала, так и с конца. Давайте подробно разберём, что делает этот код, включая структуру класса, методы и логику работы.

---

### **Общая идея**
Класс `TwoStackDeque` использует два стека (`std::stack<T>`):
- `front_stack`: Хранит элементы, доступные с "переднего" конца очереди.
- `back_stack`: Хранит элементы, доступные с "заднего" конца очереди.

Операции добавления (`push_front`, `push_back`) и удаления (`pop_front`, `pop_back`) распределяются между этими стеками. Если один из стеков пуст, метод `balance` перераспределяет элементы, чтобы обеспечить корректную работу операций удаления. Это позволяет эффективно реализовать функциональность двусторонней очереди.

---

### **Шаг 1: Структура класса**
```cpp
template<typename T>
class TwoStackDeque {
private:
    std::stack<T> front_stack;
    std::stack<T> back_stack;
    // ...
};
```
- Класс является шаблонным, что позволяет работать с любым типом данных `T`.
- `front_stack` хранит элементы, которые находятся ближе к началу очереди (для операций `push_front` и `pop_front`).
- `back_stack` хранит элементы, которые находятся ближе к концу очереди (для операций `push_back` и `pop_back`).

---

### **Шаг 2: Метод `balance`**
```cpp
void balance() {
    if (front_stack.empty()) {
        size_t half = back_stack.size() / 2;
        std::stack<T> temp;
        for (size_t i = 0; i < half; ++i) {
            temp.push(back_stack.top());
            back_stack.pop();
        }
        while (!temp.empty()) {
            front_stack.push(temp.top());
            temp.pop();
        }
    }
}
```
**Назначение**: Метод `balance` вызывается, когда `front_stack` пуст, но нужно выполнить `pop_front`. Он перераспределяет элементы из `back_stack` в `front_stack`, чтобы половина элементов оказалась в `front_stack`, а половина осталась в `back_stack`.

**Как работает**:
1. Проверяется, пуст ли `front_stack`. Если нет, метод ничего не делает.
2. Если `front_stack` пуст, вычисляется половина размера `back_stack` (`half = back_stack.size() / 2`).
3. Создаётся временный стек `temp`, куда переносятся верхние `half` элементов из `back_stack` (удаляются из `back_stack` методом `pop`).
4. Элементы из `temp` переносятся в `front_stack` в обратном порядке (через `push` и `pop`).
5. В результате половина элементов `back_stack` перемещается в `front_stack`, но в обратном порядке, что соответствует логике двусторонней очереди.

**Пример работы `balance`**:
- Пусть `back_stack` содержит элементы `[1, 2, 3, 4]` (где `4` — верхний элемент).
- `half = 4 / 2 = 2`.
- В `temp` переносятся `4`, затем `3` → `temp = [3, 4]` (верхний элемент `4`).
- Из `temp` элементы переносятся в `front_stack` → `front_stack = [4, 3]`.
- `back_stack` остаётся с `[1, 2]`.

Теперь `front_stack` содержит элементы, которые можно извлечь с помощью `pop_front`.

---

### **Шаг 3: Публичные методы**

#### **1. `push_front(T value)`**
```cpp
void push_front(T value) {
    front_stack.push(value);
}
```
- Добавляет элемент `value` в начало очереди, помещая его в `front_stack`.
- Простая операция: элемент становится верхним в `front_stack`.
- **Сложность**: O(1).

**Пример**:
- Если `front_stack = [3, 4]`, вызов `push_front(5)` добавит `5`, и `front_stack` станет `[3, 4, 5]` (верхний элемент — `5`).

---

#### **2. `push_back(T value)`**
```cpp
void push_back(T value) {
    back_stack.push(value);
}
```
- Добавляет элемент `value` в конец очереди, помещая его в `back_stack`.
- Аналогично `push_front`, элемент становится верхним в `back_stack`.
- **Сложность**: O(1).

**Пример**:
- Если `back_stack = [1, 2]`, вызов `push_back(3)` добавит `3`, и `back_stack` станет `[1, 2, 3]` (верхний элемент — `3`).

---

#### **3. `pop_front()`**
```cpp
T pop_front() {
    if (front_stack.empty()) balance();
    T val = front_stack.top();
    front_stack.pop();
    return val;
}
```
- Удаляет и возвращает элемент из начала очереди (из `front_stack`).
- Если `front_stack` пуст, вызывается `balance`, чтобы переместить элементы из `back_stack`.
- Извлекается верхний элемент `front_stack` с помощью `top` и удаляется с помощью `pop`.
- **Сложность**: O(1) в среднем, но O(n) в худшем случае, если требуется вызов `balance`.

**Пример**:
- Если `front_stack = [3, 4]`, `pop_front()` вернёт `4`, и `front_stack` станет `[3]`.
- Если `front_stack` пуст, а `back_stack = [1, 2, 3, 4]`, то:
  - Вызывается `balance`, и `front_stack` станет `[4, 3]`, а `back_stack` — `[1, 2]`.
  - Затем `pop_front()` вернёт `3`, и `front_stack` станет `[4]`.

---

#### **4. `pop_back()`**
```cpp
T pop_back() {
    if (back_stack.empty()) {
        // Аналогично balance(), но для back_stack
    }
    T val = back_stack.top();
    back_stack.pop();
    return val;
}
```
- Удаляет и возвращает элемент из конца очереди (из `back_stack`).
- Если `back_stack` пуст, должен быть вызван метод, аналогичный `balance`, для перераспределения элементов из `front_stack` в `back_stack`. Однако в коде этот метод не реализован (комментарий указывает на недостающую логику).
- Извлекается верхний элемент `back_stack` с помощью `top` и удаляется с помощью `pop`.
- **Сложность**: O(1) в среднем, но O(n) в худшем случае, если потребуется перераспределение.

**Замечание**: Код неполный, так как отсутствует логика для случая, когда `back_stack` пуст. Аналогичный `balance` метод для `pop_back` должен был бы:
1. Проверить, пуст ли `back_stack`.
2. Если пуст, переместить половину элементов из `front_stack` в `back_stack` через временный стек.

**Пример недостающей реализации для `pop_back`**:
```cpp
if (back_stack.empty()) {
    size_t half = front_stack.size() / 2;
    std::stack<T> temp;
    for (size_t i = 0; i < half; ++i) {
        temp.push(front_stack.top());
        front_stack.pop();
    }
    while (!temp.empty()) {
        back_stack.push(temp.top());
        temp.pop();
    }
}
```
- Это зеркальная версия `balance`, перемещающая элементы из `front_stack` в `back_stack`.

**Пример работы `pop_back`**:
- Если `back_stack = [1, 2, 3]`, `pop_back()` вернёт `3`, и `back_stack` станет `[1, 2]`.
- Если `back_stack` пуст, а `front_stack = [4, 3, 2, 1]`, то:
  - После перераспределения `back_stack` станет `[2, 1]`, а `front_stack` — `[4, 3]`.
  - Затем `pop_back()` вернёт `1`.

---

#### **5. `empty()`**
```cpp
bool empty() {
    return front_stack.empty() && back_stack.empty();
}
```
- Проверяет, пуста ли очередь.
- Очередь считается пустой, если оба стека (`front_stack` и `back_stack`) пусты.
- **Сложность**: O(1).

---

### **Общий пример работы**
Предположим, мы выполняем следующие операции:
```cpp
TwoStackDeque<int> deque;
deque.push_back(1);  // back_stack = [1]
deque.push_back(2);  // back_stack = [1, 2]
deque.push_front(3); // front_stack = [3]
deque.push_front(4); // front_stack = [3, 4]

std::cout << deque.pop_front() << std::endl; // Вывод: 4, front_stack = [3]
std::cout << deque.pop_back() << std::endl;  // Вывод: 2, back_stack = [1]
std::cout << deque.pop_front() << std::endl; // Вывод: 3, front_stack = []
std::cout << deque.pop_front() << std::endl; // balance вызывается, front_stack = [1], back_stack = [], Вывод: 1
std::cout << deque.empty() << std::endl;     // Вывод: 1 (true), так как оба стека пусты
```

---

### **Анализ сложности**
- **Добавление (`push_front`, `push_back`)**: O(1), так как просто добавляет элемент в стек.
- **Удаление (`pop_front`, `pop_back`)**: 
  - O(1) в среднем, если стек не пуст.
  - O(n) в худшем случае, если требуется вызов `balance` (или аналогичного метода для `pop_back`), так как перераспределяется половина элементов.
- **Проверка пустоты (`empty`)**: O(1).

---

### **Проблемы и улучшения**
1. **Недостающая логика для `pop_back`**: Код неполный, так как отсутствует перераспределение элементов для случая, когда `back_stack` пуст. Нужно добавить метод, аналогичный `balance`, для `pop_back`.
2. **Необработанные исключения**: Если оба стека пусты, вызов `pop_front` или `pop_back` приведёт к ошибке (обращение к `top` пустого стека). Следует добавить проверку:
   ```cpp
   if (empty()) throw std::runtime_error("Deque is empty");
   ```
3. **Эффективность `balance`**: Перераспределение элементов может быть оптимизировано, например, с использованием других структур данных (например, `std::vector`), но это увеличит сложность кода.

---

### **Заключение**
`TwoStackDeque` реализует двустороннюю очередь, используя два стека для хранения элементов. `front_stack` отвечает за начало очереди, `back_stack` — за конец. Метод `balance` обеспечивает перераспределение элементов, чтобы операции `pop_front` и `pop_back` работали корректно, даже если один из стеков пуст. Код эффективен для большинства операций (O(1) в среднем), но требует доработки для обработки случая пустого `back_stack` и исключительных ситуаций.

---

А вот ещё более простой вариант (DeepSeek вариант).

## Prompt:
_Как можно реализовать двустороннюю очередь (deque) только с использованием двух стеков (`std::stack`)? Приведи самую простую реализацию и подробно объясни что сделано._

### Реализация двусторонней очереди (deque) с использованием двух стеков (`std::stack`)

Двустороннюю очередь (deque) можно эмулировать с помощью двух стеков. Основная идея заключается в том, что один стек (`front_stack`) отвечает за операции с **началом** дека, а другой (`back_stack`) — за операции с **концом**.  

#### Алгоритм:
1. **`push_front(x)`** → Кладём `x` в `front_stack`.
2. **`push_back(x)`** → Кладём `x` в `back_stack`.
3. **`pop_front()`** → Если `front_stack` не пуст, удаляем его верхний элемент.  
   Иначе перекладываем все элементы из `back_stack` в `front_stack` (в обратном порядке) и затем удаляем верхний элемент.
4. **`pop_back()`** → Аналогично `pop_front()`, но наоборот: если `back_stack` пуст, перекладываем `front_stack` в `back_stack`.
5. **`front()`** → Если `front_stack` не пуст, возвращаем его верхний элемент.  
   Иначе возвращаем **нижний** элемент `back_stack` (после перекладывания).
6. **`back()`** → Если `back_stack` не пуст, возвращаем его верхний элемент.  
   Иначе возвращаем **нижний** элемент `front_stack`.

---

### Простейшая реализация на C++ (`std::stack`)

```cpp
#include <stack>
#include <stdexcept>

template <typename T>
class DequeUsingStacks {
private:
    std::stack<T> front_stack;  // Для операций с началом дека
    std::stack<T> back_stack;   // Для операций с концом дека

    // Перекладывает все элементы из одного стека в другой (инвертируя порядок)
    void move_to_front_if_empty() {
        if (front_stack.empty()) {
            while (!back_stack.empty()) {
                front_stack.push(back_stack.top());
                back_stack.pop();
            }
        }
    }

    void move_to_back_if_empty() {
        if (back_stack.empty()) {
            while (!front_stack.empty()) {
                back_stack.push(front_stack.top());
                front_stack.pop();
            }
        }
    }

public:
    void push_front(T x) {
        front_stack.push(x);
    }

    void push_back(T x) {
        back_stack.push(x);
    }

    void pop_front() {
        if (empty()) {
            throw std::runtime_error("Deque is empty!");
        }
        move_to_front_if_empty();
        front_stack.pop();
    }

    void pop_back() {
        if (empty()) {
            throw std::runtime_error("Deque is empty!");
        }
        move_to_back_if_empty();
        back_stack.pop();
    }

    T front() {
        if (empty()) {
            throw std::runtime_error("Deque is empty!");
        }
        move_to_front_if_empty();
        return front_stack.top();
    }

    T back() {
        if (empty()) {
            throw std::runtime_error("Deque is empty!");
        }
        move_to_back_if_empty();
        return back_stack.top();
    }

    bool empty() const {
        return front_stack.empty() && back_stack.empty();
    }

    size_t size() const {
        return front_stack.size() + back_stack.size();
    }
};
```

---

### Пояснение работы:
1. **`push_front(x)` и `push_back(x)`** просто добавляют элементы в соответствующие стеки.
2. **`pop_front()`**:
   - Если `front_stack` пуст, перекладываем `back_stack` в `front_stack` (инвертируя порядок).
   - Теперь верхний элемент `front_stack` — это начало дека.
3. **`pop_back()`** работает аналогично, но с `back_stack`.
4. **`front()` и `back()`**:
   - Если нужный стек пуст, перекладываем элементы из другого стека.
   - Возвращаем верхний элемент нужного стека.

---

### Сложность операций:
- **`push_front` и `push_back`** → **O(1)** (просто `push` в стек).
- **`pop_front` и `pop_back`** → **O(n)** в худшем случае (если один стек пуст, перекладываем все элементы).
- **`front` и `back`** → **O(n)** в худшем случае (если нужный стек пуст, перекладываем элементы).

---

### Вывод:
Это простая реализация, но не самая эффективная (из-за **O(n)** операций в худшем случае). Её можно оптимизировать, но для понимания принципа работы дека на стеках этого достаточно. 




