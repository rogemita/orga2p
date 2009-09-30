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

	cmp	dword HEIGHT,	3		;reviso que tenga al menos 3 pixeles de alto
	jl	abort
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]
	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna
	
	;==========================
	; ESTO VALE SOLO PARA EL X DE SOBEL
	;==========================
	cicloY:
	  mov	edi,	WIDTH		;edi registro para el width	  
	  mov	edx,	edi		;guardo el WIDTH_ALIGNED en un temporal
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX:
	      mov	eax,	[ecx]	;cargo cuatro pixeles en eax
	      and	eax,	0xFF00FF00	;paso a dos words empaquetadas
	      shr	eax,	8	;desplazo ocho bits a derecha para permitir operaciones en 8 bits
	      mov	ebx,	[ecx + edi]	;sumo dos veces la segunda linea
	      and	ebx,	0xFF00FF00	;paso a dos words empaquetadas
	      shr	ebx,	7	;desplazo siete bits a derecha para permitir operaciones en 8 bits
	      add	eax,	ebx
	      mov	ebx,	[ecx + edi * 2]	;sumo la tercera linea
	      and	ebx,	0xFF00FF00	;paso a dos words empaquetadas
	      shr	ebx,	8	;desplazo ocho bits a derecha para permitir operaciones en 8 bits
	      add	eax,	ebx
	      mov	ebx,	eax
	      shr	eax,	16	;muevo eax a la parte izquierda de la matriz
	      sub	ax,	bx	;se la resto al pixel destino
	      cmp	ax,	0x00FF
	      jg	sobresaturo
	      cmp	ax,	0x0000
	      jl	subsaturo
	      volver:

	      mov	[esi],	al	;mando el pixel
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX
	  dec	dword HEIGHT
	  jnz	cicloY

	abort:
	doLeave 0, 1

	      sobresaturo:
	      mov	eax,	0x000000FF
	      jmp	volver
	      subsaturo:
	      mov	eax,	0
	      jmp	volver