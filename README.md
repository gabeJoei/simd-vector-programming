# simd-vector-programming
Members: Bactong, Gunita, Panganiban, Lobo

---
### i. Screenshot of  program output with execution time for all cases
![Fig_1](imgs/fig1.png)

Figure 1. Program output for case 2^20

---

![Fig_2](imgs/fig2.png)

Figure 2. Program output for case 2^26

---

![Fig_3](imgs/fig3.png)

Figure 3. Program output for case 2^29

### ii. Comparative Table
![Fig_4](imgs/fig4.png)
Figure 3. Comparitive Table of execution time, correctness, and boundary checks

### iii. Analysis and Discussion

## iv. problems encountered and solutions made
1. Machine Compatibility Issues
Problem: the program did not run consistently across different machines/computer. In particular, the program running on MacOS would crash before completing execution
Solution: We reviewed and adjusted some parts of the code where the crash starts, addressing the issues encountered when running the program on different machines

2. YMM Boundary Checking
Problem: The initial YMM implementation did not have a boundary checker to handle the elements that could not be processed in complete vector-sized groups.The starting position and handling of boundary elements were also incorrect. Solution: We added a boundary-checking mechanism to handle the remaining elements that could not be processed by the main vector loop.


