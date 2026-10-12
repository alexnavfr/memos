/**
 * @file person.cpp
 * @brief Класс для работы с персонами
 * @author Alexandre Nepomniachtchi
 * @date 2024-11-19
 * @version 1.0
 * @copyright Copyright (c) 2024 Home
 */
// 
#include <iostream>
#include <vector>
#include <string>
#include <memory>
#include <algorithm>
#include <cmath>

// Макросы
#define PI 3.14159
#define SQUARE(x) ((x) * (x))

// Перечисления
enum class Color 
{ 
    RED, 
    GREEN, 
    BLUE 
};

// Структуры
struct Point 
{
    int x;
    int y;
};

// Класс с наследованием
class Shape 
{
public:
    Shape(Color c) : color(c) {}
    virtual ~Shape() = default;
    virtual double area() const = 0;

protected:
    Color color;
};

class Circle : public Shape 
{
public:
    Circle(double r, Color c) : Shape(c), radius(r) {}

    double area() const override 
    {
        return PI * SQUARE(radius);
    }

private:
    double radius;
};

// Шаблонная функция
template <typename T>
T maxValue(const T& a, const T& b) 
{
    return (a > b) ? a : b;
}

// Пространства имен
namespace MathUtils 
{
    double distance(const Point& a, const Point& b) 
    {
        return std::sqrt(SQUARE(a.x - b.x) + SQUARE(a.y - b.y));
    }
}

// Основная функция
int main(int argc, char* argv[]) 
{
    // Переменные и константы
    const int size = 10;
    auto name = std::string("Example");

    // Условные операторы
    if (argc > 1) 
    {
        std::cout << "Arguments provided: " << argc - 1 << std::endl;
    } 
    else 
    {
        std::cout << "No arguments provided" << std::endl;
    }

    // Циклы
    for (int i = 0; i < size; ++i) 
    {
        std::cout << i << " ";
    }
    std::cout << std::endl;

    int j = 0;
    while (j < size) 
    {
        std::cout << j << " ";
        ++j;
    }
    std::cout << std::endl;

    // Контейнеры STL
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    std::for_each(numbers.begin(), numbers.end(), [](int n) 
    {
        std::cout << n << " ";
    });
    std::cout << std::endl;

    // Умные указатели
    auto circle = std::make_unique<Circle>(5.0, Color::RED);
    std::cout << "Circle area: " << circle->area() << std::endl;

    // Обработка исключений
    try 
    {
        if (size == 0) 
        {
            throw std::runtime_error("Size cannot be zero");
        }
        std::cout << "100 / size = " << 100 / size << std::endl;
    } 
    catch (const std::exception& e) 
    {
        std::cerr << "Error: " << e.what() << std::endl;
    }

    // Использование шаблонной функции
    std::cout << "Max value: " << maxValue(5, 10) << std::endl;

    // Использование пространства имен
    Point a{1, 2}, b{4, 6};
    std::cout << "Distance: " << MathUtils::distance(a, b) << std::endl;

    return 0;
}
