section .data

complex1:
    complex1_name db 'a'
    complex1_pad  db 7 dup(0)  
    complex1_real dq 1.0
    complex1_img  dq 2.5

complex2:
    complex2_name db 'b'
    complex2_pad  db 7 dup(0)  
    complex2_real dq 3.5
    complex2_img  dq 4.0

polar_complx:
    polar_complx_name db 'c'
    polar_complx_pad db 7 dup(0)
    polar_complx_mag dq 10.0
    polar_complx_ang dq 0.0001

fmt db "%s => %f %f", 10, 0     ;
label_polar2rect db "Testing polars to rectangular",0
label_exp db "Testing exp",0
label_sin db "Testing sin",0
label_cos db "Testing cos",0

;;;;;;;;;;;;;
align 16
six dq 6.0
    dq 0.0
align 16
two dq 2.0
    dq 0.0
align 16
one dq 1.0
    dq 0.0
align 16
temp dq 0.0
     dq 0.0
align 16
fivefact dq 120.0
        dq 0.0
align 16
sevenfact dq 5040.0
    dq 0.0
align 16
fourfact dq 24.0
    dq 0.0
align 16
sixfact dq 720.0
       dq 0.0
;;;; Fill other constants needed 
;;;;;;;;;;;;;

temp_cmplx:
    temp_name db 'r'
    temp_pad  db 7 dup(0)
    temp_real dq 0.0
    temp_img  dq 0.0

section .text
    default rel
    extern print_cmplx,print_float
    global main

main:
    push rbp
    
    ; --- Test: Polar to Rectangular ---
    lea rdi, [polar_complx]         ; pointer to input polar struct
    lea rsi, [temp_cmplx]     ; pointer to output rect struct
    
    call polars_to_rect

    lea rdi, [label_polar2rect]
    lea rsi, [temp_cmplx]
    call print_cmplx          ; should show converted rectangular form

    ; --- Test: exp ---
    movups xmm0, [two]
    mov rdi, 0x6

    call exp

    movups [temp],xmm0 
    lea rdi, [label_exp]
    lea rsi , [temp]
    call print_float

    ; --- Test: sin ---
    movups xmm0, [two]

    call sin

    movups [temp],xmm0 
    lea rdi, [label_sin]
    lea rsi , [temp]
    call print_float

    ; --- Test: cos ---
    movups xmm0, [two]
    call cos

    movups [temp],xmm0 
    lea rdi, [label_cos]
    lea rsi , [temp]
    call print_float

    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status 0
    syscall


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FILL FUNCTIONS BELOW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------------
polars_to_rect:
;rdi has adress of polar complx rsi has address of rectangle form temp_complx
    push rbp
    mov rbp, rsp
    movsd xmm1,[rdi + 8]
    movsd xmm0, [rdi + 16]
    movsd xmm2,xmm0
    call sin
    mulsd xmm0,xmm1
    movsd [rsi + 16],xmm0
    movsd xmm0,xmm2
    call cos
    mulsd xmm0,xmm1
    movsd [rsi + 8],xmm0
    pop rbp
    ret
;-------------------------------------------------
exp:
;input is xmm0 and power is stored in rdi, output is to be stored in xmm0 only.
    push rbp
    mov rbp,rsp
    xor rcx,rcx
    movsd xmm3,xmm0
    movsd xmm0, qword [one]
    exp_loop:
    cmp rcx,rdi
    jge loop_end
    mulsd xmm0,xmm3
    inc rcx
    jmp exp_loop
loop_end:
    pop rbp
    ret
;nothing
;-------------------------------------------------
sin:
    push rbp
    mov rbp, rsp
    sub rsp, 64             

    movsd  [rsp+0], xmm0     

    
    movsd  xmm0, [rsp+0]     
    mov    rdi, 3
    call   exp                
    divsd  xmm0, qword [six]  
    movsd  [rsp+16], xmm0    

   
    movsd  xmm0, [rsp+0]     
    mov    rdi, 5
    call   exp                
    divsd  xmm0, qword [fivefact] 
    movsd  [rsp+24], xmm0     

   
    movsd  xmm0, [rsp+0]      
    mov    rdi, 7
    call   exp               
    divsd  xmm0, qword [sevenfact] 
    movsd  [rsp+32], xmm0     

  
    movsd  xmm0, [rsp+0]    
    subsd  xmm0, [rsp+16]    
    addsd  xmm0, [rsp+24]    
    subsd  xmm0, [rsp+32]     

    add rsp, 64
    pop rbp
    ret



;xmm0 is the input and is also the output.
cos:
    push rbp
    mov rbp, rsp
    sub rsp, 64            

    movsd  [rsp+0], xmm0      

   
    movsd  xmm0, [rsp+0]
    mov    rdi, 2
    call   exp                
    divsd  xmm0, qword [two]  
    movsd  [rsp+16], xmm0     

  
    movsd  xmm0, [rsp+0]
    mov    rdi, 4
    call   exp               
    divsd  xmm0, qword [fourfact]
    movsd  [rsp+24], xmm0     

   
    movsd  xmm0, [rsp+0]
    mov    rdi, 6
    call   exp                
    divsd  xmm0, qword [sixfact] 
    movsd  [rsp+32], xmm0     

   
    movsd  xmm0, qword [one] 
    subsd  xmm0, [rsp+16]    
    addsd  xmm0, [rsp+24]     
    subsd  xmm0, [rsp+32]     

    add rsp, 64
    pop rbp
    ret
;-------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CODE ENDS HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
