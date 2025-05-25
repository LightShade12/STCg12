STC_computeMedian proc
    push si
    push cx
    push dx
    push bx

    mov si, ax          ; SI = base offset (array start)
    mov cx, bx          ; CX = array size

    test cx, cx
    jz median_zero      ; if size == 0, median = 0

    mov ax, cx
    test ax, 1          ; check if odd number of elements
    jnz median_odd

    ; even size: median = (arr[mid] + arr[mid-1]) / 2
    shr ax, 1           ; mid = size / 2

    ; load arr[mid]
    mov bx, si
    mov dx, ax
    shl dx, 1           ; dx = mid * 2 (byte offset)
    add bx, dx
    mov dx, word ptr [bx]

    ; load arr[mid-1]
    mov bx, si
    mov dx, ax
    dec dx              ; mid-1
    shl dx, 1
    add bx, dx
    mov cx, word ptr [bx]

    add dx, cx
    shr dx, 1           ; average
    mov ax, dx
    jmp median_done

median_odd:
    shr ax, 1           ; mid = size / 2

    mov bx, si
    mov dx, ax
    shl dx, 1
    add bx, dx
    mov ax, word ptr [bx]

median_done:
    jmp median_exit

median_zero:
    xor ax, ax          ; median = 0 if array size 0

median_exit:
    pop bx
    pop dx
    pop cx
    pop si
    ret
STC_computeMedian endp
