; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 2                                    ;
;                                                                           ;
; ************************************************************************* ;

section .data

full: DB 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255

vals: DD 16384.0, 16384.0, 16384.0, 16384.0

; void ASM_merge2(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
section .text

global ASM_merge2
ASM_merge2:
	PUSH RBP
	MOV  RBP, RSP
	PUSH R12

	; Calculo fila en bytes
	MOV  R8, RDX	; Guardo momentaneamente RDX
	MOV  RAX, 4		; RAX = 4
	MUL  RDI		; RAX = 4 * RDI | RDX = 0
	MOV  RDI, RAX	; RDI = RAX
	MOV  RDX, R8	; Restauro RDX
	.pre:
	; Calculo los floats para multiplicar luego
	PXOR      XMM10, XMM10				; 0 para el unpack
	MOVDQU    XMM15, XMM0				; XMM15 = x | x | x | v
	SHUFPS    XMM15, XMM15, 0x00		; XMM15 = v (4 veces)
	MOVDQU    XMM14, [vals]				; XMM14 = 0.0 | 0.0 | 0.0 | 512.0 
	MULPS     XMM15, XMM14				; XMM15 = 512.0 * v (4 veces)
	SUBPS     XMM14, XMM15				; XMM14 = 512.0 - (512.0 * v) (4 veces) = 512.0 * (1.0 - v)
	CVTPS2DQ  XMM15, XMM15				; XMM15 = 512 * v (4 veces)
	CVTPS2DQ  XMM14, XMM14				; XMM15 = 512 * (1 - v) (4 veces)

	; Ciclo de mergeo
	MOV  R11, 0			; Iterador en y bytes
	MOV  R12, 0			; Iterador en y
	.cicloy:

		MOV  R8, 0	; R8 iterador de x

		.ciclox:
			; Pido los pixeles (4 de cada imagen)
			MOVDQU    XMM0, [RDX + R8]	; XMM0 = p3 | p2 | p1 | p0
			MOVDQU    XMM4, [RCX + R8]	; XMM1 = p3' | p2' | p1' | p0'

			; Desenpacketo byte en words
			MOVDQU    XMM2, XMM0		; XMM2 = XMM0
			PUNPCKLBW XMM0, XMM10		; XMM0 = p1 | p0
			MOVDQU    XMM1, XMM0		; XMM1 = XMM0
			PUNPCKHBW XMM2, XMM10		; XMM2 = p3 | p2
			MOVDQU    XMM3, XMM2		; XMM3 = XMM2

			PUNPCKLWD XMM0, XMM10		; XMM0 = p0
			PUNPCKHWD XMM1, XMM10		; XMM1 = p1
			PUNPCKLWD XMM2, XMM10		; XMM2 = p2
			PUNPCKHWD XMM3, XMM10		; XMM3 = p3

			MOVDQU    XMM6, XMM4		; XMM6 = XMM4
			PUNPCKLBW XMM4, XMM10		; XMM4 = p1' | p0'
			MOVDQU    XMM5, XMM4		; XMM5 = XMM0
			PUNPCKHBW XMM6, XMM10		; XMM6 = p3' | p2'
			MOVDQU    XMM7, XMM6		; XMM7 = XMM6

			PUNPCKLWD XMM4, XMM10		; XMM4 = p0'
			PUNPCKHWD XMM5, XMM10		; XMM5 = p1'
			PUNPCKLWD XMM6, XMM10		; XMM6 = p2'
			PUNPCKHWD XMM7, XMM10		; XMM7 = p3'

			; Multiplico XMM0
			PMULLD    XMM0, XMM15		; XMM0 = p0 * 512v
			PMULLD    XMM1, XMM15		; XMM1 = p1 * 512v
			PMULLD    XMM2, XMM15		; XMM1 = p2 * 512v
			PMULLD    XMM3, XMM15		; XMM1 = p3 * 512v
			PSRLD     XMM0, 14			; XMM0 = p0 * v
			PSRLD     XMM1, 14			; XMM0 = p1 * v
			PSRLD     XMM2, 14			; XMM0 = p2 * v
			PSRLD     XMM3, 14			; XMM0 = p3 * v
			; Multiplico XMM1
			PMULLD    XMM4, XMM14		; XMM0 = p0' * 512v
			PMULLD    XMM5, XMM14		; XMM1 = p1' * 512v
			PMULLD    XMM6, XMM14		; XMM1 = p2' * 512v
			PMULLD    XMM7, XMM14		; XMM1 = p3' * 512v
			PSRLD     XMM4, 14			; XMM0 = p0' * v
			PSRLD     XMM5, 14			; XMM0 = p1' * v
			PSRLD     XMM6, 14			; XMM0 = p2' * v
			PSRLD     XMM7, 14			; XMM0 = p3' * v

			PACKUSDW  XMM0, XMM1 		; 
			PACKUSDW  XMM2, XMM3 		; 
			PACKUSWB  XMM0, XMM2 		; 
			PACKUSDW  XMM4, XMM5 		; 
			PACKUSDW  XMM6, XMM7 		; 
			PACKUSWB  XMM4, XMM6		; 

			PADDB     XMM0, XMM4		; XMM0 = a * v + a * (1-v) | ...
			
			; Los copio en *data1
			MOVDQU    [RDX + R8], XMM0	; p0

		ADD R8, 16	; Me muevo al siguiente grupo de pixeles
		CMP R8, RDI	; Veo si llegue al final de la fila
		JL .ciclox

	.endx:
	ADD  RDX, RDI	; Muevo RDX a la siguiente fila
	ADD  RCX, RDI	; Muevo RCX a la siguiente fila
	INC  R12		; Incremento R12
	CMP  R12, RSI	; Veo si llegue al final de todo
	JL  .cicloy

	POP  R12
	POP  RBP
	RET