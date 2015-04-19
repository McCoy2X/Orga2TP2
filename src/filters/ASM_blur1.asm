; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
; EDI w, ESI h, RDX *data
global ASM_blur1
ASM_blur1:
	PUSH RBP
	MOV  RBP, RSP

	;Guardo RDX
	MOV  R11, RDX

	; Calculo la cantidad de pixeles de la imagen (w * h)
	MOV  EAX, ESI
	MOV  EDI, EDI   ; Limpio la parte superior de RSI
	MUL  RDI		; Multiplico, el numero queda en RAX
	MOV  R8, 4
	MUL  R8			; Multiplico por 4
	MOV  RCX, RAX	; Guardo la longitud en RCX

	; Muevo los nueves a XMM15 para luego hacer la division
	MOV  R8, 0x0009000900090009
	MOVQ      XMM14, R8
	PXOR      XMM15, XMM15
	PUNPCKLWD XMM15, XMM14
	PSRLD     XMM15, 16
	CVTDQ2PS  XMM15, XMM15

	; Calculo el width en bytes
	MOV  R10D, ESI
	MOV  RAX, 4
	MUL  R10
	MOV  R10, RAX	; Guardo width en bytes en R10
	; Inicializo registros
	MOV  R8, R10

	; Le resto una linea a la cantidad total de pixeles
	SUB  RCX, R10
	; Saco los costados y muevo R8 al primer pixel
	MOV  RAX, R10
	SUB  RAX, 4
	ADD  RAX, R10
	ADD  R8, 4

	.cicloy:

		.ciclox:
		; Limpio XMM3
		PXOR      XMM3, XMM3
		; Tomo los 9 pixeles
		SUB       R8, R10
		MOVDQU    XMM0, [R11 + R8 - 4] 	; Tomo los 3 pixels superiores 	XMM0 = x | p2 | p1 | p0
		PXOR      XMM1, XMM1
		PXOR      XMM2, XMM2
		PUNPCKLBW XMM1, XMM0		; XMM1 = p1 | p0
		PSRLW     XMM1, 8
		PUNPCKHBW XMM2, XMM0		; XMM2 = xx | p2
		PSRLW     XMM2, 8
		PADDUSW   XMM3, XMM1		; XMM3 = xx | p0
		PSRLDQ    XMM1, 8			; XMM1 = xx | p1
		PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1
		PADDUSW   XMM3, XMM2		; XMM3 = xx | p0 + p1 + p2
		ADD       R8, R10 			; Muevo el offset al medio
		MOVDQU    XMM0, [R11 + R8 - 4] 	; Tomo los 3 pixels del medio 	XMM0 = x | p5 | p4 | p3
		PXOR      XMM1, XMM1
		PXOR      XMM2, XMM2
		PUNPCKLBW XMM1, XMM0		; XMM1 = p4 | p3
		PSRLW     XMM1, 8
		PUNPCKHBW XMM2, XMM0		; XMM2 = xx | p5
		PSRLW     XMM2, 8
		PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3
		PSRLDQ    XMM1, 8			; XMM1 = xx | p4
		PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3 + p4
		PADDUSW   XMM3, XMM2		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5
		ADD       R8, R10 			; Muevo el offset al medio
		MOVDQU    XMM0, [R11 + R8 - 4] 	; Tomo los 3 pixels de abajo	XMM0 = x | p8 | p7 | p6
		PXOR      XMM1, XMM1
		PXOR      XMM2, XMM2
		PUNPCKLBW XMM1, XMM0		; XMM1 = p7 | p6
		PSRLW     XMM1, 8
		PUNPCKHBW XMM2, XMM0		; XMM2 = xx | p8
		PSRLW     XMM2, 8
		PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6
		PSRLDQ    XMM1, 8			; XMM1 = xx | p4
		PADDUSW   XMM3, XMM1		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7
		PADDUSW   XMM3, XMM2		; XMM3 = xx | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8
		SUB       R8, R10 			; Vuelvo a la linea que estaba

		; Tomo el promedio
		.prom:
		PXOR      XMM4, XMM4        ; Limpiar XMM4
		PUNPCKLWD XMM4, XMM3
		PSRLD     XMM4, 16
		CVTDQ2PS  XMM4, XMM4
		DIVPS     XMM4, XMM15
		PXOR      XMM5, XMM5       ; Limpiar XMM5
		CVTPS2DQ  XMM5, XMM4
		PXOR      XMM4, XMM4       ; Limpiar XMM4
		PACKUSDW  XMM4, XMM5
		PXOR      XMM5, XMM5       ; Limpiar XMM4
		PACKUSWB  XMM5, XMM4
		PSRLDQ    XMM5, 12

		MOVD      EDX, XMM5
		MOV DWORD [R11 + R8], EDX

		; Me muevo y checkeo
		ADD R8, 4
		CMP R8, RAX 				; Veo si llegue al final
		JL .ciclox

	ADD R8, 8
	ADD RAX, R10 ; Muevo el final al final de la siguiente linea de pixeles	

	;CMP R8, RCX  ;Veo si todavia tengo pixeles por recorrer
	CMP R8, RCX  ;Veo si todavia tengo pixeles por recorrer
	JL .cicloy

	POP  RBP

	RET