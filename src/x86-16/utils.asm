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
