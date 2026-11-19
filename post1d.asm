; post1d.asm - INT 10h: modo de video (AH=0Fh) y relectura de celda (AH=08h)
; Compilar: nasm -f bin post1d.asm -o post1d.com
;
; 1) AH=0Fh consulta el modo de video activo en lugar de suponerlo.
; 2) Se escribe un caracter con un atributo conocido (AH=09h) y se vuelve a leer
;    la misma celda (AH=08h) para comprobar que lo almacenado coincide con lo escrito.

ORG 100h                        ; formato .COM

CR                  equ 0Dh
LF                  equ 0Ah
MODO_TEXTO_80X25    equ 03h     ; modo de texto 80x25 a color
FILA_PRUEBA         equ 08h     ; celda de prueba: fila 8
COL_PRUEBA          equ 0Ah     ;                  columna 10
CAR_PRUEBA          equ "Z"     ; caracter escrito y releido
ATTR_PRUEBA         equ 2Fh     ; fondo verde (2) y texto blanco brillante (F)

section .data
    msgModo   db "Modo de video: $"
    msgOk     db CR, LF, "Modo texto 80x25 confirmado (03h)", CR, LF, "$"
    msgNook   db CR, LF, "Modo inesperado, se continua de todas formas", CR, LF, "$"
    msgVerOk  db CR, LF, "Verificacion OK: caracter y atributo releidos coinciden", "$"
    msgVerBad db CR, LF, "ERROR: la relectura no coincide con lo escrito", "$"
    modo_video db 0             ; modo de video leido con AH=0Fh

section .text
start:
    ; AH=0Fh: obtener el modo de video activo
    mov ah, 0Fh                 ; retorna AL = modo, AH = columnas, BH = pagina activa
    int 10h
    mov [modo_video], al        ; se guarda en memoria: DX se reutiliza al imprimir

    ; Informar el modo
    mov ah, 09h
    mov dx, msgModo
    int 21h
    mov al, [modo_video]
    call imprimir_hex_byte      ; imprime el modo en hexadecimal (por ejemplo "03")
    mov dl, "h"
    mov ah, 02h
    int 21h

    cmp byte [modo_video], MODO_TEXTO_80X25
    jne .modo_inesperado

    mov ah, 09h
    mov dx, msgOk
    int 21h
    jmp .escribir_celda

.modo_inesperado:
    mov ah, 09h
    mov dx, msgNook
    int 21h

.escribir_celda:
    ; Posicionar el cursor en la celda de prueba (INT 10h / AH=02h)
    mov ah, 02h
    xor bh, bh                  ; pagina 0
    mov dh, FILA_PRUEBA
    mov dl, COL_PRUEBA
    int 10h

    ; Escribir "Z" con atributo conocido (INT 10h / AH=09h)
    mov ah, 09h
    mov al, CAR_PRUEBA
    xor bh, bh
    mov bl, ATTR_PRUEBA
    mov cx, 1
    int 10h

    ; Reposicionar el cursor exactamente en la misma celda antes de leer
    mov ah, 02h
    xor bh, bh
    mov dh, FILA_PRUEBA
    mov dl, COL_PRUEBA
    int 10h

    ; AH=08h: leer caracter y atributo en la posicion del cursor (pagina 0)
    mov ah, 08h
    xor bh, bh
    int 10h                     ; retorna AL = caracter, AH = atributo

    ; Comparar contra lo escrito
    cmp al, CAR_PRUEBA
    jne .no_coincide
    cmp ah, ATTR_PRUEBA
    jne .no_coincide

    mov ah, 09h
    mov dx, msgVerOk
    int 21h
    jmp .fin

.no_coincide:
    mov ah, 09h
    mov dx, msgVerBad
    int 21h

.fin:
    ; Esperar una tecla sin eco y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h

; --- Subrutina: imprime AL como 2 digitos hexadecimales (INT 21h / AH=02h) ------
imprimir_hex_byte:
    push ax
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
