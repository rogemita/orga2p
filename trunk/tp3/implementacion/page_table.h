#ifndef __GDT_H__
#define __GDT_H__


/*
 * Directorio de paginas
 * Definicion de las estructuras del directorio de paginas.
 */
#define GDT_COUNT 1024

/* 
 * Struct del campo del directorio de pagina
 */
 /*****************************************************************************/
 /* |direccion base de la pag	| Disponible	| G	| PS	| 0 | PCD | PWT | U/S | R/W | P |
 /* |		31 - 12			|	11 - 9	| 8	|  7	| 6 |  4     |    3   |   2   |   1   |  0 |
 /******************************************************************************/
typedef struct str_pd_entry {
	unsigned int page_dir:20;
	unsigned char disp:3;
	unsigned char global_page:1;
	unsigned char page_size:1;
	unsigned char zero:1;
	unsigned char acced:1;
	unsigned char cache_desabled:1;
	unsigned char page_write_through:1;
	unsigned char u_su:1;
	unsigned char r_w:1;
	unsigned char p:1;
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