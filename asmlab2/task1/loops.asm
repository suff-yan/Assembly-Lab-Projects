section .data
    buffer  db 20 dup(0)     ; Output buffer for result string

section .bss
    input_buf resb 20  ; Reserve 20 bytes for input
    num     resq 1     ; 64-bit integer

section .text
    global _start ; essentially just means start here


_start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Take in number as input from user
    ; You can do this using read(0, input_buffer, size) syscall, syscall number for read is 0
    ; Make sure your input buffer is stored in rsi :)

    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, num
    syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; The below code simply converts input string to a number, don't worry about it
    mov rsi, input_buf  ; rsi points to buffer
    xor rax, rax        ; accumulator = 0

.convert1:
    movzx rcx, byte [rsi] ; load byte
    cmp rcx, 10           ; check for newline
    je .done1
    sub rcx, '0'          ; convert ASCII to digit
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp .convert1


.done1:
    ; Now RAX contains the number entered

    ; Implement following C code:
    ; int a = 0;
    ; int b = 1;
    ; for (int i=0; i < n; i++) {
    ;     int c = a + b;
    ;     a = b;
    ;     b = c;
    ; }
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push rbp
    push rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    sub rsp, 32
    mov [rsp], rax ;rsp=n
    mov rax, 0   ;a
    mov [rsp+8], rax
    mov rax, 1    ;b
    mov [rsp+16], rax
    mov rax, 0 ;i
    mov [rsp+24], rax

forBegin:
    mov rax, [rsp+24]   ;rax=i
    mov rbx, [rsp] ; rbx=n
    cmp rax, rbx
    jge forEnd
    sub rsp, 16    ;n,a,b,i are numbered wise shifted by 8
    mov rax, [rsp+24] ;rax=a
    mov rbx, [rsp+32] ;rbx=b
    add rax, rbx ;a=a+b
    mov [rsp+24], rbx ;a=b
    mov [rsp+32], rax ;b=c
    add rsp, 16
    mov rax, [rsp+24]
    add rax, 1
    mov [rsp+24], rax ;i++
    jmp forBegin

forEnd:
    mov rax, [rsp+8]
    add rsp, 32
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Print the result
    ; C code is:
    ; i = 19
    ; while (a > 0) {
    ;   buff[i] = a % 10 + '0'; Note you must access only the lower 8 bits of your register storing a here :) for example, for rdx, lower 8 bits are stored in dl
    ;   a /= 10;
    ;   i--;
    ; }
    ; write(1, buff + i + 1, 19 - i); 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    sub rsp, 16
    mov rbx, 19
    mov [rsp+8], rbx     ;[rsp]=i=19, and rax contains n the fibonaacci or an offset by one

whileBegin:
    mov rbx, [rsp+8]  ;rbx=i
    cmp rax,0
    jle whileEnd
    mov rcx, 10
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [buffer+rbx], dl 
    sub rbx, 1
    mov [rsp+8], rbx ;i--
    jmp whileBegin

whileEnd:
    add rsp, 16
    mov r15, rbx
    mov r14, 19
    add r15, 1     ;r15=i+1
    add r15, buffer
    sub r14, rbx   ;r14=19-i

    mov rax, 1
    mov rdi, 1
    mov rsi, r15
    mov rdx, r14
    syscall

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rsp
    pop rbp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF YOUR CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov rax, 60              ; syscall: exit
    xor rdi, rdi             ; exit code 0
    syscall