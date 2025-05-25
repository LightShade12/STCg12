STC_computeMode proc
    push cx
    push dx
    push si
    push di
    push bp

    mov si, ax          ; SI = base address of array
    mov cx, bx          ; CX = array size (number of words)

    xor bp, bp          ; BP = max frequency
    xor dx, dx          ; DX = mode value

    xor di, di          ; DI = outer loop index (i = 0)

outer_loop:
    cmp di, cx
    jge done_mode       ; finished

    ; load value at array[i]
    mov bx, di
    shl bx, 1           ; bx = i*2 (byte offset)
    mov ax, word ptr [si + bx]

    xor bx, bx          ; bx = frequency count = 0

    xor dx, dx          ; dx = inner loop index j = 0

inner_loop:
    cmp dx, cx
    jge check_freq      ; done inner loop

    mov bx, dx
    shl bx, 1           ; bx = j*2
    mov di, word ptr [si + bx] ; load array[j] into di

    cmp ax, di
    jne skip_inc_freq

    inc bx               ; increment frequency count in BX

skip_inc_freq:
    inc dx
    jmp inner_loop

check_freq:
    cmp bx, bp
    jle next_outer

    mov bp, bx          ; update max frequency
    mov dx, ax          ; update mode value

next_outer:
    inc di
    jmp outer_loop

done_mode:
    mov ax, dx          ; return mode value in AX

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    ret
STC_computeMode endp
endp
