; post2a.asm - INT 16h: leer scan codes
; Compilar: nasm -f bin post2a.asm -o post2a.com
;
; INT 16h / AH=00h espera una tecla y retorna AH = scan code (codigo de hardware)
; y AL = codigo ASCII. En las teclas extendidas (cursores, F1-F12, Insert, Delete)
; AL = 00h y solo el scan code identifica la tecla. El programa muestra ambos
; valores en hexadecimal hasta que se pulsa Escape (scan code 01h).

ORG 100h                        ; formato .COM

SCAN_ESC equ 01h                ; scan code de la tecla Escape
CR       equ 0Dh
LF       equ 0Ah

section .data
    prompt   db "Pulse una tecla (ESC para salir): ", CR, LF, "$"
    msgScan  db "Scan: $"
    msgAscii db "  ASCII: $"
    crlf     db CR, LF, "$"

section .text
start:
    mov ah, 09h                 ; imprimir el prompt (INT 21h / AH=09h)
    mov dx, prompt
    int 21h

.leer_tecla:
    mov ah, 00h                 ; INT 16h / AH=00h: espera una tecla
    int 16h                     ; AH = scan code, AL = ASCII (0 si es extendida)
    mov bl, ah                  ; BL = scan code
    mov bh, al                  ; BH = codigo ASCII

    cmp bl, SCAN_ESC            ; Escape termina el programa
    je .fin

    ; Mostrar "Scan: XX"
    mov ah, 09h
    mov dx, msgScan
    int 21h
    mov al, bl
    call imprimir_hex

    ; Mostrar "  ASCII: XX"
    mov ah, 09h
    mov dx, msgAscii
    int 21h
    mov al, bh
    call imprimir_hex

    mov ah, 09h                 ; nueva linea
    mov dx, crlf
    int 21h
    jmp .leer_tecla

.fin:
    mov ah, 4Ch                 ; terminar proceso
    xor al, al
    int 21h

; --- Subrutina: imprime AL como 2 digitos hexadecimales (INT 21h / AH=02h) ------
imprimir_hex:
    push ax                     ; conservar AL para el nibble bajo
    shr al, 4                   ; nibble alto
    call nibble_a_caracter
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    and al, 0Fh                 ; nibble bajo
    call nibble_a_caracter
    mov dl, al
    mov ah, 02h
    int 21h
    ret

; --- Subrutina: convierte el nibble de AL (0-15) en su caracter ASCII hexadecimal
nibble_a_caracter:
    cmp al, 9
    jle .digito
    add al, 37h                 ; 10-15 -> "A"-"F"
    ret
.digito:
    add al, 30h                 ; 0-9 -> "0"-"9"
    ret
