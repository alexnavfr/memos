# Поиск пары чисел в массиве с суммой равной данной

## Решение с использованием сортировки

Этот подход сортирует список `data` и использует два указателя для поиска пар, что позволяет эффективно находить все пары, сумма которых равна `k`.

```csharp
using System;
using System.Collections.Generic;
using System.Text;

public class Solution {
    public static string FindPairs(int k, List<int> data) {
        // Сортируем список если он не сортирован изначально!!!
        List<int> sortedData = new List<int>(data);
        sortedData.Sort(); // O(n log n) // 

        StringBuilder result = new StringBuilder();
        int left = 0;
        int right = sortedData.Count - 1;

        // Подсчитываем частоту для обработки дубликатов
        Dictionary<int, int> frequency = new Dictionary<int, int>();
        foreach (int num in sortedData) {
            frequency[num] = frequency.GetValueOrDefault(num, 0) + 1;
        }

        // Используем два указателя
        while (left < sortedData.Count) {
            int num = sortedData[left];
            int complement = k - num;

            if (frequency.ContainsKey(complement)) {
                if (num == complement) {
                    // Для num == complement считаем количество пар
                    int count = frequency[num];
                    // Количество пар: C(count, 2) = count * (count - 1) / 2
                    for (int i = 0; i < count * (count - 1) / 2; i++) {
                        result.Append($"({num}+{complement})");
                    }
                    left += count; // Пропускаем все вхождения num
                } else if (complement > num && frequency.ContainsKey(complement)) {
                    // Для разных чисел добавляем все возможные пары
                    int countNum = frequency[num];
                    int countComplement = frequency[complement];
                    for (int i = 0; i < countNum * countComplement; i++) {
                        result.Append($"({num}+{complement})");
                    }
                    left += countNum; // Пропускаем все вхождения num
                } else {
                    left++; // Переходим к следующему числу
                }
            } else {
                left++; // Переходим к следующему числу
            }
        }

        return result.Length == 0 ? "()" : result.ToString();
    }
}
```

## Объяснение решения с сортировкой:
1. **Сортировка**:
   - Сортируем копию списка `data` с помощью `Sort()` (O(n log n)).
   - Для `data=[5,5,5]`: `sortedData=[5,5,5]`.

2. **Подсчет частоты**:
   - Создаем словарь частот для обработки дубликатов (O(n)).
   - Для `data=[5,5,5]`: `{5: 3}`.

3. **Поиск пар с двумя указателями**:
   - Используем указатель `left` для перебора чисел.
   - Для каждого `num = sortedData[left]` вычисляем `complement = k - num`.
   - Если `num == complement` (например, `5+5=10`):
     - Считаем количество пар: `C(count, 2) = count * (count - 1) / 2`, где `count` — частота числа.
     - Для `count=3`: `3 * 2 / 2 = 3` пары `(5+5)`.
   - Если `num != complement` и `complement > num`, добавляем все пары: `countNum * countComplement`.
   - Пропускаем все вхождения текущего числа (`left += count`).

4. **Тестовый случай `k=10, data=[5,5,5]`**:
   - Словарь: `{5: 3}`.
   - `left=0`, `num=5`, `complement=5`.
   - Так как `num == complement`, вычисляем пары: `3 * (3-1) / 2 = 3`.
   - Добавляем `(5+5)(5+5)(5+5)`.
   - Результат: `"(5+5)(5+5)(5+5)"`.

#### Сложность:
- **Время**: O(n log n) для сортировки + O(n) для создания словаря + O(n) для прохода по списку + O(m) для формирования строки, где `m` до O(n²). Итог: O(n log n + m).
- **Память**: O(n) для словаря и копии списка + O(m) для результата.

---

### Сравнение подходов
- **LINQ**:
  - Плюсы: Компактный и выразительный код, легко читаемый.
  - Минусы: Может быть менее производительным из-за накладных расходов LINQ.
  - Сложность: O(n + m), где `m` до O(n²).
- **Сортировка**:
  - Плюсы: Эффективно для больших списков с малым количеством дубликатов, использует сортировку для упрощения логики.
  - Минусы: Дополнительная сложность O(n log n) из-за сортировки.
  - Сложность: O(n log n + m).