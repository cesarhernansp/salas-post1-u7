; post1b.asm - INT 10h: cursor y color
; Compilar: nasm -f bin post1b.asm -o post1b.com
;
; Atributo de video (1 byte): bits 7-4 = color de fondo, bits 3-0 = color del texto.
; Paleta: 0 negro, 1 azul, 2 verde, 3 cian, 4 rojo, 5 magenta, 6 marron, 7 gris,
;         8 gris oscuro, 9 azul claro, A verde claro, B cian claro, C rojo claro,
;         D magenta claro, E amarillo, F blanco brillante.

ORG 100h                        ; formato .COM

ATTR_NORMAL     equ 07h         ; gris sobre negro (atributo por defecto)
ATTR_AMARILLO_S_AZUL equ 1Eh    ; fondo azul (1) y texto amarillo (E)
ATTR_ROJO_CLARO equ 0Ch         ; fondo negro (0) y texto rojo claro (C)

section .text
start:
    ; Limpiar pantalla con scroll de toda la ventana (INT 10h / AH=06h)
    mov ah, 06h                 ; funcion: scroll hacia arriba
    xor al, al                  ; AL = 0 lineas: limpia toda la ventana
    xor cx, cx                  ; esquina superior izquierda: fila 0, columna 0
    mov dx, 184Fh               ; esquina inferior derecha: fila 24 (18h), columna 79 (4Fh)
    mov bh, ATTR_NORMAL         ; atributo de relleno
    int 10h

    ; Posicionar el cursor en fila 2, columna 10 (INT 10h / AH=02h)
    mov ah, 02h
    xor bh, bh                  ; pagina de video 0
    mov dh, 02h                 ; fila 2
    mov dl, 0Ah                 ; columna 10
    int 10h

    ; Escribir "A" amarilla sobre fondo azul (INT 10h / AH=09h)
    mov ah, 09h                 ; funcion: escribir caracter con atributo
    mov al, "A"                 ; caracter a escribir
    xor bh, bh                  ; pagina 0
    mov bl, ATTR_AMARILLO_S_AZUL
    mov cx, 1                   ; repetir 1 vez (AH=09h no avanza el cursor)
    int 10h

    ; Posicionar el cursor en fila 3, columna 10
    mov ah, 02h
    xor bh, bh
    mov dh, 03h
    mov dl, 0Ah
    int 10h

    ; Escribir "U" en rojo claro sobre negro
    mov ah, 09h
    mov al, "U"
    xor bh, bh
    mov bl, ATTR_ROJO_CLARO
    mov cx, 1
    int 10h

    ; Avanzar el cursor manualmente a la columna 11
    mov ah, 02h
    xor bh, bh
    mov dh, 03h
    mov dl, 0Bh
    int 10h

    ; Escribir "7" en rojo claro sobre negro
    mov ah, 09h
    mov al, "7"
    xor bh, bh
    mov bl, ATTR_ROJO_CLARO
    mov cx, 1
    int 10h

    ; Esperar una tecla sin eco (INT 21h / AH=07h) y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
