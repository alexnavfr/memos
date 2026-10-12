# Палидром

## Prompt:
__

**Палиндром** — это строка, которая читается одинаково слева направо и справа налево.
Примеры палиндромов: `"level"`, `"radar"`, `"топот"`, `"12321"`.

---

## 🔹 Как проверить, является ли строка палиндромом?

### ✅ Алгоритм (простой двухуказательный):

1. Установим два указателя:

   * один в начало строки (`left`),
   * другой в конец строки (`right`).
2. Пока `left < right`, сравниваем символы:

   * если `s[left] != s[right]` → не палиндром.
   * иначе двигаем указатели: `left++`, `right--`.
3. Если весь цикл прошли без несовпадений → строка палиндром.

---

## 🔹 Пример на C\#

```csharp
using System;

class Program
{
    static bool IsPalindrome(string s)
    {
        int left = 0;
        int right = s.Length - 1;

        while (left < right)
        {
            if (s[left] != s[right])
                return false;

            left++;
            right--;
        }

        return true;
    }

    static void Main()
    {
        Console.WriteLine(IsPalindrome("level")); // True
        Console.WriteLine(IsPalindrome("hello")); // False
    }
}
```

---

## 🔹 Сложность

* **Временная сложность**: `O(n)`, где `n` — длина строки.
  (Нужно пройти максимум половину строки).
* **Дополнительная память**: `O(1)` — если не создаём копий строк.

---

## 🔹 Альтернатива: через разворот строки

Можно сравнить строку с её перевёрнутой версией:

```csharp
using System;

class Program
{
    static bool IsPalindrome(string s)
    {
        string reversed = new string(s.Reverse().ToArray());
        return s == reversed;
    }

    static void Main()
    {
        Console.WriteLine(IsPalindrome("madam")); // True
    }
}
```

* Это **проще**, но использует дополнительную память `O(n)` на обратную строку.

---

Если хочешь, могу показать:

* как **найти все палиндромные подстроки**,
* как **найти самый длинный палиндром** в строке (алгоритм Манакера `O(n)`),
* или реализовать пошагово любой из них на C#.

Хочешь?

_реализуй пошагово оба._

Отлично! Начнём с пошаговой реализации:

---

## 🔷 **1. Все палиндромные подстроки (динамическое программирование)**

### 🔹 Цель:

Найти и вывести **все подстроки**, которые являются палиндромами.

---

### 🔸 Шаг 1: Идея

Для каждой подстроки `s[i..j]` проверяем, палиндром ли она.
Сохраняем информацию в двумерной таблице `dp[i][j] = true`, если это палиндром.

---

### 🔸 Шаг 2: Реализация

```csharp
using System;
using System.Collections.Generic;

class Program
{
    static List<string> FindAllPalindromes(string s)
    {
        int n = s.Length;
        bool[,] dp = new bool[n, n];
        List<string> result = new List<string>();

        for (int len = 1; len <= n; len++) // длина подстроки
        {
            for (int i = 0; i <= n - len; i++) // начало подстроки
            {
                int j = i + len - 1; // конец подстроки

                if (s[i] == s[j])
                {
                    if (len <= 2 || dp[i + 1, j - 1]) // базовый случай или вложенный палиндром
                    {
                        dp[i, j] = true;
                        result.Add(s.Substring(i, len));
                    }
                }
            }
        }

        return result;
    }

    static void Main()
    {
        var palindromes = FindAllPalindromes("abbaeae");
        Console.WriteLine("Палиндромные подстроки:");
        foreach (var p in palindromes)
            Console.WriteLine(p);
    }
}
```

---

### 🔸 Сложность:

* Время: `O(n^2)`
* Память: `O(n^2)` (матрица `dp`)

---

## 🔷 **2. Самый длинный палиндром (Алгоритм Манакера)**

### 🔹 Цель:

Найти **самую длинную палиндромную подстроку** за `O(n)`.

---

### 🔸 Шаг 1: Подготовка строки

Добавим между всеми символами `#`, чтобы обрабатывать чётные и нечётные палиндромы одинаково.
Например, `"abba"` → `"#a#b#b#a#"`

---

### 🔸 Шаг 2: Реализация

```csharp
using System;

class Program
{
    static string LongestPalindrome(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";

        // Шаг 1: Преобразуем строку
        string t = "#" + string.Join("#", s.ToCharArray()) + "#";
        int n = t.Length;
        int[] p = new int[n]; // p[i] = радиус палиндрома с центром в i
        int center = 0, right = 0;
        int maxLen = 0, maxCenter = 0;

        for (int i = 0; i < n; i++)
        {
            int mirror = 2 * center - i;

            if (i < right)
                p[i] = Math.Min(right - i, p[mirror]);

            // Пытаемся расширить палиндром вокруг i
            int a = i + p[i] + 1;
            int b = i - p[i] - 1;

            while (a < n && b >= 0 && t[a] == t[b])
            {
                p[i]++;
                a++;
                b--;
            }

            // Обновляем центр и правую границу
            if (i + p[i] > right)
            {
                center = i;
                right = i + p[i];
            }

            // Обновляем максимальный палиндром
            if (p[i] > maxLen)
            {
                maxLen = p[i];
                maxCenter = i;
            }
        }

        // Восстановим палиндром из исходной строки
        int start = (maxCenter - maxLen) / 2;
        return s.Substring(start, maxLen);
    }

    static void Main()
    {
        string s = "babad";
        Console.WriteLine("Самый длинный палиндром: " + LongestPalindrome(s));
    }
}
```

---

### 🔸 Сложность:

* Время: `O(n)`
* Память: `O(n)` (массив радиусов `p`)

---

## 🔹 Хочешь пошагово:

* визуализировать работу алгоритма?
* или собрать архив с этими примерами?

Могу оформить по шагам, как с AVL-деревом.

