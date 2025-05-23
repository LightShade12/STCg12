
ORG 100h
jmp START
; SRC DATA SEG  
.DATA
    src DW 0x8, 0x2, 0x4, 0x7, 0x1,0x3, 0x6, 0x5
;---------------------------------

.CODE

INCLUDE "utils.asm"
INCLUDE "mean.asm"
INCLUDE "qsort.asm"

;===============================

START:
    
    mov ax, 4
    call STC_sqr
    
    mov bx, 2
    call STC_min
    
    mov bx, 90
    call STC_max
    
    mov ax, cs; load data seg addr
    mov ds, ax; set data seg

    mov ax, OFFSET src ;arr_seg_offset
    mov bx, 8 ;arr_sz(words)
    call STC_computeMean

    ; prep to call qsort-----
    ; save registers ==
    push dx
    push cx
    push bx
    push ax

    ; pass args (cdecl) ==
    mov ax, 14; 2 bytes(1 word) * 7 offset
    push ax; arg: end offset

    mov ax, 0; 2 bytes(1 word) * 0 offset
    push ax; arg: start offset

    mov ax, 8 ; arg: arr_size
    push ax

    mov ax, OFFSET src; get src arr offset from seg
    push ax; arg: arr_seg_idx

    xor ax, ax; clear

    ;cdecl void qsort(arr_seg_idx, arr_size, start offset, end offset)
    call STC_qsort

    add sp, 8; cleanup args from stack

    ; restore
    pop ax
    pop bx
    pop cx
    pop dx

    ret
END START
;===================================
