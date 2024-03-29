#ifndef __GDT_H__
#define __GDT_H__


/*
 * Global Descriptor Table
 * Definicion de las estructuras de la GDT.
 */
#define GDT_COUNT 128

/* 
 * Struct de descriptor de GDT 
 */
typedef struct str_gdt_descriptor {
	unsigned short gdt_length;
	unsigned int gdt_addr;
} __attribute__((__packed__)) gdt_descriptor;

/* 
 * Struct de una entrada de la GDT 
 */
typedef struct str_gdt_entry {
	unsigned short limit_0_15;
	unsigned short base_0_15;
	unsigned char base_23_16;
	unsigned char type:4;
	unsigned char s:1;
	unsigned char dpl:2;
	unsigned char p:1;
	unsigned char limit_16_19:4;
	unsigned char avl:1;
	unsigned char l:1;
	unsigned char db:1;
	unsigned char g:1;
	unsigned char base_31_24;
} __attribute__((__packed__, aligned (8))) gdt_entry;

/*
 * GDT
 */ 
extern gdt_entry gdt[];

/*
 * Descriptor de la GDT
 */ 
extern gdt_descriptor GDT_DESC;
#endif //__GDT_H__
