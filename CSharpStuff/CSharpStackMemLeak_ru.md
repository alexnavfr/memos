# Задача со стеком. Поиск утечки памяти.

## Prompt:
_Найти утечку в коде_

--- 

В вашем коде есть несколько проблем, которые могут приводить к утечкам памяти или другим ошибкам. Давайте разберём их и предложим исправления.  

### **Исходный код (с предполагаемыми ошибками):**
```csharp
class Stack
{
    private Object[] _items;  // Опечатка: "O bject" вместо "Object"
    private int _count;

    public void Push(object item)
    {
        if (_items == null || _count == _items.Length)
        {
            Resize();
        }
        _items[_count++] = item;
    }

    public object Pop()
    {
        if (_count == 0)
            throw new InvalidOperationException("Stack is empty");
        
        var item = _items[--_count];
        _items[_count] = null;  // Удаляем ссылку, чтобы не удерживать объект
        return item;
    }

    private void Resize()
    {
        int newCapacity = _items == null ? 4 : _items.Length * 2;
        var newArray = new Object[newCapacity];
        if (_items != null)
            Array.Copy(_items, newArray, _count);
        _items = newArray;
    }
}
```

### **Проблемы и исправления:**

#### **1. Опечатка в `Object[]` (`O bject` вместо `Object`)**
- Было: `private O bject[] _items;`
- Исправлено: `private object[] _items;` (или `Object[]`, но лучше `object` в C#)

#### **2. Утечка памяти при `Pop()`**
- В текущей реализации `Pop()` уменьшает `_count`, но не удаляет ссылку на объект, что может приводить к утечке памяти (если стек долго живёт, а объекты больше не нужны).
- **Исправление:**  
  ```csharp
  public object Pop()
  {
      if (_count == 0)
          throw new InvalidOperationException("Stack is empty");
      
      var item = _items[--_count];
      _items[_count] = null;  // Удаляем ссылку, чтобы GC мог собрать объект
      return item;
  }
  ```

#### **3. Неправильное начальное выделение памяти**
- Если `_items == null`, `Resize()` выделяет массив на 4 элемента, но если `Push` вызывается много раз, это может привести к частым ресайзам.
- **Оптимизация:** Можно добавить конструктор с начальной ёмкостью:
  ```csharp
  public Stack(int initialCapacity = 4)
  {
      _items = new object[initialCapacity];
  }
  ```

#### **4. Потенциальная утечка, если `Stack` не очищается**
- Если `Stack` долго живёт и в него много раз `Push`/`Pop`, массив `_items` может оставаться большим, даже если элементов мало.
- **Исправление:** Можно добавить метод `TrimExcess()`, который уменьшает массив:
  ```csharp
  public void TrimExcess()
  {
      if (_count < _items.Length / 2)
      {
          var newArray = new object[_count];
          Array.Copy(_items, newArray, _count);
          _items = newArray;
      }
  }
  ```

### **Итоговый исправленный код:**
```csharp
class Stack
{
    private object[] _items;
    private int _count;

    public Stack(int initialCapacity = 4)
    {
        _items = new object[initialCapacity];
    }

    public void Push(object item)
    {
        if (_count == _items.Length)
        {
            Resize();
        }
        _items[_count++] = item;
    }

    public object Pop()
    {
        if (_count == 0)
            throw new InvalidOperationException("Stack is empty");
        
        var item = _items[--_count];
        _items[_count] = null;  // Убираем ссылку для GC
        return item;
    }

    private void Resize()
    {
        int newCapacity = _items.Length * 2;
        var newArray = new object[newCapacity];
        Array.Copy(_items, newArray, _count);
        _items = newArray;
    }

    public void TrimExcess()
    {
        if (_count < _items.Length / 2)
        {
            var newArray = new object[_count];
            Array.Copy(_items, newArray, _count);
            _items = newArray;
        }
    }
}
```

### **Вывод:**
- Основная **утечка памяти** была в `Pop()` (объекты оставались в массиве, даже если не использовались).
- Добавлен **конструктор с начальным размером**, чтобы уменьшить реаллокации.
- Добавлен **`TrimExcess()`**, чтобы уменьшить потребление памяти, если стек сильно уменьшился.

Если у вас есть другие части кода, которые нужно проверить — присылайте! 🚀
