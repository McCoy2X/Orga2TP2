; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 1                                    ;
;                                                                           ;
; ************************************************************************* ;

extern malloc
extern free

; void ASM_merge1(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
; EDI w, ESI, h, RDX *data1, RCX *data2, XMM0 value
global ASM_merge1
ASM_merge1:
	; PUSH RBP
	; MOV  RBP, RSP
	; PUSH RBX
	; PUSH R12
	; PUSH R13
	; PUSH R14
	; PUSH R15
	; SUB  RSP, 8

	; ; Guardo los inputs
	; MOV  R12D, EDI	; R12 = w
	; MOV  R13D, ESI	; R13 = h
	; MOV  R14, RDX	; R14 = *data1
	; MOV  R15, RCX	; R15 = *data2
	; SUB  RSP, 16
	; MOVDQU [RSP], XMM0

	; ; Veo la cantidad de pixels en bytes
	; MOV  RDI, R12
	; MOV  RAX, 4
	; MUL  RDI
	; MOV  R12, RAX

	; ; Pido memoria para cargar las 2 filas
	; MOV  RDI, R12
	; CALL malloc
	; MOV  RBX, RAX		; RBX = *filad1
	; MOV  RDI, R12
	; CALL malloc
	; MOV  RCX, RAX		; RCX = *filad2

	; ; Recupero en XMM15 value
	; MOVDQU XMM15, [RSP] 
	; ADD    RSP, 16
	; PEXTRD RDI, XMM15, 0
	; PINSRQ XMM15, RDI, 1
	; PINSRQ XMM15, RDI, 2
	; PINSRQ XMM15, RDI, 3
	; MOVDQU XMM14, 1
	; PEXTRD RDI, XMM14, 0
	; PINSRQ XMM14, RDI, 1
	; PINSRQ XMM14, RDI, 2
	; PINSRQ XMM14, RDI, 3

	; ; Cargo las 2 filas en memoria
	; MOV  RDI, 0
	; .getFilas:
	; 	MOV  EDX, [R14 + RDI * 4]	; Copio los pixeles de *data1
	; 	MOV  [RBX + RDI * 4], EDX
	; 	MOV  EDX, [R15 + RDI * 4]	; Copio las pixeles de *data2
	; 	MOV  [RCX + RDI * 4], EDX
	; 	ADD  RDI, 1
	; 	CMP  RDI, R12
	; 	JL   .getFilas

	; ; Ciclo de mergeo
	; MOV  RDI, 0	; RDI iterador de x
	; PXOR XMM1
	; .cicloy:
	; 	MOV  

	; 	.ciclox:
	; 		MOVDQU XMM0, [RBX + RDI]	; XMM0 = p3 | p2 | p1 | p0

	; 		PUNPCKLWD XMM0, XMM1        ; Empaqueto las words en doblewords
	; 		CVTDQ2PS  XMM0, XMM0        ; Transformo las doblewords a float
	; 		DIVPS     XMM0, XMM15       ; Divido por 9 los 4 floats
	; 		CVTPS2DQ  XMM0, XMM0        ; Transformo los floats a doublewords
	; 		PACKUSDW  XMM0, XMM1        ; Desenpacketo como word
	; 		PACKUSWB  XMM0, XMM1        ; Desempaqueto como byte

	; 	ADD RDI, 4
	; 	CMP RDI, R12
	; 	JL .ciclox

	; ADD  RSP, 8
	; POP  R15
	; POP  R14
	; POP  R13
	; POP  R12
	; POP  RBX
	; POP  RSP
	; RET