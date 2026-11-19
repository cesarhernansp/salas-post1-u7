; post2c.asm - Limpiar pantalla con REP STOSW en B800h
; Compilar: nasm -f bin post2c.asm -o post2c.com
;
; STOSW guarda AX en ES:DI y suma 2 a DI. Con el prefijo REP y CX como contador
; rellena una region contigua: aqui las 80 x 25 = 2000 celdas de la pantalla,
; escribiendo en cada una el par (caracter, atributo) cargado en AX
; (AL = caracter, AH = atributo).

ORG 100h                        ; formato .COM

SEG_VIDEO     equ 0B800h        ; segmento de la memoria de video en modo texto
COLUMNAS      equ 80
FILAS         equ 25
CELDAS        equ COLUMNAS * FILAS      ; 2000 celdas
BYTES_CELDA   equ 2

%define OFFSET_CELDA(fila, col) (((fila) * COLUMNAS + (col)) * BYTES_CELDA)

ESPACIO       equ 20h           ; caracter ASCII espacio
ATTR_FONDO    equ 17h           ; 0001 0111b: fondo azul (1) y texto gris claro (7)
ATTR_TEXTO    equ 1Fh           ; 0001 1111b: fondo azul (1) y texto blanco brillante (F)

section .text
start:
    mov ax, SEG_VIDEO
    mov es, ax                  ; ES = segmento de video

    ; Rellenar toda la pantalla: AH = atributo, AL = espacio
    mov ax, (ATTR_FONDO << 8) | ESPACIO     ; AX = 1720h
    xor di, di                  ; DI = 0: primera celda
    mov cx, CELDAS              ; CX = 2000 celdas
    cld                         ; DF = 0: DI avanza hacia adelante
    rep stosw                   ; ES:[DI] = AX; DI += 2; CX-- hasta que CX = 0

    ; Escribir un mensaje en la fila 12, columna 30: (12*80 + 30) * 2 = 1980
    mov di, OFFSET_CELDA(12, 30)
    mov si, titulo              ; SI apunta al mensaje (cadena terminada en 0)

.bucle_mensaje:
    lodsb                       ; AL = [DS:SI]; SI++
    or al, al                   ; fin de la cadena?
    jz .fin
    mov ah, ATTR_TEXTO          ; atributo: blanco brillante sobre azul
    stosw                       ; ES:[DI] = AX (caracter + atributo); DI += 2
    jmp .bucle_mensaje

.fin:
    ; Esperar una tecla sin eco y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h

titulo: db "HOLA DESDE B800h", 0
