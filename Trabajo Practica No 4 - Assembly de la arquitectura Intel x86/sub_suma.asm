%include "asm_io.inc"

section .data
    det_msg db "El resultado de %d*%d-%d*%d = %d", 0

section .text
global det

det:
    enter 8, 0                ; Espacio en stack para los parámetros
    pusha                     ; Guarda todos los registros generales

    mov eax, dword [ebp+12]   ; Obtiene el valor de 'a'
    mov ebx, dword [ebp+16]   ; Obtiene el valor de 'b'
    imul eax, ebx             ; a * b

    mov ebx, dword [ebp+20]   ; Obtiene el valor de 'c'
    mov ecx, dword [ebp+24]   ; Obtiene el valor de 'd'
    imul ebx, ecx             ; c * d

    sub eax, ebx              ; a * b - c * d
    mov dword [ebp-4], eax    ; Almacena el resultado en la variable local

    popa                      ; Restaura todos los registros generales
    add esp, 16               ; Ajusta el puntero de pila después de las llamadas a popa

    leave
    ret