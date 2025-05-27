
; int STC_computePopulationStandardDeviation(arr_seg_offset, arr_size)
; arr_seg_offset : AX
; arr_size : BX
; returns population_standard_deviation : AX
STC_computePopulationStandardDeviation proc

    push dx
    push cx
    push si
    push ax; arr_seg_offset
    
    push bx
    
    call STC_computeMean
    mov dx, ax; dx = mean (mu)
    
    pop cx; cx = arr_sz
    xor ax, ax; numerator
    pop bx; bx = arr_seg_offset
    mov si, 0; byte idx
    
    push cx; save orig arr_sz

sdloop:
    push cx; save arr_sz
    
    mov cx, word ds[bx+si]; xi
    sub cx, dx; xi - mu
    
    xchg cx, ax; ax -> diff, cx -> numer
    push dx
    mul ax; diff squared
    pop dx
    xchg cx,  ax; cx -> diff, ax -> numer
    
    add ax, cx; numerator += diff
    
    pop cx
    
    inc si
    inc si
    dec cx
    jnz sdloop:
endsdloop:
    pop cx; restore orig arr_sz
    xor dx, dx
    div cx; numerator/arr_sz
    
    ; the quotient is in AX
    mov di, ax
    call STC_sqrt
    
    pop si
    pop cx
    pop dx
    ret
STC_computePopulationStandardDeviation endp