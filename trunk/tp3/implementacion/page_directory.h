#ifndef __PD_H__
#define __PD_H__

/*
 * Directorio de paginas
 * Definicion de las estructuras del directorio de paginas.
 */
#define PD_COUNT 1024

/* 
 * Struct del campo del directorio de pagina
 */
 /*****************************************************************************/
 /* |direccion base de la pag	| Disponible	| G	| PS	| 0 | PCD | PWT | U/S | R/W | P |
 /* |		31 - 12			|	11 - 9	| 8	|  7	| 6 |  4     |    3   |   2   |   1   |  0 |
 /******************************************************************************/
typedef struct str_pd_entry {
	unsigned int page_dir:20;
	unsigned char avl:3;
	unsigned char global_page:1;
	unsigned char p_size:1;
	unsigned char z:1;
	unsigned char a:1;
	unsigned char cache_desabled:1;
	unsigned char page_write_through:1;
	unsigned char u_su:1;
	unsigned char r_w:1;
	unsigned char p:1;
}__attribute__((__packed__, aligned (4))) pd_entry;

/*
 * Page Directory - Pintor
 */ 
extern pd_entry pd_pintor[];
/*
 * Page Directory - Traductor
 */ 
extern pd_entry pd_traductor[];

#endif //__PD_H__