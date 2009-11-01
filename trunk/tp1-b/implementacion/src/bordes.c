#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

extern void asmSobel(const IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);

int main( int argc, char** argv )
{

   IplImage * src = 0;
   IplImage * dst = 0;
   IplImage * dst_ini = 0;

   //char* filename = argc == 2 ? argv[1] : (char*)"img/in/lena.bmp";
   char* filename = argc == 2 ? argv[1] : (char*)"img/in/lena-full.jpg";

   // Cargo la imagen
   if( (src = cvLoadImage (filename, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
	   return -1;

   // Creo una IplImage para cada salida esperada
   if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
	   return -1;

   // Creo una IplImage para cada salida esperada
   if( (dst_ini = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
	   return -1;
/*
   // Aplico el filtro (Sobel con derivada x en este caso) y salvo imagen 
   cvSobel(src, dst, 1,0,3); 	// Esta parte es la que tienen que programar los alumnos en ASM	y comparar
   cvSaveImage("img/res/c/derivada x.jpg", dst);

   // Aplico el filtro (Sobel con derivada y en esta caso) y salvo imagen 
   cvSobel(src, dst, 0,1,3);    // Esta parte es la que tienen que programar los alumnos en ASM	y comparar
   cvSaveImage("img/res/c/derivada y.jpg", dst);

// Aplico el filtro (Sobel con derivada y en esta caso) y salvo imagen 
   cvSobel(src, dst, 1,1,3);    // Esta parte es la que tienen que programar los alumnos en ASM	y comparar
   cvSaveImage("img/res/c/derivada xy.jpg", dst);
*/
    cvSobel(src, dst, 1,0,3); 	// Esta parte es la que tienen que programar los alumnos en ASM	y comparar
    cvSaveImage("img/res/c/sobel10.jpg", dst);
    asmSobel(src, dst, cvGetSize (src).width, cvGetSize (src).height, 0, 0);
    cvSaveImage("img/res/asm/sobel10.jpg", dst);

   return 0;

}


