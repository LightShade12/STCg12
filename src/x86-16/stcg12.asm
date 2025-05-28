
org 100h
jmp start

;=============CONSTANT DATA=====================================================================================
.DATA

; MEMORY BLOCK
sample_buffer dw 10 DUP(0)
SCANF_MAX_LEN db 20
scanf_buffer db 21 DUP(0)
int_buffer db 21 DUP(0)

; STRINGS FOR PRINTING 
divider_str db "[==============================================================]$"
prog_title_str db "[Statistical Calculator v1.0.1.0]$"
team_name_str db "[Software by: GROUP 12]$"
note1_str db "NOTE: INTEGER MATHEMATICS ONLY$"
usr_size_prompt_str db "Enter population size (INT) (MAX=9): $"
input_loop_heading_str db "Requesting sample values:$"
usr_sample_prompt_beg_str db "Enter value for sample $"
usr_sample_prompt_end_str db " (INT) (UNSIGNED DECIMAL) (MAX=9): $"
input_confirm_str db "Sample values set [OK]$"
arr_print_str db "Samples: $"
arr_sorted_print_str db "Sorted: $"
count_str db "Count: $"
sum_str db "Sum: $"
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
querySampleArray proc
    push bp
    mov bp, sp
    sub sp, 32; 16 nums

    lea dx, usr_size_prompt_str
    call print

    ; parse int
    mov ah, 0x1
    int 0x21
    call chtoi; size in al

    mov cx, 0
    mov cl, al; cl = arr_size
    push cx; save size
    mov word ptr [bp-6], OFFSET sample_buffer
    
    NEWLINE

    lea dx, input_loop_heading_str
    call println

; collection loop
inp_loop:
    lea dx, usr_sample_prompt_beg_str
    call print

    ; printing (cur/cap)
    ; print curr
    mov al, cl
    call itoch
    mov dl, al
    mov ah, 02h
    int 21h; print
    
    ; print the slash
    mov dl, '/'
    int 21h; print
    
    ; print capacity
    pop ax;  orig arr_sz
    push ax; save arr_sz
    call itoch
    mov dl, al
    mov ah, 02h
    int 21h; print
    
    lea dx, usr_sample_prompt_end_str
    call print

    ; single inputs
    ;mov ah, 01h
    ;int 21h; input read
    ;call chtoi

    ; scanf proc
    mov al, SCANF_MAX_LEN
    mov si, ax
    lea di, scanf_buffer
    call scanf
    
    lea di, [scanf_buffer+2]
    call sttoi

    ; write to sample_buffer
    mov si, word ptr [bp-6]; sample_buffer_seg_offset
    mov word [si], ax
    inc word ptr [bp-6]
    inc word ptr [bp-6]

    NEWLINE

    dec cl; dec curr
    jnz inp_loop
inp_loop_end:
    lea dx, input_confirm_str
    call println
    lea dx, divider_str
    call println
    
    pop ax; return arr_size to AX

    add sp, 32
    pop bp
    ret
querySampleArray endp

;=================================== PROGRAM START==============================
start:
    ; setup ds
    mov ax, cs
    mov ds, ax
    xor ax, ax

    ;; scanf proc
    ;mov al, SCANF_MAX_LEN
    ;mov si, ax
    ;lea di, scanf_buffer
    ;call scanf
    
    ;lea di, [scanf_buffer+2]
    ;call sttoi

    ;mov si, ax
    ;lea di, int_buffer
    ;call ittost

    ;NEWLINE
    ;lea dx, int_buffer
    ;call println

    ;; accessing input
    ;lea dx, [scanf_buffer+2]
    ;call println
    
    ;ret

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
    call querySampleArray; will return arr_size to AX
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

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display SUM ===========================
    push ax; save arr_sz
    mov bx, ax ;arr_sz(words)
    mov ax, OFFSET sample_buffer ;arr_seg_offset
    call STC_computeSum; returns sum in AX

    lea dx, sum_str
    call print

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display MEAN =========================
    pop ax; restore arr_sz
    push ax; save arr_sz
    mov bx, ax ;arr_sz(words)
    mov ax, OFFSET sample_buffer ;arr_seg_offset
    call STC_computeMean; retuns mean in AX

    lea dx, mean_str
    call print

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display MEDIAN =====================
    pop ax; arr_sz
    push ax; save arr_sz

    mov bx, OFFSET sample_buffer
    xchg ax, bx
    call STC_computeMedian; returns median in AX

    lea dx, median_str
    call print

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display MODE =========================
    pop ax; arr_sz
    push ax; save arr_sz

    mov bx, OFFSET sample_buffer
    xchg ax, bx; ax -> arr_seg_offset; bx-> arr_sz
    call STC_computeMode; returns mode in AX

    lea dx, mode_str
    call print

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

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

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display MIN =============================
    pop ax; arr_sz
    push ax; save arr_sz
    mov bx, OFFSET sample_buffer
    mov ax, word ds[bx]; beginning element

    lea dx, arr_min_str
    call print

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display SD =============================

    pop ax; arr_sz
    mov bx, OFFSET sample_buffer
    xchg ax, bx
    call STC_computePopulationStandardDeviation

    lea dx, standard_deviation_str
    call print

    push ax; save SD for variance

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; display VARIANCE =============================

    pop ax; restore SD
    mul ax; VAR = SQR(SD)

    lea dx, variance_str
    call print

    mov si, ax
    lea di, int_buffer
    call ittost

    lea dx, int_buffer
    call println

    ; END =========================================
    ; decorative prints
    lea dx, divider_str
    call println

    lea dx, prog_end_str
    call println

    ;================================================

    mov al, 0; exit code: EXIT_SUCCESS
    mov ah, 0x4C; return to OS
    int 0x21

; PROGRAM END ===================================================================