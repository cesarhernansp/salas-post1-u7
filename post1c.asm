; post1c.asm - Cadena en posicion exacta con color
; Compilar: nasm -f bin post1c.asm -o post1c.com
;
; Recorre una cadena caracter por caracter: por cada uno posiciona el cursor
; (INT 10h / AH=02h) y lo escribe con atributo (INT 10h / AH=09h), de modo que
; el texto queda en una fila/columna exacta y con color.

ORG 100h                        ; formato .COM

FIN_CADENA   equ "$"            ; terminador de la cadena
ATTR_NORMAL  equ 07h            ; gris sobre negro
ATTR_VERDE_CLARO equ 0Ah        ; texto verde claro sobre fondo negro

section .data
    titulo db "UNIDAD 7 - PANTALLA Y TECLADO", FIN_CADENA
    filaT  equ 5                ; fila fija del titulo
    colT   equ 25               ; columna inicial: (80 - 29) / 2 = 25, centrado

section .text
start:
    ; Limpiar pantalla (INT 10h / AH=06h)
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, ATTR_NORMAL
    int 10h

    ; Preparar el recorrido de la cadena
    mov si, titulo              ; SI apunta al inicio de la cadena
    mov dl, colT                ; DL = columna inicial
    mov dh, filaT               ; DH = fila fija

.bucle_caracter:
    mov al, [si]                ; cargar el siguiente caracter
    cmp al, FIN_CADENA          ; fin de la cadena?
    je .fin

    ; Posicionar el cursor en (DH, DL)
    mov ah, 02h
    xor bh, bh                  ; pagina 0
    int 10h

    ; Escribir el caracter con atributo verde claro
    mov ah, 09h
    xor bh, bh
    mov bl, ATTR_VERDE_CLARO
    mov cx, 1                   ; un solo caracter
    int 10h

    inc si                      ; siguiente caracter de la cadena
    inc dl                      ; siguiente columna
    jmp .bucle_caracter

.fin:
    ; Esperar una tecla sin eco y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
