; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 1                                    ;
;                                                                           ;
; ************************************************************************* ;

section .data

ones: DD 1.0, 1.0, 1.0, 1.0

; void ASM_merge1(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
; EDI w, ESI, h, RDX *data1, RCX *data2, XMM0 value
section .text

global ASM_merge1
ASM_merge1:
	PUSH RBP
	MOV  RBP, RSP

	; Calculo fila en bytes
	MOV  R8, RDX	; Guardo momentaneamente RDX
	MOV  RAX, 4		; RAX = 4
	MUL  RDI		; RAX = 4 * RDI | RDX = 0
	MOV  RDI, RAX	; RDI = RAX
	MOV  RDX, R8	; Restauro RDX

	; 0 para el unpack
	PXOR      XMM10, XMM10

	; Calculo los floats para multiplicar luego
	MOVDQU    XMM15, XMM0				; XMM15 = x | x | x | v
	SHUFPS    XMM15, XMM15, 0x00		; Shuffle float con mascara 8'b00000000	XMM15 = v | v | v | v
	MOVDQU    XMM14, [ones]				; XMM14 = 1.0 | 1.0 | 1.0 | 1.0
	SUBPS     XMM14, XMM15				; XMM14 = 1.0 - v | 1.0 - v | 1.0 - v | 1.0 - v

	; Ciclo de mergeo
	MOV  R9, 0		; Iterador en y
	.cicloy:

		MOV  R8, 0	; R8 iterador de x

		.ciclox:
			; Pido los pixeles (4 de cada imagen)
			MOVDQU    XMM0, [RDX + R8]	; XMM0 = p3 | p2 | p1 | p0
			MOVDQU    XMM1, [RCX + R8]	; XMM1 = p3' | p2' | p1' | p0'
			MOVDQU    XMM2, XMM0
			MOVDQU    XMM3, XMM1

			; Los sumo
			CALL      addPixels
			MOVDQU    XMM4, XMM0		; XMM4 = p0 * v + p0' * (1-v)
			CALL      addPixels
			MOVDQU    XMM5, XMM0		; XMM5 = p1 * v + p1' * (1-v)
			CALL      addPixels
			MOVDQU    XMM6, XMM0		; XMM5 = p2 * v + p2' * (1-v)
			CALL      addPixels
			MOVDQU    XMM7, XMM0		; XMM5 = p3 * v + p3' * (1-v)

			; Los copio en *data1
			MOVD DWORD [RDX + R8], XMM4			; p0
			MOVD DWORD [RDX + R8 + 4], XMM5		; p1
			MOVD DWORD [RDX + R8 + 8], XMM6		; p2
			MOVD DWORD [RDX + R8 + 12], XMM7	; p3

		ADD R8, 16	; Me muevo al siguiente grupo de pixeles
		CMP R8, RDI	; Veo si llegue al final de la fila
		JL .ciclox

	ADD  RDX, RDI	; Muevo RDX a la siguiente fila
	ADD  RCX, RDI	; Muevo RCX a la siguiente fila
	INC  R9		; Incremento R9
	CMP  R9, RSI	; Veo si llegue al final de todo
	JL  .cicloy

	POP  RBP
	RET

addPixels:
	; Restauro los valores de las copias
	MOVDQU    XMM0, XMM2
	MOVDQU    XMM1, XMM3

	; Multiplico XMM0
	PUNPCKLBW XMM0, XMM10	; XMM0 Bytes a words
	PUNPCKLWD XMM0, XMM10	; XMM0 Words a doublewords
	CVTDQ2PS  XMM0, XMM0	; XMM0 Doublewords a floats
	MULPS     XMM0, XMM15	; XMM0 = a * v | r * v | ...

	; Multiplico XMM1
	PUNPCKLBW XMM1, XMM10	; XMM1 Bytes a words
	PUNPCKLWD XMM1, XMM10	; XMM1 Words a doublewords
	CVTDQ2PS  XMM1, XMM1	; XMM1 Doublewords a floats
	MULPS     XMM1, XMM14	; XMM1 = a * (1-v) | r * (1-v) | ...

	ADDPS     XMM0, XMM1	; XMM0 = a * v + a * (1-v) | ...

	CVTPS2DQ  XMM0, XMM0	; XMM0 Floats a doublewords
	PACKUSDW  XMM0, XMM10	; XMM0 Doublewords a words
	PACKUSWB  XMM0, XMM10	; XMM0 Words a bytes

	; Shifteo las copias para en el proximo addPixels tomar otro pixel
	PSRLDQ    XMM2, 4
	PSRLDQ    XMM3, 4

	RET