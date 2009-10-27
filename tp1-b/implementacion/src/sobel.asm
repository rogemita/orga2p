;void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/offset.inc"
%include "include/macros.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]

%macro procedimiento 2-3 0
	movq	mm0, [edi + eax*%3]	; traigo los pixeles
	movq	mm3, mm0	; salvo lo que traje en mm3 y mm4
	movq	mm4, mm0
	pxor	mm1, mm1	; pongo en ceros mm1 y mm2
	punpcklbw mm0, mm1	; tranformo a word los pixeles de la parte baja y guardo en mm0
	punpckhbw mm3, mm1	; tranformo a word los pixeles de la parte alta y guardo en mm3

	movq	mm5, [%1]	; cargo la primer mascara, la positiva
	pmullw	mm0, mm5	; multiplico la parte baja por la mascara
	pmullw	mm3, mm5	; multiplico la parte alta por la mascara
				; y en ambos me quedo con solo la parte baja

	;packuswb mm0, mm3	; paso las words a bytes como antes y guardo en mm0
	packuswb mm0, mm3
	movq	mm5, mm0	; guardo el resultado parcial en mm5
	;;;;;;;;;;;;;;;;
	movq	mm0, mm4	; recupero mis pixeles como estaban y los guardo en mm0
	movq	mm3, mm4	; tambien los guardo en mm3
	punpcklbw mm0, mm1	; transformo como antes a words la parte baja y alta
	punpckhbw mm3, mm1

	movq	mm4, [%2]	; cargo la mascara negativa en mm4
	pmullw	mm0, mm4	; multiplico con words signadas la parte baja
	pmullw	mm3, mm4	; multiplico con words signadas la parte alta

 	packuswb mm0, mm3	; vuelvo a bytes words signadas y ademas saturo
	psllq	mm0, 16		; los ultimos 2 bytes quedan sin procesar
	
	paddsb	mm5, mm0	; sumo bytes signados con saturacion
	paddusb	mm6, mm5	; sumo bytes signados al resultado parcial del operador
%endmacro

global asmSobel

section .data
unos:		dw 1, 1, 1, 1
dos:		dw 2, 2, 2, 2
menos_unos:	dw -1, -1, -1, -1
menos_dos:	dw -2, -2, -2, -2

section .text

asmSobel:
	doEnter

sigue:
	mov	edi, SRC
	mov	edi, [edi + IMAGE_DATA]

	mov	esi, DST
	mov	esi, [esi + IMAGE_DATA]
	
	mov	ebx, HEIGHT
	sub	ebx, 2
	mov	edx, WIDTH
	mov	eax, edx
	;sar	edx, 3
	mov	ecx, 80
	inc	ecx
	mov	edx, ecx
; 	sar	edx, 4
	;mov	ecx, edx

	lea	esi, [esi + eax +1]

ciclo_x:
 	pxor	mm6, mm6
	procedimiento unos, menos_unos
	procedimiento dos, menos_dos, 1
	procedimiento unos, menos_unos, 2

	movq	[esi], mm6
	add	edi, 6
	add	esi, 6
	dec	ecx
	cmp	ecx, 0
	je	ciclo_y
	jmp	ciclo_x
ciclo_y:
	mov	ecx, edx
	dec	ebx
	sub	edi, 2
	sub	esi, 2
	cmp	ebx, 0
	jne ciclo_x

fin:
	doLeave 0, 1