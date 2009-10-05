#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

#define testOperator(OPERATOR, XDERIVATE, YDERIVATE)						\
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));				\
	OPERATOR (src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, XDERIVATE, YDERIVATE);	\
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));		\
	cvSaveImage("img/" #OPERATOR  #XDERIVATE  #YDERIVATE ".BMP", dst_asm);			\
	printf(#OPERATOR #XDERIVATE #YDERIVATE " demoro:\t%i \n", tscl)

extern void asmRoberts(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmPrewitt(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmSobel(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);

int main( int argc, char** argv ){
	IplImage * src = 0;
	IplImage * dst = 0;
	IplImage * dst_asm = 0;
	IplImage * dst_ini = 0;
	
	char* filename = argc == 2 ? argv[1] : (char*)"img/lena.bmp";

	int tscl;
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

	//SOBEL
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
	cvSobel(src, dst, 1,0,3); 	
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	cvSaveImage("img/sobelDX.BMP", dst);
	printf("cvSobel10 demoro:\t%i \n", tscl);

	testOperator(asmSobel,1,0);
	
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
	cvSobel(src, dst, 0,1,3); 	
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	cvSaveImage("img/sobelDY.BMP", dst);
	printf("cvSobel01 demoro:\t%i \n", tscl);

	testOperator(asmSobel,0,1);

	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
	cvSobel(src, dst, 1,1,3);
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	cvSaveImage("img/sobelDXDY.BMP", dst);
	printf("cvSobel11 demoro:\t%i \n", tscl);

	testOperator(asmSobel,1,1);

	//PREWITT
	testOperator(asmPrewitt,1,0);
	testOperator(asmPrewitt,0,1);
	testOperator(asmPrewitt,1,1);

	//PREWITT
	testOperator(asmRoberts,1,0);	
	testOperator(asmRoberts,0,1);
	testOperator(asmRoberts,1,1);


	cvReleaseData(src);
	cvReleaseData(dst);
	cvReleaseData(dst_asm);
	cvReleaseData(dst_ini);
	cvReleaseImage(&src);
	cvReleaseImage(&dst);
	cvReleaseImage(&dst_asm);
	cvReleaseImage(&dst_ini);

	return 0;
}


