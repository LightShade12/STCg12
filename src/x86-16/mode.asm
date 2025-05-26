;problematic inputs:  3 3 1 5 2

; int STC_computeMode(arr_seg_offset, arr_size) 
; arr_seg_offset : AX
; arr_size : BX
; returns median : AX
STC_computeMode proc
    push bp; save prev bp
    mov bp, sp; setup frame pointer

    ; save scratch regs
    push dx
    push cx
    push bx
    push si

    mov cx, bx; cx = arr_sz; 
    mov bx, ax; bx = arr_seg_offset; 
    mov si, 0; idx
    push bx; save arr_seg_offset to CONSTANT DATA [bp-10]

    mov ax, 0; last val
    mov dx, 0; cur reps

    push ax; mode val = 0
    push dx; mode reps = 0

    mov ax, 0xFFFF; init last val (-1)

modeloop:
    push cx; save arr_sz
    mov cx, word ds[bx+si]; fetch cx = curr val

    cmp cx, ax
    je seq_repeat ; last == curr
    jne seq_break ; last != curr

seq_repeat:
    inc dx; curr_reps++
    jmp end_seq_break

seq_break:
    mov dx, 1

end_seq_break:
    mov ax, cx; last = curr
    pop cx; restore arr_sz

    pop bx; bx = modereps
    cmp bx, dx
    jg skip_mode_update; if modereps > currreps
    mov bx, dx; modereps = curreps
    pop dx; dx = modeval
    mov dx, ax; mode = curr; redundant ig
    push dx; save modeval

skip_mode_update: 

    push bx; save modereps
    mov bx, [bp-10]; restore arr_seg_offset from CONSTANT_DATA

    inc si
    inc si

    dec cx
    jnz modeloop
endmodeloop:
    pop ax ; modereps
    pop ax; mode val

    pop bx; clean CONSTANT DATA 

    ;restore scratch regs
    pop si
    pop bx
    pop cx
    pop dx

    pop bp
    ret
STC_computeMode endp