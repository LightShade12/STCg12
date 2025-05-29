
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

; cdecl void STC_qsort(arr_seg_offset, arr_size, start offset, end offset)
; arr_seg_offset : DI
; arr_size : SI
; start_offset : DX
; end_offset : CX
; NOTE: OFFSETS IN BYTES
STC_qsort proc
    push bp
    mov bp, sp
    sub sp, 32; 16 nums

    mov bx, di; arr_seg_offset
    mov word ptr [bp-2], si; arr_size
    mov word ptr [bp-4], dx; start offset
    mov word ptr [bp-6], cx; end offset
    ;----
    mov word ptr [bp-8], dx; j
    mov word ptr [bp-10], dx; i
    dec word ptr [bp-10]
    dec word ptr [bp-10]; i = j-1
    mov word ptr [bp-12], cx; pivot

    ; 1st iter guard
    mov dx, word ptr [bp-12]; ld pivot
    cmp word ptr [bp-8], dx; j, pivot
    jge _end; if j == pivot i.e 1 element: return OR if j > pivot : return

    mov si, cx;pivot
    mov cx, word ptr [bx+si];ld pivot_val
    mov word ptr [bp-14], cx; pivot value
    
; while j < pivot; j++
qsort_loop:
    
    ; fetch j val & pivot val
    mov si, word ptr [bp-8]; ld j
    mov ax, word ptr [bx+si]; j val
    
    cmp ax, word ptr [bp-14]; j_v, piv_v
    jg  _skip_swap   ; if j val > pivot val
    
    ; swap start ----

    mov di, word ptr [bp-8] ; di = j
    inc word ptr [bp-10]
    inc word ptr [bp-10]; i++
    mov si, word ptr [bp-10]; si = i
    
    add si, bx
    add di, bx; convert to raw addr
    call STC_swap_in_buf; swap i & j vals from ds
    ; swap complete ----
    
_skip_swap:

    inc word ptr [bp-8]
    inc word ptr [bp-8]; j++
    
    mov ax, word ptr [bp-8]; j
    cmp ax, word ptr [bp-12]; j, pivot
    
    jl qsort_loop; loop if j < pivot
    
qsort_loop_end:; j == pivot (assuming j will never overshoot)
    
; swap i <-> pivot ====
    inc word ptr [bp-10]
    inc word ptr [bp-10]; i++
    
    mov di, word ptr [bp-12]; pivot
    mov si, word ptr [bp-10]; i
     
    ;sort pivot element
    add si, bx
    add di, bx; convert to raw addr
    call STC_swap_in_buf
    
    ; swap i & piv
    mov dx, word ptr [bp-12]; pivot
    xchg dx, word ptr [bp-10]; pivot <-> i
    mov word ptr [bp-12], dx
    ; sorted pivot index^
    mov si, word ptr [bp-12]
    mov ax, word ptr [bx+si]; update pivot val
    mov word ptr [bp-14], ax
    
    cmp word ptr [bp-12], 0
    je _skip_left_rcrs; if pivot==0: skip
    
    ; rcrse left sub-array-----
    mov dx, word ptr [bp-12]; ld sorted_pivot
    dec dx
    dec dx; left_end = pivot - 1

    cmp dx, word ptr [bp-4]
    jle _skip_left_rcrs; left_end == start_offset (will be one element sub-arr) OR left_end < start_offset
    
    ; save registers
    push dx
    push cx
    push bx
    push ax
    
    mov di, bx; arr_seg_offset
    mov si, word ptr [bp-2]; arr_size
    mov cx, dx; left_end
    mov dx, word ptr [bp-4]; left_start
    
    call STC_qsort
   
    ;restore registers
    pop ax
    pop bx
    pop cx
    pop dx
    
_skip_left_rcrs:

    ; rcrse right sub-array-----
    mov dx, word ptr [bp-12]; ld sorted_pivot
    inc dx
    inc dx; right_start = pivot + 1
 
    cmp word ptr [bp-6], dx; end, right_start
   
    jle _skip_right_rcrs; right_start == end OR right_start > end
    
    ; save registers
    push dx
    push cx
    push bx
    push ax
  
    mov di, bx; arr_seg_offset
    mov si, word ptr [bp-2]; arr_size
    ; dx already has right_start
    mov cx, word ptr [bp-6]; right_end
   
    call STC_qsort
    
    ;restore registers
    pop ax
    pop bx
    pop cx
    pop dx
    
_skip_right_rcrs:
    
_end:
    add sp, 32
    mov sp, bp
    pop bp
    ret
STC_qsort endp

;====================================================================