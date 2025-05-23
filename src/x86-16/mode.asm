;--------------MODE--------------
;; compute void find_mode(arr_seg_idx, arr_size)
; scratch registers: AX, BX, CX, DX, SI, DI
;most frequent occuring value stored in AL
;-------------------------------------------------

org 100h

.MODEL SMALL
.DATA
nums    DB 10, 20, 30, 20, 10    ; Array of 5 bytes
max_count DB 0                   ; Highest frequency found
mode_val  DB 0                   ; Mode value (most frequent)

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX

    MOV SI, 0                   ; SI = i = 0 (outer loop index)

outer_loop:
    CMP SI, 5                   ; Check if i >= 5
    JGE done                    ; If yes, exit loop (Jump if Greater or Equal)

    MOV AL, nums[SI]            ; AL = nums[i] (current number)
    MOV BL, AL                  ; BL = current number to compare
    MOV CL, 0                   ; CL = count = 0
    MOV DI, 0                   ; DI = j = 0 (inner loop index)

inner_loop:
    CMP DI, 5                   ; If j >= 5, end inner loop
    JGE check_count

    MOV AL, nums[DI]            ; AL = nums[j]
    CMP AL, BL                  ; Compare nums[j] with nums[i]
    JNE skip_count              ;Jump if Not Equal

    INC CL                      ; count++

skip_count:
    INC DI                      ; j++
    JMP inner_loop              ; Repeat inner loop

check_count:
    MOV AL, max_count
    CMP CL, AL                  ; Compare count with max_count
    JBE skip_update             ; If count <= max_count, skip update
                                ; Jump if Below or Equal 
    MOV max_count, CL           ; max_count = count
    MOV mode_val, BL            ; mode = current number

skip_update:
    INC SI                      ; i++
    JMP outer_loop              ; Repeat outer loop

done:
    MOV AL, mode_val            ; Mode value in AL

exit:
    HLT                         ; End program (HLT used for demonstration)

END MAIN


ret




