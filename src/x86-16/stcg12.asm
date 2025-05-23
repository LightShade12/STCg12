
org 100h
jmp start

;==================================================================================================
.DATA
titlestr db '[Statistical Calculator v1.0.1.0]$'
szpmtstr db 'Enter population size (INT) (MAX=10): $'
msgstr db 'Requesting sample values:$'
inpmtstr db "Enter value for sample $"
msg2 db " (INT) (UNSIGNED DECIMAL) (MAX=9): $"
sample_buffer dw 10 DUP(0)
printarr_str db "Samples: $"
sorted_str db "Sorted: $"
sp_v_set_str db "Sample values set$"
divider_str db "[==============================================================]$"
count_str db "Count: $"
mean_str db "Arithmetic Mean: $"
median_str db "Arithmetic Median: $"
mode_str db "Mode: $"
maxstr db "Max: $"
minstr db "Min: $"
sdstr db "Standard deviation (Sigma): $"
varstr db "Variance (Sigma^2): $"
endstr db "[PROGRAM END]$"
;==================================================================================================
.CODE

INCLUDE "qsort.asm"
INCLUDE "mean.asm"
INCLUDE "utils.asm"

NEWLINE macro
    ;newline
    MOV AH, 0x2                         
    MOV DL, 0DH; cr
    INT 021H
    MOV DL, 0AH; \n
    INT 021H
NEWLINE endm

; void println(string addr)
; string addr : dx
println proc
    mov ah, 0x9
    int 0x21
    NEWLINE
    ret    
println endp

; void print(string addr)
; string addr : dx
print proc
    mov ah, 0x9
    int 0x21
    ret    
print endp


; int chtoi(char)
; char : al
; return int : al
chtoi proc
    push bx
    mov bl, al
    mov ax, 0
    sub bl, '0'; '0'
    mov al, bl
    pop bx
    ret
chtoi endp

; char itoch(int)
; int : al
; return char : al
itoch proc
    push bx
    mov bl, al
    mov ax, 0
    add bl, '0'; '0'
    mov al, bl
    pop bx
    ret
itoch endp

; returns arr_size : AX
getSampleArr proc
    lea dx, szpmtstr
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

    lea dx, msgstr
    call println

inp_loop:
    lea dx, inpmtstr
    call print

    ; fmt nums
    pop ax
    push ax
    call itoch
    mov dl, al
    mov ah, 02h
    int 21h
    
    mov dl, '/'
    int 21h
    
    mov al, cl
    call itoch
    mov dl, al
    mov ah,02h
    int 21h
    
    lea dx, msg2
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
    lea dx, sp_v_set_str
    call println
    lea dx, divider_str
    call println
    
    pop ax; return arr_size
    ret
getSampleArr endp

; void printArr(arr_seg_offset, arr_size)
; arr_seg_offset : AX
; arr_size : BX
printArr proc
    push cx
    push si
    
    mov si, 0
    mov cx, bx
    mov bx, ax
    xor ax, ax
    
printloop:
    
    mov ax, word ds[bx+si]
    call itoch
    mov dl, al
    mov ah, 02h
    int 21h
    
    mov ah, 02h
    mov dl, ','
    int 21h
    
    inc si
    inc si
    dec cx
    
    jnz printloop
    
endprintloop:
    NEWLINE
    
    pop si
    pop cx
    ret
printArr endp

callQsort proc
    ; prep to call qsort-----
    ; save registers ==
    push dx
    push cx
    push bx
    push ax; arr_sz
    
    mov bx, 2
    mul bx ; 2 bytes(1 word)(BX) * count(AX)
    mov bx, ax; bx = arr_byte_sz
    dec ax
    dec ax; minus 1 word (cuz its an offset)
    
    ; pass args (cdecl) ==
    push ax; arg: end offset

    mov ax, 0; 2 bytes(1 word) * 0 offset
    push ax; arg: start offset
    
    mov ax, bx ; arg: arr_size
    mov bx, 2
    div bx; ax = arr_sz
    push ax

    mov ax, OFFSET sample_buffer; get src arr offset from seg
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
callQsort endp

; sqrt of v : AX
; returns AX: sqrt(v)
STC_sqrt proc
    ret
STC_sqrt endp
    
computePopulationStandardDeviation proc
    ;TEMP=================
    mov ax, 6
    ret
    ;TEMP=================
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
    mul ax; diff squared
    xchg cx,  ax; cx -> diff, ax -> numer
    
    add ax, cx; numerator += diff
    
    pop cx
    
    inc si
    inc si
    dec cx
    jnz sdloop:
endsdloop:
    pop cx; restore orig arr_sz
    div cx; numerator/arr_sz
    
    call STC_sqrt
    
    pop si
    pop cx
    pop dx
    ret
computePopulationStandardDeviation endp


start:
mov ax, cs
mov ds, ax
xor ax,ax

lea dx, titlestr
call println

call getSampleArr
push ax; for 2nd print
push ax; for 1st print

;=====PRINT ARRAY========================

lea dx, printarr_str
call print
pop ax

; pass args
mov bx, ax
mov ax, OFFSET sample_buffer
call printArr

;=======PRINT SORTED ARRAY=====================

lea dx, sorted_str
call print
pop ax; arr_sz

; qsort here
call callQsort

push ax; save arr_sz
; pass args
mov bx, ax
mov ax, OFFSET sample_buffer
call printArr

lea dx, count_str
call print

pop ax; restore arr_sz
push ax
call itoch
mov dx, ax
mov ah, 02h
int 21h

NEWLINE

; display MEAN =========================
pop ax
push ax; save arr_sz
mov bx, ax ;arr_sz(words)
mov ax, OFFSET sample_buffer ;arr_seg_offset
call STC_computeMean
push ax; save mean

lea dx, mean_str
call print

pop ax; restore mean
call itoch
mov dx, ax
mov ah, 02h
int 21h

NEWLINE

; display MEDIAN =====================
lea dx, median_str
call println

; display MODE =========================
lea dx, mode_str
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
push ax; save max

lea dx, maxstr
call print

pop ax; restore max
call itoch
mov dx, ax
mov ah, 02h
int 21h

NEWLINE
; display MIN =============================
pop ax; arr_sz
push ax; save arr_sz
mov bx, OFFSET sample_buffer
mov ax, word ds[bx]; beginning element
push ax; save min

lea dx, minstr
call print

pop ax; restore min
call itoch
mov dx, ax
mov ah, 02h
int 21h

NEWLINE
; display SD =============================

pop ax; arr_sz
mov bx, OFFSET sample_buffer
xchg ax, bx
call computePopulationStandardDeviation
push ax; save SD

lea dx, sdstr
call print

pop ax; restore SD
push ax; save SD
call itoch
mov dx, ax
mov ah, 02h
int 21h

NEWLINE
; display VARIANCE =============================

pop ax; restore SD
mul ax; VAR = SQR(SD)
push ax; save VAR

lea dx, varstr
call print

pop ax; restore VAR
call itoch
mov dx, ax
mov ah, 02h
int 21h

NEWLINE
; END =========================================
lea dx, endstr
call println
;========================================

mov ah, 4Ch
int 0x21
