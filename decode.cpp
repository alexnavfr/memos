static std::list<std::string> split(const std::string& chaine, char separator)
{
  std::list<std::string> result;
  size_t deb = 0;
  size_t pos = chaine.find(separator, deb);
  while (pos != std::string::npos) {
    result.push_back(chaine.substr(deb, pos-deb));
    deb = pos + 1;
    pos = chaine.find(separator, deb);
  }
  result.push_back(chaine.substr(deb));
  return result;
}

static std::string findWord(std::string& mot, const std::list<std::string>& words)
{
  size_t n = mot.size();
  if (n < 3)
    return mot;

  for (auto word : words) {
    if (n != word.length() || word.at(0) != mot.at(0) || word.at(n - 1) != mot.at(n - 1))
      continue;
    std::string word_substr = word.substr(1, n-2);
    if (std::all_of(mot.begin()+1, mot.end()-1, [&](char c) -> bool { return word_substr.find(c) != std::string::npos; }))
      return word;
  }
  return mot;
}

static std::string decode(const std::list<std::string>& words, const std::string& message)
{
  std::string clear_message;
  std::list<std::string> mots = split(message, ' ');
  for (std::string mot : mots) {
    if (!clear_message.empty())
      clear_message.append(" ");
    clear_message.append(findWord(mot, words));
  }
  return clear_message;
}

static void testDecode() {
  const std::list<std::string> words = {"hello", "mind", "are", "friend", "sincerly", "orange", "frame"};
  const std::string message = "hlelo feirnd how farme mnid organe screnliy";
  std::cout << decode(words, message) << std::endl;
}

---

## Prompt:
_Существует код написанный на С++. Давай перепишем это код на Си. код находится в присоединенном файле.(код выше)_

Вот переписанный код на языке C:

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct Node {
    char* data;
    struct Node* next;
} Node;

typedef struct {
    Node* head;
} List;

List* split(const char* chaine, char separator) {
    List* result = (List*)malloc(sizeof(List));
    result->head = NULL;
    Node** tail = &(result->head);

    const char* deb = chaine;
    const char* pos = strchr(deb, separator);
    
    while (pos != NULL) {
        int length = pos - deb;
        char* token = (char*)malloc(length + 1);
        strncpy(token, deb, length);
        token[length] = '\0';
        
        Node* newNode = (Node*)malloc(sizeof(Node));
        newNode->data = token;
        newNode->next = NULL;
        
        *tail = newNode;
        tail = &(newNode->next);
        
        deb = pos + 1;
        pos = strchr(deb, separator);
    }
    
    // Add the last part
    char* token = strdup(deb);
    Node* newNode = (Node*)malloc(sizeof(Node));
    newNode->data = token;
    newNode->next = NULL;
    *tail = newNode;
    
    return result;
}

char* findWord(const char* mot, const List* words) {
    size_t n = strlen(mot);
    if (n < 3) {
        return strdup(mot);
    }
    
    Node* current = words->head;
    while (current != NULL) {
        const char* word = current->data;
        if (strlen(word) != n || word[0] != mot[0] || word[n - 1] != mot[n - 1]) {
            current = current->next;
            continue;
        }
        
        bool allFound = true;
        for (size_t i = 1; i < n - 1; i++) {
            if (strchr(word + 1, mot[i]) == NULL) {
                allFound = false;
                break;
            }
        }
        
        if (allFound) {
            return strdup(word);
        }
        
        current = current->next;
    }
    
    return strdup(mot);
}

char* decode(const List* words, const char* message) {
    List* mots = split(message, ' ');
    char* clear_message = (char*)malloc(1);
    clear_message[0] = '\0';
    
    Node* current = mots->head;
    while (current != NULL) {
        char* mot = current->data;
        char* foundWord = findWord(mot, words);
        
        if (strlen(clear_message) > 0) {
            clear_message = (char*)realloc(clear_message, strlen(clear_message) + 2);
            strcat(clear_message, " ");
        }
        
        clear_message = (char*)realloc(clear_message, strlen(clear_message) + strlen(foundWord) + 1);
        strcat(clear_message, foundWord);
        
        free(foundWord);
        current = current->next;
    }
    
    // Free the list
    current = mots->head;
    while (current != NULL) {
        Node* next = current->next;
        free(current->data);
        free(current);
        current = next;
    }
    free(mots);
    
    return clear_message;
}

void freeList(List* list) {
    Node* current = list->head;
    while (current != NULL) {
        Node* next = current->next;
        free(current->data);
        free(current);
        current = next;
    }
    free(list);
}

void testDecode() {
    List* words = (List*)malloc(sizeof(List));
    words->head = NULL;
    
    Node* node1 = (Node*)malloc(sizeof(Node));
    node1->data = strdup("hello");
    node1->next = NULL;
    words->head = node1;
    
    Node* node2 = (Node*)malloc(sizeof(Node));
    node2->data = strdup("mind");
    node2->next = NULL;
    node1->next = node2;
    
    Node* node3 = (Node*)malloc(sizeof(Node));
    node3->data = strdup("are");
    node3->next = NULL;
    node2->next = node3;
    
    Node* node4 = (Node*)malloc(sizeof(Node));
    node4->data = strdup("friend");
    node4->next = NULL;
    node3->next = node4;
    
    Node* node5 = (Node*)malloc(sizeof(Node));
    node5->data = strdup("sincerly");
    node5->next = NULL;
    node4->next = node5;
    
    Node* node6 = (Node*)malloc(sizeof(Node));
    node6->data = strdup("orange");
    node6->next = NULL;
    node5->next = node6;
    
    Node* node7 = (Node*)malloc(sizeof(Node));
    node7->data = strdup("frame");
    node7->next = NULL;
    node6->next = node7;
    
    const char* message = "hlelo feirnd how farme mnid organe screnliy";
    char* decoded = decode(words, message);
    printf("%s\n", decoded);
    
    free(decoded);
    freeList(words);
}

int main() {
    testDecode();
    return 0;
}
```

Основные изменения при переходе с C++ на C:
1. Замена `std::list` на собственную реализацию связанного списка
2. Замена `std::string` на C-строки (`char*`)
3. Использование функций работы со строками из C (`strlen`, `strchr`, `strdup` и т.д.)
4. Ручное управление памятью с помощью `malloc`, `realloc` и `free`
5. Замена лямбда-выражения на обычный цикл в функции `findWord`
6. Добавление функций для освобождения памяти (`freeList`)

Код сохраняет ту же функциональность, что и оригинальный C++ код, но использует только средства языка C.

---

Вот подробное объяснение переписанного кода на C с комментариями для каждой значимой части:

---

### **Структуры данных**
```c
typedef struct Node {
    char* data;         // Строка (слово)
    struct Node* next;  // Указатель на следующий узел
} Node;

typedef struct {
    Node* head;         // Указатель на начало списка
} List;
```
- **`Node`** — узел связного списка, хранящий строку (`data`) и указатель на следующий элемент (`next`).
- **`List`** — сам связный список, содержащий указатель на голову (`head`). Аналог `std::list<std::string>` из C++.

---

### **Функция `split` — разбиение строки по разделителю**
```c
List* split(const char* chaine, char separator) {
    List* result = (List*)malloc(sizeof(List));  // Создаем новый список
    result->head = NULL;
    Node** tail = &(result->head);              // Указатель на хвост списка

    const char* deb = chaine;                   // Начало текущего токена
    const char* pos = strchr(deb, separator);   // Поиск разделителя

    while (pos != NULL) {
        int length = pos - deb;                 // Длина токена
        char* token = (char*)malloc(length + 1); // Выделяем память под токен
        strncpy(token, deb, length);            // Копируем часть строки
        token[length] = '\0';                   // Добавляем нулевой символ

        Node* newNode = (Node*)malloc(sizeof(Node)); // Создаем узел
        newNode->data = token;
        newNode->next = NULL;

        *tail = newNode;                        // Добавляем узел в конец списка
        tail = &(newNode->next);               // Обновляем хвост

        deb = pos + 1;                          // Перемещаем начало за разделитель
        pos = strchr(deb, separator);          // Ищем следующий разделитель
    }

    // Добавляем последний токен (после последнего разделителя)
    char* token = strdup(deb);                  // Копируем оставшуюся часть
    Node* newNode = (Node*)malloc(sizeof(Node));
    newNode->data = token;
    newNode->next = NULL;
    *tail = newNode;

    return result;
}
```
- **Аналог C++:** `std::list<std::string> split(...)`.
- **Логика:**
  1. Разбивает строку `chaine` по разделителю `separator`.
  2. Каждый токен сохраняется в новом узле списка.
  3. Использует `strchr` для поиска разделителя и `strncpy` для копирования подстрок.
  4. Возвращает список токенов.

---

### **Функция `findWord` — поиск слова по условиям**
```c
char* findWord(const char* mot, const List* words) {
    size_t n = strlen(mot);
    if (n < 3) {
        return strdup(mot);  // Слова короче 3 символов не обрабатываем
    }

    Node* current = words->head;
    while (current != NULL) {
        const char* word = current->data;
        // Проверяем длину и первую/последнюю буквы
        if (strlen(word) != n || word[0] != mot[0] || word[n - 1] != mot[n - 1]) {
            current = current->next;
            continue;
        }

        // Проверяем, что все буквы в середине слова совпадают (без учета порядка)
        bool allFound = true;
        for (size_t i = 1; i < n - 1; i++) {
            if (strchr(word + 1, mot[i]) == NULL) {  // Ищем букву в середине слова
                allFound = false;
                break;
            }
        }

        if (allFound) {
            return strdup(word);  // Нашли подходящее слово
        }

        current = current->next;
    }

    return strdup(mot);  // Возвращаем исходное слово, если не нашли замену
}
```
- **Аналог C++:** `std::string findWord(...)`.
- **Логика:**
  1. Проверяет, что слово `mot` длиннее 2 символов.
  2. Ищет в списке `words` слово, где:
     - Та же длина.
     - Та же первая и последняя буква.
     - Все средние буквы есть в исходном слове (порядок не важен).
  3. Возвращает найденное слово или копию исходного.

---

### **Функция `decode` — декодирование сообщения**
```c
char* decode(const List* words, const char* message) {
    List* mots = split(message, ' ');  // Разбиваем сообщение на слова
    char* clear_message = (char*)malloc(1);
    clear_message[0] = '\0';          // Начало результирующей строки

    Node* current = mots->head;
    while (current != NULL) {
        char* mot = current->data;
        char* foundWord = findWord(mot, words);  // Ищем замену для слова

        if (strlen(clear_message) > 0) {
            clear_message = (char*)realloc(clear_message, strlen(clear_message) + 2);
            strcat(clear_message, " ");  // Добавляем пробел между словами
        }

        // Добавляем найденное слово в результат
        clear_message = (char*)realloc(clear_message, strlen(clear_message) + strlen(foundWord) + 1);
        strcat(clear_message, foundWord);

        free(foundWord);  // Освобождаем временную память
        current = current->next;
    }

    // Освобождаем список слов
    current = mots->head;
    while (current != NULL) {
        Node* next = current->next;
        free(current->data);
        free(current);
        current = next;
    }
    free(mots);

    return clear_message;
}
```
- **Аналог C++:** `std::string decode(...)`.
- **Логика:**
  1. Разбивает `message` на слова.
  2. Для каждого слова ищет замену через `findWord`.
  3. Собирает результат в строку `clear_message`, добавляя пробелы.
  4. Динамически расширяет память под результат с помощью `realloc`.
  5. Освобождает временные данные перед возвратом.

---

### **Функция `freeList` — освобождение памяти списка**
```c
void freeList(List* list) {
    Node* current = list->head;
    while (current != NULL) {
        Node* next = current->next;
        free(current->data);  // Освобождаем строку
        free(current);        // Освобождаем узел
        current = next;
    }
    free(list);              // Освобождаем саму структуру списка
}
```
- **Назначение:** Рекурсивно освобождает память, занятую списком и его элементами.

---

### **Тестовая функция `testDecode`**
```c
void testDecode() {
    List* words = (List*)malloc(sizeof(List));
    words->head = NULL;

    // Вручную создаем список слов (аналог std::list в C++)
    Node* node1 = (Node*)malloc(sizeof(Node));
    node1->data = strdup("hello");
    node1->next = NULL;
    words->head = node1;

    Node* node2 = (Node*)malloc(sizeof(Node));
    node2->data = strdup("mind");
    node2->next = NULL;
    node1->next = node2;

    // ... (аналогично добавляются остальные слова)

    const char* message = "hlelo feirnd how farme mnid organe screnliy";
    char* decoded = decode(words, message);
    printf("%s\n", decoded);  // Вывод: "hello friend how frame mind orange sincerly"

    free(decoded);
    freeList(words);  // Освобождаем память
}
```
- **Логика:**
  1. Создает список слов для теста.
  2. Вызывает `decode` для сообщения с перепутанными буквами.
  3. Проверяет, что слова восстанавливаются корректно.

---

### **Основные отличия от C++**
1. **Ручное управление памятью:** `malloc`, `realloc`, `free` вместо деструкторов.
2. **Нет классов и STL:** Связный список реализован вручную.
3. **Работа со строками:** `char*` и C-функции (`strlen`, `strchr`) вместо `std::string`.
4. **Отсутствие исключений:** Проверки ошибок опущены для краткости (в реальном коде нужны).

Этот код полностью повторяет логику оригинала, но соответствует стандарту C.




