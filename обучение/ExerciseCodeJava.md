# ExercisesJava из CodinGame

несколько задач которые я скопировал с теста на сайте CodinGame (CA CIB)

### Task 1 (40 min)

#### Prompt:
_задача на деревья. язык Java. создать метод `int compute(int startNodeId, List<Integer> fromIds, List<Integer> toIds)`which should return the last node id of the network found when starting from node with id `startNodeId` and folowing links of the network. `fromId` and `endIds` are two arrary the same lenght witch describe the one-way links of the network (fromIds[i] is linked to toIds[i]) In case you run into a loop when traversing the network, method shold return the id of the last node traversed befor closing the loop._

Here’s a Java implementation of the `compute` method that follows the given rules:  

### **Approach**
1. **Build a Graph:**  
   - Use a **HashMap** where each node maps to its next connected node.
2. **Traverse the Graph from `startNodeId`:**  
   - Use a **Set** to track visited nodes and detect loops.
   - If a node is **visited again**, return the last node before the loop.
   - If a node has **no outgoing edges**, return that node.

---

### **Java Implementation**
```java
import java.util.*;

public class NetworkTraversal {
    
    public static int compute(int startNodeId, List<Integer> fromIds, List<Integer> toIds) {
        // Step 1: Build the graph as a HashMap (directed adjacency list)
        Map<Integer, Integer> graph = new HashMap<>();
        for (int i = 0; i < fromIds.size(); i++) {
            graph.put(fromIds.get(i), toIds.get(i));
        }

        // Step 2: Traverse the network from startNodeId
        Set<Integer> visited = new HashSet<>();
        int currentNode = startNodeId;

        while (graph.containsKey(currentNode)) {
            if (visited.contains(currentNode)) {
                return currentNode; // Return last node before closing the loop
            }
            visited.add(currentNode);
            currentNode = graph.get(currentNode);
        }

        return currentNode; // Return last reachable node
    }

    public static void main(String[] args) {
        // Test Cases
        List<Integer> fromIds = Arrays.asList(1, 2, 3, 4, 5);
        List<Integer> toIds = Arrays.asList(2, 3, 4, 5, 3); // 5 → 3 creates a loop

        System.out.println(compute(1, fromIds, toIds)); // Expected: 3 (loop detected)

        fromIds = Arrays.asList(1, 2, 3);
        toIds = Arrays.asList(2, 3, 4); // No loops
        System.out.println(compute(1, fromIds, toIds)); // Expected: 4 (last node)
    }
}
```

---

### **Explanation**
1. **Graph Construction:**  
   - Uses a `HashMap<Integer, Integer>` to store `from → to` relationships.
2. **Traversal with Loop Detection:**  
   - Uses a `HashSet` to store visited nodes.
   - If a node appears twice, it means we encountered a **loop**, and we return the last traversed node.
   - If a node **has no outgoing edges**, we return it as the final destination.

---

### **Complexity Analysis**
- **Graph Construction:** `O(N)`  
- **Traversal:** `O(N)` (in worst case, visits each node once)  
- **Total Complexity:** **`O(N)`**  

🚀 This solution is efficient and handles both normal traversal and cycle detection! 🚀

### мои замечания по результатам. теста в CodinGame - провалились только 2 теста "SimpleLoop" "Cyrcle"

-----------

## Task 2
Prompt:
_implement in Java method will check if string is correct `boolean check(String str)`. return true if string is empty or `null`, string A, correct, string (A) correct, string (A) correct string A and B correct, string concatenation AB correct too. **Example**: String `[()]` is correct `(()[])` is correct. String `([)]` is not correct. `((` is not correct._

You need a method to check if a given string is **correct** based on the following criteria:  
1. **Empty or null strings are correct**  
2. **Single letters (A, B, etc.) are correct**  
3. **Parentheses/brackets must be balanced and properly nested**  
4. **Strings formed by concatenation of correct substrings are correct**  

This sounds like a **valid parentheses problem** combined with additional checks. Below is an implementation in Java using a **stack** to check balanced brackets and a recursive approach to handle concatenation:  

---

### **Java Implementation**
```java
import java.util.Stack;

public class StringChecker {
    
    public static boolean check(String str) {
        if (str == null || str.isEmpty()) return true;  // Rule 1: Empty or null is correct
        if (str.matches("[A-Z]+")) return true;         // Rule 2: Single letters (A, B, ...) are correct
        
        if (isBalanced(str)) return true;               // Rule 3: Balanced brackets check
        
        // Rule 4: Check if the string is a valid concatenation of correct substrings
        for (int i = 1; i < str.length(); i++) {
            String left = str.substring(0, i);
            String right = str.substring(i);
            if (check(left) && check(right)) {
                return true;
            }
        }
        
        return false;
    }

    // Helper method to check balanced brackets using a Stack
    private static boolean isBalanced(String str) {
        Stack<Character> stack = new Stack<>();
        for (char ch : str.toCharArray()) {
            if (ch == '(' || ch == '[' || ch == '{') {
                stack.push(ch);
            } else if (ch == ')' || ch == ']' || ch == '}') {
                if (stack.isEmpty()) return false;
                char open = stack.pop();
                if (!matches(open, ch)) return false;
            }
        }
        return stack.isEmpty();
    }

    // Helper method to check if brackets match
    private static boolean matches(char open, char close) {
        return (open == '(' && close == ')') || 
               (open == '[' && close == ']') || 
               (open == '{' && close == '}');
    }

    // Test cases
    public static void main(String[] args) {
        System.out.println(check(null));           // true
        System.out.println(check(""));             // true
        System.out.println(check("A"));            // true
        System.out.println(check("(A)"));          // true
        System.out.println(check("AB"));           // true
        System.out.println(check("(){}[]"));       // true
        System.out.println(check("[()]"));         // true
        System.out.println(check("((){})"));       // true
        System.out.println(check("([)]"));         // false
        System.out.println(check("((("));          // false
        System.out.println(check(")("));           // false
    }
}
```

---

### **Explanation**
1. **Base Cases:**
   - If the string is `null` or empty → **Return `true`**
   - If the string contains only `A-Z` → **Return `true`**
   
2. **Bracket Checking:**
   - Uses a **stack** to ensure the brackets `()[]{}` are balanced.
   
3. **Concatenation Checking:**
   - Recursively checks if the string can be split into **two correct substrings**.

---

### **Test Cases**
| Input       | Expected Output |
|-------------|----------------|
| `null`      | ✅ `true`       |
| `""`        | ✅ `true`       |
| `"A"`       | ✅ `true`       |
| `"(A)"`     | ✅ `true`       |
| `"AB"`      | ✅ `true`       |
| `"()"`      | ✅ `true`       |
| `"[()]"`    | ✅ `true`       |
| `"((){})"`  | ✅ `true`       |
| `"([)]"`    | ❌ `false`      |
| `"((("`     | ❌ `false`      |
| `")("`      | ❌ `false`      |

---

This approach ensures correctness while maintaining efficiency. 🚀

### Вывод все тесты прошли!!!!