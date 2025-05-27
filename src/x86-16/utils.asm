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

NEWLINE macro
    push ax
    push dx
    ;newline
    MOV AH, 0x2                         
    MOV DL, 0DH; cr
    INT 021H
    MOV DL, 0AH; \n
    INT 021H
    pop dx
    pop ax
NEWLINE endm

; void println(string addr)
; string addr : dx
println proc
    push ax
    mov ah, 0x9
    int 0x21
    NEWLINE
    pop ax
    ret    
println endp

; void print(string addr)
; string addr : dx
print proc
    push ax
    mov ah, 0x9
    int 0x21
    pop ax
    ret    
print endp


; int chtoi(char)
; char : al
; return int : al
chtoi proc
    push bx
    mov bl, al
    mov ax, 0
    sub bl, '0'; get integer
    mov al, bl
    pop bx
    ret
chtoi endp

; int sttoi(str_seg_offset)
; str_seg_offset : DI
; return int : AX
sttoi proc
    push bp
    mov bp, sp
    push bx
    sub sp, 32

    mov word ptr [bp-4], 0; result

    mov si, 0
    mov bx, di; bx = str_seg_offset

parseintloop:
    mov ax, 0
    mov al, byte ptr [bx + si]; fetch char
    cmp al, '$'
    je endparseintloop; break if null terminator

    call chtoi; integer in al now
    mov word ptr [bp-6], ax

    mov ax, word ptr [bp-4];ax=res
    mov dx, 10
    mul dx; res*=10

    add ax, word ptr [bp-6]; res+=int
    mov word ptr [bp-4], ax

    inc si
    jmp parseintloop
endparseintloop:

    mov ax, word ptr [bp-4]; final

    add sp, 32
    pop bx
    pop bp
    ret
sttoi endp

; str is stored in wrong place(beginning of ds)
; dx is stripped from addr calc
; X is stored 2 places away from [bx](i.e max_size)

; void scanf(buffer_seg_offset, size)
; buffer_seg_offset : DI
; size : SI
scanf proc
    push bp
    mov bp, sp
    push bx; save scratch reg

    mov bx, di; bx=arr_seg_offset
    mov ax, si; ax=max_input_size
    mov byte ptr [bx], al; set max length in 1st pos(byte)
    mov dx, bx; for 0A int
    mov al, 0; prep for DOS interrupt
    mov ah, 0x0A
    int 0x21

    mov dl, [bx+1]; input read length/size
    mov dh, 0
    mov di, dx
    mov [bx+di+2], '$'; append null terminator

    pop bx
    pop bp
    ret
scanf endp

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

; ONLY WORKS FOR DECIMAL DIGITS
; write to DS:DX
; void ittost(buff_addr, val)
; buff_addr : DI
; val : SI
ittost proc
    push bp
    mov bp, sp
    push bx
    sub sp, 32

    mov bx, di; bx = buff_seg_offset
    mov word ptr [bp-4], si; value
    mov si, 0

itostrloop:
    mov ax, word ptr [bp-4]; value
    and ax, 0xF000
    shr ax, 3*4; hexadecimal MSD
    inc si
enditostrloop:

    add sp, 32
    pop bx
    pop bp
    ret
ittost endp



; void printNum(num)
; num : AX
printNum proc
    push dx
    push ax
    call itoch
    mov dx, ax
    mov ah, 02h
    int 21h
    pop ax
    pop dx
    ret
printNum endp

; void printArr(arr_seg_offset, arr_size)
; arr_seg_offset : AX
; arr_size : BX
printArr proc
    push cx
    push si
    push bx
    push ax
    
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
    
    pop ax
    pop bx 
    pop si
    pop cx
    ret
printArr endp

; sqrt of v : DI
; returns AX: sqrt(v)
STC_sqrt proc
    push bp
    mov bp, sp
    push bx
    mov word [bp-6], di; assign v
    mov word [bp-8], 1; count
    
sqrtloop:

    mov ax, word [bp-8]; ax = count
    mul ax; sqr(count)
    cmp ax, word [bp-6]
    jg sqrtloopend; if (sqr(cx)>v): break
    
    inc word [bp-8]; count++
    jmp sqrtloop; loopback while(true)

sqrtloopend:
    sub word [bp-8], 1
    mov ax, word [bp-8]; return in ax
    
    pop bx
    pop bp
    ret
STC_sqrt endp

; int STC_computeSum(arr_seg_offset, arr_size)
; arr_seg_offset : AX
; arr_size : BX
; returns sum of elements : AX
STC_computeSum proc

    ; save scratch regs
    push dx
    push cx
    push bx
    push si
    
    mov cx, bx; cx = arr_size
    mov bx, ax; bx = arr_seg_offset
    xor ax, ax; sum
    mov si, 0; idx
    
sumloop:
    
    mov dx, word ds[bx+si]
    add ax, dx
    
    inc si
    inc si; idx++
    
    dec cx
    jnz sumloop
endsumloop:
    
    ; restore scratch regs
    pop si
    pop bx
    pop cx
    pop dx
    ret
STC_computeSum endp