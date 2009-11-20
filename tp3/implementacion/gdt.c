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
// 0000000000001 | 000 = 0x08
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
// 0000000000010 | 000 = 0x10
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
* |base 31:24 | G | D/B | L | AVL | Seg. Limit 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16
*  0x00		  0      1     0      0        0x0        1   00        1   0010	0x0B		*
* | BASE ADRESS 15:00				| SEGMENT LIMIT 15:00			| *
*	0x8000							0x0F9F				*
*********************************************************************************************/

// 0000000000011 | 000 = 0x18
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
	* 		0x5000							0x0067							  *
	*********************************************************************************************/
// 0000000000010 | 000 = 0x20

	(gdt_entry){ 
		(unsigned short) 0x0067, 
		(unsigned short) 0x0000,
		(unsigned char) 0x00, 
		(unsigned char) 0x9, 
		(unsigned char) 0, 
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
	* 		0x5000									0x0067							  *
	*********************************************************************************************/
// 0000000000100 | 000 = 0x28

	(gdt_entry){ 
		(unsigned short) 0x0067, 
		(unsigned short) 0x0000,
		(unsigned char) 0x00, 
		(unsigned char) 0x9, 
		(unsigned char) 0, 
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
* |base 31:24 | G | D/B | L | AVL | Seg. Limit. 19:16	| P | DPL (2) | S | TYPE (4) | base 23:16| *
*  0x00		1    1    0    0      0x0	  	  1    00       1   0010	0x00	*
* | BASE ADRESS 15:00					| SEGMENT LIMIT 15:00			| *
* 		0x0000						0x0067			  *
*********************************************************************************************/

// 0000000000110 | 000 = 0x30

	(gdt_entry){ 
		(unsigned short) 0x0067, 
		(unsigned short) 0x0000,
		(unsigned char) 0x00, 
		(unsigned char) 0x9,
		(unsigned char) 0, 
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
