; ----------MEAN--------------- 
; Computes the mean (average) of an array of unsigned words.
; Inputs are passed through registers instead of the stack.  

;FUNCTION
; cdecl void STC_computeMean(arr_seg_idx, arr_size)
; arr_seg_idx : AX
; arr_size (in bytes): BX
; returns mean : AX
;-------------------------------

STC_computeMean proc
    ; save registers
    push cx
    push bx
    push dx
    push si
    ; args -> local vars
    mov cx, bx ; CX = arr_size 
    mov bx, ax ; BX = base arr seg offset
    xor ax, ax ; AX = sum = 0
    xor si, si ; SI = byte index = 0

    push cx; save arr word size

    push ax 
    mov ax, cx
    mov cx, 2
    mul cx
    mov cx, ax; CX= arr bytes size
    pop ax

mean_loop:
    mov     dx, word ds[bx + si]  ; Read word from array
    add     ax, dx                ; Add to sum
    inc     si                    
    inc     si                    ; byte index++
    cmp     si, cx  
    jl      mean_loop             ; If byte index < array_byte_sz,
                                  ; continue loop
end_loop:
    pop cx    ; restore arr words size
    xor dx, dx; set dividend hb to 0
    div cx    ; AX / CX -> Quotient in AX, remainder in DX
    ; restore registers
    pop si
    pop dx
    pop bx
    pop cx
    ret 
STC_computeMean endp
