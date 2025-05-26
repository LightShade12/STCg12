
org 100h
jmp start

;=============CONSTANT DATA=====================================================================================
.DATA

; MEMORY BLOCK
sample_buffer dw 10 DUP(0)

; STRINGS FOR PRINTING 
divider_str db "[==============================================================]$"
prog_title_str db '[Statistical Calculator v1.0.1.0]$'
team_name_str db "[Software by: GROUP 12]$"
note1_str db "NOTE: INTEGER MATHEMATICS ONLY$"
usr_size_prompt_str db 'Enter population size (INT) (MAX=9): $'
input_loop_heading_str db 'Requesting sample values:$'
usr_sample_prompt_beg_str db "Enter value for sample $"
usr_sample_prompt_end_str db " (INT) (UNSIGNED DECIMAL) (MAX=9): $"
input_confirm_str db "Sample values set [OK]$"
arr_print_str db "Samples: $"
arr_sorted_print_str db "Sorted: $"
count_str db "Count: $"
mean_str db "Arithmetic Mean: $"
median_str db "Arithmetic Median: $"
mode_str db "Mode: $"
arr_max_str db "Max: $"
arr_min_str db "Min: $"
standard_deviation_str db "Standard deviation (Sigma): $"
variance_str db "Variance (Sigma^2): $"
prog_end_str db "[PROGRAM END]$"
;==================================================================================================
.CODE

INCLUDE "qsort.asm"
INCLUDE "mean.asm"
INCLUDE "utils.asm"
INCLUDE "mode.asm"
INCLUDE "median.asm"
INCLUDE "SD.asm"

; returns arr_size : AX
getSampleArr proc
    lea dx, usr_size_prompt_str
    call print

    ; parse int
    mov ah, 0x1
    int 0x21
    call chtoi

    mov cx, 0
    mov cl, al; set arr_size
    push cx
    mov si, OFFSET sample_buffer
    
    NEWLINE

    lea dx, input_loop_heading_str
    call println

inp_loop:
    lea dx, usr_sample_prompt_beg_str
    call print

    mov al, cl
    call itoch
    mov dl, al
    mov ah,02h
    int 21h
    
    mov dl, '/'
    int 21h
    
    ; fmt nums
    pop ax
    push ax
    call itoch
    mov dl, al
    mov ah, 02h
    int 21h
    
    lea dx, usr_sample_prompt_end_str
    call print

    ; single inputs
    mov ah, 01h
    int 21h
    call chtoi
    mov word ds[si], ax
    inc si
    inc si

    NEWLINE

    dec cl
    jnz inp_loop
inp_loop_end:
    lea dx, input_confirm_str
    call println
    lea dx, divider_str
    call println
    
    pop ax; return arr_size
    ret
getSampleArr endp

;=================================== PROGRAM START==============================
start:
; setup ds
mov ax, cs
mov ds, ax
xor ax, ax

; decorative prints
lea dx, divider_str
call println

lea dx, prog_title_str
call println

lea dx, team_name_str
call println

lea dx, note1_str
call println

lea dx, divider_str
call println

; call sample collection procedure
call getSampleArr; will return arr_size to AX
push ax; for print

;=====PRINT ARRAY========================

lea dx, arr_print_str
call print

; pass args
mov bx, ax
mov ax, OFFSET sample_buffer
call printArr

;=======PRINT SORTED ARRAY=====================

lea dx, arr_sorted_print_str
call print
pop ax; arr_sz

; qsort here
call callQsort

push ax; save arr_sz
; pass args
mov bx, ax
mov ax, OFFSET sample_buffer
call printArr

; display COUNT =============================

lea dx, count_str
call print

pop ax; restore arr_sz

call printNum

NEWLINE

; display MEAN =========================
push ax; save arr_sz
mov bx, ax ;arr_sz(words)
mov ax, OFFSET sample_buffer ;arr_seg_offset
call STC_computeMean; retuns mean in AX

lea dx, mean_str
call print

call printNum

NEWLINE

; display MEDIAN =====================
pop ax; arr_sz
push ax; save arr_sz

mov bx, OFFSET sample_buffer
xchg ax, bx
call STC_computeMedian; returns median in AX

lea dx, median_str
call print

call printNum; AX has Median value

NEWLINE

; display MODE =========================
pop ax; arr_sz
push ax; save arr_sz

mov bx, OFFSET sample_buffer
xchg ax, bx; ax -> arr_seg_offset; bx-> arr_sz
call STC_computeMode; returns mode in AX

lea dx, mode_str
call print

call printNum;AX has mode value

NEWLINE

; display MAX ===========================
pop ax; arr_sz
push ax; save arr_sz

mov bx, OFFSET sample_buffer
mov si, 2
mul si; ax = bytesize = 2 * arr_size
dec ax; ax--
dec ax; ax = offset (size-1)
mov si, ax
mov ax, word ds[bx+si]; end element

lea dx, arr_max_str
call print

call printNum

NEWLINE
; display MIN =============================
pop ax; arr_sz
push ax; save arr_sz
mov bx, OFFSET sample_buffer
mov ax, word ds[bx]; beginning element

lea dx, arr_min_str
call print

call printNum

NEWLINE
; display SD =============================

pop ax; arr_sz
mov bx, OFFSET sample_buffer
xchg ax, bx
call computePopulationStandardDeviation

lea dx, standard_deviation_str
call print

push ax; save SD for variance
call printNum

NEWLINE
; display VARIANCE =============================

pop ax; restore SD
mul ax; VAR = SQR(SD)

lea dx, variance_str
call print

call printNum

NEWLINE
; END =========================================
; decorative prints
lea dx, divider_str
call println

lea dx, prog_end_str
call println

;================================================

mov ah, 4Ch; return to OS
int 0x21

; PROGRAM END ===================================================================