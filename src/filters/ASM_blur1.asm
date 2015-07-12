; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

extern malloc
extern free

section .data

dosk: DW 7283, 7283, 7283, 7283, 7283, 7283, 7283, 7283 ; 7283 = (int)((2^16 / 9) + 1)

round: DD 0x7F80

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
; EDI w, ESI h, RDX *data
section .text

global ASM_blur1
ASM_blur1:
	PUSH RBP
	MOV  RBP, RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	SUB  RSP, 8

	LDMXCSR [round]

	; Guardo w, h y *data
	MOV  R13, RDX
	MOV  R14D, EDI
	MOV  R15D, ESI

	; Guardo el dosk
	MOVDQU XMM11, [dosk]

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
	.get:
		MOVDQU XMM0, [R8 + RDI]
		MOVDQU [R12 + RDI], XMM0
		MOVDQU XMM0, [RSI + RDI]
		MOVDQU [R13 + RDI], XMM0
		ADD RDI, 16
		CMP RDI, R14
		JL  .get

	; Limpio XMM12 para desenpacketar
	PXOR XMM12, XMM12

	; Ciclo
	ADD  R8, R14	; Posiciono *data en la segunda fila 
	MOV  R10, R8 ; Guardo el R8 anterior
	ADD  R8, R14 ; Avanzo una fila
	MOV  RDI, 0  ; Iterador en x
	MOV  R9, 2	; Iterador en y
	.ciclo:

		; Tomo los 9 pixeles de memoria
		MOVDQU    XMM0, [R12 + RDI]		; XMM0 = x | p2 | p1 | p0
		MOVDQU    XMM1, XMM0			; XMM1 = XMM0
		PUNPCKLBW XMM0, XMM12			; XMM0 = p1 | p0
		PUNPCKHBW XMM1, XMM12			; XMM1 = xx | p2

		MOVDQU    XMM2, [R13 + RDI]		; XMM2 = x | p5 | p4 | p3
		MOVDQU    XMM3, XMM2			; XMM3 = XMM2
		PUNPCKLBW XMM2, XMM12			; XMM2 = p4 | p3
		PUNPCKHBW XMM3, XMM12			; XMM3 = xx | p5

		MOVDQU    XMM4, [R8  + RDI - 4]	; XMM4 = p8 | p7 | p6 | x
		PSRLDQ    XMM4, 4				; XMM4 = x | p8 | p7 | p6
		MOVDQU    XMM5, XMM4			; XMM5 = XMM4
		PUNPCKLBW XMM4, XMM12			; XMM4 = p7 | p6
		PUNPCKHBW XMM5, XMM12			; XMM5 = xx | p8

		; Sumo los 9 pixeles
		MOVDQU    XMM15, XMM0		; XMM15 = p1 | p0
		MOVDQU    XMM14, XMM1       ; XMM14 = xx | p2
		PADDUSW   XMM15, XMM2		; XMM15 = p1 + p4 | p0 + p3
		PADDUSW   XMM14, XMM3       ; XMM14 = xx | p2 + p5
		PADDUSW   XMM15, XMM4		; XMM15 = p1 + p4 + p7 | p0 + p3 + p6
		PADDUSW   XMM14, XMM5       ; XMM14 = xx | p2 + p5 + p8
		MOVDQU    XMM13, XMM15		; XMM13 = XMM15
		PSRLDQ    XMM13, 8			; XMM13 = xx | p1 + p4 + p7
		PADDUSW   XMM15, XMM14		; XMM15 = p1 + p4 + p7 | p0 + p2 + p3 + p5 + p6 + p8
		PADDUSW   XMM15, XMM13      ; XMM15 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8

		; Divido por 9
		MOVDQU    XMM14, XMM15		; XMM14 = XMM15
		PMULHW    XMM15, XMM11		; High of psum * dosk
		PMULLW    XMM14, XMM11		; Low of psum * dosk
		PUNPCKLWD XMM14, XMM15		; XMM15 = psum
		PSRLD     XMM14, 16			; XMM14 >> 16
		PACKUSDW  XMM14, XMM15		; XMM14 = psum
		PACKUSWB  XMM14, XMM15		; XMM14 = psum

		MOVD DWORD [R10 + RDI + 4], XMM14	; Escribo en memoria (Imagen)

		; Me muevo y checkeo si llegue al final de la linea
		ADD RDI, 4
		MOV RSI, R14
		SUB RSI, 8
		CMP RDI, RSI	; Veo si llegue al final
		JL  .ciclo

		; Recorro y copio la fila de pixeles siguientes, swapeo los punteros (Y copio )
		MOV RDI, 0 		; Iterador
		MOV RSI, R8 	; Punero a segunda fila
		XCHG R13, R12	; Exchange R13 and R12 pointers to allocated memory
		.cicloget:
			MOVDQU XMM0, [RSI + RDI]
			MOVDQU [R13 + RDI], XMM0
			ADD RDI, 16
			CMP RDI, R14
			JL  .cicloget

		MOV R10, R8 ; Guardo el R8 anterior
		ADD R8, R14 ; Avanzo una fila
		MOV RDI, 0 ; Iterador en x

		INC R9
		CMP R9, R15  ; Veo si todavia tengo pixeles por recorrer
		JL  .ciclo
	
	; Libero la memoria que pedi
	MOV RDI, R12
	CALL free
	MOV RDI, R13
	CALL free

	ADD  RSP, 8
	POP  R15
	POP  R14
	POP  R13
	POP  R12
	POP  RBX
	POP  RBP

	RET