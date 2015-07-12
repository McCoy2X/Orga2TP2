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

%macro addPixels 0
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
%endmacro

global ASM_merge1
ASM_merge1:
	PUSH RBP
	MOV  RBP, RSP

	; Calculo fila en bytes
	MOV  R8, RDX	; Guardo momentaneamente RDX
	MOV  RAX, 4		; RAX = 4
	MUL  RDI		; RAX = 4 * RDI | RDX = 0
	MOV  RDI, RAX	; RDI = RAX

	; 0 para el unpack
	PXOR XMM10, XMM10

	; Calculo tamaño de la imagen en bytes
	MOV  RAX, RDI
	MUL  RSI
	MOV  R9, RAX
	MOV  RDX, R8	; Restauro RDX

	; Calculo los floats para multiplicar luego
	MOVDQU    XMM15, XMM0				; XMM15 = x | x | x | v
	SHUFPS    XMM15, XMM15, 0x00		; Shuffle float con mascara 8'b00000000	XMM15 = v | v | v | v
	MOVDQU    XMM14, [ones]				; XMM14 = 1.0 | 1.0 | 1.0 | 1.0
	SUBPS     XMM14, XMM15				; XMM14 = 1.0 - v | 1.0 - v | 1.0 - v | 1.0 - v

	; Ciclo de mergeo
	MOV  R8, 0	; R8 iterador de bytes
	.ciclo:

		; Pido los pixeles (4 de cada imagen)
		MOVDQU    XMM0, [RDX]	; XMM0 = p3 | p2 | p1 | p0
		MOVDQU    XMM1, [RCX]	; XMM1 = p3' | p2' | p1' | p0'
		MOVDQU    XMM2, XMM0
		MOVDQU    XMM3, XMM1

		; Los sumo
		addPixels
		MOVD DWORD [RDX], XMM0
		;PEXTRD    EAX, XMM0, 0x00	; EAX = p0 * v + p0' * (1-v)
		;PINSRD    XMM4, EAX, 0x00	; XMM4 = p0 * v + p0' * (1-v)
		addPixels
		MOVD DWORD [RDX + 4], XMM0
		;PEXTRD    EAX, XMM0, 0x00	; EAX = p1 * v + p1' * (1-v)
		;PINSRD    XMM4, EAX, 0x01	; XMM4 = p1 * v + p1' * (1-v)
		addPixels
		MOVD DWORD [RDX + 8], XMM0
		;PEXTRD    EAX, XMM0, 0x00	; EAX = p2 * v + p2' * (1-v)
		;PINSRD    XMM4, EAX, 0x02	; XMM4 = p2 * v + p2' * (1-v)
		addPixels
		MOVD DWORD [RDX + 12], XMM0
		;PEXTRD    EAX, XMM0, 0x00	; EAX = p3 * v + p3' * (1-v)
		;PINSRD    XMM4, EAX, 0x03	; XMM4 = p3 * v + p3' * (1-v)

		; Los copio en *data1
		;MOVDQU [RDX], XMM4			; p0 | p1 | p2 | p3

		ADD R8, 16		; Me muevo al siguiente grupo de pixeles
		ADD RDX, 16		; Muevo RDX
		ADD RCX, 16		; Muevo RDX
		CMP R8, R9		; Veo si llegue al final
		JL  .ciclo

	POP  RBP
	RET