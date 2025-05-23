
; swap si and di vals from ds
; cdecl void STC_swap_in_buf(si, di)
STC_swap_in_buf proc
    push ax
    push bx
    mov ax, word ds[si]
    mov bx, word ds[di]
    mov word ds[si], bx
    mov word ds[di], ax
    pop bx
    pop ax
    ret
STC_swap_in_buf endp

; cdecl void STC_qsort(arr_seg_idx, arr_size, start offset, end offset)
; scratch registers: AX, BX, CX, DX 
; Caller should save these ^
STC_qsort proc
    push bp
    mov bp, sp
    ; fetch args
    mov si, [bp+4] ; load src arr seg offset: arr_seg_idx
    mov cx, [bp+6] ; load size: arr_size
    mov ax, [bp+8]; j : start offset
    mov bx, ax; i
    dec bx
    dec bx; i = j - 1
    mov dx, [bp+10] ; pivot : end offset

    ; 1st iter guard
    cmp dx, ax
    jz _end; if j == pivot i.e 1 element: return
    jl _end; if j > pivot : return
    
    push ax; save original j
    
; while j < pivot; j++
_loop:
    ;save scratch registers
    push cx; size
    push ax; j
    
    ; fetch j val & pivot val
    push si
    add si, ax
    mov cx, word ds[si]; j val
    sub si, ax
    add si, dx
    mov ax, word ds[si]; pivot val
    pop si
    ; cx & ax are modified now
    
    cmp ax, cx; if j val > pivot val
    pop ax; j
    js  _skip_swap   
    
    ; swap start
    mov di, si
    add di, ax; di = j
    
    push si; save si
    inc bx
    inc bx; i++
    add si, bx; si = i
    
    call STC_swap_in_buf; swap i & j vals from ds
    ; swap complete
    
    pop si; arr_seg_idx

    
_skip_swap:

    pop cx; arr_sz
    inc ax
    inc ax; j++
    
    cmp dx, ax; j < pivot
    
    jnz _loop; only if dx and ax are aligned to two bytes
    
_loop_end:; j == pivot (assuming AX will never overshoot)
    pop ax; restore original j
    
; swap i <-> pivot ====
    inc bx
    inc bx; i++
    
    mov di, si
    add di, dx; pivot
    
    push si
    add si, bx; i
    
    call STC_swap_in_buf
    pop si
    
    xchg dx, bx; pivot <-> i
    ; dx is modified now; sorted pivot
    ; bx: end
    
    cmp dx, 0
    ;jz _skip_left_rcrs; if pivot==0: skip
    
    ; rcrse left sub-array-----
    dec dx
    dec dx; left_end = pivot - 1

    cmp dx, ax
    jz _skip_left_rcrs; left_end == start (will be one element sub-arr)
    jl _skip_left_rcrs; left_end < start
    
    ; save registers
    push dx
    push cx
    push bx
    push ax
    
    ;args; will be popped inside function
    push dx; left_end
    push ax; left_start
    push cx; arr_size
    push si; arr_seg_idx
    
    call STC_qsort; will restore regs
    
    add sp, 8;cleanup args from stack
    
     ;restore registers
    pop ax
    pop bx
    pop cx
    pop dx
    
_skip_left_rcrs:

    inc dx
    inc dx; restore pivot
    
    ; rcrse right sub-array-----
    inc dx
    inc dx; right_start = pivot + 1
 
    cmp bx, dx; end < right_start
    
    jz _skip_right_rcrs; right_start == arr_size
    jl _skip_right_rcrs; right_start > arr_size
    
    ; save registers
    push dx
    push cx
    push bx
    push ax
    
    push bx; end
    push dx; start
    push cx; arr_size
    push si; arr_seg_idx
    
    call STC_qsort
    
    add sp, 8;cleanup args from stack
    
    ;restore registers
    pop ax
    pop bx
    pop cx
    pop dx
    
_skip_right_rcrs:
    
    dec dx
    dec dx; restore pivot;
    
_end:
    mov sp, bp
    pop bp
    ret
STC_qsort endp


