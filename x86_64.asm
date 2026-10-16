section .text
    default rel
    global x86_64

x86_64:
    ; Stack frame
    push rbp
    mov rbp, rsp
    add rbp, 8+8

    ; PARAMETERS
    ; xmm0      = scalarVal
    ; rdx       = *vec
    ; r8        = *Xi
    ; r9        = *Yi
    ; [rbp+32]  = size

    ; INITIALIZATION
    ; index = 0
    ; size = size
    xor r10, r10
    movsxd r11, dword [rbp+32]

.loop:
    ; if (index >= size), exit
    cmp r10, r11
    jae .exit

    ; xmm1 = aXi + Yi
    movss xmm1, [r8 + r10*4]
    mulss xmm1, xmm0
    movss xmm2, [r9 + r10*4]
    addss xmm1, xmm2

    ; store result in *vec
    movss [rdx + r10*4], xmm1

    inc r10
    jmp .loop

.exit:
    pop rbp
    xor rax, rax
    ret