section .data
    shifted_disk db "Shifted disk "
    from_str db " from "
    to_str db " to "
    a_rod db 'A'
    b_rod db 'B'
    c_rod db 'C'
    newline db 10
    shifted_len equ 13
    from_len equ 6
    to_len equ 4
    buffer db 100 dup(0) ; Output buffer for result string

section .bss
    input_buf resb 20  ; Reserve 20 bytes for input
    num resq 1         ; 64-bit integer

section .text
    global printNum
    global hanoi
    global _start 
    global printFromAndTo

printNum:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to print an arbitary number stored in rax    
    ; num in rdi since thats the first parameter and its an adrres to the buffer probably rsp part
    push rbp
    push rbx
    push rcx
    push rdx

    mov rax, rdi
    lea rsi, [buffer+99] ;using 99 because we need the number to be in the correct order
    xor rbp, rbp
    cmp rax, 0
    jne .tostring_test
    sub rsi, 1
    mov byte [rsi], '0'
    mov rbp, 1
    jmp .show

.tostring_test:
    mov rcx, 10

.tostring:
    xor rdx, rdx
    div rcx
    add dl, '0'
    sub rsi, 1
    mov [rsi], dl
    add rbp, 1
    cmp rax, 0
    jne .tostring

.show:
    mov rax, 1
    mov rdi, 1    ;rsi is already fixed to first digit of number in decimal form
    mov rdx, rbp
    syscall

    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printFromAndTo:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to print " from " *rax " to " *rdi
    ;but aren't the parameters
    push rax
    push rdi
    push rsi
    push rdx

    mov al, dil
    mov bl, sil
    push rax
    push rbx
    mov rax, 1
    mov rdi, 1
    mov rsi, from_str
    mov rdx, from_len
    syscall
    pop rbx
    pop rax
    mov [buffer], al
    push rax
    push rbx
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 1
    syscall
    pop rbx
    pop rax
    
    push rax
    push rbx
    mov rax, 1
    mov rdi, 1
    mov rsi, to_str
    mov rdx, to_len
    syscall
    pop rbx
    pop rax
    mov [buffer], bl
    push rax
    push rbx
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 1
    syscall
    pop rbx
    pop rax
    push rax
    push rbx
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    pop rbx
    pop rax

    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; C code for function
;;;; void hanoi(int n, char from, char to, char aux) {
;;;;     if (n == 1) {
;;;;         printf("Shifted disk 1 from %c to %c\n", from, to);
;;;;         return;
;;;;     }
;;;;     hanoi(n - 1, from, aux, to);
;;;;     printf("Shifted disk %d from %c to %c\n", n, from, to);
;;;;     hanoi(n - 1, aux, to, from);
;;;; }


hanoi:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi  
    mov r13, rsi    
    mov r14, rdx     
    mov r15, rcx  
    cmp r12, 1
    jne .repeat
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 1
    mov rdi, 1
    mov rsi, shifted_disk
    mov rdx, shifted_len
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    push rdi
    mov rdi, 1
    call printNum
    pop rdi
    
    mov rdi, r13  
    mov rsi, r14   
    call printFromAndTo
    jmp .end
    
.repeat:
    mov rdi, r12
    sub rdi, 1
    mov rsi, r13   
    mov rdx, r15  
    mov rcx, r14    
    call hanoi
    
    push rax
    push rdi
    push rsi
    push rdx
    mov rax, 1
    mov rdi, 1
    mov rsi, shifted_disk
    mov rdx, shifted_len
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    push rdi
    mov rdi, r12
    call printNum
    pop rdi
    mov rdi, r13  
    mov rsi, r14 
    call printFromAndTo
    mov rdi, r12
    sub rdi, 1
    mov rsi, r15
    mov rdx, r14
    mov rcx, r13
    call hanoi
    
.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start of your code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write code to take in number as input, then call hanoi(num, 'A','B','C')
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 20
    syscall

    ;some more stuff, to convert the decimal string to a 64 bit number

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx

.tonum:
    mov al, [input_buf+rcx]
    cmp al, 10
    je .done
    sub al, '0'
    imul rbx, 10
    add rbx, rax
    add rcx, 1
    jmp .tonum

.done:
    mov [num], rbx
    mov rdi, rbx
    mov rsi, 'A'
    mov rdx, 'B'
    mov rcx, 'C'
    call hanoi

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of your code  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall
