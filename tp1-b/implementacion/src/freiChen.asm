%include "include/offset.inc"
%include "include/macros.mac"
%include "include/tp1bFreiChen.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]

global	asmFreiChen

section .text

asmFreiChen:
	doEnter RESERVED_BYTES


	xor	edx, edx
	mov	eax, SRC
	mov	eax, [eax + WIDTH_STEP]
	mov	ebx, STEP_X
	div	ebx
	mov	REMAINDER, edx		;consigo el resto del ancho respecto de 6

	mov	edi, SRC		;edi <-- *SRC
	mov	edi, [edi + IMAGE_DATA]
	
	mov	edx, SRC
	mov	edx, [edx + WIDTH_STEP]

	mov	esi, DST		;esi <-- *DST
	mov	esi, [esi + IMAGE_DATA]
	inc 	esi
	add	esi, edx		;esi apunta a la segunda fila segunda columna

	mov	ebx, HEIGHT		;va a ser mi variable de altura
	
	
	pcmpeqb	xmm0, xmm0		;creo el raiz de dos
	psrld	xmm0, 31
	pslld	xmm0, 1
	cvtdq2ps	xmm0, xmm0
	sqrtps	xmm0, xmm0
	movdq2q	mm7, xmm0
	
 	cargarRaiz2	xmm7

	mov	eax, XORDER

	cmp	eax, 0
	jne	procesaX	
	jmp	preProcesaY
procesaX:

cicloSX_y:
	xor	ecx, ecx
cicloSX_x:
 	pxor	xmm6, xmm6		;limpio A
	pxor	xmm7, xmm7		;limpio B

	xor	eax, eax		;offset de linea

	movdqu	xmm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movdqu	xmm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm4, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm5, [edi + eax]		
		
	mov	eax, esi

	;******************************
	; PROCESO LAS LINEAS QUE CARGUE
	;******************************
	freiChenX xmm0, xmm1, xmm2
	freiChenX xmm1, xmm2, xmm3
	freiChenX xmm2, xmm3, xmm4
	freiChenX xmm3, xmm4, xmm5


	add 	esi, STEP_X		
	add	edi, STEP_X
	add	ecx, STEP_X

	cmp	ecx, edx
	jl	cicloSX_x

	cmp	ebx, 4
	jg	procesaSX
	jmp	noProcesaSX
procesaSX:

	;******************************
	; PROCESO EL RESTO DE
	; LAS LINEAS QUE CARGUE
	;******************************

	sub	esi, 2
	sub	edi, 2

	xor	eax, eax		;offset de linea

	movdqu	xmm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movdqu	xmm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm4, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm5, [edi + eax]

	mov	eax, esi

	freiChenX xmm0, xmm1, xmm2, 1
	freiChenX xmm1, xmm2, xmm3, 1
	freiChenX xmm2, xmm3, xmm4, 1
	freiChenX xmm3, xmm4, xmm5, 1


	add	esi, 2
	add	edi, 2

noProcesaSX:
	mov	eax, REMAINDER

	sub	esi, eax
	sub	edi, eax

	mov	eax, edx
	add	eax, edx
	add	eax, edx
	add	esi, eax
	add	edi, eax	;esi debiera apuntar a la segunda columna de la fila
				;cuatro lugares mas abajo de la primera fila anterior
	sub	ebx, 4		;aca debo ver si me pase del area de la imagen y sino saltar
	cmp	ebx, 0
	jge	cicloSX_y		

preProcesaY:

	mov	eax, YORDER
	cmp	eax, 0
	jne	procesaY	
	jmp	fin


procesaY:
	xor	edx, edx
	mov	eax, SRC
	mov	eax, [eax + WIDTH_STEP]
	mov	ebx, STEP_Y
	div	ebx
	mov	REMAINDER, edx		;consigo el resto del ancho respecto de 6

	mov	edi, SRC		;edi <-- *SRC
	mov	edi, [edi + IMAGE_DATA]

	mov	edx, SRC
	mov	edx, [edx + WIDTH_STEP]
	
	mov	esi, DST		;esi <-- *DST
	mov	esi, [esi + IMAGE_DATA]
	inc 	esi
	add	esi, edx		;esi apunta a la segunda fila segunda columna

	mov	ebx, HEIGHT		;va a ser mi variable de altura

cicloSY_y:
	xor	ecx, ecx
cicloSY_x:
	xor	eax, eax		;offset de linea

	movdqu	xmm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movdqu	xmm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm4, [edi + eax]		
		
	mov	eax, esi

	;******************************
	; PROCESO LAS LINEAS QUE CARGUE
	;******************************
	freiChenY xmm2, xmm0
	freiChenY xmm3, xmm1
	freiChenY xmm4, xmm2

	add 	esi, STEP_Y		
	add	edi, STEP_Y
	add	ecx, STEP_Y

	cmp	ecx, edx
	jl	cicloSY_x

	cmp	ebx, 3
	jg	procesaSY
	jmp	noProcesaSY
procesaSY:


	;******************************
	; PROCESO EL RESTO DE
	; LAS LINEAS QUE CARGUE
	;******************************

	sub	esi, 2
	sub	edi, 2

	xor	eax, eax		;offset de linea

	movdqu	xmm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movdqu	xmm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movdqu	xmm4, [edi + eax]		
		
	mov	eax, esi

	freiChenY xmm2, xmm0
	freiChenY xmm3, xmm1
	freiChenY xmm4, xmm2

	add	esi, 2
	add	edi, 2

noProcesaSY:
	mov	eax, REMAINDER

	sub	esi, eax
	sub	edi, eax

	mov	eax, edx
	add	eax, edx
	add	esi, eax
	add	edi, eax	;esi debiera apuntar a la segunda columna de la fila
				;cuatro lugares mas abajo de la primera fila anterior
	sub	ebx, 3		;aca debo ver si me pase del area de la imagen y sino saltar
	cmp	ebx, 0
	jge	cicloSY_y		

fin:
	doLeave RESERVED_BYTES, 1
	;freiChen