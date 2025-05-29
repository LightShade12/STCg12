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
    mov ah, 0
    add al, '0'; map to char representation
    ret
itoch endp

; write to DS:DI
; void ittost(buff_addr, val)
; buff_addr : DI
; val : SI
ittost proc
    push bp
    mov bp, sp
    push bx
    push ax
    sub sp, 32; 16 numbers

    mov bx, di; bx = buff_seg_offset
    mov ax, si; ax = value
    mov word ptr [bp-8], 10; dec base
    mov si, 0
    mov cx, 0; str_out_len

ittost_convert_loop:
    mov dx, 0; dec num
    div word ptr [bp-8]; ax/=10

    add dl, '0'; map to char
    push dx; save lsd dec char

    inc cx; str_out_len++
    cmp ax, 9
    jg ittost_convert_loop; loop till al < 9

    cmp ax, 0
    je ittost_writer_loop
    add al, '0'; map to char
    mov byte ptr [bx+si], al; write msd to str_buff
    inc si

ittost_writer_loop:
    pop ax; fetch dec char
    mov byte ptr [bx+si], al;  write to string_buff
    inc si
loop ittost_writer_loop; loop till str_out_len written

    mov byte ptr [bx+si], '$';  write terminator to string_buff

    add sp, 32
    pop ax
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
    push bp
    mov bp, sp
    sub sp, 32; 16

    push cx
    push si
    push bx
    push ax
    
    mov word ptr [bp-4], 0; index
    mov cx, bx; arr_sz
    mov bx, ax; arr_seg_offset
    xor ax, ax
    
printloop:
    push cx 

    mov si, word ptr [bp-4]; load idx
    mov ax, word ptr ds[bx+si]; fetch element

    mov si, ax
    lea di, int_buffer
    call ittost; convert to str

    lea dx, int_buffer
    call print; print number
   
    mov dl, ','
    mov ah, 02h
    int 21h; print comma
    
    inc word ptr [bp-4]
    inc word ptr [bp-4]; index++

    pop cx
    dec cx
    jnz printloop
    
endprintloop:
    NEWLINE
    
    pop ax
    pop bx 
    pop si
    pop cx

    add sp, 32
    pop bp

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

; 1,048,576 bytes or 1 Megabyte (1MB)
; segment is 64KB
; fff7 : ffff
; malloc
; - allocates heap memory
; 
; int malloc(bytesize)
; bytesize : DI
; returns memory block address : AX
malloc proc
    push bp
    mov bp, sp
    sub sp, 32; 16 nums

    mov word ptr [bp-2], 0xA00; segment offset
    mov ax, word ptr [bp-2]

    add sp, 32
    pop bp
    ret
malloc endp