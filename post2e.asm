; post2e.asm - INT 16h/AH=02h: estado de Shift/Ctrl reflejado en B800h
; Compilar: nasm -f bin post2e.asm -o post2e.com
;
; INT 16h / AH=02h retorna en AL el byte de estado del teclado que el BIOS mantiene
; en 0040h:0017h, sin esperar ninguna tecla. Bits del byte de estado:
;   bit 0 = Shift derecho    bit 1 = Shift izquierdo   bit 2 = Ctrl    bit 3 = Alt
;   bit 4 = ScrollLock       bit 5 = NumLock           bit 6 = CapsLock bit 7 = Insert
; El programa sondea ese byte en un bucle continuo y muestra "1" o "0" en la fila 0
; (escritura directa en B800h) segun Shift o Ctrl esten presionados. Termina con Escape.

ORG 100h                        ; formato .COM

SEG_VIDEO     equ 0B800h        ; segmento de la memoria de video en modo texto
COLUMNAS      equ 80
FILAS         equ 25
CELDAS        equ COLUMNAS * FILAS
BYTES_CELDA   equ 2

%define OFFSET_CELDA(fila, col) (((fila) * COLUMNAS + (col)) * BYTES_CELDA)

; Mascaras del byte de estado de AH=02h
MASK_SHIFT    equ 03h           ; bits 0 y 1: Shift derecho o izquierdo (0000 0011b)
MASK_CTRL     equ 04h           ; bit 2: Ctrl (0000 0100b)

; Posiciones en la fila 0
FILA_ESTADO   equ 0
COL_SHIFT_VAL equ 6             ; "SHIFT:" ocupa las columnas 0-5; el digito va en la 6
COL_CTRL_ETQ  equ 8             ; "CTRL:" ocupa las columnas 8-12
COL_CTRL_VAL  equ 13            ; el digito va en la columna 13

; Atributos y caracteres
ATTR_FONDO    equ 07h           ; gris claro sobre negro
ATTR_ETIQUETA equ 0Fh           ; blanco brillante sobre negro
ATTR_SHIFT    equ 0Ah           ; verde claro sobre negro
ATTR_CTRL     equ 0Ch           ; rojo claro sobre negro
ESPACIO       equ 20h
SCAN_ESC      equ 01h           ; scan code de Escape

section .data
    etiqSh db "SHIFT:"          ; 6 caracteres
    etiqCt db "CTRL:"           ; 5 caracteres

section .text
start:
    mov ax, SEG_VIDEO
    mov es, ax                  ; ES = segmento de video

    ; Limpiar la pantalla con REP STOSW
    mov ax, (ATTR_FONDO << 8) | ESPACIO
    xor di, di
    mov cx, CELDAS
    cld
    rep stosw

    ; Etiqueta "SHIFT:" en la fila 0, columna 0
    mov di, OFFSET_CELDA(FILA_ESTADO, 0)
    mov si, etiqSh
    mov cx, 6
.etiqueta_shift:
    lodsb                       ; AL = caracter de la etiqueta
    mov ah, ATTR_ETIQUETA
    stosw                       ; caracter + atributo en ES:DI
    loop .etiqueta_shift

    ; Etiqueta "CTRL:" en la fila 0, columna 8 -> offset (0*80 + 8) * 2 = 16
    mov di, OFFSET_CELDA(FILA_ESTADO, COL_CTRL_ETQ)
    mov si, etiqCt
    mov cx, 5
.etiqueta_ctrl:
    lodsb
    mov ah, ATTR_ETIQUETA
    stosw
    loop .etiqueta_ctrl

.bucle_sondeo:
    ; AH=02h: consultar el byte de estado de teclas modificadoras (no bloqueante)
    mov ah, 02h
    int 16h                     ; AL = byte de estado de 0040h:0017h
    mov bl, al                  ; conservar el byte de estado completo

    ; Bits 0-1: Shift derecho / izquierdo
    mov cl, "0"                 ; se supone que no esta presionado
    test bl, MASK_SHIFT         ; ZF = 1 si ambos bits valen 0
    jz .shift_listo
    mov cl, "1"                 ; algun Shift presionado
.shift_listo:
    mov di, OFFSET_CELDA(FILA_ESTADO, COL_SHIFT_VAL)    ; (0*80 + 6) * 2 = 12
    mov [es:di], cl
    mov byte [es:di+1], ATTR_SHIFT

    ; Bit 2: Ctrl
    mov cl, "0"
    test bl, MASK_CTRL          ; ZF = 1 si el bit 2 vale 0
    jz .ctrl_listo
    mov cl, "1"
.ctrl_listo:
    mov di, OFFSET_CELDA(FILA_ESTADO, COL_CTRL_VAL)     ; (0*80 + 13) * 2 = 26
    mov [es:di], cl
    mov byte [es:di+1], ATTR_CTRL

    ; AH=01h: verificar si hay una tecla en el buffer (no bloqueante)
    mov ah, 01h
    int 16h
    jz .bucle_sondeo            ; ZF = 1: no hay tecla, seguir sondeando

    ; Hay una tecla: consumirla del buffer (AH=00h) y comprobar si es Escape
    mov ah, 00h
    int 16h                     ; AH = scan code, AL = ASCII
    cmp ah, SCAN_ESC
    jne .bucle_sondeo

    mov ah, 4Ch                 ; terminar proceso
    xor al, al
    int 21h
