
Язык С++. Framework Google Test. Предложи варианты тестов для класса MyClass:
```cpp
namespace NS
{
struct transformRule
{
    std::vector<int> pattern;
    int result;
};
struct pointForPi
{
    double x;
    double y;
};
struct Change
{
    long coin2; //€2 coins
    long bill5;// €5 bill
    long bill10; // €10 bill
};
class MyClass
{
private:
    /* data */
public:

    static int getIndexOfHeaviest( int w0,int w1,int w2);

    static int computeSumOfMultiples(int n);

    static int findClosestTo(int arr[], int arraySize, int numToFind);

    static std::string getPasswordFromFiles(const std::vector<std::string>& files, const std::vector<std::string>& clues);

    static std::vector<std::vector<std::string>> computeBloodGenes(std::string parent1, std::string parent2, std::string child);

    static std::vector<std::vector<int>> getMatrixTransformedByRule( std::vector<std::vector<int>> grid, std::vector<CodinGameTests::transformRule> rules);

    static std::string reformatString(int n, const std::string str);

    static double calculateApproximateOfPi(std::vector<CodinGameTests::pointForPi> & pts);

    static bool optimalChange( long cashToGet, CodinGameTests::Change &coins);

    static std::string isDuoDigit( int numToCheck);

    static std::string isDuoDigitBasic( int numToCheck);

    static int getBit(unsigned int value, int pos);

    static bool getPatternInImage(
        int imageWidth, int imageHeight, std::vector<std::string> image,
        int patternWidth, int patternHeight, std::vector<std::string> pattern);

    static std::vector<int> replaceWithGreatestRight(int arr[], int nbElem );
    static bool isExist(int ints[], int size, int k);
    static std::vector<int>
    pair_with_sum_indices(const std::vector<int> &numbers, int k);
    static int findSmallestInterval(std::vector<int> numbers);
    static std::vector<int> countRotation(int n_cogwheels, std::vector<std::vector<int>> connections);
    static int countPath(std::vector<int> shops, std::vector<std::vector<int>> roads);
};
} 
```
