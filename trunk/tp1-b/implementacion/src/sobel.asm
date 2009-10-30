;void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/offset.inc"
%include "include/macros.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]
%define REMAINDER	[ebp - 4]

%macro obtenerBajo 2-3 0
	movq		%1, %2		;copio el dato
%if %3 != 0
	psrlq		%1, %3		;desplazo dos columnas
%endif
	punpcklbw	%1, %1		;desempaqueto la parte baja
	psllw		%1, 8		;retiro el excedente alto
	psrlw		%1, 8
%endmacro

%macro obtenerAlto 2-3 0
	movq		%1, %2		;copio el dato
%if %3 != 0
	psrlq		%1, %3		;desplazo dos columnas
%endif
	punpckhbw	%1, %1		;desempaqueto la parte baja
	psllw		%1, 8		;retiro el excedente alto
	psrlw		%1, 8
%endmacro      



%macro	sobelX 3
	;**************************
	; VOY A APLICAR EL OPERADOR
	; EN LA PARTE BAJA
	;**************************
	obtenerBajo	mm6, %2		;obtengo los bajos de la segunda fila
	psllw		mm6, 1		;multiplico por dos

	obtenerBajo	mm7, %1		;obtengo los bajos de la primera fila
	paddusw		mm6, mm7	;sumo saturado
	obtenerBajo	mm7, %3		;obtengo los bajos de la tercera fila
	paddusw		mm6, mm7	;sumo saturado

	obtenerBajo	mm7, %2, 16	;obtengo los bajos de la segunda fila
	psllw		mm7, 1		;multiplico por dos
	psubusw		mm6, mm7

	obtenerBajo	mm7, %1, 16	;obtengo los bajos de la primera fila
	psubusw		mm6, mm7	;sumo saturado
	obtenerBajo	mm7, %3, 16	;obtengo los bajos de la tercera fila
	psubusw		mm6, mm7	;sumo saturado

	;************************
	; TERMINE COPIO A DESTINO
	;************************
	packsswb	mm6, mm6
	movq		[eax], mm6	;copio los 8 bytes al destino de los cuales 6 son validos
	add		eax, 4	;salto la linea siguiente
	
	;**************************
	; VOY A APLICAR EL OPERADOR
	; EN LA PARTE ALTA
	;**************************	
	obtenerAlto	mm6, %2		;obtengo los bajos de la segunda fila
	psllw		mm6, 1		;multiplico por dos

	obtenerAlto	mm7, %1		;obtengo los bajos de la primera fila
	paddusw		mm6, mm7	;sumo saturado
	obtenerAlto	mm7, %3		;obtengo los bajos de la tercera fila
	paddusw		mm6, mm7	;sumo saturado

	obtenerAlto	mm7, %2, 16	;obtengo los bajos de la segunda fila
	psllw		mm7, 1		;multiplico por dos
	psubusw		mm6, mm7

	obtenerAlto	mm7, %1, 16	;obtengo los bajos de la primera fila
	psubusw		mm6, mm7	;sumo saturado
	obtenerAlto	mm7, %3, 16	;obtengo los bajos de la tercera fila
	psubusw		mm6, mm7	;sumo saturado

	;************************
	; TERMINE COPIO A DESTINO
	;************************
	;pxor		mm7, mm7
	packsswb	mm6, mm6
	;psllq		mm6, 32
	;psrlq		mm6, 32
	movq		[eax], mm6	;copio los 8 bytes al destino de los cuales 6 son validos
	sub		eax, 4
	add		eax, edx	;salto la linea siguiente

%endmacro

global	asmSobel

section .text

asmSobel:
	doEnter 4

	xor	edx, edx
	mov	eax, SRC
	mov	eax, [eax + WIDTH_STEP]
	mov	ebx, 6
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


ciclo_y:
	xor	ecx, ecx
ciclo_x:
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
	sobelX mm0, mm1, mm2
	sobelX mm1, mm2, mm3
	sobelX mm2, mm3, mm4
	sobelX mm3, mm4, mm5

	add 	esi, 6		
	add	edi, 6
	add	ecx, 6
	cmp	ecx, edx
	jl	ciclo_x

	mov	eax, REMAINDER

	sub	esi, eax
	sub	edi, eax
	;sub	ecx, 6		;voy a sumar el resto en esi de los pixeles no procesados
	;mov	eax, edx	;con lo que debiera llegar a la primera columna de la siguiente fila
	;sub	eax, ecx
	;add	esi, eax
	;add	edi, eax
	;sub	esi, 5
	;sub	edi, 5
	mov	eax, edx
	add	eax, edx
	add	eax, edx
	add	esi, eax
	add	edi, eax	;esi debiera apuntar a la segunda columna de la fila
				;cuatro lugares mas abajo de la primera fila anterior
	sub	ebx, 4		;aca debo ver si me pase del area de la imagen y sino saltar
	cmp	ebx, 0
	jge	ciclo_y		

fin:
	doLeave 4, 1