; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

extern malloc

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
; EDI w, ESI h, RDX *data
global ASM_blur1
ASM_blur1:
	PUSH RBP
	MOV  RBP, RSP
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15

	; Guardo w, h y *data
	MOV  R13, RDX
	MOV  R14D, EDI
	MOV  R15D, ESI

	; Calculo el width en bytes
	MOV  R12, R14
	MOV  RAX, 4
	MUL  R12
	MOV  R12, RAX	; Guardo width en bytes en R9

	; Pido memoria para guardar las primeras 2 lineas de pixels
	MOV  RDI, R12
	CALL malloc
	MOV  RDI, R12
	MOV  R12, RAX	; * fila pixeles superior
	CALL malloc
	;Guardo data en R8
	MOV  R8, R13	; * data
	MOV  R13, RAX	; * fila pixeles del medio

	; Calculo la cantidad de pixeles de la imagen (w * h)
	MOV  RAX, R14
	MUL  R15		; Multiplico, el numero queda en RAX
	MOV  RDI, 4		; Multiplico por 4 (bytes por pixel)
	MUL  RDI		; Multiplico por 4
	MOV  R9, RAX	; Guardo la longitud en bytes en R9

	; Calculo el width en bytes
	MOV  RAX, 4
	MUL  R14
	MOV  R14, RAX	; Guardo width en bytes en R14

	; Muevo los nueves a XMM15 para luego hacer la division
	MOV       RDI, 0x0009000900090009
	MOVQ      XMM14, RDI
	PXOR      XMM15, XMM15
	PUNPCKLWD XMM15, XMM14
	PSRLD     XMM15, 16
	CVTDQ2PS  XMM15, XMM15

	; Recorro y copio las 2 filas de pixeles
	MOV RDI, 0 		; Iterador
	MOV RSI, R8		; Puntero a segunda fila
	ADD RSI, R14
	.cicloxgetinicio:
		MOV EDX, [R8 + RDI]
		MOV [R12 + RDI], EDX
		MOV EDX, [RSI + RDI]
		MOV [R13 + RDI], EDX
		ADD RDI, 4
		CMP RDI, R14
		JL  .cicloxgetinicio

	; Le resto una linea a la cantidad total de pixeles
	SUB R9, R14
	; Pongo el tope del iterador como una fila menos los dos ultimos bytes
	MOV RAX, R14
	SUB RAX, 12
	; Creo un iterador de la imagen que empieza en [1][0]
	MOV R10, 0
	ADD R10, R14

	.cicloy:

		MOV RDI, 0

		.cicloxblur:
			; Limpio XMM3
			PXOR      XMM3, XMM3
			; Tomo los 9 pixeles
			MOVDQU    XMM0, [R12 + RDI] ; Tomo los 3 pixels superiores 	XMM0 = x | p2 | p1 | p0
			PXOR      XMM1, XMM1
			PXOR      XMM2, XMM2
			PUNPCKLBW XMM1, XMM0		; XMM1 = p1 | p0
			PUNPCKHBW XMM2, XMM0		; XMM2 = xx | p2
			PSRLW     XMM1, 8
			PSRLW     XMM2, 8
			PADDUSW   XMM3, XMM1		; XMM3 = xx | p0
			PSRLDQ    XMM1, 8			; XMM1 = xx | p1
			PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1
			PADDUSW   XMM3, XMM2		; XMM3 = xx | p0 + p1 + p2

			MOVDQU    XMM0, [R13 + RDI] 	; Tomo los 3 pixels del medio 	XMM0 = x | p5 | p4 | p3
			PXOR      XMM1, XMM1
			PXOR      XMM2, XMM2
			PUNPCKLBW XMM1, XMM0		; XMM1 = p4 | p3
			PUNPCKHBW XMM2, XMM0		; XMM2 = xx | p5
			PSRLW     XMM1, 8
			PSRLW     XMM2, 8
			PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3
			PSRLDQ    XMM1, 8			; XMM1 = xx | p4
			PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3 + p4
			PADDUSW   XMM3, XMM2		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5

			LEA       RSI, [R8 + R10]
			ADD       RSI, RDI
			ADD       RSI, R14
			MOVDQU    XMM0, [RSI] 	    ; Tomo los 3 pixels de abajo	XMM0 = x | p8 | p7 | p6
			PXOR      XMM1, XMM1
			PXOR      XMM2, XMM2
			PUNPCKLBW XMM1, XMM0		; XMM1 = p7 | p6
			PUNPCKHBW XMM2, XMM0		; XMM2 = xx | p8
			PSRLW     XMM1, 8
			PSRLW     XMM2, 8
			PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6
			PSRLDQ    XMM1, 8			; XMM1 = xx | p4
			PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7
			PADDUSW   XMM3, XMM2		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8

			; Tomo el promedio
			PXOR      XMM4, XMM4        ; Limpiar XMM4
			PUNPCKLWD XMM4, XMM3        ; Empaqueto las words en doblewords
			PSRLD     XMM4, 16          ; Lo shifteo
			CVTDQ2PS  XMM4, XMM4        ; Transformo las doblewords a float
			DIVPS     XMM4, XMM15       ; Divido por 9
			PXOR      XMM5, XMM5        ; Limpiar XMM5
			CVTPS2DQ  XMM5, XMM4        ; Transformo los floats a doublewords
			PXOR      XMM4, XMM4        ; Limpiar XMM4
			PACKUSDW  XMM4, XMM5        ; Desenpacketo como word
			PXOR      XMM5, XMM5        ; Limpiar XMM4
			PACKUSWB  XMM5, XMM4        ; Desempaqueto como byte
			PSRLDQ    XMM5, 12          ; Shifteo

			MOVD      EDX, XMM5         ; Muevo a registro de proposito general
			LEA       RSI, [R8 + R10 + 4]
			ADD       RSI, RDI
			MOV DWORD [RSI], EDX        ; Escribo en memoria (Imagen)

			; Me muevo y checkeo
			ADD RDI, 4
			CMP RDI, RAX				; Veo si llegue al final
			JL .cicloxblur

		ADD R10, R14 ; Muevo R10 a la siguiente fila

		; Recorro y copio las 2 filas de pixeles
		MOV RDI, 0 		; Iterador
		MOV RSI, R8 	; Puntero a segunda fila
		ADD RSI, R10
		.cicloxget:
			MOV EDX, [R13 + RDI]
			MOV [R12 + RDI], EDX
			MOV EDX, [RSI + RDI]
			MOV [R13 + RDI], EDX
			ADD RDI, 4
			CMP RDI, R14
			JL  .cicloxget

		MOV RDI, 0
		MOV RSI, 0

		CMP R10, R9  ;Veo si todavia tengo pixeles por recorrer
		JL .cicloy

	POP  R15
	POP  R14
	POP  R13
	POP  R12
	POP  RBP

	RET