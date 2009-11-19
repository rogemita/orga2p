BITS 16

%include "macrosmodoreal.mac"

global start
extern GDT_DESC
extern gdt;
extern IDT_DESC
extern idtFill
extern tsss;
extern idt
extern _isr32


;Aca arranca todo, en el primer byte.
start:
; 		cli					;no me interrumpan por ahora, estoy ocupado
; 		jmp 	bienvenida
; 
; ;aca ponemos todos los mensajes		
; iniciando: db 'Iniciando el kernel mas inutil del mundo'
; iniciando_len equ $ - iniciando		
; 
; 
; bienvenida:
; 	IMPRIMIR_MODO_REAL iniciando, iniciando_len, 0x07, 0, 0
	; Ejercicios AQUI

	; TODO: Habilitar A20
	call check_A20
	;xchg	bx, bx
	cmp ax, 1
	je deshabilitar_interrupciones
	call enable_A20

deshabilitar_interrupciones:	; TODO: Dehabilitar Interrupciones

	; Ejercicio 1
		
		; TODO: Cargar el registro GDTR
		
		; TODO: Pasar a modo protegido

	;deshabilitamos las interrupciones
	cli
		
	;cargamos la gdt
	lgdt		[GDT_DESC]
	;xchg	bx, bx		
	;seteamos el bit PE del registro cr0
	mov		eax, cr0
	or		eax, 01h
	mov		cr0, eax
	
	;segundo segmento en la GDT, el primero es nulo
	jmp		0x08:modo_protegido

BITS 32
modo_protegido:
	;xchg	bx, bx
	mov	ax, 0x0010
	mov	ds, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	ax, 0x0018
	mov	es, ax
	xor	edi, edi
	;mov	edi, 162					;paso a la fila de abajo y salteo la primer columna
	mov	ecx, 80
	mov	ax, 0xbe32
	;mov	edx, ecx

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
	;je		seguir
	;dec		ebx
	;add		edi, 4
	;mov	ecx, edx
	;jmp		ciclo_x
	loop	medio

	mov	ecx, 80

ultima_fila:
	stosw
	loop	ultima_fila
	
	
seguir:
	;lodsb -> al, [ds:esi] y este aumenta esi en lo que sea
	;stosw -> escribe en es:edi y ademas aumenta edi en 2 bytes (lo que sea)

	;jmp $

	; Ejercicio 2
		
		; TODO: Habilitar paginacion
	;xchg bx, bx
	; Ejercicio 3

	;Esto va en la rutina de interrupciones!!
	
	
	;habilito paginacion	
	mov eax, 0x0000B000		;cargo la direccion del directorio en cr3
	mov cr3, eax

	mov eax, cr0				
	or  eax, 0x80000000		;habilito paginacion
	mov cr0, eax
	;xchg bx, bx


	mov	eax, idt
	add	eax, 32*8
	call	idtFill
; 	mov dword	[eax], _isr32
; 	mov dword	[eax+4], _isr32
; 	mov word	[eax+2], 0x0008
; 	mov word	[eax+4], 0x8E00

	lidt [IDT_DESC]

	call	pic_reset
	call	pic_enable

	sti
	jmp sigue

		; TODO: Inicializar la IDT
		
		; TODO: Resetear la pic
		
		; TODO: Cargar el registro IDTR
				
	; Ejercicio 4
	
		; TODO: Inicializar las TSS
		
		; TODO: Inicializar correctamente los descriptores de TSS en la GDT
		
		; TODO: Cargar el registro TR con el descriptor de la GDT de la TSS actual
		
		; TODO: Habilitar la PIC
		
		; TODO: Habilitar Interrupciones
		
		; TODO: Saltar a la primer tarea
		
		
%include "a20.asm"
%include "pic.asm"

%define TASK1INIT	0x8000
%define TASK2INIT	0x9000
%define PDPINTOR	0xA000
%define PDTRADU		0xB000
%define PTPINTOR	0xC000
%define PTTRADK		0xD000
%define STACKTR		0x16000
%define STACKPT		0x15000
%define KORG		0x1200

TIMES TASK1INIT - KORG - ($ - $$) db 0x00
incbin "pintor.tsk"
incbin "traductor.tsk"
TIMES PDPINTOR - KORG - ($ - $$) db 0x00

; |*******************************************************************|
;				Directorio de pagina de Pintor					
; |*******************************************************************|
	dd	PTPINTOR | 3
%rep	0x400 - 1
	dd	0x00000000
%endrep


; |*******************************************************************|
;				Directorio de pagina de Traductor					
; |*******************************************************************|
	dd	PTTRADK | 3
%rep	0x400 - 1
	dd	0x00000000
%endrep
; |*******************************************************************|
;				Tabla de pagina de Pintor					
; |*******************************************************************|
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
	dd	0x0			; 20
	dd	0x00015003	; 21
%rep	162			; 22 - 183
	dd	0x0
%endrep
	dd	0x00010003	; 184
%rep	839			; 185 - 1023
	dd	0x0
%endrep

; |*******************************************************************|
;				Tabla de pagina de Traductor					
; |*******************************************************************|
%assign dir 0x0
%rep	0x8			; 0-7
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
	dd 0x00016003	; 22
	dd 0x0			; 23
	dd 0x000B8003	;24
%rep	135			; 25 - 159
	dd 0x0
%endrep
%assign dir 0x000A0000
%rep	0x20		; 160 - 191
	dd	dir | 3		;supervisor, read/write, not present
%assign dir dir+4096
%endrep	
%rep	832			; 192 - 1023
	dd 0x0
%endrep

sigue:
xchg bx, bx
mov	edi, tsss

; cargo en el descriptro de la gdt correspondiente a la tarea kernel, la base de la tss de la misma
mov	esi, gdt
add	esi, (8*4 + 2)
mov	eax, edi
mov	[esi], ax
shr	eax, 16
mov	[esi + 4], al
mov	[esi + 7], ah

add	edi, 104	; nos paramos en la segunda entry de la tabla de tss's

; cargo en el descriptro de la gdt correspondiente a la tarea traductor, la base de la tss de la misma
mov	esi, gdt
add	esi, (8*5 + 2)
mov	eax, edi
mov	[esi], ax
shr	eax, 16
mov	[esi + 4], al
mov	[esi + 7], ah
;cargamos la informacion de la tarea traductor antes de saltar
add	edi, 4
mov	[edi], esp
add	edi, 4
mov word [edi], ss
add	edi, (5*4)
mov dword [edi], PDTRADU
add	edi, (2*4)
mov dword [edi], 0x00000202
add	edi, (5*4)		; salteo eax, ecx, edx, ebx
mov	eax, 0x17000 - 0x4 ;direccion virtual de la pila del traductor pero que crece desde abajo

;PREGUNTAR ESTO
;xchg	bx, bx
mov	[edi], eax
mov	[edi], eax
add	edi, (2*4)
;stosd	; esp
;stosd	; ebp
add	edi, (3*4)
mov word [edi], 0x08
add	edi, 4
mov	eax, 0x10
%rep	4
	mov [edi], eax
	;stosd		; les doy el segmento de dato
%endrep
	add edi, (4*4)
add	edi, (6)
mov word [edi], 0xFFFF

mov	edi, tsss
add	edi, (104*2)	; estamos parados en la tercera posicion de la tss, para cargar la tss pintor
; cargo en el descriptro de la gdt correspondiente a la tarea pintor, la base de la tss de la misma
mov	esi, gdt
add	esi, (8*6 + 2)
mov	eax, edi
mov	[esi], ax
shr	eax, 16
mov	[esi + 4], al
mov	[esi + 7], ah
;cargamos la informacion de la tarea pintor
add	edi, 4
mov	[edi], esp
add	edi, 4
mov word [edi], ss
add	edi, (5*4)
mov dword [edi], PDPINTOR
add	edi, (2*4)
mov dword [edi], 0x00000202
add	edi, (5*4)
mov	eax, 0x16000 - 0x4 ;direccion virtual de la pila del pintor pero que crece desde abajo
;;;;;;;;;;;;;;;;;
mov	[edi], eax
mov	[edi], eax
add	edi, (2*4)
;stosd	; esp
;stosd	; ebp
;;;;;;;;;;;;;;;;;;;
add	edi, (3*4)
mov word [edi], 0x08
add 	edi, 4
mov	eax, 0x10
%rep	4
	mov	[edi], eax
	;stosd		; les doy el segmento de dato
%endrep
	add	edi, (4*4)

add	edi, (6)
mov word [edi], 0xFFFF

xchg bx, bx
;jmp $

;cargo el task register con el descriptor correspondiente a la tarea actual
mov	ax, 0x20
str	ax

jmp	0x28:0x0
jmp	$





