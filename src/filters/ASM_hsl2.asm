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

section .rodata

section .data

align 16
masc_sup: dd 0.0, 0.0, 1.0, 1.0
masc_inf: dd 0.0, 0.0, 0.0, 0.0
masc_max: dq 0x7FFF7FFF7FFF7FFF, 0x7FFF7FFF7FFF7FFF
masc_abs: dq 0x7FFFFFFF7FFFFFFF, 0x7FFFFFFF7FFFFFFF
cte_360: dd 0.0, 360.0, 0.0, 0.0
cte_360_lsb: dd 360.0, 0.0, 0.0, 0.0
cte_60: dd 60.0, 60.0, 60.0, 60.0
cte_510: dd 510.0, 510.0, 510.0, 510.0
cte_2: dd 2.0, 2.0, 2.0, 2.0
cte_1: dd 1.0, 1.0, 1.0, 1.0
cte_255: dd 0.0, 0.0, 0.0, 255.0001
cte_255_4: dd 255.0, 255.0, 255.0, 255.0
align 16
cte_suma: dd 0.0, 4.0, 2.0, 6.0
cte_cmp1: dd 360.0, 300.0, 240.0, 180.0
cte_cmp2: dd 300.0, 240.0, 180.0, 120.0
cte_cmp3: dd 120.0, 60.0, 0.0, 0.0
cte_cmp4: dd 60.0, 0.0, 0.0, 0.0
limpiar: dd 0x0, 0x0, 0x0, 0xFFFFFFFF
limpiar_lsb: dd 0xFFFFFFFF, 0x0, 0x0, 0x0
limpiar_msb: dd 0x0, 0x0, 0x0, 0xFFFFFFFF
limpiar_h: dd 0x0, 0xFFFFFFFF, 0x0, 0x0


section .text

ASM_hsl2:

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

        movss [rbp - HUE], xmm0
        movss [rbp - SATURATION], xmm1
        movss [rbp - LIGHT], xmm2

        mov r14d, 0

        .ciclo:
        cmp r14d, ebx
        je .fin
        ; COSO

        movd xmm15, [r13+r14]

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
        pslldq xmm11, 4         ;
        por xmm4, xmm11         ;
        pslldq xmm11, 4         ;
        por xmm4, xmm11         ;
        pslldq xmm11, 4         ;
        por xmm4, xmm11         ;
        movdqu xmm11, xmm4      ;
        pslldq xmm11, 4         ;
        pxor xmm4, xmm11        ; Limpio el resultado de XMM4 en caso de que haya empate
        ; En XMM4 tengo la mascara que me va a filtar despues las sumas

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
        andps xmm8, xmm4          ; XMM8  = el resultado con la mascara aplicada
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
        addps xmm10, xmm8         ; 
        psrldq xmm8, 4            ; 
        addps xmm10, xmm8         ; XMM10 = el resultado final en menos significativos
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


        movdqu xmm0, [rbp - 16]  ; XMM0 = ll | ss | hh | x

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

        ; CALCULO DE C
                                ; XMM0 =       l       |       s       |       h       |       a
        pshufd xmm1, xmm0, 0xFF ; XMM1 =       l       |       l       |       l       |       l
        mulps xmm1, [cte_2]     ; XMM1 =      2*l      |      2*l      |      2*l      |      2*l
        subps xmm1, [cte_1]     ; XMM1 =     2*l-1     |     2*l-1     |     2*l-1     |     2*l-1
        andps xmm1, [masc_abs]  ; XMM1 =  fabs(2*l-1)  |  fabs(2*l-1)  |  fabs(2*l-1)  |  fabs(2*l-1)
        movdqa xmm2, [cte_1]    ; XMM2 =       1       |       1       |       1       |       1
        subps xmm2, xmm1        ; XMM1 =   1-(2*l-1)   |   1-(2*l-1)   |   1-(2*l-1)   |   1-(2*l-1)
        pshufd xmm1, xmm0, 0xAA ; XMM2 =       s       |       s       |       s       |       s
        mulps xmm1, xmm2        ; XMM1 = (1-(2*l-1))*s | (1-(2*l-1))*s | (1-(2*l-1))*s | (1-(2*l-1))*s
        pslldq xmm1, 12         ; XMM1 =       c       |       0       |       0       |       0
        psrldq xmm1, 12         ; XMM1 =       0       |       0       |       0       |       c

        ; CALCULO DE X
        movdqa xmm2, [cte_1]    ; XMM2 =             1
        pshufd xmm3, xmm0, 0x55 ; XMM3 =             h
        divps xmm3, [cte_60]    ; XMM3 =            h/60
        movdqu xmm4, xmm3       ; XMM4 =            XMM3
        movdqu xmm6, [cte_2]    ; XMM5 =             2
        cmpps xmm6, xmm3, 1     ; XMM5 =         (2 < h/60)
        divps xmm4, [cte_2]     ; XMM4 =          (h/60)/2
        roundps xmm5, xmm4, 0x03; XMM5 =         floor(XMM4)
        mulps xmm5, [cte_2]     ; XMM5 =        floor(XMM4)*2
        subps xmm3, xmm5        ; XMM3 =        fmod(h/60, 2)
        ;andps xmm6, xmm3
        movdqu xmm6, xmm3
        subps xmm6, [cte_1]     ; XMM3 =       fmod(h/60, 2)-1
        andps xmm6, [masc_abs]  ; XMM4 =    fabs(fmod(h/60, 2)-1)
        subps xmm2, xmm6        ; XMM5 =   1-fabs(fmod(h/60, 2)-1)
        mulps xmm2, xmm1        ; XMM5 = c*(1-fabs(fmod(h/60, 2)-1))
        pslldq xmm2, 12
        psrldq xmm2, 12
                                ; XMM2 =             x

        ; CALCULO DE M
        pshufd xmm3, xmm0, 0xFF ; XMM3 =   l   |   l   |   l   |   l   |
        pshufd xmm4, xmm1, 0x00 ; XMM4 =   c   |   c   |   c   |   c   |
        divps xmm4, [cte_2]     ; XMM4 =  c/2  |  c/2  |  c/2  |  c/2  |
        subps xmm3, xmm4        ; XMM3 = l-c/2 | l-c/2 | l-c/2 | l-c/2 |

        ; CALCULO LAS MASCARAS
        pshufd xmm9, xmm0, 0x55 ; XMM3 = h
        ;movdqa xmm9, [temp]
        movdqu xmm10, [cte_cmp1]
        movdqu xmm11, [cte_cmp2]
        cmpps xmm10, xmm9, 2
        cmpps xmm11, xmm9, 2
        andnps xmm10, xmm11
        movdqu xmm12, [cte_cmp3]
        movdqu xmm13, [cte_cmp4]
        cmpps xmm12, xmm9, 2
        cmpps xmm13, xmm9, 2
        andnps xmm12, xmm13

        pshufd xmm4, xmm12, 0x55 ;  0   <= h < 60
        pshufd xmm5, xmm12, 0x00 ; 60   <= h < 120
        pshufd xmm6, xmm10, 0xFF ; 120  <= h < 180
        pshufd xmm7, xmm10, 0xAA ; 180  <= h < 240
        pshufd xmm8, xmm10, 0x55 ; 240  <= h < 300
        pshufd xmm9, xmm10, 0x00 ; 300  <= h < 360

                           ;         b | g | r | a
        movdqu xmm10, xmm2 ; XMM10 = 0 | 0 | 0 | x
        pslldq xmm10, 4    ; XMM10 = 0 | 0 | x | 0
        orps xmm10, xmm1   ; XMM10 = 0 | 0 | x | c
        pslldq xmm10, 4    ; XMM10 = 0 | x | c | 0
        
        movdqu xmm11, xmm1 ; XMM11 = 0 | 0 | 0 | c
        pslldq xmm11, 4    ; XMM11 = 0 | 0 | c | 0
        orps xmm11, xmm2   ; XMM11 = 0 | 0 | c | x
        pslldq xmm11, 4    ; XMM11 = 0 | c | x | 0
        
        movdqu xmm12, xmm2 ; XMM12 = 0 | 0 | 0 | c
        pslldq xmm12, 4    ; XMM12 = 0 | 0 | c | 0
        orps xmm12, xmm1   ; XMM12 = 0 | 0 | c | x
        pslldq xmm12, 8    ; XMM12 = c | x | 0 | 0
        
        movdqu xmm13, xmm1 ; XMM13 = 0 | 0 | 0 | x
        pslldq xmm13, 4    ; XMM13 = 0 | 0 | x | 0
        orps xmm13, xmm2   ; XMM13 = 0 | 0 | x | c
        pslldq xmm13, 8    ; XMM13 = x | c | 0 | 0

        movdqu xmm14, xmm1 ; XMM14 = 0 | 0 | 0 | c
        pslldq xmm14, 8    ; XMM14 = 0 | c | 0 | 0
        orps xmm14, xmm2   ; XMM14 = 0 | c | 0 | x
        pslldq xmm14, 4    ; XMM14 = c | 0 | x | 0

        movdqu xmm15, xmm2 ; XMM15 = 0 | 0 | 0 | x
        pslldq xmm15, 8    ; XMM15 = 0 | x | 0 | 0
        orps xmm15, xmm1   ; XMM15 = 0 | x | 0 | c
        pslldq xmm15, 4    ; XMM15 = x | 0 | c | 0
        
        andps xmm4, xmm10
        andps xmm5, xmm11
        andps xmm6, xmm12
        andps xmm7, xmm13
        andps xmm8, xmm14
        andps xmm9, xmm15

        addps xmm4, xmm5
        addps xmm4, xmm6
        addps xmm4, xmm7
        addps xmm4, xmm8
        addps xmm4, xmm9    ; XMM4 = b' | g' | r' | 0

        addps xmm4, xmm3            ; XMM4 =    b'+m    |    g'+m    |    r'+m    | -
        mulps xmm4, [cte_255_4]     ; XMM4 = (b'+m)*255 | (g'+m)*255 | (r'+m)*255 | -
        movdqa xmm5, [limpiar_lsb]  ;
        andnps xmm5, xmm4           ; XMM5 = (b'+m)*255 | (g'+m)*255 | (r'+m)*255 | 0
        andps xmm0, [limpiar_lsb]   ; XMM0 =      0     |      0     |      0     | a
        orps xmm0, xmm5             ; XMM0 = (b'+m)*255 | (g'+m)*255 | (r'+m)*255 | a
        cvtps2dq xmm0, xmm0
        packusdw xmm0, xmm0
        packuswb xmm0, xmm0
        pand xmm0, [limpiar_lsb]

        movd [r13 + r14], xmm0

        add r14, 4
        jmp .ciclo

        .fin:
        add rsp, 8
        pop r15
        pop r14
        pop r13
        pop r12
        add rsp, 16
        pop rbx
        pop rbp

        ret
