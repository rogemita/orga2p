;void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/offset.inc"
%include "include/macros.mac"
%include "include/tp1b.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]
%define REMAINDER	[ebp - 4]
%define MASK_LO		[ebp - 12]
%define MASK_HI		[ebp - 8]
%define	STEP_X		6
%define	STEP_Y		6
%define RESERVED_BYTES	12


global	asmSobel

section .text

asmSobel:
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
	;mov	edx, WIDTH		;edx <-- WIDTH

	mov	esi, DST		;esi <-- *DST
	mov	esi, [esi + IMAGE_DATA]
	inc 	esi
	add	esi, edx		;esi apunta a la segunda fila segunda columna

	mov	ebx, HEIGHT		;va a ser mi variable de altura

sobelX:

cicloSX_y:
	xor	ecx, ecx
cicloSX_x:
 	pxor	mm6, mm6		;limpio A
	pxor	mm7, mm7		;limpio B

	xor	eax, eax		;offset de linea

	movq	mm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movq	mm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm4, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm5, [edi + eax]		
		
	mov	eax, esi

	;******************************
	; PROCESO LAS LINEAS QUE CARGUE
	;******************************
	sobelPrewittX mm0, mm1, mm2, 0
	sobelPrewittX mm1, mm2, mm3, 0
	sobelPrewittX mm2, mm3, mm4, 0
	sobelPrewittX mm3, mm4, mm5, 0

	add 	esi, STEP_X		
	add	edi, STEP_X
	add	ecx, STEP_X

	cmp	ecx, edx
	jl	cicloSX_x

	cmp	ebx, 4
	jle	noProcesaSX


	;******************************
	; PROCESO EL RESTO DE
	; LAS LINEAS QUE CARGUE
	;******************************

	sub	esi, 2
	sub	edi, 2

	xor	eax, eax		;offset de linea

	movq	mm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movq	mm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm4, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm5, [edi + eax]

	mov	eax, esi

	sobelPrewittX mm0, mm1, mm2, 0, 1
	sobelPrewittX mm1, mm2, mm3, 0, 1
	sobelPrewittX mm2, mm3, mm4, 0, 1
	sobelPrewittX mm3, mm4, mm5, 0, 1

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

sobelY:
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

	pxor	mm7, mm7		;limpio B
	mov	dword MASK_LO, 0x00FF0000	;OJO ACA que estoy borrando este byte por el tema del or a destino para no procesar basura
	mov	dword MASK_HI, 0x00FF00FF

cicloSY_y:
	xor	ecx, ecx
cicloSY_x:
	movq	mm7, MASK_LO

	xor	eax, eax		;offset de linea

	movq	mm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movq	mm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm4, [edi + eax]		
		
	mov	eax, esi

	;******************************
	; PROCESO LAS LINEAS QUE CARGUE
	;******************************
	sobelPrewittY mm0, mm2
	sobelPrewittY mm1, mm3
	sobelPrewittY mm2, mm4

	add 	esi, STEP_Y		
	add	edi, STEP_Y
	add	ecx, STEP_Y

	cmp	ecx, edx
	jl	cicloSY_x

	cmp	ebx, 3
	jle	noProcesaSY


	;******************************
	; PROCESO EL RESTO DE
	; LAS LINEAS QUE CARGUE
	;******************************

	sub	esi, 2
	sub	edi, 2

	xor	eax, eax		;offset de linea

	movq	mm0, [edi]		;cargo las seis lineas correspondientes
	add	eax, edx		;salto una linea
	movq	mm1, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm2, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm3, [edi + eax]		
	add	eax, edx		;salto una linea
	movq	mm4, [edi + eax]		
		
	mov	eax, esi

	sobelPrewittY mm0, mm2
	sobelPrewittY mm1, mm3
	sobelPrewittY mm2, mm4

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