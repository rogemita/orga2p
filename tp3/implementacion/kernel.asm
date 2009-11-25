BITS 16

%include "macrosmodoreal.mac"
%include "macrosmodoprotegido.mac"

global start
extern GDT_DESC		; puntero al descriptor de gdt
extern gdt;		; puntero a la gdt
extern IDT_DESC		; puntero al descriptor de la idt
extern idt		; puntero a la idt
extern idtFill		; metodo para iniciar descriptores de la idt
extern tsss;		; puntero a la tsss = arreglo de datos tss 


start:

jmp inicio	
nombre_grupo:		db 'Orga 2 POPA'
nombre_grupo_len	equ $ - nombre_grupo		

;|**************************************************************************************|
;|				- EJERCICIO 1 -						|
;|	1-Se deshabilitan las interrupciones hasta que se inicialize			|
;|		una IDT con sus rutinas respectivas de atencion				|
;|	2-enable_A20 = activacion del pin 20						|
;|		SI (Checkeo del pin A20): continuar SINO llamar a enable_A20		|
;|		Se carga el descriptor de gdt en el registro gdtr (base|limite)		|
;|	3-En el cr0 se habilita el bit de modo protegido, bit 0				|
;|	4-Se utiliza un jmp far para pasar a modo protegido				|
;|		usando 0x08 como selector de gdt, asi cs vale 0x08 de a partir de ahora	|
;|		ahora cs pasa a ser un selector de seg. y se interpreta de esta forma:	|
;|		0x08 = [ index=0000000000001 | TI=0 (GDT)| RPL=00 (maximo privilegio)]	|
;|		segundo descriptor de segmento de la gdt, perteneciente al segmento	|
;|		de codigo:								|
;|	**************************************************************************	|
;|	*|base 31:24|G|D/B|L|AVL|Seg.Limit 19:16|P|DPL (2)|S|TYPE (4)|base 23:16|*	|
;|	*|   0x00   |1| 1 |0| 0 |	0xF	|1|  00   |1|  0xA   |    00    |* 	|
;|	*|----------------------------------------------------------------------|*	|
;|	*|base 15:00				|Seg. limit 15:00		|*	|
;|	*|0x0000				|0xFFFF				|*	|
;|	**************************************************************************	|
;|	5-Una vez pasado a modo protegido: se inicializan los selectores de segmentos	|
;|		de datos con el selector de gdt:					|
;|		0x10 = [ index=0000000000010 | TI=0 (GDT)| RPL=00 (maximo privilegio)]	|
;|		con el descriptor de datos:						|
;|	**************************************************************************	|
;|	*|base 31:24|G|D/B|L|AVL|Seg.Limit 19:16|P|DPL (2)|S|TYPE (4)|base 23:16|*	|
;|	*|   0x00   |1| 1 |0| 0 |	0xF	|1|  00   |1|  0x2   |    00    |* 	|
;|	*|----------------------------------------------------------------------|*	|
;|	*|base 15:00				|Seg. limit 15:00		|*	|
;|	*|0x0000				|0xFFFF				|*	|
;|	**************************************************************************	|
;|	6-Al registro ES momentaneamente lo cargamos con el tercer descriptor de la gdt:|
;|		0x18 = [ index=0000000000010 | TI=0 (GDT)| RPL=00 (maximo privilegio)]	|
;|		este descriptor contiene un segmento solo destinado para la matriz	|
;|		de video, mapeada desde 0xB8000 de memoria, size=80*25*2bytes		|
;|	**************************************************************************	|
;|	*|base 31:24|G|D/B|L|AVL|Seg.Limit 19:16|P|DPL (2)|S|TYPE (4)|base 23:16|*	|
;|	*|   0x00   |0| 1 |0| 0 |	0x0	|1|  00   |1|  0x2   |    0B    |* 	|
;|	*|----------------------------------------------------------------------|*	|
;|	*|base 15:00				|Seg. limit 15:00		|*	|
;|	*|0x8000				|0x0F9F				|*	|
;|	**************************************************************************	|
;|		se limpia la pantalla colocando caracter vacio de fondo negro (ax=0x00)	|
;|		usando la funcion stosw ( [es:edi] = ax ).				|
;|		De la misma forma se recorre la matriz colocando solo en los bordes	|
;|		un caracter deseado, armando asi un recuadro como pide el enunciado 1.c.|
;|											|
;|**************************************************************************************|

inicio:
	; 1
	cli
	
	; 2
	call check_A20	
 	cmp ax, 1
 	je continuar
	call enable_A20	

continuar:
	lgdt		[GDT_DESC]

	; 3
	mov		eax, cr0
	or		eax, 01h
	mov		cr0, eax
	
	; 4
	jmp		0x08:modo_protegido

	; 5
BITS 32	; ahora trabajando con 32 bits
modo_protegido:
	mov	ax, 0x10	; segmento de datos
	mov	ds, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	; 6
	mov	ax, 0x18	; segmento de memoria de video
	mov	es, ax
	xor	edi, edi
	mov	ecx, (80*25)
	xor eax, eax

limpiar_pantalla:
	stosw
	loop limpiar_pantalla

	xor	edi, edi
	mov	ax, 0xbefe
	mov	ecx, 80

primer_fila:
	stosw
	loop	primer_fila

	mov ecx, 25-2

medio:
	mov	[es:edi], ax
	add	edi, (80-1)*2
	mov	[es:edi], ax
	inc	edi
	inc	edi
	loop	medio

	mov	ecx, 80

ultima_fila:
	stosw
	loop	ultima_fila

	mov	ax, 0x10
	mov	es, ax		; doy el segmento de datos a es como el resto

	;stosw -> escribe lo que esta en ax en [es:edi] y ademas aumenta edi en 2 bytes

;|**************************************************************************************|
;|				- EJERCICIO 2 -						|
;|	la definicion de directorios y tablas de paginas se encuentra en la etiqueta:	|
;|		inicializacion_directorios_y_tablas_de_paginas				|
;|	1-En cr3 se guarda la posicion donde comienza el directorio de tablas de paginas|
;|		perteneciente al kernel (directorio que comparte con el traductor).	|
;|		El P.D. tiene una entry para apuntar a una primer tabla de paginas:	|
;|		info tab:								|
;|		CR3 = 0x000B000								|
;|		0x00000000-0x00007fff -> 0x00000000-0x00007fff				|
;|		0x00009000-0x00010fff -> 0x00009000-0x00010fff				|
;|		0x00013000-0x00013fff -> 0x000b8000-0x000b8fff				|
;|		0x00016000-0x00016fff -> 0x00016000-0x00016fff				|
;|		0x00018000-0x00018fff -> 0x000b8000-0x000b8fff				|
;|		0x000a0000-0x000bffff -> 0x000a0000-0x000bffff				|
;|		------------------------------------------------			|
;|		El directorio de tablas de paginas de la tarea pintor:			|
;|		info tab:								|
;|		CR3 = 0x000A000								|
;|		primer tabla de paginas:						|
;|		0x00000000-0x00008fff -> 0x00000000-0x00008fff				|
;|		0x0000e000-0x0000ffff -> 0x0000e000-0x0000ffff				|
;|		0x00013000-0x00013fff -> 0x000b8000-0x000b8fff				|
;|		0x00015000-0x00015fff -> 0x00015000-0x00015fff				|
;|		0x000b8000-0x000b8fff -> 0x00010000-0x00010fff				|
;|	2-Habilito paginacion seteando el ultimo bit de cr0				|
;|	3-Imprimimos el nombre del grupo como indica el enunciado			|
;|											|
;|**************************************************************************************|

		;habilitando paginacion	
	; 1
	mov eax, 0x0000B000		;cargo la direccion del directorio de paginas en cr3
	mov cr3, eax

	; 2
	mov eax, cr0				
	or  eax, 0x80000000		;habilito paginacion
	mov cr0, eax

	; 3
	IMPRIMIR_TEXTO nombre_grupo, nombre_grupo_len, 0xbe, 1, 10, 0x13000
	; direccion 0x13000 mapeada a memoria de video

;|**************************************************************************************|
;|				- EJERCICIO 3 -						|
;|	1-Se completan las entries en la idt con las rutinas de atencion, las cuales	|
;|		se encuentran implementadas en isr.asm					|
;|	2-Coloco en el registro de idt el descriptor de idt				|
;|	3-Llamo a las rutinas para resetear el pic y para habilitarlo			|
;|	4-Por ultimo con la idt completada y sus correspondientes rutinas se habilitan	|
;|		las interrupciones ya que estas pueden ser atendidas ahora		|
;|											|
;|**************************************************************************************|

	; 1
	call	idtFill		; inicializa la idt

	; 2
	lidt [IDT_DESC]		; carga en el registro idtr el descriptor de idt

	; 3
	call	pic_reset	; reset del pic
	call	pic_enable	; activacion del pic

	; 4
	sti			; habilitacion de interrupciones

;|**************************************************************************************|
;|				- Algunos defines -					|
;|**************************************************************************************|

%define TASK1INIT	0x8000	; inicio tarea pintor
%define TASK2INIT	0x9000	; inicio tarea traductor
%define PDPINTOR	0xA000	; page directory de pintor
%define PDTRADU		0xB000	; page directory de traductor y kernel
%define PTPINTOR	0xC000	; tabla de paginas de pintor
%define PTTRADK		0xD000	; tabla de paginas de traductor y kernel
%define STACKTR		0x16000	; pila del traductor
%define STACKPT		0x15000	; pila del pintor 
%define KORG		0x1200	; comienzo del codigo de kernel

;|**************************************************************************************|
;|				- EJERCICIO 4 -						|
;|	1-Se colocan 3 descriptores de tss en la gdt:					|
;|		*descriptor de la tss de la tarea del kernel: Esta tss se usa solo para |
;|		el primer cambio de tarea, se encuentra la tss vacia para completarse.	|
;|		tss[0] = contexto actual (kernel)					|
;|		*descriptor de la tss de la tarea del traductor: 			|
;|		tss[1] = contexto del traductor: se completa dinamicamente (**)		|
;|		*descriptor de la tss de la tarea del pintor: 				|
;|		tss[2] = contexto del pintor: se completa dinamicamente (***)		|
;|		Los 3 descriptores son de este estilo, con sus respectivas bases	|
;|	**************************************************************************	|
;|	*|base 31:24|G|D/B|L|AVL|Seg.Limit 19:16|P|DPL (2)|S|TYPE (4)|base 23:16|*	|
;|	*|   0x00(*)|0| 1 |0| 0 |	0x0	|1|  00   |0|  0x9   |    00(*) |* 	|
;|	*|----------------------------------------------------------------------|*	|
;|	*|base 15:00				|Seg. limit 15:00		|*	|
;|	*|0x0000 (se completa dinamicamente)(*)	|0x0067	(103)			|*	|
;|	**************************************************************************	|
;|	---------------------------------------------------------------------------	|
;|			TSS TRADUCTOR		|		TSS PINTOR		|
;|		ESP0 = 0x17000 - 0x4		|ESP0 = 0x16000 - 0x4			|
;|		SS0 = ss = segmento datos = 0x10|SS0 = ss = segmentos datos = 0x10	|
;|		CR3 = PDTRADU			|CR3 = PDPINTOR				|
;|		EIP = TASK2INIT	inicio tarea	|EIP = TASK1INIT inicio tarea		|
;|		EFLAGS = 0x202 (interrup. | 1 )	|EFLAGS = 0x202 (interrup. | 1 )	|
;|		ESP y EBP = ESP0		|ESP y EBP = ESP0			|
;|		ES,SS,DS,FS,GS = 0x10 seg.datos	|ES,SS,DS,FS,GS = 0x10 seg.datos	|
;|		CS = 0x08 seg. codigo		|CS = 0x08 seg. codigo			|
;|		i/o map = 0xFFFF		|i/o map = 0xFFFF			|
;|	---------------------------------------------------------------------------	|
;|	2-se mueve al task register = 0x20 descriptor de tss kernel			|
;|	3-se hace un jmp far usando 0x30 descriptor de tss pintor:			|
;|		se reconoce a 0x30 como descriptor de tss y hace cambio de contexto	|
;|	4-Se coloca en el timer tick una rutina de cambio de tarea entre la 1 y la 2	|
;|		en el archivo isr.asm, etiqueta _isr32:					|
;|		se usa la variable isrnumero que tiene la rutina next_clock, modulo 2	|
;|		(isrnumero mod 2) = 0 o 2 => tarea pintor				|
;|		(isrnumero mod 2) = 1 o 3 => tarea traductor				|
;|											|
;|**************************************************************************************|

	; 1
	mov	edi, tsss

	; (*) cargo en el descriptro de la gdt correspondiente a la tarea kernel, la base de la tss de la misma
	mov	esi, gdt
	add	esi, (8*4 + 2)
	mov	eax, edi
	mov	[esi], ax
	shr	eax, 16
	mov	[esi + 4], al
	mov	[esi + 7], ah
	
	add	edi, 104	; nos paramos en la segunda entry de la tabla de tss's

	; (*) cargo en el descriptro de la gdt correspondiente a la tarea traductor, la base de la tss de la misma
	mov	esi, gdt
	add	esi, (8*5 + 2)
	mov	eax, edi
	mov	[esi], ax
	shr	eax, 16
	mov	[esi + 4], al
	mov	[esi + 7], ah

	; (**) cargamos la informacion de la tarea traductor antes de saltar
	add	edi, 4
	mov dword [edi], 0x17000 - 0x4
	add	edi, 4
	mov word [edi], ss
	add	edi, (5*4)
	mov dword [edi], PDTRADU
	add	edi, (4)
	mov dword [edi], TASK2INIT
	add	edi, (4)
	mov dword [edi], 0x00000202
	add	edi, (5*4)		; salteo eax, ecx, edx, ebx
	mov	eax, 0x17000 - 0x4 ;direccion virtual de la pila del traductor pero que crece desde abajo
	stosd	; esp
	stosd	; ebp
	add	edi, (2*4)
	mov word [edi], 0x10
	add	edi, 4
	mov word [edi], 0x08
	add	edi, 4
	mov	eax, 0x10
	%rep	4
		stosd		; les doy el segmento de dato
	%endrep
	add	edi, (6)
	mov word [edi], 0xFFFF
	
	mov	edi, tsss
	add	edi, (104*2)	; estamos parados en la tercera posicion de la tss, para cargar la tss pintor

	; (*) cargo en el descriptro de la gdt correspondiente a la tarea pintor, la base de la tss de la misma
	mov	esi, gdt
	add	esi, (8*6 + 2)
	mov	eax, edi
	mov	[esi], ax
	shr	eax, 16
	mov	[esi + 4], al
	mov	[esi + 7], ah

	; (***) cargamos la informacion de la tarea pintor
	add	edi, 4
	mov dword [edi], (0x16000 - 0x4)
	add	edi, 4
	mov word [edi], ss
	add	edi, (5*4)
	mov dword [edi], PDPINTOR
	add	edi, (4)
	mov dword [edi],TASK1INIT
	add	edi, (4)
	mov dword [edi], 0x00000202
	add	edi, (5*4)
	mov	eax, 0x16000 - 0x4 ;direccion virtual de la pila del pintor pero que crece desde abajo
	stosd	; esp
	stosd	; ebp
	add	edi, (2*4)
	mov word [edi], 0x10
	add	edi, 4
	mov word [edi], 0x08
	add 	edi, 4
	mov	eax, 0x10
	%rep	4
		mov	[edi], eax
		stosd		; les doy el segmento de dato
	%endrep
	add	edi, (6)
	mov word [edi], 0xFFFF
	
	; 2
	mov	ax, 0x20
	ltr	ax
	
	; 3
	jmp	0x30:0x0
	jmp	$
		
%include "a20.asm"
%include "pic.asm"

inicializacion_directorios_y_tablas_de_paginas:

TIMES TASK1INIT - KORG - ($ - $$) db 0x00
incbin "pintor.tsk"
incbin "traductor.tsk"
TIMES PDPINTOR - KORG - ($ - $$) db 0x00

; |*********************************************************************|
;		Directorio de paginas de Pintor				|
; |*********************************************************************|
	dd	PTPINTOR | 3
%rep	0x400 - 1
	dd	0x00000000
%endrep


; |*********************************************************************|
;		Directorio de paginas de Traductor			|
; |*********************************************************************|
	dd	PTTRADK | 3
%rep	0x400 - 1
	dd	0x00000000
%endrep
; |*********************************************************************|
;		Tabla de paginas de Pintor				|
; |*********************************************************************|
%assign dir 0x0
%rep	0x9			; 0-8
	dd	dir | 3		;supervisor, read/write, not present
%assign dir dir+4096
%endrep	
%rep	0x5			; 9 - 13
	dd	0x0
%endrep
%assign dir 0x0000E000
%rep	0x2			; 14 - 15
	dd	dir | 3		;supervisor, read/write, not present
%assign dir dir+4096
%endrep
%rep	0x3			; 16 - 18
	dd	0x0
%endrep
	dd	0x000B8003	; 19
	dd	0x0		; 20
	dd	0x00015003	; 21
%rep	162			; 22 - 183
	dd	0x0
%endrep
	dd	0x00010003	; 184
%rep	839			; 185 - 1023
	dd	0x0
%endrep

; |*********************************************************************|
; |		Tabla de paginas de Traductor				|
; |*********************************************************************|
%assign dir 0x0
%rep	0x8			; 0 - 7
	dd	dir | 3		;supervisor, read/write, not present
%assign dir dir+4096
%endrep	
	dd	0x0			; 8
%assign dir 0x00009000
%rep	0x8			; 9 - 16
	dd	dir | 3		;supervisor, read/write, not present
%assign dir dir+4096
%endrep	
%rep	0x2			; 17 - 18
	dd	0x0
%endrep
	dd	0x000B8003	; 19
%rep	0x2			; 20 - 21
	dd	0x0
%endrep
	dd 0x00016003		; 22 
	dd 0x0			; 23
	dd 0x000B8003		; 24
%rep	135			; 25 - 159
	dd 0x0
%endrep
%assign dir 0x000A0000
%rep	0x20			; 160 - 191
	dd	dir | 3		;supervisor, read/write, not present
%assign dir dir+4096
%endrep	
%rep	832			; 192 - 1023
	dd 0x0
%endrep