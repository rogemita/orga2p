;void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/offset.inc"
%include "include/macros.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]

%macro	sobelX 3
	;**************************
	; VOY A APLICAR EL OPERADOR
	; EN LA PARTE BAJA
	;**************************
	pxor		mm6, mm6
	pxor		mm7, mm7
	punpcklbw	mm6, %2		;paso a word en A la segunda linea
	psllw		mm6, 1		;multiplico por dos
	punpcklbw	mm7, %1 	;paso a word en B la primera linea
	paddsw		mm6, mm7	;sumo saturado
	punpcklbw	mm7, %3		;paso a word en B la tercera linea
	paddsw		mm6, mm7	;sumo saturado
	movq		mm7, %2		;copio en B la segunda linea
	psrlq		mm7, 16		;desplazo para sumar las columnas de izquierda y derecha
	punpcklbw	mm7, mm7	;lo paso a word tomando para la parte alta los ceros
					;que quedaron al desplazar
	psllw		mm7, 1		;multiplico por dos
	psubsw		mm6, mm7	;resto la primera columna
	movq		mm7, %1		;hago lo propio con la primera linea
	psrlq		mm7, 16
	punpcklbw	mm7, mm7
	psubsw		mm6, mm7
	movq		mm7, %3		;y con la tercera linea
	psrlq		mm7, 16
	punpcklbw	mm7, mm7
	psubsw		mm6, mm7

	
	;**************************
	; VOY A APLICAR EL OPERADOR
	; EN LA PARTE ALTA
	;**************************	
	pxor		mm6, mm6
	pxor		mm7, mm7
	punpckhbw	mm6, %2		;paso a word en A la segunda linea
	psllw		mm6, 1		;multiplico por dos
	punpckhbw	mm7, %1 	;paso a word en B la primera linea
	paddsw		mm6, mm7	;sumo saturado
	punpckhbw	mm7, %3		;paso a word en B la tercera linea
	paddsw		mm6, mm7	;sumo saturado
	movq		mm7, %2		;copio en B la segunda linea
	psrlq		mm7, 80		;desplazo para sumar las columnas de izquierda y derecha
	punpcklbw	mm7, mm7	;lo paso a word tomando para la parte alta los ceros
					;que quedaron al desplazar
	psllw		mm7, 1		;multiplico por dos
	psubsw		mm6, mm7	;resto la primera columna
	movq		mm7, %1		;hago lo propio con la primera linea
	psrlq		mm7, 80
	punpcklbw	mm7, mm7
	psubsw		mm6, mm7
	movq		mm7, %3		;y con la tercera linea
	psrlq		mm7, 80
	punpcklbw	mm7, mm7
	psubsw		mm6, mm7	

	;************************
	; TERMINE COPIO A DESTINO
	;************************
	pxor		mm7, mm7
	packsswb	mm6, mm7
	movq		[eax], mm6	;copio los 8 bytes al destino de los cuales 6 son validos
	add		eax, edx	;salto la linea siguiente

%endmacro

global	asmSobel

section .text

asmSobel:
	doEnter

	mov	edi, SRC		;edi <-- *SRC
	mov	edi, [edi + IMAGE_DATA]
	
	mov	edx, WIDTH		;edx <-- WIDTH

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
	mov	eax, edx
	sub	eax, 8		;voy a ver si puedo seguir levantando de fuente o me paso 
	cmp	ecx, eax	; de mi memoria
	jle	ciclo_x

	sub	ecx, 6		;voy a sumar el resto en esi de los pixeles no procesados
	mov	eax, WIDTH	;con lo que debiera llegar a la primera columna de la siguiente fila
	sub	eax, ecx
	add	esi, eax	
	inc	esi
	add	esi, edx
	add	esi, edx
	add	esi, edx	;esi debiera apuntar a la segunda columna de la fila
				;cuatro lugares mas abajo de la primera fila anterior
	mov	eax, WIDTH
	shr	eax, 2
	add	edx, eax	;desplazo a 

	sub	ebx, 4		;aca debo ver si me pase del area de la imagen y sino saltar
	cmp	ebx, 0
	jge	ciclo_y		

fin:
	doLeave 0, 1