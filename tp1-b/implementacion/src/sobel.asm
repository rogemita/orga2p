;void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/offset.inc"
%include "include/macros.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]

global asmSobel

section .data
menos_unos:	dd 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
menos_dos:	db -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
dos:	db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2

mask: dd 0x00000000, 0xffffffff, 0xffffffff, 0xffffffff
mask1: dd 0xffff0000, 0x00000000, 0x00000000, 0x00000000
mask2: dd 0x0000ffff, 0x00000000, 0x00000000, 0x00000000
mask3: dd 0xffffffff, 0x00000000, 0x00000000, 0x00000000

a: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

section .text

asmSobel:
	doEnter

	

sigue:
	mov	edi, SRC
	mov	edi, [edi + IMAGE_DATA]

	mov	esi, DST
	mov	esi, [esi + IMAGE_DATA]

	mov	ebx, HEIGHT
	sub 	ebx, 2
	mov	edx, WIDTH
	mov	eax, edx
	sar	edx, 3
; 	sar	edx, 4
	mov	ecx, edx
	movdqu	xmm0, [edi]
	movdqu	xmm1, xmm0
	psllq	xmm1, 2
	pxor	xmm6, xmm6

ciclo_x:
	movdqu	xmm0, [edi + eax]
	pxor	xmm1, xmm1
	pxor	xmm2, xmm2
	punpcklbw xmm1, xmm0
	punpckhbw xmm2, xmm0
	pslldq	xmm0, 2
	pxor	xmm3, xmm3
	pxor	xmm4, xmm4
	punpcklbw xmm3, xmm0
	punpckhbw xmm4, xmm0

	movdqu	xmm5, [dos]
	movdqu	xmm0, [menos_dos]

	pmullw	xmm1, xmm5
	pmullw	xmm2, xmm5
	pmullw	xmm3, xmm0
	pmullw	xmm4, xmm0

	packuswb xmm1, xmm2
	packsswb xmm3, xmm4
	paddsb	xmm1, xmm3
	paddsb	xmm6, xmm1	;-> segunda fila hecha en xmm6

	;;;;;;;;;;;;;;;;;;

	movdqu	xmm0, [edi]
	pxor	xmm1, xmm1
	pxor	xmm2, xmm2
	punpcklbw xmm1, xmm0
	punpckhbw xmm2, xmm0
	pslldq	xmm0, 2
	pxor	xmm3, xmm3
	pxor	xmm4, xmm4
	punpcklbw xmm3, xmm0
	punpckhbw xmm4, xmm0

	movdqu	xmm5, [dos]
	movdqu	xmm0, [menos_dos]

	pmullw	xmm1, xmm5
	pmullw	xmm2, xmm5
	pmullw	xmm3, xmm0
	pmullw	xmm4, xmm0

	packuswb xmm1, xmm2
	packsswb xmm3, xmm4
	paddsb	xmm1, xmm3
	paddsb	xmm6, xmm1	;-> primer fila hecha en xmm6

	;;;;;;;;;;;;;;;;;;

	movdqu	xmm0, [edi + eax*2]
	pxor	xmm1, xmm1
	pxor	xmm2, xmm2
	punpcklbw xmm1, xmm0
	punpckhbw xmm2, xmm0
	pslldq	xmm0, 2
	pxor	xmm3, xmm3
	pxor	xmm4, xmm4
	punpcklbw xmm3, xmm0
	punpckhbw xmm4, xmm0

	movdqu	xmm5, [dos]
	movdqu	xmm0, [menos_dos]

	pmullw	xmm1, xmm5
	pmullw	xmm2, xmm5
	pmullw	xmm3, xmm0
	pmullw	xmm4, xmm0

	packuswb xmm1, xmm2
	packsswb xmm3, xmm4
	paddsb	xmm1, xmm3
	paddsb	xmm6, xmm1	;-> tercer fila hecha en xmm6
	
	;;;;;;;;;;;;;;;;;;

	movdqu	[esi], xmm6
; 	add	edi, 16
; 	add	esi, 16
	add	edi, 6
	add	esi, 6
	cmp	ecx, 0
	je	ciclo_y
	jmp	ciclo_x
ciclo_y:
	mov	ecx, edx
	dec	ebx
	cmp	ebx, 0
	jne ciclo_x

fin:
	doLeave 0, 1