section .text
default rel
global ymm
ymm:     
    ; CONTENTS:
    ; xmm0 = x
    ; rdx = *vec
    ; r8 = *xi
    ; r9 = *yi
    ; [rsp+40] = size
    
    xor r10, r10 ; clear register r10 to be used for index.
    mov r11, [rsp + 40] ; obtain vector size
    vbroadcastss ymm3, xmm0 ; duplicate x across ymm3

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
    
    vmulps ymm0, ymm0, ymm3 ; ymm0 = x * Xi
    vaddps ymm2, ymm0, ymm1 ; ymm2 = x*x1 + Yi
    
    ; store result in *vec
    vmovups [rdx + r10], ymm2
    
    add r10, 32
    jmp .loop
    
.break:
    xor rax, rax
    ret