section .text
default rel
global ymm
ymm:     
    ; CONTENTS:
    ; xmm0 = x
    ; rdx = *vec
    ; r8 = *xi
    ; r9 = *yi
    ; [rsp+40] = size (int)
    
    xor r10, r10 ; clear register r10 to be used for index.
    movsxd r11, dword [rsp + 40] ; obtain vector size
    vbroadcastss ymm3, xmm0 ; duplicate x across ymm3
    
    ; convert vector size to bytes
    imul r11, 4
    
    ; FOR HANDLING BOUNDARY ELEMENTS:
    ; round down to multiple of 8 (Cannot use div, overwrites rdx)
    mov rax, r11
    and rax, ~31
  
.loop:
    ; if (index >= r10): break;
    cmp r10, rax
    jae .boundary
    
    ; load 8 single-precision floats (xi)
    vmovups ymm0, [r8 + r10]
    ; load 8 single-precision floats (yi)
    vmovups ymm1, [r9 + r10]
    
    ; in parallel
    vmulps ymm0, ymm0, ymm3 ; ymm0 = x * Xi
    vaddps ymm2, ymm0, ymm1 ; ymm2 = x*x1 + Yi
    
    ; store 8 floats in *vec
    vmovups [rdx + r10], ymm2
    
    add r10, 32
    jmp .loop
    
.boundary: 
    cmp r10, r11
    jae .break
    
    ; load 1 single-precision float (xi)
    vmovss xmm0, [r8 + r10]
    ; load 1 single-precision float (yi)
    vmovss xmm1, [r9 + r10]

    ; not in parallel (scalar)
    vmulss xmm0, xmm0, xmm3      ; xmm0 = x * Xi
    vaddss xmm2, xmm0, xmm1      ; xmm2 = x*x1 + Yi

    ; store 1 float in vec*
    vmovss [rdx + r10], xmm2     

    add r10, 4
    jmp .boundary
    
.break:
    xor rax, rax
    ret