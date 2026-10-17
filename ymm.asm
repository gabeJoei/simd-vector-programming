section .text
default rel
global ymm
ymm:    
    ; create stack frame
    push rbp
    mov rbp, rsp
    add rbp, 8+8
    
    ; CONTENTS:
    ; xmm0 = scalarVal
    ; rdx = *vec
    ; r8 = *xi
    ; r9 = *yi
    ; [rbp+32] = size
    
    xor r10, r10 ; clear register r10 to be used for index.
    movsxd r11, dword[rbp+40] ; obtain vector size
    vbroadcastss ymm3, xmm0 ; duplicate scalarVal across ymm3

; convert vector size to bytes
imul r11, 4
.loop:
    ; if (index == r10): break;
    cmp r10, r11
    jae .break
    
    ; load 8 single-precision floats (xi)
    vmovups ymm0, [r8 + r10]
    ; load 8 single-precision floats (yi)
    vmovups ymm1, [r9 + r10]
    
    vmulps ymm0, ymm0, ymm3 ; ymm0 = scalarVal * Xi
    vaddps ymm2, ymm0, ymm1 ; ymm2 = scalarVal*x1 + Yi
    
    ; store result in *vec
    vmovups [rdx + r10], ymm2
    
    add r10, 32
    jmp .loop
    
.break:
    pop rbp
    xor rax, rax
    ret