; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 2                                     ;
;                                                                           ;
; ************************************************************************* ;

extern malloc
extern free

; void ASM_blur2( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur2
ASM_blur2:
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
	MOV  RAX, 4
	MUL  R14
	MOV  R14, RAX	; Guardo width en bytes en R14
	ADD  R14, 16	; Pido un poco mas de memoria para no tener problemas de segmento

	; Pido memoria para guardar las primeras 2 lineas de pixels
	MOV  RDI, R14
	CALL malloc
	MOV  R12, RAX	; * fila pixeles superior
	MOV  RDI, R14
	CALL malloc
	MOV  R8, R13	; R8 = * data
	MOV  R13, RAX	; * fila pixeles del medio
	SUB  R14, 16

	; Recorro y copio las 2 filas de pixeles
	MOV RDI, 0 		; Iterador
	MOV RSI, R8		; Puntero a segunda fila
	ADD RSI, R14
	.cicloget:
		MOV EDX, [R8 + RDI]
		MOV [R12 + RDI], EDX
		MOV EDX, [RSI + RDI]
		MOV [R13 + RDI], EDX
		ADD RDI, 4
		CMP RDI, R14
		JL  .cicloget

	; Ciclo
	MOV R9, 2	; Iterador en y
	ADD R8, R14	; Posiciono *data en la segunda fila 
	.cicloy:

		MOV R10, R8
		ADD R8, R14 ; Avanzo una fila
		MOV RDI, 0 ; Iterador en x

		.ciclox:
			; Clear XMM15 to unpack with ceroes
			PXOR      XMM15, XMM15
			PXOR      XMM14, XMM14
			PXOR      XMM13, XMM13
			; Tomo los 9 pixeles de memoria
			MOVDQU    XMM0, [R12 + RDI]	; XMM0 = x | p2 | p1 | p0
			MOVDQU    XMM1, XMM0		; XMM1 = x | p2 | p1 | p0
			MOVDQU    XMM2, XMM0		; XMM2 = x | p2 | p1 | p0
			PUNPCKLBW XMM1, XMM15		; XMM1 = p1 | p0
			PUNPCKHBW XMM2, XMM15		; XMM2 = xx | p2

			MOVDQU    XMM0, [R13 + RDI]	; XMM0 = x | p5 | p4 | p3
			MOVDQU    XMM3, XMM0		; XMM3 = x | p5 | p4 | p3
			MOVDQU    XMM4, XMM0		; XMM4 = x | p5 | p4 | p3
			PUNPCKLBW XMM3, XMM15		; XMM3 = p4 | p3
			PUNPCKHBW XMM4, XMM15		; XMM4 = xx | p5

			MOVDQU    XMM0, [R8  + RDI - 4]	; XMM0 = x | p8 | p7 | p6
			PSRLDQ    XMM0, 4			; XMM14 = xx | p1 + p4 + p7
			MOVDQU    XMM5, XMM0		; XMM5 = x | p8 | p7 | p6
			MOVDQU    XMM6, XMM0		; XMM6 = x | p8 | p7 | p6
			PUNPCKLBW XMM5, XMM15		; XMM5 = p7 | p6
			PUNPCKHBW XMM6, XMM15		; XMM6 = xx | p8

			; Sumo los 9 pixeles
			PADDUSW   XMM15, XMM1		; XMM15 = p1 | p0
			PADDUSW   XMM14, XMM2       ; XMM14 = xx | p2
			PADDUSW   XMM15, XMM3		; XMM15 = p1 + p4 | p0 + p3
			PADDUSW   XMM14, XMM4       ; XMM14 = xx | p2 + p5
			PADDUSW   XMM15, XMM5		; XMM15 = p1 + p4 + p7 | p0 + p3 + p6
			PADDUSW   XMM14, XMM6       ; XMM14 = xx | p2 + p5 + p8
			MOVDQU    XMM13, XMM15		; XMM14 = XMM15
			PADDUSW   XMM15, XMM14		; XMM15 = p1 + p4 + p7 | p0 + p2 + p3 + p5 + p6 + p8
			PSRLDQ    XMM13, 8			; XMM14 = xx | p1 + p4 + p7
			PADDUSW   XMM15, XMM13      ; XMM15 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8

			; Divido por 9
			; Guardo dosk para division
			.p:
			MOVDQU 	  XMM13, [dosk]
			MOVDQU    XMM14, XMM15
			PMULHW    XMM15, XMM13		; High of psum * dosk
			PMULLW    XMM14, XMM13		; Low of psum * dosk
			PUNPCKLWD XMM14, XMM15		; XMM15 = psum
			PSRLD     XMM14, 16
			PXOR      XMM15, XMM15
			PACKUSDW  XMM14, XMM15
			PACKUSWB  XMM14, XMM15

			MOVD      EDX, XMM14			; Muevo a registro de proposito general
			MOV DWORD [R10 + RDI + 4], EDX	; Escribo en memoria (Imagen)

			; Me muevo y checkeo si llegue al final de la linea
			ADD RDI, 4
			MOV R11, R14
			SUB R11, 8
			CMP RDI, R11	; Veo si llegue al final
			JL  .ciclox

		; Recorro y copio las 2 filas de pixeles siguientes
		MOV RDI, 0 		; Iterador
		MOV RSI, R8 	; Puntero a segunda fila
		.cicloxget:
			MOV EDX, [R13 + RDI]
			MOV [R12 + RDI], EDX
			MOV EDX, [RSI + RDI]
			MOV [R13 + RDI], EDX
			ADD RDI, 4
			CMP RDI, R14
			JL  .cicloxget

		INC R9
		CMP R9, R15  ; Veo si todavia tengo pixeles por recorrer
		JL .cicloy

	; Libero la memoria que pedi
	MOV RDI, R12
	CALL free
	MOV RDI, R13
	CALL free

	POP  R15
	POP  R14
	POP  R13
	POP  R12
	POP  RBP

	RET