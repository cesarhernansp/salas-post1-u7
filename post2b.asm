; post2b.asm - Escritura directa en B800h
; Compilar: nasm -f bin post2b.asm -o post2b.com
;
; En modo texto 80x25 la memoria de video esta en el segmento B800h. Cada celda
; ocupa 2 bytes consecutivos: el codigo ASCII y el byte de atributo
; (bits 7-4 = fondo, bits 3-0 = texto). El desplazamiento de la celda es
;       offset = (fila * 80 + columna) * 2
; Por ejemplo, fila 10 y columna 35: (10*80 + 35) * 2 = 1670.

ORG 100h                        ; formato .COM

SEG_VIDEO     equ 0B800h        ; segmento de la memoria de video en modo texto
COLUMNAS      equ 80            ; celdas por fila
BYTES_CELDA   equ 2             ; caracter + atributo

; Desplazamiento (en bytes) de la celda (fila, columna), calculado al ensamblar
%define OFFSET_CELDA(fila, col) (((fila) * COLUMNAS + (col)) * BYTES_CELDA)

ATTR_BLANCO_BRILLANTE equ 0Fh   ; texto blanco brillante sobre negro
ATTR_AMARILLO         equ 0Eh   ; texto amarillo sobre negro
ATTR_VERDE_CLARO      equ 0Ah   ; texto verde claro sobre negro
ATTR_ROJO_CLARO       equ 0Ch   ; texto rojo claro sobre negro

COL_CENTRO    equ 35            ; columna usada para las cuatro letras

section .text
start:
    ; ES apunta al segmento de video: [es:di] direcciona la pantalla
    mov ax, SEG_VIDEO
    mov es, ax

    ; fila 10, columna 35 -> (10*80 + 35) * 2 = 1670
    mov di, OFFSET_CELDA(10, COL_CENTRO)
    mov byte [es:di], "H"                   ; byte de caracter
    mov byte [es:di+1], ATTR_BLANCO_BRILLANTE   ; byte de atributo

    ; fila 11, columna 35 -> (11*80 + 35) * 2 = 1830
    mov di, OFFSET_CELDA(11, COL_CENTRO)
    mov byte [es:di], "O"
    mov byte [es:di+1], ATTR_AMARILLO

    ; fila 12, columna 35 -> (12*80 + 35) * 2 = 1990
    mov di, OFFSET_CELDA(12, COL_CENTRO)
    mov byte [es:di], "L"
    mov byte [es:di+1], ATTR_VERDE_CLARO

    ; fila 13, columna 35 -> (13*80 + 35) * 2 = 2150
    mov di, OFFSET_CELDA(13, COL_CENTRO)
    mov byte [es:di], "A"
    mov byte [es:di+1], ATTR_ROJO_CLARO

    ; Esperar una tecla sin eco (INT 21h / AH=07h) y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
