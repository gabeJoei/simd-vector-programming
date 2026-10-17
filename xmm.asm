section .text
default rel
global xmm

xmm:
    ;xmm0 = scalarVal, rdx = output Z, r8 = input A, r9 = input B
    ;[rsp+40] = n (vector length)

    shufps xmm0, xmm0, 0       ;Copy scalarVal into all 4 XMM lanes
    xor r10, r10               ;Set index i = 0
    mov r11, [rsp+40]          ;Load vector length n

.loop:
    ;Check if 4 elements remain for processing
    lea rax, [r10+4]           
    cmp rax, r11               
    ja .remainder              

    ;Process 4 floats at once
    ;Z[i:i+4] = scalarVal * A[i:i+4] + B[i:i+4]
    movups xmm1, [r8+r10*4]
    mulps xmm1, xmm0
    addps xmm1, [r9+r10*4]
    movups [rdx+r10*4], xmm1

    add r10, 4
    jmp .loop

.remainder:
    ; Process remaining elements if n is not divisible by 4
    cmp r10, r11
    jae .done

.scalar:
    movss xmm1, [r8+r10*4] ;Load one float from A[i]
    mulss xmm1, xmm0       ;Multiply A[i] by scalarVal
    addss xmm1, [r9+r10*4] ;Add B[i]
    movss [rdx+r10*4], xmm1  ;Store Z[i]

    inc r10 
    cmp r10, r11 ;Check if more elements remain
    jb .scalar

.done:
    xor eax, eax
    ret
