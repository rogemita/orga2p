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

global asmSobel

section .data

section .text

asmSobel:
	doEnter 1
	
	cmp dword XORDER, 0
	je	ySobel

	xSobel:
	;==========================
	; SOBEL XORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna

	cicloY:
	 mov edx, edi
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX:
	      mov	eax,	[ecx]	;cargo cuatro pixeles en eax
	      and	eax,	0x00FF00FF	;paso a dos words empaquetadas
	      ;shr	eax,8	;desplazo ocho bits a derecha para permitir operaciones en 8 bits
	      mov	ebx,	[ecx + edi]	;sumo dos veces la segunda linea
	      and	ebx,	0x00FF00FF	;paso a dos words empaquetadas
	      shl	ebx,1	;desplazo siete bits a derecha para permitir operaciones en 8 bits
	      add	eax,	ebx
	      mov	ebx,	[ecx + edi * 2]	;sumo la tercera linea
	      and	ebx,	0x00FF00FF	;paso a dos words empaquetadas
	      ;shr	ebx,	8	;desplazo ocho bits a derecha para permitir operaciones en 8 bits
	      add	eax,	ebx
	      mov	ebx,	eax
	      shr	eax,	16	;muevo eax a la parte izquierda de la matriz
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
	      jnz cicloX
	  dec	dword T_HEIGHT
	  jnz	cicloY
	jmp pintaBordes

	ySobel:

	cmp dword YORDER, 0
	je	pintaBordes
	;==========================
	; SOBEL YORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna

	cicloY2:
	 mov edx, edi
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX2:
	      mov	eax,	[ecx + edi * 2]		;cargo cuatro pixeles en eax
	      mov	ebx,	eax		;copio a ebx
	      and	eax,	0x00FF00FF	;paso a dos words empaquetadas
	      and	ebx,	0x0000FF00	;hago lo mismo con el pixel del medio
	      shr	ebx,	7
	      add	bx,	ax		;acumulo el primero con el segundo
	      and	ebx,	0x0000FFFF
	      shr	eax,	16
	      add	bx,	ax		;ya acumulamos los primeros en bx

	      mov	eax,	[ecx]	;cargo la tercera linea
	      and	eax,	0x00FFFFFF
	      ror	eax,	16		;paso la parte izq a der i.e. me queda el primer pixel en ax en una word
	      sub	bx,	ax		;resto el primer pixel
	      xor	ax,	ax		;borro la parte baja me quedan los otros dos arriba
	      or	ebx,	eax		;paso la parte alta de eax a ebx como contenedor temporal queda: px2 px3 \ acum
	      shr	eax,	16		;bajo los dos pixeles altos
	      and	eax,	0x000000FF	;me quedo con el tercer pixel
	      sub	bx,	ax		;resto el tercer pixel
	      mov	eax,	ebx		;voy a recuperar el segundo pixel
	      and	eax,	0xFF000000
	      shr	eax,	23		;lo paso a derecha multiplicado por dos
	      sub	bx,	ax		;resto el segundo pixel
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
	      jnz cicloX2
	  dec	dword T_HEIGHT
	  jnz	cicloY2
	  
	  

	  
	  
	  
	  
	  
	  
	xRoberts:
	;==========================
	; ROBERTS XORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]


	cicloY4:
	 mov edx, edi
	  sub	edx,	1		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX4:
	      mov	al,	[ecx]	;cargo 2 pixeles en eax
	      
	      mov	bx,	[ecx + edi]	;sumo dos veces la segunda linea
	      and	bx,	0xFF00	;paso a word empaquetada
	      shr	bx, 8	;desplazo 8 bits a derecha para permitir operaciones en 8 bits

	      sub	al,	bl	;se la resto al pixel destino
	      cmp	al,	0xFF
	      jg	sobresaturo4
	      cmp	al,	0x00
	      jl	subsaturo4
	      volver4:

	      add	[esi],	al	;mando el pixel
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX4
	  dec	dword T_HEIGHT
	  jnz	cicloY4
	jmp pintaBordes

	yRoberts:

	cmp dword YORDER, 0
	je	pintaBordes
	;==========================
	; SOBEL YORDER
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
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX5:
	  	  mov	bx,	[ecx]	;cargo la primera linea
	      and	bx,	0xFF00
		  shr	bx, 8 ;lo llevo a la parte menos significativa
		  
	      mov	al,	[ecx + edi]		;cargo un pixel en eax
	      and	al,	0xFF	;paso a dos words empaquetadas
		  
	      sub	bl,	al		;resto el  pixel
	      cmp	bl,	0xFF
	      jg	sobresaturo5
	      cmp	bl,	0x00
	      jl	subsaturo5
	      volver5:

	      add	[esi],	bl	;mando el pixel
	      noPintar5:
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX5
	  dec	dword T_HEIGHT
	  jnz	cicloY5	  
	  
	  
	  
	  
	  
	  
	  
	cmp dword XORDER, 0
	je	yPrewitt

	xPrewitt:
	;==========================
	; PEWRITT XORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna

	cicloY6:
	 mov edx, edi
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX6:
	      mov	eax,	[ecx]	;cargo cuatro pixeles en eax
	      and	eax,	0x00FF00FF	;paso a dos words empaquetadas
	      ;shr	eax,8	;desplazo ocho bits a derecha para permitir operaciones en 8 bits
	      mov	ebx,	[ecx + edi]	;sumo dos veces la segunda linea
	      and	ebx,	0x00FF00FF	;paso a dos words empaquetadas
	     ;shl	ebx,1	;desplazo siete bits a derecha para permitir operaciones en 8 bits
	      add	eax,	ebx
	      mov	ebx,	[ecx + edi * 2]	;sumo la tercera linea
	      and	ebx,	0x00FF00FF	;paso a dos words empaquetadas
	      ;shr	ebx,	8	;desplazo ocho bits a derecha para permitir operaciones en 8 bits
	      add	eax,	ebx
	      mov	ebx,	eax
	      shr	eax,	16	;muevo eax a la parte izquierda de la matriz
	      sub	ax,	bx	;se la resto al pixel destino
	      cmp	ax,	0x00FF
	      jg	sobresaturo6
	      cmp	ax,	0x0000
	      jl	subsaturo6
	      volver6:

	      add	[esi],	al	;mando el pixel
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX6
	  dec	dword T_HEIGHT
	  jnz	cicloY6
	jmp pintaBordes

	yPrewitt:

	cmp dword YORDER, 0
	je	pintaBordes
	;==========================
	; SOBEL YORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna

	cicloY7:
	 mov edx, edi
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX7:
	      mov	eax,	[ecx + edi * 2]		;cargo cuatro pixeles en eax
	      mov	ebx,	eax		;copio a ebx
	      and	eax,	0x00FF00FF	;paso a dos words empaquetadas
	      and	ebx,	0x0000FF00	;hago lo mismo con el pixel del medio
	      shr	ebx,	8
	      add	bx,	ax		;acumulo el primero con el segundo
	      and	ebx,	0x0000FFFF
	      shr	eax,	16
	      add	bx,	ax		;ya acumulamos los primeros en bx

	      mov	eax,	[ecx]	;cargo la tercera linea
	      and	eax,	0x00FFFFFF
	      ror	eax,	16		;paso la parte izq a der i.e. me queda el primer pixel en ax en una word
	      sub	bx,	ax		;resto el primer pixel
	      xor	ax,	ax		;borro la parte baja me quedan los otros dos arriba
	      or	ebx,	eax		;paso la parte alta de eax a ebx como contenedor temporal queda: px2 px3 \ acum
	      shr	eax,	16		;bajo los dos pixeles altos
	      and	eax,	0x000000FF	;me quedo con el tercer pixel
	      sub	bx,	ax		;resto el tercer pixel
	      mov	eax,	ebx		;voy a recuperar el segundo pixel
	      and	eax,	0xFF000000
	      shr	eax,	24		;lo paso a derecha multiplicado por dos
	      sub	bx,	ax		;resto el segundo pixel
	      cmp	bx,	0x00FF
	      jg	sobresaturo7
	      cmp	bx,	0x0000
	      jl	subsaturo7
	      volver7:

	      add	[esi],	bl	;mando el pixel
	      noPintar7:
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX7
	  dec	dword T_HEIGHT
	  jnz	cicloY7
	  
	  
	  
	  
	  
	  

	;==========================
	; TRESHOLD
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	edx,	SRC
	mov	edi,	[edx + WIDTH_STEP]
	
	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna

	cicloY3:
	 mov edx, edi
	  sub	edx,	2		;le resto los pixeles laterales

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2

	  cicloX3:
	      cmp	byte [esi], 	0xF0
	      jge	seguirTreshold

	      mov	byte [esi],	0	;mato el pixel
	      seguirTreshold:
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX3
	  dec	dword T_HEIGHT
	  jnz	cicloY3

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
		
	      sobresaturo4:
	      mov	al,	0xFF
	      jmp	volver4
	      subsaturo4:
	      mov	al,	0
	      jmp	volver4

	      sobresaturo5:
	      mov	bl,	0x000000FF
	      jmp	volver5
	      subsaturo5:
	      mov	bl,	0
	      jmp	volver5
	
	      sobresaturo6:
	      mov	al,	0xFF
	      jmp	volver6
	      subsaturo6:
	      mov	al,	0
	      jmp	volver6

	      sobresaturo7:
	      mov	bl,	0xFF
	      jmp	volver7
	      subsaturo7:
	      mov	bl,	0
	      jmp	volver7