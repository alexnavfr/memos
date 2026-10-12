# С++17 новые фичи

## Prompt:

_Расскажи от новшествах в версии C++17.  Кратко и с примерами остановись на самых значимых новшествах._

C++17 добавил множество улучшений в язык и стандартную библиотеку. Вот краткий обзор **наиболее значимых новшеств**, с короткими пояснениями и примерами.

---

### 🔹 1. **Structured Bindings (Структурное разложение)**

Позволяет "распаковывать" кортежи и структуры на переменные.

```cpp
#include <tuple>
auto [x, y] = std::make_pair(1, 2);  // x = 1, y = 2
```

---

### 🔹 2. **if / switch с инициализацией**

Теперь можно объявлять переменную прямо внутри `if` или `switch`.

```cpp
if (int x = f(); x > 0) {
    // использовать x
}
```

---

### 🔹 3. **inline variables**

Позволяет определять глобальные переменные `inline`, чтобы избежать множественного определения при подключении заголовков.

```cpp
inline int global_value = 42;
```

---

### 🔹 4. **std::optional**

Хранит значение или ничего — аналог `Nullable` в C#.

```cpp
#include <optional>
std::optional<int> get(bool ok) {
    if (ok) return 5;
    return std::nullopt;
}
```

---

### 🔹 5. **std::variant**

Контейнер, хранящий **одно из нескольких** типов (аналог union, но безопасный).

```cpp
#include <variant>
std::variant<int, std::string> v = "text";
v = 42;
```

---

### 🔹 6. **std::any**

Хранит значение **любого типа**, как `object` в C# или `void*`, но безопаснее.

```cpp
#include <any>
std::any a = 5;
a = std::string("Hello");
```

---

### 🔹 7. **Fold Expressions** (для вариадик-шаблонов)

Упрощение обработки параметров шаблонов.

```cpp
template<typename... Args>
auto sum(Args... args) {
    return (... + args);  // суммирует все аргументы
}
```

---

### 🔹 8. **Улучшенные constexpr**

Теперь можно писать более сложный `constexpr`-код (циклы, условия, и т.д.).

```cpp
constexpr int factorial(int n) {
    int res = 1;
    for (int i = 2; i <= n; ++i) res *= i;
    return res;
}
```

---

### 🔹 9. **String View (`std::string_view`)**

Небольшой, быстрый "вид" на строку — без копирования.

```cpp
#include <string_view>
void print(std::string_view sv) {
    std::cout << sv << '\n';
}
```

---

### 🔹 10. **Parallel Algorithms (в `<algorithm>`)**

Поддержка параллельного выполнения стандартных алгоритмов.

```cpp
#include <algorithm>
#include <execution>
std::sort(std::execution::par, v.begin(), v.end());
```

---

### 🔹 Прочие улучшения

* `[[nodiscard]]`, `[[maybe_unused]]` — новые атрибуты.
* `__has_include` — проверка наличия заголовков.
* Упрощение SFINAE и шаблонов.
* std::filesystem — работа с файлами и путями (официально в C++17).

---

Если хочешь, могу подготовить мини-проект, где все эти фичи показаны на практике.

