/* C version of the Scalar vector (AXPY) operation */
void cVersion(float scalarVal, float *vec, float *Xi, float *Yi, int size) {
    for (int i = 0; i < size; i++) {
        vec[i]= scalarVal*Xi[i] + Yi[i];
    }
}