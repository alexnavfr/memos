# Временный файл с решением.

## Prompt:
_давай создадим метод `List<string> Parse(string data, List<string> d)` который на вход получает строку `data` и словарь `d` анализирует строку и на основании словаря возвращает список всех возможных комбинаций слов, которые образуют исходную строку. На каком алгоритме будет основано решение. Построчно прокомментируй код._


```csharp
using System;
using System.Collections.Generic;
using System.Linq;

public class StringParser
{
    // Кеш для мемоизации результатов, чтобы избежать повторных вычислений
    private Dictionary<string, List<List<string>>> memo = new Dictionary<string, List<List<string>>>();
    
    /// <summary>
    /// Основной метод для разбора строки на все возможные комбинации слов из словаря
    /// </summary>
    /// <param name="data">Исходная строка для разбора</param>
    /// <param name="d">Словарь доступных слов</param>
    /// <returns>Список строк, каждая из которых представляет одну возможную комбинацию слов</returns>
    public List<string> Parse(string data, List<string> d)
    {
        // Очищаем кеш перед началом работы
        memo.Clear();
        
        // Преобразуем список в HashSet для быстрого поиска O(1)
        HashSet<string> dictionary = new HashSet<string>(d);
        
        // Получаем все возможные разбиения строки
        List<List<string>> allCombinations = ParseRecursive(data, dictionary);
        
        // Преобразуем список списков слов в список строк, соединяя слова пробелами
        return allCombinations.Select(combination => string.Join(" ", combination)).ToList();
    }
    
    /// <summary>
    /// Рекурсивный метод для поиска всех возможных разбиений строки
    /// </summary>
    /// <param name="s">Строка для разбора</param>
    /// <param name="dictionary">Словарь доступных слов</param>
    /// <returns>Список всех возможных разбиений в виде списка списков слов</returns>
    private List<List<string>> ParseRecursive(string s, HashSet<string> dictionary)
    {
        // Проверяем, есть ли уже результат в кеше
        if (memo.ContainsKey(s))
        {
            return memo[s];
        }
        
        // Список для хранения всех найденных комбинаций для текущей строки
        List<List<string>> result = new List<List<string>>();
        
        // Базовый случай: если строка пустая, возвращаем список с одним пустым списком
        if (string.IsNullOrEmpty(s))
        {
            result.Add(new List<string>());
            return result;
        }
        
        // Перебираем все возможные префиксы строки
        for (int i = 1; i <= s.Length; i++)
        {
            // Извлекаем префикс текущей длины
            string prefix = s.Substring(0, i);
            
            // Проверяем, есть ли этот префикс в словаре
            if (dictionary.Contains(prefix))
            {
                // Получаем оставшуюся часть строки после префикса
                string remaining = s.Substring(i);
                
                // Рекурсивно получаем все возможные разбиения оставшейся части
                List<List<string>> subResults = ParseRecursive(remaining, dictionary);
                
                // Для каждого разбиения оставшейся части создаем новую комбинацию
                foreach (List<string> subResult in subResults)
                {
                    // Создаем новый список, начинающийся с текущего префикса
                    List<string> newCombination = new List<string> { prefix };
                    
                    // Добавляем все слова из разбиения оставшейся части
                    newCombination.AddRange(subResult);
                    
                    // Добавляем эту комбинацию к результатам
                    result.Add(newCombination);
                }
            }
        }
        
        // Сохраняем результат в кеше для избежания повторных вычислений
        memo[s] = result;
        
        return result;
    }
}

// Пример использования
public class Program
{
    public static void Main()
    {
        StringParser parser = new StringParser();
        
        // Тестовые данные
        string data = "catsanddog";
        List<string> dictionary = new List<string> { "cat", "cats", "and", "sand", "dog" };
        
        // Получаем все возможные комбинации
        List<string> combinations = parser.Parse(data, dictionary);
        
        // Выводим результаты
        Console.WriteLine($"Исходная строка: {data}");
        Console.WriteLine($"Словарь: [{string.Join(", ", dictionary)}]");
        Console.WriteLine("Все возможные комбинации:");
        
        foreach (string combination in combinations)
        {
            Console.WriteLine($"- {combination}");
        }
    }
}
``