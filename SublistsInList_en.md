### **Finding All Possible Sublists in a List (C# and C++)**
A sublist of a given list is any contiguous or non-contiguous subset of elements. We can generate all possible sublists using **bit masking (for subsets)** or **nested loops (for contiguous subarrays)**.

---

## **Solution in C# (All Sublists Using Bitmasking)**
This solution generates all possible sublists, including both contiguous and non-contiguous sublists.  
```csharp
using System;
using System.Collections.Generic;

class Program
{
    static List<List<int>> GetAllSublists(int[] arr)
    {
        int n = arr.Length;
        List<List<int>> result = new List<List<int>>();
        int totalSubsets = 1 << n; // 2^n subsets

        for (int i = 0; i < totalSubsets; i++)
        {
            List<int> sublist = new List<int>();
            for (int j = 0; j < n; j++)
            {
                if ((i & (1 << j)) != 0) // Check if the j-th bit is set
                {
                    sublist.Add(arr[j]);
                }
            }
            result.Add(sublist);
        }
        return result;
    }

    static void Main()
    {
        int[] arr = { 1, 2, 3 };
        List<List<int>> sublists = GetAllSublists(arr);

        Console.WriteLine("All Possible Sublists:");
        foreach (var sublist in sublists)
        {
            Console.WriteLine("[" + string.Join(", ", sublist) + "]");
        }
    }
}
```
### **Explanation:**
- We iterate through all **2ⁿ possible subsets** using bitwise operations.
- Each bit in the number `i` represents whether the element at that position is included.
- The result contains all **contiguous and non-contiguous** sublists.

---

## **Solution in C++ (All Sublists Using Bitmasking)**
This approach is similar to the C# solution but implemented in C++.

```cpp
#include <iostream>
#include <vector>

using namespace std;

vector<vector<int>> getAllSublists(vector<int>& arr) {
    int n = arr.size();
    vector<vector<int>> result;
    int totalSubsets = 1 << n; // 2^n subsets

    for (int i = 0; i < totalSubsets; i++) {
        vector<int> sublist;
        for (int j = 0; j < n; j++) {
            if (i & (1 << j)) { // Check if the j-th bit is set
                sublist.push_back(arr[j]);
            }
        }
        result.push_back(sublist);
    }
    return result;
}

int main() {
    vector<int> arr = {1, 2, 3};
    vector<vector<int>> sublists = getAllSublists(arr);

    cout << "All Possible Sublists:\n";
    for (const auto& sublist : sublists) {
        cout << "[";
        for (size_t i = 0; i < sublist.size(); i++) {
            cout << sublist[i] << (i < sublist.size() - 1 ? ", " : "");
        }
        cout << "]\n";
    }
    return 0;
}
```
### **Explanation:**
- We generate **all subsets** using a **bitmasking approach**.
- Each subset is built by checking which bits are set in the **binary representation** of numbers from `0` to `2ⁿ-1`.

---

## **Alternative: Finding Only Contiguous Sublists**
If you need only **contiguous sublists** (subarrays), you can use a **nested loop**.

### **C# Solution (Only Contiguous Sublists)**
```csharp
using System;
using System.Collections.Generic;

class Program
{
    static List<List<int>> GetContiguousSublists(int[] arr)
    {
        List<List<int>> result = new List<List<int>>();
        int n = arr.Length;

        for (int i = 0; i < n; i++)
        {
            List<int> sublist = new List<int>();
            for (int j = i; j < n; j++)
            {
                sublist.Add(arr[j]);
                result.Add(new List<int>(sublist)); // Store a copy
            }
        }
        return result;
    }

    static void Main()
    {
        int[] arr = { 1, 2, 3 };
        List<List<int>> sublists = GetContiguousSublists(arr);

        Console.WriteLine("Contiguous Sublists:");
        foreach (var sublist in sublists)
        {
            Console.WriteLine("[" + string.Join(", ", sublist) + "]");
        }
    }
}
```

### **C++ Solution (Only Contiguous Sublists)**
```cpp
#include <iostream>
#include <vector>

using namespace std;

vector<vector<int>> getContiguousSublists(vector<int>& arr) {
    vector<vector<int>> result;
    int n = arr.size();

    for (int i = 0; i < n; i++) {
        vector<int> sublist;
        for (int j = i; j < n; j++) {
            sublist.push_back(arr[j]);
            result.push_back(sublist);
        }
    }
    return result;
}

int main() {
    vector<int> arr = {1, 2, 3};
    vector<vector<int>> sublists = getContiguousSublists(arr);

    cout << "Contiguous Sublists:\n";
    for (const auto& sublist : sublists) {
        cout << "[";
        for (size_t i = 0; i < sublist.size(); i++) {
            cout << sublist[i] << (i < sublist.size() - 1 ? ", " : "");
        }
        cout << "]\n";
    }
    return 0;
}
```

### **Comparison of Approaches**
| Approach | Includes Non-Contiguous Sublists? | Complexity |
|----------|---------------------------------|------------|
| **Bitmasking (Subsets)** | ✅ Yes | **O(2ⁿ \** n)** |
| **Nested Loops (Contiguous Sublists)** | ❌ No | **O(n²)** |


### **Conclusion**
- **Use bitmasking** if you need **all subsets (including non-contiguous)**.
- **Use nested loops** if you need **only contiguous sublists**.

Would you like an optimized approach for larger datasets? 🚀

