# Безопасная сумма в С#

## Prompt:
_Consider the following:
~~~csharp
List<int> nums = Enumerable.Range(1, 1000000).toList();
int sum = 0;
Parallel.forEach(nums,(num) => 
{
    sum += num
});
Console.WriteLine($"sum: {sum}");
~~~
Which  statements accurately describe the behavior of this  C# code_

The provided C# code attempts to calculate the sum of numbers from 1 to 1,000,000 using `Parallel.ForEach`, but it has a **critical thread-safety issue** due to **unsynchronized access to the shared `sum` variable**. Here are the accurate statements describing its behavior:

### **Key Issues & Behavior**:
1. **Race Condition**:
   - `sum += num` is **not thread-safe**. Multiple threads can read and modify `sum` simultaneously, leading to **lost updates**.
   - The final `sum` will likely be **less than the correct value** (500,000,500,000 for 1 to 1,000,000) due to race conditions.

2. **No Atomicity/Thread Safety**:
   - `sum` is an `int`, and `+=` is not an atomic operation (it involves read-modify-write steps).
   - No synchronization mechanism (e.g., `lock`, `Interlocked`, or `Concurrent` collections) is used.

3. **Parallel.ForEach Behavior**:
   - `Parallel.ForEach` splits `nums` into chunks and processes them across multiple threads.
   - Since `sum` is shared, threads **interfere** with each other unpredictably.

4. **Output Variability**:
   - Each run may produce a **different (incorrect) result** due to race conditions.

---

### **Corrected Approaches**:
#### **1. Use `Interlocked.Add` for Atomic Updates**
```csharp
int sum = 0;
Parallel.ForEach(nums, num => 
{
    Interlocked.Add(ref sum, num); // Thread-safe atomic addition
});
Console.WriteLine($"Sum: {sum}"); // Correct: 500000500000
```

#### **2. Use PLINQ (`Sum()` with AsParallel)**
```csharp
int sum = nums.AsParallel().Sum(); // Built-in thread-safe aggregation
Console.WriteLine($"Sum: {sum}"); // Correct: 500000500000
```

#### **3. Use `lock` (Slower but Safe)**
```csharp
object lockObj = new object();
int sum = 0;
Parallel.ForEach(nums, num => 
{
    lock (lockObj) { sum += num; } // Thread-safe but slower
});
Console.WriteLine($"Sum: {sum}");
```

---

### **Accurate Statements About the Original Code**:
✅ **The code compiles but produces incorrect results due to race conditions.**  
✅ **Multiple threads modify `sum` concurrently without synchronization.**  
✅ **The final value of `sum` will be less than the expected sum (500,000,500,000).**  
✅ **The result varies between runs because of unsynchronized access.**  
❌ **The code correctly calculates the sum of numbers from 1 to 1,000,000.** *(False, due to race conditions)*  

### **Why Avoid `Parallel.ForEach` with Shared Variables?**
- **Performance Pitfall**: Contention on shared state (`sum`) can make parallel code **slower** than sequential code.
- **Correctness Risk**: Race conditions lead to **non-deterministic bugs**.

### **Best Practice**:
Use **thread-safe constructs** (`Interlocked`, PLINQ, or immutable data) for parallel aggregation in C#. For summing, `AsParallel().Sum()` is the simplest and most efficient solution.
