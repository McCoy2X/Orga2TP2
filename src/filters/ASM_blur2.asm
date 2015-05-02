; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 2                                     ;
;                                                                           ;
; ************************************************************************* ;

extern malloc
extern free

section .data

dosk: DW 7283, 7283, 7283, 7283, 7283, 7283, 7283, 7283 ; 7283 = (int)((2^16 / 9) + 1)

round: DD 0x7F80

; void ASM_blur2( uint32_t w, uint32_t h, uint8_t* data )
; EDI w, ESI h, RDX *data
section .text

global ASM_blur2
ASM_blur2:
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

	MOVDQU XMM13, [dosk]

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
			; Pixel 0 y 1

			; Clear XMM to unpack with ceroes
			PXOR      XMM15, XMM15
			PXOR      XMM14, XMM14
			; Tomo los pixeles de memoria
			MOVDQU    XMM0, [R12 + RDI]	; XMM0 = p3 | p2 | p1 | p0
			MOVDQU    XMM1, XMM0		; XMM1 = XMM0
			PUNPCKLBW XMM0, XMM15		; XMM0 = p1 | p0
			PUNPCKHBW XMM1, XMM15		; XMM1 = p3 | p2

			MOVDQU    XMM2, [R12 + RDI + 4]	; XMM2 = p4 | p3 | p2 | p1
			MOVDQU    XMM3, XMM2		; XMM3 = XMM2
			PUNPCKLBW XMM2, XMM15		; XMM2 = p2 | p1
			PUNPCKHBW XMM3, XMM15		; XMM3 = p4 | p3

			MOVDQU    XMM4, [R13 + RDI]	; XMM4 = p9 | p8 | p7 | p6
			MOVDQU    XMM5, XMM4		; XMM5 = XMM4
			PUNPCKLBW XMM4, XMM15		; XMM4 = p7 | p6
			PUNPCKHBW XMM5, XMM15		; XMM5 = p9 | p8

			MOVDQU    XMM6, [R13 + RDI + 4]	; XMM6 = p10 | p9 | p8 | p7
			MOVDQU    XMM7, XMM6		; XMM7 = XMM6
			PUNPCKLBW XMM6, XMM15		; XMM6 = p8 | p7
			PUNPCKHBW XMM7, XMM15		; XMM7 = p10 | p9

			MOVDQU    XMM8, [R8  + RDI]	; XMM8 = p15 | p14 | p13 | p12
			MOVDQU    XMM9, XMM8		; XMM9 = XMM8
			PUNPCKLBW XMM8, XMM15		; XMM8 = p13 | p12
			PUNPCKHBW XMM9, XMM15		; XMM9 = p15 | p14

			MOVDQU    XMM10, [R8  + RDI + 4]	; XMM10 = p16 | p15 | p14 | p13
			MOVDQU    XMM11, XMM10		; XMM11 = XMM10
			PUNPCKLBW XMM10, XMM15		; XMM10 = p14 | p13
			PUNPCKHBW XMM11, XMM15		; XMM11 = p16 | p15

			; Sumo los 9 pixeles de 0 y 1, guardo el resultado en XMM15
			PADDUSW   XMM15, XMM0		; XMM15 = p1 | p0
			PADDUSW   XMM15, XMM1		; XMM15 = p1 + p3 | p0 + p2
			PADDUSW   XMM15, XMM2		; XMM15 = p1 + p2 + p3 | p0 + p1 + p2
			PADDUSW   XMM15, XMM4		; XMM15 = p1 + p2 + p3 + p7 | p0 + p1 + p2 + p6
			PADDUSW   XMM15, XMM5		; XMM15 = p1 + p2 + p3 + p7 + p9 | p0 + p1 + p2 + p6 + p8
			PADDUSW   XMM15, XMM6		; XMM15 = p1 + p2 + p3 + p7 + p8 + p9 | p0 + p1 + p2 + p6 + p7 + p8
			PADDUSW   XMM15, XMM8		; XMM15 = p1 + p2 + p3 + p7 + p8 + p9 + p13 | p0 + p1 + p2 + p6 + p7 + p8 + p12
			PADDUSW   XMM15, XMM9		; XMM15 = p1 + p2 + p3 + p7 + p8 + p9 + p13 + p15 | p0 + p1 + p2 + p6 + p7 + p8 + p12 + p14
			PADDUSW   XMM15, XMM10		; XMM15 = p1 + p2 + p3 + p7 + p8 + p9 + p13 + p14 + p15 | p0 + p1 + p2 + p6 + p7 + p8 + p12 + p13 + p14

			; Divido por 9
			MOVDQU    XMM0, XMM15
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

			MOVDQU    XMM15, XMM0
			PSRLDQ    XMM15, 8
			MOVDQU    XMM14, XMM15
			PMULHW    XMM15, XMM13		; High of psum * dosk
			PMULLW    XMM14, XMM13		; Low of psum * dosk
			PUNPCKLWD XMM14, XMM15		; XMM15 = psum
			PSRLD     XMM14, 16
			PXOR      XMM15, XMM15
			PACKUSDW  XMM14, XMM15
			PACKUSWB  XMM14, XMM15

			MOVD      EDX, XMM14			; Muevo a registro de proposito general
			MOV DWORD [R10 + RDI + 8], EDX	; Escribo en memoria (Imagen)

			; Pixel 2 y 3
			; Tomo los pixeles de memoria

			; Clear XMM to unpack with ceroes
			PXOR      XMM15, XMM15
			PXOR      XMM14, XMM14
			MOVDQU    XMM0, [R12 + RDI + 8]	; XMM0 = p5 | p4 | p3 | p2
			MOVDQU    XMM1, XMM0		; XMM1 = XMM0
			PUNPCKLBW XMM0, XMM15		; XMM0 = p3 | p2
			PUNPCKHBW XMM1, XMM15		; XMM1 = p5 | p4

			MOVDQU    XMM4, [R13 + RDI + 8]	; XMM4 = p11 | p10 | p9 | p8
			MOVDQU    XMM5, XMM4		; XMM5 = XMM4 
			PUNPCKLBW XMM4, XMM15		; XMM4 = p9 | p8
			PUNPCKHBW XMM5, XMM15		; XMM5 = p11 | p10

			MOVDQU    XMM8, [R8  + RDI + 8]	; XMM10 = p17 | p16 | p15 | p14
			MOVDQU    XMM9, XMM8		; XMM11 = XMM10
			PUNPCKLBW XMM8, XMM15		; XMM10 = p15 | p14
			PUNPCKHBW XMM9, XMM15		; XMM11 = p17 | p16

			; Sumo los 9 pixeles de 2 y 3, guardo el resultado en XMM15
			PADDUSW   XMM15, XMM0		; XMM15 = p3 | p2
			PADDUSW   XMM15, XMM1		; XMM15 = p3 + p5 | p2 + p4
			PADDUSW   XMM15, XMM3		; XMM15 = p3 + p4 + p5 | p2 + p3 + p4
			PADDUSW   XMM15, XMM4		; XMM15 = p3 + p4 + p5 + p9 | p2 + p3 + p4 + p8
			PADDUSW   XMM15, XMM5		; XMM15 = p3 + p4 + p5 + p9 + p11 | p2 + p3 + p4 + p8 + p10
			PADDUSW   XMM15, XMM7		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 | p2 + p3 + p4 + p8 + p9 + p10
			PADDUSW   XMM15, XMM8		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 + p15 | p2 + p3 + p4 + p8 + p9 + p10 + p14
			PADDUSW   XMM15, XMM9		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 + p15 + p17 | p2 + p3 + p4 + p8 + p9 + p10 + p14 + p16
			PADDUSW   XMM15, XMM11		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 + p15 + p16 + p17 | p2 + p3 + p4 + p8 + p9 + p10 + p14 + p15 + p16

			; Divido por 9
			; Salto al final si llegue al fin de la linea
			MOVDQU    XMM0, XMM15
			MOVDQU    XMM14, XMM15		; XMM14 = XMM15
			PMULHW    XMM15, XMM13		; High of psum * dosk
			PMULLW    XMM14, XMM13		; Low of psum * dosk
			PUNPCKLWD XMM14, XMM15		; XMM15 = psum
			PSRLD     XMM14, 16
			PXOR      XMM15, XMM15
			PACKUSDW  XMM14, XMM15
			PACKUSWB  XMM14, XMM15

			MOVD DWORD [R10 + RDI + 12], XMM14	; Escribo en memoria (Imagen)

			MOVDQU    XMM15, XMM0
			PSRLDQ    XMM15, 8
			MOVDQU    XMM14, XMM15		; XMM14 = XMM15
			PMULHW    XMM15, XMM13		; High of psum * dosk
			PMULLW    XMM14, XMM13		; Low of psum * dosk
			PUNPCKLWD XMM14, XMM15		; XMM15 = psum
			PSRLD     XMM14, 16
			PXOR      XMM15, XMM15
			PACKUSDW  XMM14, XMM15
			PACKUSWB  XMM14, XMM15

			MOVD DWORD [R10 + RDI + 16], XMM14	; Escribo en memoria (Imagen)

			; Me muevo y checkeo si llegue al final de la linea
			ADD RDI, 16
			MOV R11, R14
			SUB R11, 16
			CMP RDI, R11	; Veo si llegue al final
			JL  .ciclox

			; Blureo los ultimos 2 bytes de la linea
			PXOR      XMM15, XMM15
			MOVDQU    XMM0, [R12 + RDI]	; XMM0 = p3 | p2 | p1 | p0
			MOVDQU    XMM1, XMM0		; XMM1 = XMM0
			MOVDQU    XMM3, XMM0		; XMM1 = XMM0
			PUNPCKLBW XMM0, XMM15		; XMM0 = p1 | p0
			PUNPCKHBW XMM1, XMM15		; XMM1 = p3 | p2
			PSRLDQ    XMM3, 4
			PUNPCKLBW XMM3, XMM15		
			MOVDQU    XMM4, [R13 + RDI]	; XMM4 = p9 | p8 | p7 | p6
			MOVDQU    XMM5, XMM4		; XMM5 = XMM4
			MOVDQU    XMM7, XMM4		; XMM1 = XMM0
			PUNPCKLBW XMM4, XMM15		; XMM4 = p7 | p6
			PUNPCKHBW XMM5, XMM15		; XMM5 = p9 | p8
			PSRLDQ    XMM7, 4
			PUNPCKLBW XMM7, XMM15		
			MOVDQU    XMM8, [R8  + RDI]	; XMM8 = p15 | p14 | p13 | p12
			MOVDQU    XMM9, XMM8		; XMM9 = XMM8
			MOVDQU    XMM11, XMM8		; XMM1 = XMM0
			PUNPCKLBW XMM8, XMM15		; XMM8 = p13 | p12
			PUNPCKHBW XMM9, XMM15		; XMM9 = p15 | p14
			PSRLDQ    XMM11, 4
			PUNPCKLBW XMM11, XMM15		

			; Sumo los 9 pixeles de 2 y 3, guardo el resultado en XMM15
			PADDUSW   XMM15, XMM0		; XMM15 = p3 | p2
			PADDUSW   XMM15, XMM1		; XMM15 = p3 + p5 | p2 + p4
			PADDUSW   XMM15, XMM3		; XMM15 = p3 + p4 + p5 | p2 + p3 + p4
			PADDUSW   XMM15, XMM4		; XMM15 = p3 + p4 + p5 + p9 | p2 + p3 + p4 + p8
			PADDUSW   XMM15, XMM5		; XMM15 = p3 + p4 + p5 + p9 + p11 | p2 + p3 + p4 + p8 + p10
			PADDUSW   XMM15, XMM7		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 | p2 + p3 + p4 + p8 + p9 + p10
			PADDUSW   XMM15, XMM8		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 + p15 | p2 + p3 + p4 + p8 + p9 + p10 + p14
			PADDUSW   XMM15, XMM9		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 + p15 + p17 | p2 + p3 + p4 + p8 + p9 + p10 + p14 + p16
			PADDUSW   XMM15, XMM11		; XMM15 = p3 + p4 + p5 + p9 + p10 + p11 + p15 + p16 + p17 | p2 + p3 + p4 + p8 + p9 + p10 + p14 + p15 + p16

			; Divido por 9
			MOVDQU    XMM0, XMM15
			MOVDQU    XMM14, XMM15
			PMULHW    XMM15, XMM13		; High of psum * dosk
			PMULLW    XMM14, XMM13		; Low of psum * dosk
			PUNPCKLWD XMM14, XMM15		; XMM15 = psum
			PSRLD     XMM14, 16
			PXOR      XMM15, XMM15
			PACKUSDW  XMM14, XMM15
			PACKUSWB  XMM14, XMM15

			MOVD DWORD [R10 + RDI + 4], XMM14	; Escribo en memoria (Imagen)

			MOVDQU    XMM15, XMM0
			PSRLDQ    XMM15, 8
			MOVDQU    XMM14, XMM15
			PMULHW    XMM15, XMM13		; High of psum * dosk
			PMULLW    XMM14, XMM13		; Low of psum * dosk
			PUNPCKLWD XMM14, XMM15		; XMM15 = psum
			PSRLD     XMM14, 16
			PXOR      XMM15, XMM15
			PACKUSDW  XMM14, XMM15
			PACKUSWB  XMM14, XMM15

			MOVD DWORD [R10 + RDI + 8], XMM14	; Escribo en memoria (Imagen)

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

	ADD  RSP, 8
	POP  R15
	POP  R14
	POP  R13
	POP  R12
	POP  RBX
	POP  RBP

	RET