;void asmPrewitt(const char* src, char* dst, int ancho, int alto, int xorder, int yorder)

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

global asmPrewitt

section .data

section .text

asmPrewitt:
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


	cmp dword XORDER, 0
	je	yPrewitt

	xPrewitt:
	;==========================
	; PEWRITT XORDER
	;==========================
	mov eax, HEIGHT
	mov dword T_HEIGHT, eax

	mov	ecx,	SRC		;ecx registro para el pixel de origen
	mov	ecx,	[ecx + IMAGE_DATA]

	mov	esi,	DST		;esi registro para el pixel de destino
	mov	esi,	[esi + IMAGE_DATA]

	add	esi,	edi		;salteo la primera linea
	inc	esi			;salteo la primer columna

	cicloY6:
	 mov edx, edi
	  sub	edx,	2		;le resto los pixeles laterales

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
	      jle	noSobreSaturo
	      jmp	sobresaturo6
	      noSobreSaturo:
	      cmp	ax,	0x0000
	      jge	volver6
	      jmp	subsaturo6
	      volver6:

	      add	[esi],	al	;mando el pixel
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX6

	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2
	  dec	dword T_HEIGHT
	  jnz	cicloY6

	yPrewitt:

	cmp dword YORDER, 0
	jne	sigueYPrewitt
	jmp	pintaBordes
	sigueYPrewitt:
	;==========================
	; PREWITT YORDER
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

	      or	[esi],	bl	;mando el pixel
	      noPintar7:
	      inc	ecx
	      inc	esi
	      dec edx
	      jnz cicloX7
	  add	ecx,	2		;sumo dos para llevar al primero de la linea siguiente
	  add	esi,	2
	  dec	dword T_HEIGHT
	  jnz	cicloY7
	  
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