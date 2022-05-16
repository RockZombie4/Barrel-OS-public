org 0x7C00   ; add 0x7C00 to label addresses
 bits 16      ; tell the assembler we want 16 bit code
 
   mov ax, 0  ; set up segments
   mov ds, ax
   mov es, ax
   mov ss, ax     ; setup stack
   mov sp, 0x7C00 ; stack grows downwards from 0x7C00
 
   mov si, welcome
   call print_string
 
 mainloop:
   mov si, prompt
   call print_string
 
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; yes, ignore it
 
   mov si, buffer
   mov di, cmd_hi  ; "hi" command
   call strcmp
   jc .helloworld
 
   mov si, buffer
   mov di, cmd_help  ; "help" command
   call strcmp
   jc .help
  
   mov si, buffer
   mov di, cmd_clear  ; "clear" command
   call strcmp
   jc .clear

   mov si, buffer
   mov di, cmd_print  ; "print" command
   call strcmp
   jc .print

   mov si, buffer
   mov di, cmd_input  ; "input" command
   call strcmp
   jc .input

   mov si, buffer
   mov di, cmd_reboot  ; "reboot" command
   call strcmp
   jc .reboot

   mov si, buffer
   mov di, cmd_shutdown  ; "shutdown" command
   call strcmp
   jc .shutdown

 
   mov si,badcommand
   call print_string 
   jmp mainloop  
 
 .helloworld:
   mov si, msg_helloworld
   call print_string
 
   jmp mainloop
 
 .help:
   mov si, msg_help
   call print_string
 
   jmp mainloop

; --------------------------------- clear command
 .clear:
   mov ax, 13h
   int 10h
   int 0x10
   db 0x0ea
   dw 0x0000
   dw 0xffff

 .print:
   %include "printinput.asm"
 .input:
   mov ah, 00h
   int 16h
 .reboot:
; put whatever code you want here!!! (Replace the code here.)

   mov ah, 0x0e ; tty mode 
   mov al, 'R'
   int 0x10
   mov al, 'E'
   int 0x10
   mov al, 'B'
   int 0x10
   mov al, 'O'
   int 0x10
   mov al, 'O'
   int 0x10
   mov al, 'T'
   int 0x10


   db 0x0ea
   dw 0x0000
   dw 0xffff
 .shutdown:
   mov ah, 0x0e
   mov al, 'S'
   int 0x10
   mov al, 'H'
   int 0x10
   mov al, 'U'
   int 0x10
   mov al, 'T'
   int 0x10
   mov al, 'D'
   int 0x10
   mov al, 'O'
   int 0x10
   mov al, 'W'
   int 0x10
   mov al, 'N'
   int 0x10
   
 
 welcome db 'Welcome to My OS!', 0x0D, 0x0A, 0
 msg_helloworld db 'Hello OSDev World!', 0x0D, 0x0A, 0
 badcommand db 'Command not found!', 0x0D, 0x0A, 0
 prompt db '>', 0
 cmd_hi db 'hi', 0
 cmd_help db 'help', 0
 msg_help db 'My OS: Commands: hi, help, clear', 0x0D, 0x0A, 0
; --------------------clear command name
 cmd_clear db 'clear', 0
 cmd_print db 'print', 0
 cmd_input db 'input', 0
 cmd_reboot db 'reboot', 0
 cmd_shutdown db 'shutdown', 0 
 buffer times 64 db 0
 ; ================
 ; calls start here
 ; ================
 
 print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret
 
 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret
 
   times 510-($-$$) db 0
   dw 0AA55h ; some BIOSes require this signature
