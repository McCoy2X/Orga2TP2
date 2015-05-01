; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_hsl2(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl2

extern malloc
extern rgbTOhsl
extern free
extern hslTOrgb

%define HUE        12
%define SATURATION 8
%define LIGHT      4
%define TAM_FLOAT  4

section .rodata

section .data

masc_sup: dd 0.0, 0.0, 1.0, 1.0
masc_inf: dd 0.0, 0.0, 0.0, 0.0
masc_max: dq 0x7FFF7FFF7FFF7FFF, 0x7FFF7FFF7FFF7FFF
masc_abs: dq 0x7FFFFFFF7FFFFFFF, 0x7FFFFFFF7FFFFFFF
cte_360: dd 0.0, 360.0, 0.0, 0.0
cte_360_lsb: dd 360.0, 0.0, 0.0, 0.0
cte_60: dd 0.0, 60.0, 60.0, 60.0
cte_510: dd 510.0, 510.0, 510.0, 510.0
cte_2: dd 2.0, 2.0, 2.0, 2.0
cte_1: dd 1.0, 1.0, 1.0, 1.0
cte_255: dd 0.0, 0.0, 0.0, 255.0001
align 16
cte_suma: dd 0.0, 4.0, 2.0, 6.0
limpiar: dd 0x0, 0x0, 0x0, 0xFFFFFFFF
limpiar_lsb: dd 0xFFFFFFFF, 0x0, 0x0, 0x0
limpiar_msb: dd 0x0, 0x0, 0x0, 0xFFFFFFFF
limpiar_h: dd 0x0, 0xFFFFFFFF, 0x0, 0x0
floor: dd 0x7F80

section .text

ASM_hsl2:
        ldmxcsr [floor]

        push rbp
        push rbx
        mov rbp, rsp
        sub rsp, 16
        push r12
        push r13
        push r14
        push r15
        sub rsp, 8

        mov r13, rdx
        ;mov r14d, edi
        ;mov r15d, esi

        mov rax, rdi
        mul rsi
        mov rbx, 4
        mul rbx
        mov rbx, rax

        ; Guardo los XMM en el Stack
        ; Me hago el pelotudo y lo guardo al reves, asi me los levanta bien ;)

        movss [rbp - HUE], xmm0
        movss [rbp - SATURATION], xmm1
        movss [rbp - LIGHT], xmm2

        ; Genero el lugar para almacenar los 4 pixelocos
        mov rdi, 16
        call malloc
        mov r12, rax
        mov r14d, 0

        .ciclo:
        cmp r14d, ebx
        je .fin
        ; Lentamente me comienzo a cagar en todo
        ; Cargo las cosas como corresponde y veo que esto lo convierta
        lea rdi, [r13 + r14]
        mov rsi, r12
        call rgbTOhsl
        ; COSO
        movdqu xmm15, [r12]

        movd xmm1, [r13 + r14]  ; XMM1 = b | g | r | x (en int8)
        pxor xmm2, xmm2         ; XMM2 = 0
        punpcklbw xmm1, xmm2    ; XMM1 = b | g | r | x (en int16)
        punpcklwd xmm1, xmm2    ; XMM1 = b | g | r | x (en int)
        movdqu xmm0, xmm1       ; XMM0 = b | g | r | x (en int)
        psrldq xmm1, 4
        pslldq xmm1, 4          ; XMM1 = b | g | r | 0 (en int)

        movdqu xmm2, xmm1       ; XMM2 = b | g | r | x
        movdqu xmm3, xmm2
        pslldq xmm3, 4          ; XMM3 = g | r | x | 0
        movdqu xmm4, xmm3
        pslldq xmm4, 4          ; XMM4 = r | x | 0 | 0

        movdqu xmm5, [masc_max] ; XMM5 = FF...
        pxor xmm6, xmm6         ; XMM6 = 0

        pminsw xmm5, xmm2
        pminsw xmm5, xmm3
        pminsw xmm5, xmm4       ; XMM5 = cmin | - | - | -

        pmaxsw xmm6, xmm2
        pmaxsw xmm6, xmm3
        pmaxsw xmm6, xmm4       ; XMM6 = cmax | - | - | -

        pshufd xmm2, xmm6, 0xFF ; XMM2 = cmax | cmax | cmax | cmax
        movdqu xmm3, xmm1
        psrldq xmm3, 4          ; XMM3 =   0  | b | g | r
        pand xmm5, [limpiar]    ; XMM5 = cmin | 0 | 0 | 0
        pand xmm6, [limpiar]    ; XMM6 = cmax | 0 | 0 | 0
        por  xmm3, xmm5         ; XMM3 = cmin | b | g | r
        pcmpeqd xmm3, xmm2      ; XMM3 = cmin == cmax | b == cmax | g == cmax | r == cmax
        pshufd xmm4, xmm3, 0x1B ; XMM4 =   r == cmax  | g == cmax | b == cmax | cmin == cmax
        movdqu xmm11, xmm4      ; XMM11= XMM4
        pslldq xmm11, 4
        por xmm4, xmm11
        pslldq xmm11, 4
        por xmm4, xmm11
        pslldq xmm11, 4
        por xmm4, xmm11
        movdqu xmm11, xmm4
        pslldq xmm11, 4
        pxor xmm4, xmm11
        ; En XMM3 tengo la mascara que me va a filtar despues las sumas, la idea es hacer
        ; todas las sumas (al pedo, pero bueh, me evito saltos :P), hacer alto PAND con la
        ; mascara y clavarme terrible suma horizontal. SSSE3 BITCHES :P

        ; Regs al pedo: XMM0, XMM7, ...
        ; CALCULO DE H
        pshufd xmm7, xmm1, 0xB4   ; XMM7  =      g      |      b      |      r      |      0
        pshufd xmm8, xmm1, 0xD8   ; XMM8  =      b      |      r      |      g      |      0
        pshufd xmm9, xmm5, 0xFF   ; XMM9  =     cmin    |     cmin    |     cmin    |     cmin   
        movdqu xmm11, xmm2        ; XMM11 =     cmax    |     cmax    |     cmax    |     cmax
        psubd xmm11, xmm9         ; XMM11 = cmax - cmin | cmax - cmin | cmax - cmin | cmax - cmin
        cvtdq2ps xmm10, xmm11     ; XMM10 = (float)XMM11
        psubd xmm7, xmm8          ; XMM7  = g - b | b - r | r - g | -
        cvtdq2ps xmm8, xmm7       ; XMM8  = (float)XMM7
        divps xmm8, xmm10         ; XMM8  =      (g-b)/d     |      (b-r)/d     |      (r-g)/d     | -
        addps xmm8, [cte_suma]    ; XMM8  =    (g-b)/d + 6   |    (b-r)/d + 2   |    (r-g)/d + 4   | -
        mulps xmm8, [cte_60]      ; XMM8  = 60*((g-b)/d + 6) | 60*((b-r)/d + 2) | 60*((r-g)/d + 4) | -
        andps xmm8, xmm4          ; XMM8  = el resultado ENMASCARADO (No me golpeen :P)
        pshufd xmm9, xmm5, 0xFF   ; XMM9  =     cmin     |     cmin     |     cmin     |     cmin   
        pcmpeqd xmm9, xmm2        ; XMM9  = cmin == cmax | cmin == cmax | cmin == cmax | cmin == cmax
        andnps xmm9, xmm8         ; Hago esto para salvar el NaN si dividi por cero 
        movdqu xmm8, xmm9         ;  
        movdqu xmm10, xmm8        ;
        psrldq xmm8, 4            ;
        addps xmm10, xmm8         ;
        psrldq xmm8, 4            ;
        addps xmm10, xmm8         ;
        psrldq xmm8, 4            ;
        addps xmm10, xmm8         ; Esto es mas hackoso que el carajo, pero la verdad la
        psrldq xmm8, 4            ; suma horizontal es una cagada. :/
        addps xmm10, xmm8         ; XMM10 = el posta en menos significativos
        movdqu xmm8, [cte_360_lsb]; XMM8  = 0 | 0 | 0 | 360
        cmpps xmm8, xmm10, 2      ; XMM8 = posta >= 360 (en LSB)
        andps xmm8, [cte_360_lsb] ; XMM8 = (posta >= 360)? 360 : 0 (en LSB)
        subps xmm10, xmm8         ; XMM10 = h (en LSB)

        ; CALCULO DE L
        movdqu xmm7, xmm6       ; XMM7 =     cmax    | 0 | 0 | 0
        paddd xmm7, xmm5        ; XMM7 = cmax + cmin | 0 | 0 | 0
        cvtdq2ps xmm8, xmm7     ; XMM8 = (float)XMM7
        divps xmm8, [cte_510]   ; XMM8 = (cmax + cmin)/510 | 0 | 0 | 0
                                ; XMM8 = l (en MSB)

        ; CALCULO DE S
        movdqu xmm7, xmm6        ; XMM7  =      cmax     | 0 | 0 | 0
        pcmpeqd xmm7, xmm5       ; XMM7  =  cmax == cmin | 0 | 0 | 0
        movdqu xmm11, xmm6       ; XMM11 =      cmax     | 0 | 0 | 0
        psubd xmm11, xmm5        ; XMM11 =  cmax - cmin  | 0 | 0 | 0
        movdqu xmm12, xmm8       ; XMM12 =       l       | 0 | 0 | 0
        mulps xmm12, [cte_2]     ; XMM12 =      2*l      | 0 | 0 | 0
        subps xmm12, [cte_1]     ; XMM12 =     2*l-1     | 0 | 0 | 0
        andps xmm12, [masc_abs]  ; XMM12 =  fabs(2*l-1)  | 0 | 0 | 0
        movdqa xmm13, [cte_1]    ; XMM13 =       1       | 0 | 0 | 0
        subps xmm13, xmm12       ; XMM13 = 1-fabs(2*l-1) | 0 | 0 | 0
        cvtdq2ps xmm9, xmm11     ; XMM9  = (float)XMM11  | 0 | 0 | 0
        divps xmm9, xmm13        ; XMM9  =    d/XMM13    | 0 | 0 | 0
        divps xmm9, [cte_255]    ; XMM9  = s (en MSB)
        andps xmm9, [limpiar_msb]; XMM9  = solamente s
        andnps xmm7, xmm9        ; XMM7  = esta el valor de s, si es que cumplio la condicion

        ; PONGO TODO EN UN SOLO REGISTRO
                                    ; XMM8  = l | 0 | 0 | 0
        psrldq xmm7, 4              ; XMM9  = 0 | s | 0 | 0
        pslldq xmm10, 4             ; XMM10 = - | - | h | 0
        andps xmm10, [limpiar_h]    ; XMM9  = 0 | 0 | h | 0
        pand xmm0, [limpiar_lsb]    ; XMM0  = 0 | 0 | 0 | x
        cvtdq2ps xmm1, xmm0         ; XMM1  = (float)XMM0
        orps xmm1, xmm8             ; XMM1  = l | 0 | 0 | x
        orps xmm1, xmm7             ; XMM1  = l | s | 0 | x
        orps xmm1, xmm10            ; XMM1  = l | s | h | x


        ; FIN COSO
        movdqu xmm0, [rbp - 16]  ; XMM0 = ll | ss | hh | x
        ;movdqu xmm1, [r12]      ; XMM1 = l | s | h | x

        addps xmm0, xmm1        ; XMM0 = ll + l | ss + s | hh + h | x
        movdqu xmm4, xmm0       ; XMM4 = XMM0
        movdqu xmm5, xmm0       ; XMM5 = XMM0

        movdqu xmm2, [masc_sup] ; XMM5 = 1.0 |  1.0  | 0.0 | x
        movdqu xmm3, [masc_inf] ; XMM3 = 0.0 |  0.0  | 0.0 | x

        movdqu xmm6, [cte_360]  ; XMM6 = 0.0 | 0.0 | 360.0 | x
        movdqu xmm7, [masc_inf] ; XMM7 = 0.0 | 0.0 |  0.0  | x
        movdqu xmm8, xmm6       ; Me guardo el 360 en estos registros, despues los voy a
        movdqu xmm9, xmm6       ; sumar con la copia en XMM5

        minps xmm4, xmm2        ;
        maxps xmm4, xmm3        ; XMM4 = ll_p | ss_p | 0.0 | x

        shufps xmm0, xmm4, 0xE4 ; XMM0 = ll_p | ss_p | hh + h | x

        cmpps xmm6, xmm5, 2     ; hh + h >= 360?
        cmpps xmm7, xmm5, 2     ; hh + h >= 0?
        andps xmm6, xmm8        ; (hh + h) >= 360 ? XMM6[2] = 360 : XMM6[2] = 0
        andnps xmm7, xmm9       ; !((hh + h) >= 0) ? XMM7[2] = 360 : XMM7[2] = 0

        subps xmm0, xmm6        ; XMM0 = ll_p | ss_p | hh + h - XMM6[2] | x
        addps xmm0, xmm7        ; XMM0 = ll_p | ss_p | hh + h + XMM7[2] | x

        movdqu [r12], xmm0

        mov rdi, r12
        lea rsi, [r13 + r14]
        call hslTOrgb
        add r14, 4
        jmp .ciclo

        .fin:
        mov rdi, r12
        call free

        add rsp, 8
        pop r15
        pop r14
        pop r13
        pop r12
        add rsp, 16
        pop rbx
        pop rbp

        ret