#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

extern void asmSobel(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);

int main( int argc, char** argv )
{

	IplImage * src = 0;
	IplImage * dst = 0;
	IplImage * dst_asm = 0;
	IplImage * dst_ini = 0;
	
	char* filename = argc == 2 ? argv[1] : (char*)"img/lena.bmp";
	
	// Cargo la imagen
	if( (src = cvLoadImage (filename, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
		return -1;
	
	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		return -1;
	
	// Creo una IplImage para cada salida esperada
	if( (dst_ini = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		return -1;
	
	// Creo una IplImage para la salida de la funcion en asembler
	if( (dst_asm = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		return -1;
	
	// Aplico el filtro (Sobel con derivada x en este caso) y salvo imagen 
	cvSobel(src, dst, 1,0,3); 	// Esta parte es la que tienen que programar los alumnos en ASM	y comparar
	asmSobel(src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, 1, 0);
	cvSaveImage("img/derivada x.BMP", dst);
	cvSaveImage("img/derivada xASM.BMP", dst_asm);
	
	// Aplico el filtro (Sobel con derivada y en esta caso) y salvo imagen 
	cvSobel(src, dst, 0,1,3);    // Esta parte es la que tienen que programar los alumnos en ASM	y comparar
	asmSobel(src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, 0, 1);
	cvSaveImage("img/derivada y.BMP", dst);
	cvSaveImage("img/derivada yASM.BMP", dst_asm);	

	// Aplico el filtro (Sobel con derivada x e y en esta caso) y salvo imagen 
	cvSobel(src, dst, 1,1,3);    // Esta parte es la que tienen que programar los alumnos en ASM	y comparar
	asmSobel(src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, 1, 1);
	cvSaveImage("img/derivada xy.BMP", dst);
	cvSaveImage("img/derivada xyASM.BMP", dst_asm);	

	return 0;

}


