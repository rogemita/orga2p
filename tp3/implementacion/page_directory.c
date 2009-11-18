#include "page_directory.h"

/*
 * Definicion del directorio de pagina para el pintor
 */
pd_entry pd_pintor[PD_COUNT] = {

 /********************************************************************************/
 /* |direccion base de la pag	| Disponible	| G	| PS	| 0 | PCD | PWT | U/S | R/W | P |	*/
 /* |	 |	11 - 9	| 8	|  7	| 6 |  4     |    3   |   2   |   1   |  0 |	*/
 /********************************************************************************/

	(pd_entry){
		(unigned int) 
	}
}

/*
 * Definicion del directorio de pagina para el traductor
 */

pd_entry pd_traductor[GDT_COUNT] = {
}