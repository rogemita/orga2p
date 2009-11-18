#include "gdt.h"
#include "tss.h"


/*
 * Definicion de la GDT
 */
gdt_entry gdt[GDT_COUNT] = {
	/* Descriptor nulo*/

	/*********************************************************************************************
	* |base 31:24 | G | D/B | L | AVL | Seg. Limit 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16	| *
	* 																				  *
	* | BASE ADRESS 15:00						| SEGMENT LIMIT 15:00				| *
	*																				  *
	*********************************************************************************************/

	(gdt_entry){ 
		(unsigned short) 0x0000, 
		(unsigned short) 0xFFFF,
		(unsigned char) 0x00, 
		(unsigned char) 0x0, 
		(unsigned char) 0, 
		(unsigned char) 0, 
		(unsigned char) 0, 
		(unsigned char) 0x0,
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 0, 
		(unsigned char) 0x00 
	},

	/*********************************************************************************************
	* |base 31:24 | G | D/B | L | AVL | Seg. Limit. 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16	| *
	*  0x00		   1	  1      0      0      0xF			  1   00            1   1010		0x00		  *
	* | BASE ADRESS 15:00						| SEGMENT LIMIT 15:00				| *
	* 		0x0000									0xFFFF							  *
	*********************************************************************************************/

	(gdt_entry){ 
		(unsigned short) 0xFFFF, 
		(unsigned short) 0x0000,
		(unsigned char) 0x00, 
		(unsigned char) 0xA, 
		(unsigned char) 1, 
		(unsigned char) 0, 
		(unsigned char) 1, 
		(unsigned char) 0xF,
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 1,  
		(unsigned char) 1, 
		(unsigned char) 0x00 
	},

	/*********************************************************************************************
	* |base 31:24 | G | D/B | L | AVL | Seg. Limit 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16	| *
	*  0x00		  1      1     0      0        0xF			  1   00	       1   0010		0x00		  *
	* | BASE ADRESS 15:00						| SEGMENT LIMIT 15:00				| *
	*	0x0000										0xFFFF							  *
	*********************************************************************************************/

	(gdt_entry){ 
		(unsigned short) 0xFFFF, 
		(unsigned short) 0x0000,
		(unsigned char) 0x00, 
		(unsigned char) 0x2, 
		(unsigned char) 1, 
		(unsigned char) 0,
		(unsigned char) 1, 
		(unsigned char) 0xF,
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 1,  
		(unsigned char) 1, 
		(unsigned char) 0x00 
	},

	/*********************************************************************************************
	* |base 31:24 | G | D/B | L | AVL | Seg. Limit 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16	| *
	*  0x00		  0      1     0      0        0x0      		  1   00	       1   0010		0x0B		  *
	* | BASE ADRESS 15:00						| SEGMENT LIMIT 15:00				| *
	*	0x8000										0x0F9F							  *
	*********************************************************************************************/

(gdt_entry){ 
		(unsigned short) 0x0F9F, 
		(unsigned short) 0x8000,
		(unsigned char) 0x0B, 
		(unsigned char) 0x2, 
		(unsigned char) 1, 
		(unsigned char) 0, 
		(unsigned char) 1, 
		(unsigned char) 0x0,
		(unsigned char) 0, 
		(unsigned char) 0,  
		(unsigned char) 1,  
		(unsigned char) 0, 
		(unsigned char) 0x00 
	},

	/*********************************************************************************************
	* |base 31:24 | G | D/B | L | AVL | Seg. Limit. 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16	| *
	*  0x00		   1	  1      0      0      0x0			  1   00            1   0010		0x01		  *
	* | BASE ADRESS 15:00						| SEGMENT LIMIT 15:00				| *
	* 		0x5000									0x0067							  *
	*********************************************************************************************/

	(gdt_entry){ 
		(unsigned short) 0x0067, 
		(unsigned short) 0x5000,
		(unsigned char) 0x01, 
		(unsigned char) 0x2, 
		(unsigned char) 1, 
		(unsigned char) 0, 
		(unsigned char) 1, 
		(unsigned char) 0x0,
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 1,  
		(unsigned char) 1, 
		(unsigned char) 0x00 
	},

	/*********************************************************************************************
	* |base 31:24 | G | D/B | L | AVL | Seg. Limit. 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16	| *
	*  0x00		   1	  1      0      0      0x0			  1   00            1   0010		0x01		  *
	* | BASE ADRESS 15:00						| SEGMENT LIMIT 15:00				| *
	* 		0x6000									0x0067							  *
	*********************************************************************************************/

	(gdt_entry){ 
		(unsigned short) 0x0067, 
		(unsigned short) 0x6000,
		(unsigned char) 0x01, 
		(unsigned char) 0x2, 
		(unsigned char) 1, 
		(unsigned char) 0, 
		(unsigned char) 1, 
		(unsigned char) 0x0,
		(unsigned char) 0,  
		(unsigned char) 0,  
		(unsigned char) 1,  
		(unsigned char) 1, 
		(unsigned char) 0x00 
	}
};

/*
 * Definicion del GDTR
 */ 
gdt_descriptor GDT_DESC = {sizeof(gdt)-1, (unsigned int)&gdt};
