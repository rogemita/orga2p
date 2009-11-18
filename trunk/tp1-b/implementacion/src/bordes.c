#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>

#define testOperator(OPERATOR, XDERIVATE, YDERIVATE)						\
	cvSet(dst_asm, CV_RGB(0,0,0),NULL);								\
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));				\
	OPERATOR (src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, XDERIVATE, YDERIVATE);	\
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));		\
	cvSaveImage("img/res/asm/" #OPERATOR  #XDERIVATE  #YDERIVATE ".jpg", dst_asm);			\
	printf(#OPERATOR #XDERIVATE #YDERIVATE " demoro: %i\n", tscl);

#define testOperatorNoPrint(OPERATOR, XDERIVATE, YDERIVATE)						\
	cvSet(dst_asm, CV_RGB(0,0,0),NULL);								\
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));				\
	OPERATOR (src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, XDERIVATE, YDERIVATE);	\
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));		\
	cvSaveImage("img/res/asm/" #OPERATOR  #XDERIVATE  #YDERIVATE ".jpg", dst_asm);			

#define	CORRIDAS	1
extern void asmRoberts(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmPrewitt(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmSobel(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmFreiChen(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);

int main( int argc, char** argv ){
	IplImage * src = 0;
	IplImage * dst = 0;
	IplImage * dst_asm = 0;
	IplImage * dst_ini = 0;

	int		tiempos[6][CORRIDAS];
	long long int	promedios [6];
	
	//char* filename = argc == 2 ? argv[1] : (char*)"img/in/test2.bmp";
	//char* filename = argc == 2 ? argv[1] : (char*)"img/in/lucie12.jpg";
	char* filename = argc == 2 ? argv[1] : (char*)"img/in/lena-full.jpg";
	//char* filename = argc == 2 ? argv[1] : (char*)"img/in/lena.bmp";

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

	int i;
	for(i = 0; i < CORRIDAS; i++){
		//SOBEL
		__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
		cvSobel(src, dst, 1,0,3); 	
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
		
		tiempos[0][i] = tscl;
	
		testOperatorNoPrint(asmSobel,1,0);

		tiempos[1][i] = tscl;
		
		__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
		cvSobel(src, dst, 0,1,3); 	
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	
		tiempos[2][i] = tscl;

		testOperatorNoPrint(asmSobel,0,1);

		tiempos[3][i] = tscl;
	
		__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
		cvSobel(src, dst, 1,1,3);
		__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));

		tiempos[4][i] = tscl;
	
		testOperatorNoPrint(asmSobel,1,1);

		tiempos[5][i] = tscl;
	}
	
	promedios[0] = promedios[1] = promedios[2] = promedios[3] = promedios[4] = promedios[5] = 0;

	for(i = 0; i < CORRIDAS; i++){
		promedios[0] += tiempos[0][i];
		promedios[1] += tiempos[1][i];
		promedios[2] += tiempos[2][i];
		promedios[3] += tiempos[3][i];
		promedios[4] += tiempos[4][i];
		promedios[5] += tiempos[5][i];
	}

	promedios[0] /= CORRIDAS;
	promedios[1] /= CORRIDAS;
	promedios[2] /= CORRIDAS;
	promedios[3] /= CORRIDAS;
	promedios[4] /= CORRIDAS;
	promedios[5] /= CORRIDAS;	

	printf("cvSobel01 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[0]);
	printf("cvSobel10 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[2]);
	printf("cvSobel11 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[4]);
	printf("asmSobel01 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[1]);
	printf("asmSobel10 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[3]);
	printf("asmSobel11 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[5]);

	//SOBEL CV
	cvSet(dst, CV_RGB(0,0,0),NULL);
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
	cvSobel(src, dst, 1,0,3); 	
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	cvSaveImage("img/res/c/sobelDX.BMP", dst);
	printf("cvSobel10 demoro: %i\n", tscl);

	cvSet(dst, CV_RGB(0,0,0),NULL);
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
	cvSobel(src, dst, 0,1,3); 	
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	cvSaveImage("img/res/c/sobelDY.BMP", dst);
	printf("cvSobel01 demoro: %i\n", tscl);

	cvSet(dst, CV_RGB(0,0,0),NULL);
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));
	cvSobel(src, dst, 1,1,3);
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));
	cvSaveImage("img/res/c/sobelDXDY.BMP", dst);
	printf("cvSobel11 demoro: %i\n", tscl);

	//SOBEL
	testOperator(asmSobel,1,0);
	testOperator(asmSobel,0,1);
	testOperator(asmSobel,1,1);


	//PREWITT
	testOperator(asmPrewitt,1,0);
 	testOperator(asmPrewitt,0,1);
 	testOperator(asmPrewitt,1,1);

	//PREWITT
	testOperator(asmRoberts,1,0);	
	testOperator(asmRoberts,0,1);
	testOperator(asmRoberts,1,1);

	//FREI-CHEN

	testOperator(asmFreiChen,1,0);	
	testOperator(asmFreiChen,0,1);
	testOperator(asmFreiChen,1,1);


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


