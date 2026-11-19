; post2d.asm - Mini editor: INT 16h + B800h
; Compilar: nasm -f bin post2d.asm -o post2d.com
;
; Editor de una linea: lee cada tecla con INT 16h / AH=00h y escribe el caracter
; directamente en la memoria de video (segmento B800h), sin usar INT 10h.
; Enter termina el programa; Retroceso borra el ultimo caracter.

ORG 100h                        ; formato .COM

SEG_VIDEO     equ 0B800h        ; segmento de la memoria de video en modo texto
COLUMNAS      equ 80
FILAS         equ 25
CELDAS        equ COLUMNAS * FILAS
BYTES_CELDA   equ 2

FILA_EDICION  equ 12            ; fila fija de edicion
COL_INICIAL   equ 0             ; primera columna de la linea
FILA_AYUDA    equ 10            ; fila del texto de ayuda

ESPACIO       equ 20h
ASCII_ENTER   equ 0Dh
ASCII_RETROCESO equ 08h
ATTR_FONDO    equ 07h           ; gris claro sobre negro
ATTR_TEXTO    equ 0Fh           ; blanco brillante sobre negro
ATTR_AYUDA    equ 0Eh           ; amarillo sobre negro

%define OFFSET_CELDA(fila, col) (((fila) * COLUMNAS + (col)) * BYTES_CELDA)

section .text
start:
    mov ax, SEG_VIDEO
    mov es, ax                  ; ES = segmento de video

    ; Limpiar la pantalla con REP STOSW (sin pasar por el BIOS)
    mov ax, (ATTR_FONDO << 8) | ESPACIO
    xor di, di
    mov cx, CELDAS
    cld
    rep stosw

    ; Texto de ayuda en la fila 10
    mov di, OFFSET_CELDA(FILA_AYUDA, COL_INICIAL)
    mov si, ayuda
.bucle_ayuda:
    lodsb                       ; AL = siguiente caracter de la ayuda
    or al, al
    jz .ayuda_lista
    mov ah, ATTR_AYUDA
    stosw
    jmp .bucle_ayuda
.ayuda_lista:

    mov dx, COL_INICIAL         ; DX = columna actual de edicion

.leer_tecla:
    mov ah, 00h                 ; INT 16h / AH=00h: espera una tecla (una sola lectura)
    int 16h                     ; AH = scan code, AL = ASCII
    cmp al, ASCII_ENTER
    je .fin
    cmp al, ASCII_RETROCESO
    je .retroceso
    or al, al                   ; AL = 0: tecla extendida (cursores, F1...), se ignora
    jz .leer_tecla

    mov cl, al                  ; guardar el caracter: AX se usa para el calculo

    ; offset = (fila * 80 + columna) * 2
    mov ax, FILA_EDICION * COLUMNAS
    add ax, dx                  ; AX = fila * 80 + columna
    shl ax, 1                   ; AX *= 2 (2 bytes por celda)
    mov di, ax

    mov [es:di], cl             ; byte de caracter
    mov byte [es:di+1], ATTR_TEXTO  ; byte de atributo

    inc dx                      ; siguiente columna
    cmp dx, COLUMNAS            ; si se llega al borde, se vuelve al inicio
    jl .leer_tecla
    mov dx, COL_INICIAL
    jmp .leer_tecla

.retroceso:
    cmp dx, COL_INICIAL         ; nada que borrar en la primera columna
    jbe .leer_tecla
    dec dx                      ; retroceder una columna
    mov ax, FILA_EDICION * COLUMNAS
    add ax, dx
    shl ax, 1
    mov di, ax
    mov byte [es:di], ESPACIO   ; borrar el caracter
    mov byte [es:di+1], ATTR_FONDO
    jmp .leer_tecla

.fin:
    mov ah, 4Ch                 ; terminar proceso
    xor al, al
    int 21h

ayuda: db "Mini editor: escriba texto (Retroceso borra, Enter termina)", 0
