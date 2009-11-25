#include "isr.h"
#include "idt.h"


/*
 * Metodo para inicializar los descriptores de la IDT 
 */
void idtFill() {
	idt[0].offset_0_15 = (unsigned short) ((unsigned int)(&_isr0) & (unsigned int) 0xFFFF); \
	idt[0].segsel = (unsigned short) 0x0008; \
	idt[0].attr = (unsigned short) 0x8E00; \
	idt[0].offset_16_31 = (unsigned short) ((unsigned int)(&_isr0) >> 16 & (unsigned int) 0xFFFF);
	/*
	 * TODO: Completar inicializacion de la IDT aqui
	 * 
	 */
	idt[1].offset_0_15 = (unsigned short) ((unsigned int)(&_isr1) & (unsigned int) 0xFFFF); \
	idt[1].segsel = (unsigned short) 0x0008; \
	idt[1].attr = (unsigned short) 0x8E00; \
	idt[1].offset_16_31 = (unsigned short) ((unsigned int)(&_isr1) >> 16 & (unsigned int) 0xFFFF);

	idt[2].offset_0_15 = (unsigned short) ((unsigned int)(&_isr2) & (unsigned int) 0xFFFF); \
	idt[2].segsel = (unsigned short) 0x0008; \
	idt[2].attr = (unsigned short) 0x8E00; \
	idt[2].offset_16_31 = (unsigned short) ((unsigned int)(&_isr2) >> 16 & (unsigned int) 0xFFFF);

	idt[3].offset_0_15 = (unsigned short) ((unsigned int)(&_isr3) & (unsigned int) 0xFFFF); \
	idt[3].segsel = (unsigned short) 0x0008; \
	idt[3].attr = (unsigned short) 0x8E00; \
	idt[3].offset_16_31 = (unsigned short) ((unsigned int)(&_isr3) >> 16 & (unsigned int) 0xFFFF);

	idt[4].offset_0_15 = (unsigned short) ((unsigned int)(&_isr4) & (unsigned int) 0xFFFF); \
	idt[4].segsel = (unsigned short) 0x0008; \
	idt[4].attr = (unsigned short) 0x8E00; \
	idt[4].offset_16_31 = (unsigned short) ((unsigned int)(&_isr4) >> 16 & (unsigned int) 0xFFFF);

	idt[5].offset_0_15 = (unsigned short) ((unsigned int)(&_isr5) & (unsigned int) 0xFFFF); \
	idt[5].segsel = (unsigned short) 0x0008; \
	idt[5].attr = (unsigned short) 0x8E00; \
	idt[5].offset_16_31 = (unsigned short) ((unsigned int)(&_isr5) >> 16 & (unsigned int) 0xFFFF);

	idt[6].offset_0_15 = (unsigned short) ((unsigned int)(&_isr6) & (unsigned int) 0xFFFF); \
	idt[6].segsel = (unsigned short) 0x0008; \
	idt[6].attr = (unsigned short) 0x8E00; \
	idt[6].offset_16_31 = (unsigned short) ((unsigned int)(&_isr6) >> 16 & (unsigned int) 0xFFFF);

	idt[7].offset_0_15 = (unsigned short) ((unsigned int)(&_isr7) & (unsigned int) 0xFFFF); \
	idt[7].segsel = (unsigned short) 0x0008; \
	idt[7].attr = (unsigned short) 0x8E00; \
	idt[7].offset_16_31 = (unsigned short) ((unsigned int)(&_isr7) >> 16 & (unsigned int) 0xFFFF);

	idt[8].offset_0_15 = (unsigned short) ((unsigned int)(&_isr8) & (unsigned int) 0xFFFF); \
	idt[8].segsel = (unsigned short) 0x0008; \
	idt[8].attr = (unsigned short) 0x8E00; \
	idt[8].offset_16_31 = (unsigned short) ((unsigned int)(&_isr8) >> 16 & (unsigned int) 0xFFFF);

	idt[9].offset_0_15 = (unsigned short) ((unsigned int)(&_isr9) & (unsigned int) 0xFFFF); \
	idt[9].segsel = (unsigned short) 0x0008; \
	idt[9].attr = (unsigned short) 0x8E00; \
	idt[9].offset_16_31 = (unsigned short) ((unsigned int)(&_isr9) >> 16 & (unsigned int) 0xFFFF);

	idt[10].offset_0_15 = (unsigned short) ((unsigned int)(&_isr10) & (unsigned int) 0xFFFF); \
	idt[10].segsel = (unsigned short) 0x0008; \
	idt[10].attr = (unsigned short) 0x8E00; \
	idt[10].offset_16_31 = (unsigned short) ((unsigned int)(&_isr10) >> 16 & (unsigned int) 0xFFFF);

	idt[11].offset_0_15 = (unsigned short) ((unsigned int)(&_isr11) & (unsigned int) 0xFFFF); \
	idt[11].segsel = (unsigned short) 0x0008; \
	idt[11].attr = (unsigned short) 0x8E00; \
	idt[11].offset_16_31 = (unsigned short) ((unsigned int)(&_isr11) >> 16 & (unsigned int) 0xFFFF);

	idt[12].offset_0_15 = (unsigned short) ((unsigned int)(&_isr12) & (unsigned int) 0xFFFF); \
	idt[12].segsel = (unsigned short) 0x0008; \
	idt[12].attr = (unsigned short) 0x8E00; \
	idt[12].offset_16_31 = (unsigned short) ((unsigned int)(&_isr12) >> 16 & (unsigned int) 0xFFFF);

	idt[13].offset_0_15 = (unsigned short) ((unsigned int)(&_isr13) & (unsigned int) 0xFFFF); \
	idt[13].segsel = (unsigned short) 0x0008; \
	idt[13].attr = (unsigned short) 0x8E00; \
	idt[13].offset_16_31 = (unsigned short) ((unsigned int)(&_isr13) >> 16 & (unsigned int) 0xFFFF);

	idt[14].offset_0_15 = (unsigned short) ((unsigned int)(&_isr14) & (unsigned int) 0xFFFF); \
	idt[14].segsel = (unsigned short) 0x0008; \
	idt[14].attr = (unsigned short) 0x8E00; \
	idt[14].offset_16_31 = (unsigned short) ((unsigned int)(&_isr14) >> 16 & (unsigned int) 0xFFFF);

	idt[16].offset_0_15 = (unsigned short) ((unsigned int)(&_isr16) & (unsigned int) 0xFFFF); \
	idt[16].segsel = (unsigned short) 0x0008; \
	idt[16].attr = (unsigned short) 0x8E00; \
	idt[16].offset_16_31 = (unsigned short) ((unsigned int)(&_isr16) >> 16 & (unsigned int) 0xFFFF);

	idt[17].offset_0_15 = (unsigned short) ((unsigned int)(&_isr17) & (unsigned int) 0xFFFF); \
	idt[17].segsel = (unsigned short) 0x0008; \
	idt[17].attr = (unsigned short) 0x8E00; \
	idt[17].offset_16_31 = (unsigned short) ((unsigned int)(&_isr17) >> 16 & (unsigned int) 0xFFFF);

	idt[18].offset_0_15 = (unsigned short) ((unsigned int)(&_isr18) & (unsigned int) 0xFFFF); \
	idt[18].segsel = (unsigned short) 0x0008; \
	idt[18].attr = (unsigned short) 0x8E00; \
	idt[18].offset_16_31 = (unsigned short) ((unsigned int)(&_isr18) >> 16 & (unsigned int) 0xFFFF);

	idt[19].offset_0_15 = (unsigned short) ((unsigned int)(&_isr19) & (unsigned int) 0xFFFF); \
	idt[19].segsel = (unsigned short) 0x0008; \
	idt[19].attr = (unsigned short) 0x8E00; \
	idt[19].offset_16_31 = (unsigned short) ((unsigned int)(&_isr19) >> 16 & (unsigned int) 0xFFFF);

	idt[32].offset_0_15 = (unsigned short) ((unsigned int)(&_isr32) & (unsigned int) 0xFFFF); \
	idt[32].segsel = (unsigned short) 0x0008; \
	idt[32].attr = (unsigned short) 0x8E00; \
	idt[32].offset_16_31 = (unsigned short) ((unsigned int)(&_isr32) >> 16 & (unsigned int) 0xFFFF);
}

/*
 * IDT
 */ 
idt_entry idt[255] = {};

/*
 * Descriptor de la IDT (para cargar en IDTR)
 */
idt_descriptor IDT_DESC = {sizeof(idt)-1, (unsigned int)&idt};

