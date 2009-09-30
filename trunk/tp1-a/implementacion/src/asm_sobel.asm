;void asmSobel(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/defines.inc"
%include "include/offset.inc"
%include "include/macros.mac"



%define SRC	[ebp + 8]
%define DST	[ebp + 12]
%define WIDTH 	[ebp + 16]
%define HEIGHT	[ebp + 20]
%define XORDER	[ebp + 24]
%define YORDER	[ebp + 28]

global asmSobel

section .data

section .text

asmSobel:
	doEnter
	
	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	cmp	edi,	3		;reviso que tenga al menos 3 pixeles de ancho
	jl	abort

	mov	esi,	HEIGHT		;esi registro para el height
	cmp	esi,	3		;reviso que tenga al menos 3 pixeles de alto
	jl	abort
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	ebx,	DST		;ebx registro para el pixel de destino
	mov	ebx,	[ebx + IMAGE_DATA]
	add	ebx,	edi		;salteo la primera linea
	inc	ebx			;salteo la primer columna
	
	;==========================
	; ESTO VALE SOLO PARA EL X DE SOBEL
	;==========================
	cicloY:
	  mov	edi,	WIDTH		;edi registro para el width	  
	  mov	edx,	edi		;guardo el WIDTH_ALIGNED en un temporal
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	ebx,	2

	  cicloX:
	      mov	eax,	[ecx]	;cargo cuatro pixeles en eax
	      add	eax,	[ecx + edi]	;sumo dos veces la segunda linea
	      add	eax,	[ecx + edi]
	      add	eax,	[ecx + edi * 2]	;sumo la tercera linea
	      and	eax,	0xF0F0	;acá se puede estar estropeando la saturacion
	      sar	eax,	4	;desplazo cuatro bits a derecha para permitir operaciones en 8 bits
	      and	dword [ebx],	0xFFF0	;voy a pasar la parte más baja de la doublew
	      add	[ebx],	al	;mando el pixel
	      sar	eax,	8	;muevo eax a la parte izquierda de la matriz
	      sub	[ebx],	al	;se la resto al pixel destino
	      inc	ecx
	      inc	ebx
	      dec edx
	      jnz cicloX
	  dec	esi
	  jnz	cicloY

	abort:
	doLeave 0, 1
