#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <float.h>
#include "cVersion.c"

//extern void xmm(float scalarVal, float *vec, float *Xi, float *Yi, int size);
extern void x86_64(float scalarVal,float *vec, float *Xi, float *Yi, int size);
extern void ymm(float scalarVal,float *vec, float *Xi, float *Yi, int size);

/*Function that prints the first 5 and last 5 elements of a vector*/
void printVectors(float *vecC, float *vecAsm, int size, char *name) {
    printf("Version %s against C (sanity checker)\n", name);
    printf("First 5 elements of the C version: ");
    for (int i=0;i<5;i++) {
        printf("%f ", vecC[i]);
    }
    printf("\nFirst 5 elements of the %s version: ", name);
    for (int i=0;i<5;i++) {
        printf("%f ", vecAsm[i]);
    }
    printf("\nLast 5 elements of the C version: ");
    for (int i=size-5;i<size;i++) {
        printf("%f ", vecC[i]);
    }
    printf("\nLast 5 elements of the %s version: ", name);
    for (int i=size-5;i<size;i++) {
        printf("%f ", vecAsm[i]);
    }
    printf("\n\n");
}

/*Function that compares the elements of four vectors*/
void comparisonChecker(float *vecC, float *asmVec, int size, char *name) {
    for (int i = 0; i < size; i++) {
        if (vecC[i] != asmVec[i]) {
            printf("Mismatch found at index %d: C=%f, %s=%f\n", i, vecC[i], name, asmVec[i]);
            return;
        }
    }
    printf("All elements match between C and %s.\n", name);
    
}

/*Function that runs the ymm, xmm, x86_64 and the C versions of the Scalar vector (AXPY)
for 30 iteration. Calaculates and displays the average time it took for each version*/
void averageTime(char *name,
                void (*function)(float, float*, float*, float*, int), 
                float scalarVal, float *vec, float *Xi, float *Yi, int size){

    struct timespec start={0,0}, end={0,0};
    double totalTime = 0.0;
    for (int i=0;i<30;i++) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        function(scalarVal, vec, Xi, Yi, size);
        clock_gettime(CLOCK_MONOTONIC, &end);
        totalTime+=((double)(end.tv_sec - start.tv_sec) + (double)(end.tv_nsec - start.tv_nsec) / 1000000000.0);
    }
    printf("Average time taken for %s over %d iterations: %f seconds\n\n", name, 30, totalTime / 30);
}

void boundaryChecker(int size, float* vec, int simdWidth, char* name){
    int remainder = size % simdWidth;
    if (remainder != 0) {
        printf("\nBoundary check Failed.\n The size of the %s vector of %d is not a multiple of the required %s SIMD width of %d.\nAs such the last %d will not be processed.\n\n", name, size, name, simdWidth, remainder);
    }else{
        printf("\nBoundary check Passed.\n The size of the %s vector of %d is a multiple of the required %s SIMD width of %d.\nAll elements will be processed.\n\n", name, size, name, simdWidth);
    }
}

int main() {
    char choice='0';
    int size;
    float x=FLT_MAX;

   
    /* User input for vector size.*/
    while(choice != 'A' && choice != 'a' && choice != 'B' && choice != 'b' && choice != 'C' && choice != 'c' && choice != 'D' && choice != 'd') {
        printf("Choose the size of the vector: \nA.) 2^20\nB.) 2^26\nC.) 2^27\nD.) End\nAnswer: ");
        scanf(" %c", &choice);
    }    
    if(choice == 'A' || choice == 'a') {
        printf("You chose 2^20\n");
        size = pow(2,20);
    }else if (choice == 'B' || choice == 'b') {
        printf("You chose 2^26\n");
        size = pow(2,26);
    }else if (choice == 'C' || choice == 'c') {
        printf("You chose 2^27\n");
        size = pow(2,27);
    }else if (choice == 'D' || choice == 'd') {
        printf("Ending program.\n");
        return 0;
    }

    /* user input for the scalar value (x)*/
    while(x==FLT_MAX) {
        printf("Enter a scalar value (float): ");
        if(scanf("%f", &x)!=1){  // <-- checks if the input is a valid float
            printf("Invalid input. Please enter a valid float value.\n");
            while(getchar() != '\n'); 
            x = FLT_MAX;
        }
    }

    /*Initializing Vector size and elements*/
    float *vecC = (float*)_aligned_malloc(size * sizeof(float), 32);
    float *vecXMM = (float*)_aligned_malloc(size * sizeof(float), 16);
    float *vecx86_64 = (float*)_aligned_malloc(size * sizeof(float), 32);
    float *vecYMM = (float*)_aligned_malloc(size * sizeof(float), 32);

    float *Xi = (float*)_aligned_malloc(size * sizeof(float), 32);
    float *Yi = (float*)_aligned_malloc(size * sizeof(float), 32);

    for (int i = 0; i < size; i++) {
       Xi[i] = i+0.005;
       Yi[i] = i+0.005;
    }

/*--------------------------------------------------------
Passing the function C into another function called averageTime.
Where it runs the function 30 times and calculates the average time.
In this section, we also display the first 5 and last 5 vector element*/
    printf("\n");
    averageTime("C", cVersion, x, vecC, Xi, Yi, size);
/*---------------------------------------------------------*/

/*Passing the function x86_64 into another function called averageTime.
Where it runs the function 30 times and calculates the average time.
In this section, we also display the first 5 and last 5 vector element*/

    averageTime("x86_64", x86_64, x, vecx86_64, Xi, Yi, size);
    printVectors(vecC,vecx86_64, size, "x86_64");
/*---------------------------------------------------------*/

/*Passing the function XMM into another function called averageTime.
Where it runs the function 30 times and calculates the average time.
In this section, we also display the first 5 and last 5 vector element*/
    boundaryChecker(size, vecXMM, 4, "XMM");
    //averageTime("XMM", xmm, x, vecXMM, Xi, Yi, size);
    //printVectors(vecC,vecXMM, size, "XMM");
/*---------------------------------------------------------*/

/*Passing the function YMM into another function called averageTime.
Where it runs the function 30 times and calculates the average time.
In this section, we also display the first 5 and last 5 vector element*/

    
    //boundaryChecker(size, vecYMM, 8, "YMM");
    //printf("Hello\n\n");
    averageTime("YMM", ymm, x, vecYMM, Xi, Yi, size);
    printVectors(vecC, vecYMM, size, "YMM");
/*---------------------------------------------------------*/

/* Checker that checks if the vectors values match*/
printf("\n\nChecking if the vectors match...\n");
comparisonChecker(vecC, vecXMM, size, "XMM");
comparisonChecker(vecC, vecx86_64, size, "x86_64");
comparisonChecker(vecC, vecYMM, size, "YMM");

/* We freed the allocated memory */
    _aligned_free(vecXMM);
    _aligned_free(vecC);    
    _aligned_free(vecx86_64);
    _aligned_free(vecYMM);
    _aligned_free(Xi);
    _aligned_free(Yi);
    return 0;
}