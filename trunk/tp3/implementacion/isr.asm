BITS 32
%include "macrosmodoprotegido.mac"
extern pic1_intr_end


; ----------------------------------------------------------------
; Interrupt Service Routines
; TODO: Definir el resto de las ISR
; ----------------------------------------------------------------

global _isr0, _isr5, _isr6, _isr7, _isr9, _isr10, _isr11, _isr12, _isr13, _isr14, _isr16, _isr17, _isr19, _isr32
msgisr0: db 'EXCEPCION: Division por cero'
msgisr0_len equ $-msgisr0
msgisr1: db 'EXCEPCION: '
msgisr1_len equ $-msgisr1
msgisr2: db 'EXCEPCION: '
msgisr2_len equ $-msgisr2
msgisr3: db 'EXCEPCION: '
msgisr3_len equ $-msgisr3
msgisr4: db 'EXCEPCION: '
msgisr4_len equ $-msgisr4
msgisr5: db 'EXCEPCION: BOUND Range Exceeded'
msgisr5_len equ $-msgisr5
msgisr6: db 'EXCEPCION: Codigo de operacion invalido'
msgisr6_len equ $-msgisr6
msgisr7: db 'EXCEPCION: Device Non Avalible (No Math Coprocessor)'
msgisr7_len equ $-msgisr7
msgisr8: db 'EXCEPCION: '
msgisr8_len equ $-msgisr8
msgisr9: db 'EXCEPCION: Coprocessor Segment Overrun'
msgisr9_len equ $-msgisr9
msgisr10: db 'EXCEPCION: TSS Invalida'
msgisr10-_len equ $-msgisr10
msgisr11: db 'EXCEPCION: Segmento No Presente'
msgisr11_len equ $-msgisr11
msgisr12: db 'EXCEPCION: Stack-Segment Fault '
msgisr12_len equ $-msgisr12
msgisr13: db 'EXCEPCION: Proteccion General'
msgisr13_len equ $-msgisr13
msgisr14: db 'EXCEPCION: Pagina No Presente'
msgisr14_len equ $-msgisr14
msgisr16: db 'EXCEPCION: Error De Punto Flotante'
msgisr16_len equ $-msgisr16
msgisr17: db 'EXCEPCION: Alignment Check'
msgisr17_len equ $-msgisr17
msgisr19: db 'EXCEPCION: Error De Punto Flotante En SIMD'
msgisr19_len equ $-msgisr19
; msgisr: db 'EXCEPCION: '
; msgisr_len equ $-msgisr
_isr0:
	mov edx, msgisr0
	IMPRIMIR_TEXTO edx, msgisr0_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr5:
	mov edx, msgisr5
	IMPRIMIR_TEXTO edx, msgisr5_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr6:
	mov edx, msgisr6
	IMPRIMIR_TEXTO edx, msgisr6_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr7:
	mov edx, msgisr7
	IMPRIMIR_TEXTO edx, msgisr7_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr9:
	mov edx, msgisr9
	IMPRIMIR_TEXTO edx, msgisr9_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr10:
	mov edx, msgisr10
	IMPRIMIR_TEXTO edx, msgisr10_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr11:
	mov edx, msgisr11
	IMPRIMIR_TEXTO edx, msgisr11_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr12:
	mov edx, msgisr12
	IMPRIMIR_TEXTO edx, msgisr12_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr13:
	mov edx, msgisr13
	IMPRIMIR_TEXTO edx, msgisr13_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr14:
	mov edx, msgisr14
	IMPRIMIR_TEXTO edx, msgisr14_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr16:
	mov edx, msgisr16
	IMPRIMIR_TEXTO edx, msgisr16_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr17:
	mov edx, msgisr17
	IMPRIMIR_TEXTO edx, msgisr17_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr19:
	mov edx, msgisr19
	IMPRIMIR_TEXTO edx, msgisr19_len, 0x0C, 0, 0, 0x13000
	jmp $

_isr32:
	cli
	pushad
	call	next_clock
	mov  al, 0x60
	out 0x20, al
switching_task:
	mov	ebx, [isrnumero]
	bt	ebx, 0
	jc	traductor
pintor:
	jmp	0x30:0x0
	jmp	termino

traductor:
	jmp	0x28:0x0

termino:
	popad
	sti
	iret


; Funcion para dibujar el reloj.
; void next_clock(void)
next_clock:
	pushad
	inc DWORD [isrnumero]
	mov ebx, [isrnumero]
	cmp ebx, 0x4
	jl .ok
		mov DWORD [isrnumero], 0x0
		mov ebx, 0
	.ok:
		add ebx, isrmessage1
		mov edx, isrmessage
		IMPRIMIR_TEXTO edx, 6, 0x0A, 23, 1, 0x13000
		IMPRIMIR_TEXTO ebx, 1, 0x0A, 23, 8, 0x13000
	popad
	ret

isrmessage: db 'Clock:'
isrnumero: dd 0x00000000
isrmessage1: db '|'
isrmessage2: db '/'
isrmessage3: db '-'
isrmessage4: db '\'
