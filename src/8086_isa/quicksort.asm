
;
; SRC SEG
;-------------------------------
SET 0x0; set DS = 0x0 * 0x10
src: 
DW 0x6 ;0
DW 0x34
DW 0x19
DW 0x15
DW 0x08
DW 0x3
DW 0x99
DW 123;7
;---------------------------------
; DST SEG
SET 0x2; set DS = 0x1 * 0x10
dst: 
DW[0,8]
;--------------------------------

; stack parameter(cdecl): arr, size
; no saves
def qsort
{
    pop si; load src arr seg offset
    pop cx ;load size
    
    xor ax, ax; reset for retval
    mov di, OFFSET dst
    
_loop:

    mov ax, word ds[si]
    mov word es[di], ax
    
    inc si
    inc si
    inc di
    inc di
    
    dec cx
    jnz _loop
    
    ret
}

;================

start:

mov ax, 0x0; load data seg addr
mov ds, ax; set data seg

mov ax, 0x2; DST seg
mov es, ax

; pass args (cdecl)
mov ax, 8 ; array size
push ax

mov ax, OFFSET src; get src arr offset from seg
push ax

xor ax, ax

call qsort

hlt

;=======================================================================================
;
; SRC SEG
;-------------------------------
SET 0x0; set DS = 0x0 * 0x10
src: 
DW 0x6 ;0
DW 0x34
DW 0x19
DW 0x15
DW 0x08
DW 0x3
DW 0x99
DW 123;7
;---------------------------------
; DST SEG
SET 0x2; set DS = 0x2 * 0x10
dst: 
DW[0,8]
;--------------------------------

; stack parameter(cdecl): arr, size
; no saves
def qsort
{
    pop si ;load src arr seg offset
    pop cx ;load size
    
    cmp cx, 0
    jz _end
    
    xor ax, ax; reset for retval

    mov ax, word ds[si]
    mov word es[di], ax
    
    inc si
    inc si
    inc di
    inc di
    
    dec cx
    
    push cx
    push si
    call qsort
_end:
    ret
}

;================

start:

mov ax, 0x0; load data seg addr
mov ds, ax; set data seg

mov ax, 0x2; DST seg
mov es, ax

; pass args (cdecl)
mov ax, 8 ; array size
push ax

mov di, OFFSET dst
mov ax, OFFSET src; get src arr offset from seg
push ax

xor ax, ax

call qsort

hlt

;============================================================================================
;
; SRC SEG
;-------------------------------
SET 0x0; set DS = 0x0 * 0x10
src: 
DW 0x6 ;0
DW 0x34
DW 0x19
DW 0x15
DW 0x08
DW 0x3
DW 0x99
DW 123;7
;---------------------------------

; cdecl void swap_in_buf(si, di)
def swap_in_buf
{
    push ax
    push bx
    mov ax, word ds[si]
    mov bx, word ds[di]
    mov word ds[si], bx
    mov word ds[di], ax
    pop ax
    pop bx
    ret
}

; cdecl void qsort(arr_seg_idx, arr_size, start, end)
; caller save: AX, CX, DX
def qsort
{
    pop si ; load src arr seg offset: arr_seg_idx
    pop cx ; load size: arr_size
    pop ax ; j : start 
    mov bx, ax; i = j-1
    dec bx; i
    pop dx ; pivot : end

    cmp dx, ax; if j == pivot i.e 1 element
    jz _loop_end
    
; while j < pivot; j++
_loop:
    push cx
    push ax
    
    ; fetch j val & pivot val
    push si
    add si, ax
    mov cx, word ds[si]; j val
    sub si, ax
    add si, dx
    mov ax, word ds[si]; pivot val
    pop si
    
    cmp ax, cx; if j val < pivot val
    js  _skip_swap   
    
    ; swap
    inc bx;i++
    
    push si
    add si, bx
    mov ax, word ds[si] ; i val
    mov word ds[si], cx; i val -> j val
    pop si
    
    pop cx; j
    add si, cx
    mov word ds [si], ax; j val -> i val
    
    sub si, cx; restored si
    mov ax, cx; restore ax : j
    pop cx; arr_sz
    
_skip_swap:

    inc ax
    cmp dx, ax
    jnz _loop

_loop_end:

    push cx
    push si
    call qsort
_end:
    ret
}

;=====================

start:

mov ax, 0x0; load data seg addr
mov ds, ax; set data seg

; prep to call qsort-----
; pass args (cdecl)
mov ax, 8
push ax; arg: end

mov ax, 0
push ax; arg: start

mov ax, 8 ; arg: arr_size
push ax

mov ax, OFFSET src; get src arr offset from seg
push ax; arg: arr_seg_idx

xor ax, ax; clear

;cdecl void qsort(arr_seg_idx, arr_size, start, end)
call qsort

hlt


;=========================================================================================================



;
; SRC SEG
;-------------------------------
SET 0x0; set DS = 0x0 * 0x10
src: 
DW 0x6 ;0
DW 0x34
DW 0x19
DW 0x15
DW 0x08
DW 0x3
DW 0x99
DW 123;7
;---------------------------------

; cdecl void swap_in_buf(si, di)
def swap_in_buf
{
    push ax
    push bx
    mov al, word ds[si]
    mov bl, word ds[di]
    mov word ds[si], bl
    mov word ds[di], al
    pop ax
    pop bx
    ret
}

; cdecl void qsort(arr_seg_idx, arr_size, start, end)
; scratch registers: AX, CX, DX
def qsort
{
    ; fetch args
    pop si ; load src arr seg offset: arr_seg_idx
    pop cx ; load size: arr_size
    pop ax ; j : start 
    mov bx, ax; i
    dec bx; i = j - 1
    pop dx ; pivot : end

    ; 1st iter guard
    cmp dx, ax; if j == pivot i.e 1 element
    jz _loop_end
    
; while j < pivot; j++
_loop:
    ;save scratch registers
    push cx
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
    
    cmp ax, cx; if j val < pivot val
    js  _skip_swap   
    
    ; swap start
    inc bx;i++
    
    push si
    add si, bx
    mov ax, word ds[si] ; i val
    mov word ds[si], cx; i val -> j val
    pop si
    
    pop cx; j
    add si, cx
    mov word ds[si], ax; j val -> i val
    sub si, cx; restored si
    ; swap complete
    
    mov ax, cx; restore ax : j
    pop cx; arr_sz
    
_skip_swap:

    inc ax
    cmp dx, ax
    jnz _loop
_loop_end:

    cmp dx, ax; redundant(for sanity)
    jnz _end
    
    ; swap i <-> pivot
    inc bx
    inc bx; i++
    
    push cx
    push ax
    push si
    
    add si, bx
    mov ax, word ds[si]; i val
    sub si, bx
    add si, dx
    mov cx, word ds[si]; pivot val
    mov word ds[si], ax; pivot val -> i val
    sub si, dx
    add si, bx
    mov word ds[si], cx ;i val -> pivot val
    
    pop si
    pop ax
    pop cx
    
    
    xchg dx, bx; pivot <-> i
    ; dx is modified now; sorted pivot
    ; bx: end
    
    
    ; rcrse left sub-array-----
    dec dx
    dec dx; end = pivot - 1

    cmp dx, 0
    jz _skip_left_rcrs; pivot == 0
    js _skip_left_rcrs; pivot < 0
    
    ; save registers
    push dx
    push cx
    push ax
    
    ;args
    push dx; end
    push ax; start
    push cx; arr_size
    push si; arr_seg_idx
    
    call qsort
_skip_left_rcrs:

    inc dx
    inc dx; restore pivot
    
    ; rcrse right sub-array-----
    inc dx; start = pivot + 1
    cmp cx, dx
    jz _skip_right_rcrs; pivot == 0
    js _skip_right_rcrs; pivot < 0
    inc dx
    
    ; save registers
    push dx
    push cx
    push ax
    
    ; args
    push bx; end
    push dx; start
    push cx; arr_size
    push si; arr_seg_idx
    
    call qsort
_skip_right_rcrs:
    
    dec dx
    dec dx; restore dx
    
_end:
    ; restore saved registers
    pop ax
    pop cx
    pop dx
    ret
}

;=============================

start:

mov ax, 0x0; load data seg addr
mov ds, ax; set data seg

; prep to call qsort-----
; save registers ==
push dx
push cx
push ax

; pass args (cdecl) ==
mov ax, 8
push ax; arg: end

mov ax, 0
push ax; arg: start

mov ax, 8 ; arg: arr_size
push ax

mov ax, OFFSET src; get src arr offset from seg
push ax; arg: arr_seg_idx

xor ax, ax; clear

;cdecl void qsort(arr_seg_idx, arr_size, start, end)
call qsort

hlt

;===================================


;
; SRC SEG
;-------------------------------
SET 0x0; set DS = 0x0 * 0x10
src: 
DW 0x6 ;0
DW 0x34
DW 0x19
DW 0x15
DW 0x08
DW 0x3
DW 0x99
DW 123;7
;---------------------------------

; cdecl void swap_in_buf(si, di)
def swap_in_buf
{
    push ax
    push bx
    mov ax, word ds[si]
    mov bx, word ds[di]
    mov word ds[si], bx
    mov word ds[di], ax
    pop bx
    pop ax
    ret
}

; cdecl void qsort(arr_seg_idx, arr_size, start, end)
; scratch registers: AX, CX, DX
def qsort
{
    ; fetch args
    pop si ; load src arr seg offset: arr_seg_idx
    pop cx ; load size: arr_size
    pop ax ; j : start 
    mov bx, ax; i
    dec bx; i = j - 1
    pop dx ; pivot : end

    ; 1st iter guard
    cmp dx, ax; if j == pivot i.e 1 element
    jz _loop_end
    
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
    js  _skip_swap   
    
    ; swap start
    pop ax; j
    mov di, si
    add di, ax; di = j
    
    push si
    inc bx; i++
    add si, bx; si = i
    
    call swap_in_buf
    ; swap complete
    
    pop si
    pop cx; arr_sz
    
_skip_swap:

    inc ax; j++
    cmp dx, ax; j < pivot
    jnz _loop
_loop_end:; j == pivot (assuming AX will never overshoot)

    cmp dx, ax; redundant(for sanity)
    jnz _end
    
; swap i <-> pivot ====
    inc bx; i++
    ;NOTE: inc/decrement indices TWICE for a word offset
    
    mov di, si
    add, di, dx; pivot
    
    push si
    add si, bx; i
    
    swap_in_buf
    pop si
    
    xchg dx, bx; pivot <-> i
    ; dx is modified now; sorted pivot
    ; bx: end
    
    ; rcrse left sub-array-----
    dec dx
    dec dx; end = pivot - 1

    cmp dx, 0
    jz _skip_left_rcrs; pivot == 0
    js _skip_left_rcrs; pivot < 0
    
    ; save registers
    push dx
    push cx
    push ax
    
    ;args
    push dx; end
    push ax; start
    push cx; arr_size
    push si; arr_seg_idx
    
    call qsort
_skip_left_rcrs:

    inc dx
    inc dx; restore pivot
    
    ; rcrse right sub-array-----
    inc dx; start = pivot + 1
    cmp cx, dx
    jz _skip_right_rcrs; pivot == 0
    js _skip_right_rcrs; pivot < 0
    inc dx
    
    ; save registers
    push dx
    push cx
    push ax
    
    ; args
    push bx; end
    push dx; start
    push cx; arr_size
    push si; arr_seg_idx
    
    call qsort
_skip_right_rcrs:
    
    dec dx
    dec dx; restore dx
    
_end:
    ; restore saved registers
    pop ax
    pop cx
    pop dx
    ret
}

;=============================

start:

mov ax, 0x0; load data seg addr
mov ds, ax; set data seg

; prep to call qsort-----
; save registers ==
push dx
push cx
push ax

; pass args (cdecl) ==
mov ax, 8
push ax; arg: end

mov ax, 0
push ax; arg: start

mov ax, 8 ; arg: arr_size
push ax

mov ax, OFFSET src; get src arr offset from seg
push ax; arg: arr_seg_idx

xor ax, ax; clear

;cdecl void qsort(arr_seg_idx, arr_size, start, end)
call qsort

hlt

;===================================

