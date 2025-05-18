; ----------MEAN--------------- 
; Computes the mean (average) of an array of unsigned bytes.
; Inputs are passed through registers instead of the stack.  

;FUNCTION
; cdecl void compute_mean(arr_seg_idx)
; scratch registers: AX, BX, SI, DL, AH
;def compute_mean
;{
    ; fetch args
    ;pop si         ; load source array segment offset: arr_seg_idx
    ;xor ax, ax      ; clear AX: sum = 0
    ;xor bx, bx      ; BX = index = 0

    ;mean_loop {
    ;loop code
    ; jl mean_loop }
    ; compute mean  
    ;The  mean is stored in AL.
;-------------------------------
.model small
.stack 100h
.data
nums    db 10, 20, 30, 20, 10     ; Array of 5 unsigned bytes

.code
start:
    mov     ax, @data             ; Initialize data segment
    mov     ds, ax

    mov     si, offset nums       ; SI = base address of nums
    xor     ax, ax                ; AX = sum = 0
    xor     bx, bx                ; BX = index = 0

mean_loop:
    mov     dl, [si + bx]         ; Read byte from array
    add     al, dl                ; Add to sum (AL)
    inc     bx                    ; index++
    cmp     bx, 5                 ; Compare with array size
    jl      mean_loop             ; If index < 5, continue loop

   
    mov     ah, 0                 ; Clear AH 
    mov     bl, 5                 ; Divisor = 5
    div     bl                    ; AL / BL -> Quotient in AL, remainder in AH

    ; AL now contains the mean

end_loop:
    jmp     end_loop              ; Infinite loop to halt
