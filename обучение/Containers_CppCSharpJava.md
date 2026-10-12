# Сравнительная таблица контейнеров на C++/C#/Java.

### Prompt:
_Подготовь сравнительную таблицу контейнеров (like std::list) для языков С++/C#/Java с примерами использования_

Вот сравнительная таблица контейнеров для хранения последовательных элементов (аналог `std::list` в C++) в C++, C# и Java:

| **Язык**  | **Контейнер**      | **Основан на**       | **Доступ по индексу** | **Быстрое удаление/вставка** | **Пример использования** |
|-----------|--------------------|----------------------|------------------------|-----------------------------|--------------------------|
| **C++**   | `std::list<T>`     | Двусвязный список   | ❌ (нет `operator[]`)  | ✅ (O(1) в середине)       | ```cpp<br>#include <list><br>#include <iostream><br>int main() { std::list<int> lst = {1, 2, 3}; lst.push_back(4); lst.remove(2); for (int x : lst) std::cout << x << " "; return 0; }``` |
| **C++**   | `std::vector<T>`   | Динамический массив | ✅ (O(1))              | ❌ (O(n) в середине)       | ```cpp<br>#include <vector><br>#include <iostream><br>int main() { std::vector<int> vec = {1, 2, 3}; vec.push_back(4); vec.erase(vec.begin() + 1); for (int x : vec) std::cout << x << " "; return 0; }``` |
| **C#**    | `LinkedList<T>`    | Двусвязный список   | ❌ (нет `[]`)          | ✅ (O(1) в середине)       | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { LinkedList<int> lst = new LinkedList<int>(new int[] {1, 2, 3}); lst.AddLast(4); lst.Remove(2); foreach (int x in lst) Console.Write(x + " "); } }``` |
| **C#**    | `List<T>`          | Динамический массив | ✅ (O(1))              | ❌ (O(n) в середине)       | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { List<int> list = new List<int> {1, 2, 3}; list.Add(4); list.RemoveAt(1); foreach (int x in list) Console.Write(x + " "); } }``` |
| **Java**  | `LinkedList<T>`    | Двусвязный список   | ❌ (O(n) доступ)       | ✅ (O(1) в середине)       | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { LinkedList<Integer> lst = new LinkedList<>(Arrays.asList(1, 2, 3)); lst.add(4); lst.remove(Integer.valueOf(2)); for (int x : lst) System.out.print(x + " "); } }``` |
| **Java**  | `ArrayList<T>`     | Динамический массив | ✅ (O(1))              | ❌ (O(n) в середине)       | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { ArrayList<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3)); list.add(4); list.remove(1); for (int x : list) System.out.print(x + " "); } }``` |

### Выбор контейнера:
- **Если нужны быстрые вставка/удаление в середине** → `std::list` (C++), `LinkedList<T>` (C#/Java).
- **Если важен быстрый доступ по индексу** → `std::vector` (C++), `List<T>` (C#), `ArrayList<T>` (Java).
- **Если неизвестно заранее** → Обычно динамический массив (`std::vector`, `List<T>`, `ArrayList<T>`) быстрее и эффективнее.


Привожу аналогичные сравнительные таблицы для различных типов контейнеров в C++, C# и Java.  

---

## **1. Очереди (Queue, Deque)**
| **Язык**  | **Контейнер**          | **Основан на**        | **FIFO (O(1))** | **Двунаправленная** | **Пример использования** |
|-----------|------------------------|-----------------------|-----------------|----------------------|--------------------------|
| **C++**   | `std::queue<T>`        | Однонаправленная очередь на `std::deque` | ✅ | ❌ | ```cpp<br>#include <queue><br>#include <iostream><br>int main() { std::queue<int> q; q.push(1); q.push(2); q.pop(); std::cout << q.front(); return 0; }``` |
| **C++**   | `std::deque<T>`        | Двунаправленная очередь | ✅ | ✅ | ```cpp<br>#include <deque><br>#include <iostream><br>int main() { std::deque<int> dq = {1, 2, 3}; dq.push_front(0); dq.pop_back(); for (int x : dq) std::cout << x << " "; return 0; }``` |
| **C#**    | `Queue<T>`             | Очередь FIFO | ✅ | ❌ | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { Queue<int> q = new Queue<int>(); q.Enqueue(1); q.Enqueue(2); q.Dequeue(); Console.Write(q.Peek()); } }``` |
| **C#**    | `LinkedList<T>`        | Двунаправленный список | ✅ | ✅ | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { LinkedList<int> dq = new LinkedList<int>(); dq.AddFirst(1); dq.AddLast(2); dq.RemoveFirst(); Console.Write(dq.First.Value); } }``` |
| **Java**  | `Queue<T>` (`LinkedList`) | Связанный список | ✅ | ❌ | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { Queue<Integer> q = new LinkedList<>(); q.add(1); q.add(2); q.poll(); System.out.println(q.peek()); } }``` |
| **Java**  | `Deque<T>` (`LinkedList`) | Двунаправленный список | ✅ | ✅ | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { Deque<Integer> dq = new LinkedList<>(); dq.addFirst(1); dq.addLast(2); dq.removeFirst(); System.out.println(dq.peekFirst()); } }``` |

---

## **2. Стек (Stack)**
| **Язык**  | **Контейнер**       | **Основан на**      | **LIFO (O(1))** | **Пример использования** |
|-----------|---------------------|---------------------|-----------------|--------------------------|
| **C++**   | `std::stack<T>`     | `std::deque<T>`     | ✅ | ```cpp<br>#include <stack><br>#include <iostream><br>int main() { std::stack<int> s; s.push(1); s.push(2); s.pop(); std::cout << s.top(); return 0; }``` |
| **C#**    | `Stack<T>`          | `List<T>`          | ✅ | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { Stack<int> s = new Stack<int>(); s.Push(1); s.Push(2); s.Pop(); Console.Write(s.Peek()); } }``` |
| **Java**  | `Stack<T>`          | `Vector<T>`        | ✅ | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { Stack<Integer> s = new Stack<>(); s.push(1); s.push(2); s.pop(); System.out.println(s.peek()); } }``` |

---

## **3. Множества (Set, HashSet, TreeSet)**
| **Язык**  | **Контейнер**         | **Основан на**        | **Уникальные элементы** | **Сортировка** | **Поиск (O(1)/O(log n))** | **Пример использования** |
|-----------|-----------------------|-----------------------|------------------------|----------------|--------------------------|--------------------------|
| **C++**   | `std::set<T>`         | Красно-черное дерево | ✅ | ✅ | O(log n) | ```cpp<br>#include <set><br>#include <iostream><br>int main() { std::set<int> s = {3, 1, 2}; s.insert(4); std::cout << *s.begin(); return 0; }``` |
| **C++**   | `std::unordered_set<T>` | Хеш-таблица | ✅ | ❌ | O(1) | ```cpp<br>#include <unordered_set><br>#include <iostream><br>int main() { std::unordered_set<int> s = {3, 1, 2}; s.insert(4); std::cout << s.count(2); return 0; }``` |
| **C#**    | `HashSet<T>`          | Хеш-таблица | ✅ | ❌ | O(1) | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { HashSet<int> s = new HashSet<int> {3, 1, 2}; s.Add(4); Console.Write(s.Contains(2)); } }``` |
| **C#**    | `SortedSet<T>`        | Красно-черное дерево | ✅ | ✅ | O(log n) | ```csharp<br>using System;<br>using System.Collections.Generic;<br>class Program { static void Main() { SortedSet<int> s = new SortedSet<int> {3, 1, 2}; Console.Write(s.Min); } }``` |
| **Java**  | `HashSet<T>`          | Хеш-таблица | ✅ | ❌ | O(1) | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { Set<Integer> s = new HashSet<>(Arrays.asList(3, 1, 2)); s.add(4); System.out.println(s.contains(2)); } }``` |
| **Java**  | `TreeSet<T>`          | Красно-черное дерево | ✅ | ✅ | O(log n) | ```java<br>import java.util.*;<br>public class Main { public static void main(String[] args) { TreeSet<Integer> s = new TreeSet<>(Arrays.asList(3, 1, 2)); System.out.println(s.first()); } }``` |

---

## **4. Отображения (Map, Dictionary)**
| **Язык**  | **Контейнер**           | **Основан на**        | **Поиск (O(1)/O(log n))** | **Упорядоченность** | **Пример использования** |
|-----------|-------------------------|-----------------------|--------------------------|----------------------|--------------------------|
| **C++**   | `std::map<K, V>`        | Красно-черное дерево | O(log n) | ✅ | ```cpp<br>#include <map><br>#include <iostream><br>int main() { std::map<int, std::string> m = {{1, "one"}}; m[2] = "two"; std::cout << m[1]; return 0; }``` |
| **C++**   | `std::unordered_map<K, V>` | Хеш-таблица | O(1) | ❌ | ```cpp<br>#include <unordered_map><br>#include <iostream><br>int main() { std::unordered_map<int, std::string> m = {{1, "one"}}; std::cout << m[1]; return 0; }``` |
| **C#**    | `Dictionary<K, V>`       | Хеш-таблица | O(1) | ❌ | ```csharp<br>using System; using System.Collections.Generic; class Program { static void Main() { Dictionary<int, string> d = new Dictionary<int, string> { {1, "one"} }; Console.Write(d[1]); } }``` |
| **Java**  | `HashMap<K, V>`          | Хеш-таблица | O(1) | ❌ | ```java<br>import java.util.*; public class Main { public static void main(String[] args) { HashMap<Integer, String> m = new HashMap<>(); m.put(1, "one"); System.out.println(m.get(1)); } }``` |

---

Это основные контейнеры с их сравнением и примерами.
