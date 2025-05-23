; cdecl int square(val)
; val: AX
; return square : AX
STC_sqr proc
mul ax
ret
STC_sqr endp

; cdecl int STC_min(v1,v2)
; v1 : AX
; v2 : BX
; return min : ax
; scratch reg: ax, bx
STC_min proc
cmp ax,bx
jl LT
mov ax, bx
ret
LT:; all good
ret
STC_min endp


; cdecl int STC_max(v1,v2)
; v1 : AX
; v2 : BX
; return max : ax
; scratch reg: ax, bx
STC_max proc
cmp ax,bx
jg GT
mov ax, bx
ret
GT:; all good
ret
STC_max endp

; int maxArr(arr_seg_offset, arr_size)
; arr_seg_offset : AX
; arr_size : BX
; returns max element : AX
STC_maxArr proc
    push dx
    push cx
    push si
    
    mov si, 0
    mov cx, bx
    mov dx, ax; dx = arr_seg_offset
    mov ax, 0; INIT MAX VAL
maxarrloop:
    
    xchg bx, dx
    mov dx, word ds[bx+si]
    xchg bx, dx
    
    call STC_max
    
    inc si
    inc si; word increment
    dec cx
    jnz maxarrloop    
endmaxarrloop:

    pop si
    pop cx
    pop dx
    ret
STC_maxArr endp

; int minArr(arr_seg_offset, arr_size)
; arr_seg_offset : AX
; arr_size : BX
; returns min element : AX
STC_minArr proc
    push dx
    push cx
    push si
    
    mov si, 0
    mov cx, bx
    mov dx, ax; dx = arr_seg_offset
    mov ax, 9; INIT_MIN_VAL
minarrloop:
    
    xchg bx, dx
    mov dx, word ds[bx+si]
    xchg bx, dx
    
    call STC_min
    
    inc si
    inc si; word increment
    dec cx
    jnz minarrloop    
endminarrloop:

    pop si
    pop cx
    pop dx
    ret
STC_minArr endp