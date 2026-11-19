; post1.asm - INT 21h: salida de texto basica
; Compilar: nasm -f bin post1.asm -o post1.com
; Ejecutar: post1.com
;
; INT 21h / AH=09h imprime la cadena apuntada por DS:DX hasta encontrar el "$".
; No admite atributos de color: el texto sale con el color actual de la pantalla.

ORG 100h                        ; formato .COM: el codigo empieza en CS:0100h

CR  equ 0Dh                     ; retorno de carro
LF  equ 0Ah                     ; salto de linea

section .data
    msg1 db "Arquitectura de Computadores", CR, LF, "$"
    msg2 db "Unidad 7: Pantalla y Teclado", CR, LF, "$"
    msg3 db "Laboratorio POST-1", CR, LF, "$"

section .text
start:
    ; Imprimir msg1
    mov ah, 09h                 ; funcion DOS: imprimir cadena terminada en "$"
    mov dx, msg1                ; DS:DX apunta a la cadena
    int 21h

    ; Imprimir msg2 (AH sigue valiendo 09h)
    mov dx, msg2
    int 21h

    ; Imprimir msg3
    mov dx, msg3
    int 21h

    ; Salir al sistema operativo
    mov ah, 4Ch                 ; funcion DOS: terminar proceso
    xor al, al                  ; codigo de retorno 0
    int 21h
