# Реализация LRU-кэша.

## Prompt:
_Как реализовать кэш с ограниченным размером и политикой LRU (Least Recently Used) с использованием контейнеров STL? Дай объяснение каждой строки._

# Реализация LRU-кэша с использованием STL контейнеров

LRU (Least Recently Used) - это политика вытеснения из кэша элементов, которые дольше всего не использовались. Вот реализация с использованием `std::list` и `std::unordered_map`:

```cpp
#include <list>
#include <unordered_map>
#include <iostream>

template <typename Key, typename Value>
class LRUCache {
private:
    // Список для хранения ключей в порядке их использования (от недавних к старым)
    std::list<Key> recentList;
    
    // Хеш-таблица для быстрого доступа к данным по ключу
    // Хранит пары (ключ, итератор на позицию в recentList)
    std::unordered_map<Key, std::pair<Value, typename std::list<Key>::iterator>> cacheMap;
    
    // Максимальный размер кэша
    size_t capacity;

public:
    // Конструктор, принимающий максимальный размер кэша
    LRUCache(size_t capacity) : capacity(capacity) {}
    
    // Проверка наличия ключа в кэше
    bool contains(const Key& key) const {
        return cacheMap.find(key) != cacheMap.end();
    }
    
    // Получение значения по ключу
    Value& get(const Key& key) {
        auto it = cacheMap.find(key);
        if (it == cacheMap.end()) {
            throw std::out_of_range("Key not found in cache");
        }
        
        // Перемещаем ключ в начало списка (как недавно использованный)
        recentList.splice(recentList.begin(), recentList, it->second.second);
        
        // Обновляем итератор в хеш-таблице
        it->second.second = recentList.begin();
        
        return it->second.first;
    }
    
    // Добавление или обновление значения в кэше
    void put(const Key& key, const Value& value) {
        auto it = cacheMap.find(key);
        
        if (it != cacheMap.end()) {
            // Ключ уже существует - обновляем значение и перемещаем в начало
            it->second.first = value;
            recentList.splice(recentList.begin(), recentList, it->second.second);
            it->second.second = recentList.begin();
        } else {
            // Новый ключ - проверяем, не превышен ли размер кэша
            if (cacheMap.size() >= capacity) {
                // Удаляем самый старый элемент (последний в списке)
                Key lastKey = recentList.back();
                cacheMap.erase(lastKey);
                recentList.pop_back();
            }
            
            // Добавляем новый элемент в начало списка
            recentList.push_front(key);
            
            // Сохраняем в хеш-таблице значение и итератор на позицию в списке
            cacheMap[key] = {value, recentList.begin()};
        }
    }
    
    // Вспомогательная функция для вывода содержимого кэша (для демонстрации)
    void printCache() const {
        std::cout << "LRU Cache (capacity " << capacity << ", size " << cacheMap.size() << "):\n";
        for (const auto& key : recentList) {
            std::cout << key << " => " << cacheMap.at(key).first << "\n";
        }
        std::cout << std::endl;
    }
};
```

## Построчное объяснение:

1. **Шаблон класса**: `template <typename Key, typename Value>` - делает кэш универсальным для любых типов ключей и значений.

2. **Контейнеры**:
   - `std::list<Key> recentList` - хранит ключи в порядке их использования (первый элемент - последний использованный).
   - `std::unordered_map<Key, std::pair<Value, typename std::list<Key>::iterator>> cacheMap` - хеш-таблица, которая для каждого ключа хранит пару (значение, итератор на позицию в списке).

3. **Конструктор**: `LRUCache(size_t capacity)` - инициализирует максимальный размер кэша.

4. **Метод contains**: проверяет наличие ключа в кэше без изменения порядка элементов.

5. **Метод get**:
   - Ищет ключ в хеш-таблице.
   - Если ключ найден, перемещает его в начало списка с помощью `splice` (эффективная операция для списка).
   - Обновляет итератор в хеш-таблице.
   - Возвращает значение.

6. **Метод put**:
   - Если ключ уже существует, обновляет его значение и перемещает в начало списка.
   - Если ключ новый:
     - При превышении размера удаляет последний элемент из списка и соответствующий элемент из хеш-таблицы.
     - Добавляет новый ключ в начало списка.
     - Сохраняет в хеш-таблице значение и итератор на позицию в списке.

7. **Метод printCache**: вспомогательная функция для вывода содержимого кэша.

## Пример использования:

```cpp
int main() {
    LRUCache<int, std::string> cache(3);
    
    cache.put(1, "one");
    cache.put(2, "two");
    cache.put(3, "three");
    cache.printCache();  // 3 => three, 2 => two, 1 => one
    
    cache.get(2);        // Делаем ключ 2 недавно использованным
    cache.printCache();  // 2 => two, 3 => three, 1 => one
    
    cache.put(4, "four"); // Вытесняется ключ 1 (самый старый)
    cache.printCache();  // 4 => four, 2 => two, 3 => three
    
    return 0;
}
```

Эта реализация обеспечивает:
- \(O(1)\) для операций вставки и доступа (благодаря хеш-таблице)
- Эффективное перемещение элементов в списке (операция `splice` работает за \(O(1)\).
- Автоматическое вытеснение самых старых элементов при превышении размера
- 