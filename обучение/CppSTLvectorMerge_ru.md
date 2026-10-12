# Объединение векторов без дубликатов. (C++ STL)

## Prompt:
_Напиши функцию для объединения двух `std::vector<int>` без дубликатов с оптимальной производительностью._

Вот функция для объединения двух `std::vector<int>` без дубликатов с оптимальной производительностью. Она использует `std::unordered_set` для эффективной проверки дубликатов:

```cpp
#include <vector>
#include <unordered_set>
#include <algorithm>

std::vector<int> merge_vectors_without_duplicates(const std::vector<int>& vec1, const std::vector<int>& vec2) {
    std::vector<int> result;
    std::unordered_set<int> seen_elements;
    
    // Предварительно резервируем память для оптимизации
    result.reserve(vec1.size() + vec2.size());
    
    // Вспомогательная лямбда для добавления элементов с проверкой
    auto add_unique = [&](int value) {
        if (seen_elements.insert(value).second) {
            result.push_back(value);
        }
    };
    
    // Добавляем элементы из первого вектора
    for (int num : vec1) {
        add_unique(num); // вызываем лямбду( анонимную функцию), если удалось добавить в `seen_elements` - добавим в результат.
    }
    
    // Добавляем элементы из второго вектора
    for (int num : vec2) {
        add_unique(num);
    }
    
    return result;
}
```

### Оптимизации:
1. **Использование хэш-таблицы (`unordered_set`)** для быстрой проверки наличия элементов (O(1) в среднем случае)
2. **Предварительное резервирование памяти** для избежания многократных перераспределений
3. **Однократный проход** по каждому вектору (O(n+m) сложность)
4. **Вставка без сортировки** (быстрее чем решения с сортировкой + unique)

### Альтернативный вариант (если нужна сортировка)
Если вам нужно получить отсортированный результат, можно использовать `std::set`, но это будет менее эффективно для больших объемов данных:

```cpp
#include <vector>
#include <set>
#include <algorithm>

std::vector<int> merge_vectors_sorted_without_duplicates(const std::vector<int>& vec1, const std::vector<int>& vec2) {
    std::set<int> unique_elements(vec1.begin(), vec1.end());
    unique_elements.insert(vec2.begin(), vec2.end());
    return std::vector<int>(unique_elements.begin(), unique_elements.end());
}
```

Выбирайте первый вариант, если порядок элементов не важен и нужна максимальная производительность.

