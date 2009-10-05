;void asmRoberts(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

%include "include/defines.inc"
%include "include/offset.inc"
%include "include/macros.mac"



%define SRC	[ebp + 8]
%define DST	[ebp + 12]
%define WIDTH 	[ebp + 16]
%define HEIGHT	[ebp + 20]
%define XORDER	[ebp + 24]
%define YORDER	[ebp + 28]
%define T_HEIGHT	[ebp - 4]

;=================
; doCorridaX
;=================
; Pinta una linea en horizontal de negro
; =================
%macro doCorridaX 0
	mov ebx,	edi
	%%corridaX:
		and byte [esi], bl
		inc esi		
		dec ebx
		jnz %%corridaX
%endmacro

global asmRoberts

section .data

section .text

asmRoberts:
	doEnter 1

	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	;=============================
	; limpiamos la imagen
	;=============================

	cicloYcls:
	 mov edx, edi
	  cicloXcls:
	      mov	dword [esi],	0	;mando el pixel
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloXcls
	  dec	dword T_HEIGHT
	  jnz	cicloYcls

	xRoberts:
	cmp dword XORDER, 0
	je	yRoberts
	;==========================
	; ROBERTS XORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	cicloY4:
	 mov edx, edi
	  sub	edx,	1		;le resto los pixeles laterales

	  inc	ecx			;sumo dos para llevar al primero de la linea siguiente
	  inc	esi

	  cicloX4:
	      mov	ax,	[ecx]	;cargo 4 pixeles en eax
	      and	ax,	0x00FF
	      
	      mov	bx,	[ecx + edi]	;sumo dos veces la segunda linea
	      shr	bx,	8	;desplazo 8 bits a derecha para permitir operaciones en 8 bits

	      sub	ax,	bx	;se la resto al pixel destino
	      cmp	ax,	0x00FF
	      jg	sobresaturo
	      cmp	ax,	0x0000
	      jl	subsaturo
	      volver:
	      add	[esi],	al	;mando el pixel
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX4
	  dec	dword T_HEIGHT
	  jnz	cicloY4

	yRoberts:

	cmp dword YORDER, 0
	je	pintaBordes
	;==========================
	; ROBERTS YORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	cicloY5:
	 mov edx, edi
	  sub	edx,	1		;le resto los pixeles laterales

	  inc	ecx			;sumo dos para llevar al primero de la linea siguiente
	  inc	esi	

	  cicloX5:
	  	  mov	bx,	[ecx]	;cargo la primera linea
		  shr	bx, 8 ;lo llevo a la parte menos significativa
		  
	      mov	ax,	[ecx + edi]		;cargo un pixel en eax
	      and	ax,	0x00FF	;paso a dos words empaquetadas
		  
	      sub	bx,	ax		;resto el  pixel
	      cmp	bx,	0x00FF
	      jg	sobresaturo2
	      cmp	bx,	0x0000
	      jl	subsaturo2
	      volver2:

	      add	[esi],	bl	;mando el pixel
	      noPintar2:
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX5
	  dec	dword T_HEIGHT
	  jnz	cicloY5	  

	pintaBordes:
	mov esi, DST		;esi registro para el pixel de destino
	mov esi, [esi + IMAGE_DATA]

	; pinta las columnas primera y última

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]

	mov ecx, HEIGHT
	mov ebx, WIDTH
	
	ciclo:
		cmp ecx, 0
		je abort
		mov byte [esi], 0x0
		mov eax, esi
		lea esi, [esi + ebx]
		mov byte [esi-1], 0
		mov esi, eax
		add esi, edi
		dec ecx
		jmp ciclo

	abort:
	doLeave 1, 1

	      sobresaturo:
	      mov	eax,	0x000000FF
	      jmp	volver
	      subsaturo:
	      mov	eax,	0
	      jmp	volver

	      sobresaturo2:
	      mov	ebx,	0x000000FF
	      jmp	volver2
	      subsaturo2:
	      mov	ebx,	0
	      jmp	volver2