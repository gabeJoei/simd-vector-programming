section .data
scalarVal dd 0
section .text
default rel
global ymm
ymm:
    ; change main: to ymm:
    
    ; create stack frame
    push rbp
    mov rbp, rsp
    add rbp, 8+8
    
    ; CONTENTS:
    ; ecx = scalarVal
    ; rdx = *vec
    ; r8 = *xi
    ; r9 = *yi
    ; [rbp+32] = size
    
    xor r10, r10 ; clear register r10 to be used for index.
    mov r11, [rbp+32] ; obtain vector size
    mov [scalarVal], ecx ; obtain scalarVal
    vbroadcastsd ymm3, [scalarVal] ; duplicate scalarVal across ymm3

; convert vector size to bytes
imul r11, 4
.loop:
    ; if (index == r10): break;
    cmp r10, r11
    je .break
    
    ; load 8 single-precision floats (xi)
    vmovdqu ymm0, [r8 + r10]
    vmulps ymm0, ymm0, ymm3 ; scalarVal * Xi
    
    ; load 8 single-precision floats (yi)
    vmovdqu ymm1, [r9 + r10]
    vaddps ymm2, ymm0, ymm1 ; scalarVal*x1 + y1
    
    ; store result in *vec
    vmovdqu [rdx + r10], ymm2
    
    add r10, 32
    jmp .loop
    
.break:
    pop rbp
    xor rax, rax
    ret