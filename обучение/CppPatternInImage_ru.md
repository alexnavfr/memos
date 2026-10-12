# Поиск двумерного подмассива в массиве. 
# задача возможно должна решить задачу из кодингаме про картинку с флагом, марио и тд и тп.

## Prompt:
_расскажи о алгоритме "Поиск двумерного подмассива в массиве" и областях его применения. Приведи решение на С++ с подробным объяснением. Предоставь test cases._

Алгоритм **поиска двумерного подмассива в массиве** (часто называют *поиск подматрицы в матрице*) — это задача, в которой дана **большая матрица** (MxN) и **малая матрица** (pxq), и требуется найти, находится ли малая матрица как подмассив внутри большой.

---

## 📌 Пример задачи

* Большая матрица `A` размера `MxN`
* Подматрица `B` размера `pxq`
  Нужно проверить, существует ли в `A` такая область, которая по содержимому совпадает с `B`.

---

## 🔍 Области применения

1. **Обработка изображений** – поиск шаблона (подизображения) внутри большого изображения.
2. **Распознавание символов** – нахождение шаблонов букв/цифр.
3. **Анализ данных** – выявление совпадающих паттернов в таблицах.
4. **Геоинформационные системы** – поиск шаблона участка на карте.
5. **Компьютерное зрение и роботы** – определение объектов по шаблону.

---

## 🧠 Идея алгоритма (наивный подход)

1. Перебирать все возможные положения верхнего левого угла подматрицы `B` внутри матрицы `A`.
2. Для каждого такого положения сравнивать содержимое `B` и соответствующий фрагмент `A`.
3. Если найдено полное совпадение — вернуть `true`.

---

## 💻 Реализация на C++

```cpp
#include <iostream>
#include <vector>

using namespace std;

// Проверка, совпадает ли подматрица A[x...x+p][y...y+q] с матрицей B
bool matchAt(const vector<vector<int>>& A, const vector<vector<int>>& B, int x, int y) {
    int p = B.size();
    int q = B[0].size();

    for (int i = 0; i < p; ++i) {
        for (int j = 0; j < q; ++j) {
            if (A[x + i][y + j] != B[i][j])
                return false;
        }
    }
    return true;
}

// Основной алгоритм поиска
bool findSubmatrix(const vector<vector<int>>& A, const vector<vector<int>>& B) {
    int M = A.size();
    int N = A[0].size();
    int p = B.size();
    int q = B[0].size();

    if (p > M || q > N) return false; // подматрица больше матрицы

    for (int i = 0; i <= M - p; ++i) {
        for (int j = 0; j <= N - q; ++j) {
            if (matchAt(A, B, i, j))
                return true;
        }
    }
    return false;
}
```

---

## ✅ Примеры (test cases)

```cpp
void test() {
    vector<vector<int>> A = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 0, 1, 2},
        {3, 4, 5, 6}
    };

    vector<vector<int>> B1 = {
        {6, 7},
        {0, 1}
    };

    vector<vector<int>> B2 = {
        {7, 8},
        {1, 2}
    };

    vector<vector<int>> B3 = {
        {4, 5, 6},
        {0, 1, 2}
    };

    vector<vector<int>> B4 = {
        {8, 9},
        {1, 2}
    };

    cout << "B1 found? " << (findSubmatrix(A, B1) ? "Yes" : "No") << endl; // Yes
    cout << "B2 found? " << (findSubmatrix(A, B2) ? "Yes" : "No") << endl; // Yes
    cout << "B3 found? " << (findSubmatrix(A, B3) ? "Yes" : "No") << endl; // No
    cout << "B4 found? " << (findSubmatrix(A, B4) ? "Yes" : "No") << endl; // No
}
```

---

## ⏱️ Временная сложность

* **Временная**: `O((M - p + 1) * (N - q + 1) * p * q)` – на каждую позицию сверяется `p*q` элементов.
* **Пространственная**: `O(1)` – используется фиксированное количество дополнительной памяти.

---

## 📈 Улучшения

Если `B` сравнительно маленькая, а `A` очень большая, можно применять более эффективные методы:

* **Хэширование подматриц (Rolling Hash)** – например, Rabin-Karp для 2D
* **Преобразование в строки и поиск подстроки**
* **Свертка (convolution)** — при применении к изображению

Если интересно, могу показать реализацию с 2D-Rabin-Karp.

---

Хочешь улучшенную версию с хэшированием для ускорения или оставить базовый вариант?

---
## Prompt:
_Спасибо. Давай пока перепишем этот метод таким образом: Implément la fonction `vectot<int> getPatternInImage( int imageWidth, intimageHeight, vector<string> image, int patternWidth, int patternHeight, vector<string> pattern)`où les parameters sont:
- `imageWidth`: `int` la largeur de l'image
- `imageHeight`: `int` la hauteur de l'image
- `image`: `std::vector<std::string>` l'image, un vector de string, où chaque caractère represent un pixel
- `patternWidth`: `int` la largeur du motif
- `patternHeigth`: `int` la hauteur du motif
- `pattern`: `std::vector<std::string>` la largeur de l'image

et qui doit retourner:

- si le motif est présent dans l'image: la position `x`, `y`, sous la form d'un vecteur de 2 entiers, représentant le coin en haut à gauche du 1er motif, en partant du haut vers le bas, et de gauche à droite.
- si le motif n'est pas present dans l'image: [-1,-1]._

Вот как можно переписать алгоритм в форме функции `std::vector<int> getPatternInImage(...)`, как ты просил. Мы просто адаптируем ранее описанную идею на новую структуру данных (строки как ряды пикселей).

---

## ✅ C++ — Функция `getPatternInImage`

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

vector<int> getPatternInImage(
    int imageWidth,
    int imageHeight,
    const vector<string>& image,
    int patternWidth,
    int patternHeight,
    const vector<string>& pattern
) {
    // Быстрая проверка: паттерн больше изображения
    if (patternWidth > imageWidth || patternHeight > imageHeight)
        return {-1, -1};

    for (int y = 0; y <= imageHeight - patternHeight; ++y) {
        for (int x = 0; x <= imageWidth - patternWidth; ++x) {
            bool match = true;
            for (int dy = 0; dy < patternHeight && match; ++dy) {
                for (int dx = 0; dx < patternWidth && match; ++dx) {
                    if (image[y + dy][x + dx] != pattern[dy][dx]) {
                        match = false;
                    }
                }
            }
            if (match) {
                return {x, y}; // позиция вхождения: левый верхний угол
            }
        }
    }

    return {-1, -1}; // не найдено
}
```

---

## 🧪 Пример использования / Тесты

```cpp
void test() {
    vector<string> image = {
        "ABCDE",
        "FGHIJ",
        "KLMNO",
        "PQRST",
        "UVWXY"
    };

    vector<string> pattern1 = {
        "HI",
        "LM"
    };

    vector<string> pattern2 = {
        "ST",
        "XY"
    };

    vector<string> pattern3 = {
        "CD",
        "GH"
    };

    vector<int> pos1 = getPatternInImage(5, 5, image, 2, 2, pattern1);
    vector<int> pos2 = getPatternInImage(5, 5, image, 2, 2, pattern2);
    vector<int> pos3 = getPatternInImage(5, 5, image, 2, 2, pattern3);

    cout << "Pattern1: (" << pos1[0] << ", " << pos1[1] << ")\n"; // Ожидается (2, 1)
    cout << "Pattern2: (" << pos2[0] << ", " << pos2[1] << ")\n"; // Ожидается (3, 3)
    cout << "Pattern3: (" << pos3[0] << ", " << pos3[1] << ")\n"; // Ожидается (-1, -1)
}
```

---

## 📌 Пояснение

* `image[y][x]` — обращение к символу в строке изображения (y-строка, x-символ).
* Мы двигаем окно поиска по всем возможным позициям так, чтобы паттерн не вышел за границы изображения.
* Сравниваем каждый символ в подокне с соответствующим символом в `pattern`.

---

Если хочешь, могу также:

* оптимизировать это решение с использованием хеширования (2D Rabin-Karp),
* адаптировать под Unicode/цветовое представление пикселей,
* добавить возвращение всех вхождений.

Скажи, если нужно расширение.


