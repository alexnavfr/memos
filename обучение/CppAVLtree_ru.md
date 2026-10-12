# Что такое АВЛ (AVL) - деревья.

## Prompt:
_Расскажи кратко и точно что такое АВЛ деревья. Дай примеры._

**АВЛ-дерево** (или **AVL-дерево**) — это **сбалансированное двоичное дерево поиска**, в котором **разница высот** левого и правого поддеревьев **каждой вершины** не превышает 1.

Названо в честь изобретателей: **Адельсон-Вельский и Ландис** (1962 год).

---

### Основные свойства:

* Это **двоичное дерево поиска**: для каждой вершины все ключи в левом поддереве меньше, в правом — больше.
* **Балансировка** поддерживается автоматически при вставке и удалении элементов.
* Для восстановления баланса используются **ротации (повороты)**:

  * Однолевый (RR)
  * Одноправый (LL)
  * Лево-правый (LR)
  * Право-левый (RL)

---

### Пример:

Допустим, вставим в пустое АВЛ-дерево ключи: `10`, `20`, `30`.

1. Вставка `10`:

   ```
   10
   ```

2. Вставка `20`:

   ```
     10
       \
       20
   ```

3. Вставка `30`:

   ```
     10
       \
       20
         \
         30
   ```

   Это **несбалансированное дерево** (правое поддерево слишком высокое).
   Применяем **RR-ротацию**:

   После поворота:

   ```
     20
    /  \
   10  30
   ```

Теперь дерево снова сбалансировано.

---

### Применение:

* Базы данных
* Компиляторы
* Хранение отсортированных данных с быстрым доступом, вставкой и удалением

---

Вот пример **простого АВЛ-дерева на C++**, реализующего **вставку с балансировкой**.

---

### ✅ C++: Реализация вставки в АВЛ-дерево

```cpp
#include <iostream>
#include <algorithm>

struct Node {
    int key;
    Node* left;
    Node* right;
    int height;
    
    Node(int k) : key(k), left(nullptr), right(nullptr), height(1) {}
};

// Получаем высоту вершины
int height(Node* node) {
    return node ? node->height : 0;
}

// Обновляем высоту вершины
void updateHeight(Node* node) {
    node->height = 1 + std::max(height(node->left), height(node->right));
}

// Получаем баланс-фактор (разность высот)
int getBalance(Node* node) {
    return node ? height(node->left) - height(node->right) : 0;
}

// Правый поворот
Node* rotateRight(Node* y) {
    Node* x = y->left;
    Node* T2 = x->right;
    
    x->right = y;
    y->left = T2;
    
    updateHeight(y);
    updateHeight(x);
    
    return x;
}

// Левый поворот
Node* rotateLeft(Node* x) {
    Node* y = x->right;
    Node* T2 = y->left;
    
    y->left = x;
    x->right = T2;
    
    updateHeight(x);
    updateHeight(y);
    
    return y;
}

// Вставка с балансировкой
Node* insert(Node* node, int key) {
    if (!node)
        return new Node(key);
    
    if (key < node->key)
        node->left = insert(node->left, key);
    else if (key > node->key)
        node->right = insert(node->right, key);
    else // Дубликаты не допускаются
        return node;
    
    updateHeight(node);
    int balance = getBalance(node);

    // Балансировка
    if (balance > 1 && key < node->left->key)
        return rotateRight(node);           // LL

    if (balance < -1 && key > node->right->key)
        return rotateLeft(node);            // RR

    if (balance > 1 && key > node->left->key) {
        node->left = rotateLeft(node->left); // LR
        return rotateRight(node);
    }

    if (balance < -1 && key < node->right->key) {
        node->right = rotateRight(node->right); // RL
        return rotateLeft(node);
    }

    return node;
}

// Обход в прямом порядке
void printPreOrder(Node* root) {
    if (!root) return;
    std::cout << root->key << " ";
    printPreOrder(root->left);
    printPreOrder(root->right);
}

int main() {
    Node* root = nullptr;
    int keys[] = {10, 20, 30, 40, 50, 25};

    for (int key : keys)
        root = insert(root, key);

    std::cout << "Pre-order traversal of AVL tree:\n";
    printPreOrder(root);
    std::cout << std::endl;

    return 0;
}
```

---

### 📌 Что делает этот код:

* Вставляет значения в АВЛ-дерево
* Поддерживает балансировку через ротации
* Выводит дерево в **pre-order** (сначала корень, потом левый, потом правый)

Добавим в код **удаление** и **поиск** в АВЛ-дереве.

---

## 🔧 Обновлённый код АВЛ-дерева (C++): вставка, удаление, поиск

```cpp
#include <iostream>
#include <algorithm>

struct Node {
    int key;
    Node* left;
    Node* right;
    int height;
    
    Node(int k) : key(k), left(nullptr), right(nullptr), height(1) {}
};

int height(Node* node) {
    return node ? node->height : 0;
}

void updateHeight(Node* node) {
    node->height = 1 + std::max(height(node->left), height(node->right));
}

int getBalance(Node* node) {
    return node ? height(node->left) - height(node->right) : 0;
}

Node* rotateRight(Node* y) {
    Node* x = y->left;
    Node* T2 = x->right;
    
    x->right = y;
    y->left = T2;
    
    updateHeight(y);
    updateHeight(x);
    
    return x;
}

Node* rotateLeft(Node* x) {
    Node* y = x->right;
    Node* T2 = y->left;
    
    y->left = x;
    x->right = T2;
    
    updateHeight(x);
    updateHeight(y);
    
    return y;
}

Node* balance(Node* node) {
    updateHeight(node);
    int balance = getBalance(node);

    if (balance > 1 && getBalance(node->left) >= 0)
        return rotateRight(node); // LL

    if (balance > 1 && getBalance(node->left) < 0) {
        node->left = rotateLeft(node->left); // LR
        return rotateRight(node);
    }

    if (balance < -1 && getBalance(node->right) <= 0)
        return rotateLeft(node); // RR

    if (balance < -1 && getBalance(node->right) > 0) {
        node->right = rotateRight(node->right); // RL
        return rotateLeft(node);
    }

    return node;
}

Node* insert(Node* node, int key) {
    if (!node)
        return new Node(key);

    if (key < node->key)
        node->left = insert(node->left, key);
    else if (key > node->key)
        node->right = insert(node->right, key);
    else
        return node; // нет дубликатов

    return balance(node);
}

Node* minValueNode(Node* node) {
    while (node->left)
        node = node->left;
    return node;
}

Node* remove(Node* root, int key) {
    if (!root)
        return nullptr;

    if (key < root->key)
        root->left = remove(root->left, key);
    else if (key > root->key)
        root->right = remove(root->right, key);
    else {
        if (!root->left || !root->right) {
            Node* temp = root->left ? root->left : root->right;
            delete root;
            return temp;
        } else {
            Node* temp = minValueNode(root->right);
            root->key = temp->key;
            root->right = remove(root->right, temp->key);
        }
    }

    return balance(root);
}

bool search(Node* root, int key) {
    if (!root) return false;
    if (key == root->key) return true;
    return key < root->key ? search(root->left, key) : search(root->right);
}

void printPreOrder(Node* root) {
    if (!root) return;
    std::cout << root->key << " ";
    printPreOrder(root->left);
    printPreOrder(root->right);
}

int main() {
    Node* root = nullptr;
    int keys[] = {10, 20, 30, 40, 50, 25};

    for (int key : keys)
        root = insert(root, key);

    std::cout << "Pre-order after insertion:\n";
    printPreOrder(root);
    std::cout << "\n";

    // Поиск
    int target = 25;
    std::cout << "Search " << target << ": " << (search(root, target) ? "Found" : "Not Found") << "\n";

    // Удаление
    root = remove(root, 40);
    std::cout << "Pre-order after deleting 40:\n";
    printPreOrder(root);
    std::cout << "\n";

    return 0;
}
```

---

### 🧠 Что добавлено:

| Возможность      | Описание                                                                            |
| ---------------- | ----------------------------------------------------------------------------------- |
| `search()`       | Рекурсивный поиск значения в дереве                                                 |
| `remove()`       | Удаление элемента с последующей балансировкой                                       |
| `minValueNode()` | Нахождение минимального элемента в правом поддереве (нужно для замены при удалении) |

Так же балансировка была вынесена в отдельный метод `balance` для читаемости и по принципу DRY.

---


Хочешь — могу сделать визуализацию дерева в консоли или графически (Qt, SVG, текстово).



