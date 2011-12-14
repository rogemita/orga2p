#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define testOperator(OPERATOR, XDERIVATE, YDERIVATE)						\
	cvSet(dst_asm, CV_RGB(0,0,0),NULL);								\
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));				\
	OPERATOR (src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, XDERIVATE, YDERIVATE);	\
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));		\
	cvSaveImage("img/res/asm/" #OPERATOR  #XDERIVATE  #YDERIVATE ".bmp", dst_asm, p);			\
	printf(#OPERATOR #XDERIVATE #YDERIVATE " demoro: %i\n", tscl);

#define testOperatorNoPrint(OPERATOR, XDERIVATE, YDERIVATE)						\
	cvSet(dst_asm, CV_RGB(0,0,0),NULL);								\
	__asm__ __volatile__ ("rdtsc;mov %%eax,%0" : : "g" (tscl));				\
	OPERATOR (src, dst_asm, cvGetSize (src).width, cvGetSize(src).height, XDERIVATE, YDERIVATE);	\
	__asm__ __volatile__ ("rdtsc;sub %0,%%eax;mov %%eax,%0" : : "g" (tscl));		\
	cvSaveImage("img/res/asm/" #OPERATOR  #XDERIVATE  #YDERIVATE ".bmp", dst_asm, p);			

#define	CORRIDAS	1
#define PI		3.14159265
#define GRID_ALPHA	900

typedef unsigned int uint;

/*
		public static function applyHough(data:ByteArray, width:uint, height:uint, threshold:uint = 5, gridAlpha:uint = 180, outBmpData:BitmapData = null):Vector.<Vector.<Point>>
		{
			var i		:int;
			var j		:int;
			var k		:int;
			var l		:int;
			var maxRho	:uint					= uint((Math.sqrt(2) * Math.max(height, width)) / 2);		
			var angStep	:Number					= Math.PI / (gridAlpha);
			var currRho	:Number;
			var currAng	:Number;
			var r		:int;
			
			threshold	= Math.min(height, width) / threshold;
			
			var bins	:Vector.<Vector.<uint>>	= new Vector.<Vector.<uint>>(2 * maxRho,true);
			for(i = 0; i < 2 * maxRho; i++)
				bins[i]	= new Vector.<uint>(gridAlpha, true);
			
			data.position	= 0;
*/

IplImage* applyHough(IplImage* src, char threshold){
    int i,j,k,l;
    uint maxRho = PI * (src->width > src->height ? src->width : src->height)/ 2;
    float angStep = PI / GRID_ALPHA;
    float currRho, currAng;
    int r;
    threshold = (src->width < src->height ? src->width : src->height) / threshold;
    uint** bins;
    char pixel;

    bins = (uint**)malloc(2 * maxRho * sizeof(uint*));
    for (i = 0; i < 2 * maxRho; i++) 
      bins[i] = (uint*)malloc(GRID_ALPHA * sizeof(int));

    for(j = 0; j < src->height; j++){
	    for(i = 0; i < src->width; i++){
		    pixel	= src->imageData[src->width * j + i];
		    if(pixel > threshold){
			    for(k = 0; k < GRID_ALPHA; k++){
				    currRho	= i * cos(k * angStep) + j * sin(k * angStep);
				    r		= (int)(currRho - src->width/2 + maxRho);
				    if(r > 0 && r < maxRho * 2)
					    bins[r][k]++;	
			    } 		
		    }
	    }
    }
    CvSize dstSize;
    dstSize.width	= 2 * maxRho;
    dstSize.height	= GRID_ALPHA;
    
    IplImage* dstRef = cvCreateImage (dstSize, IPL_DEPTH_8U, 1);

    if(dstRef != 0){
      uint point;
      for(i = 0; i < 2 * maxRho; i++){
	      for(j = 0; j < GRID_ALPHA; j++){
		      point	= bins[i][j];
		      if(point > threshold){
			      dstRef->imageData[i * GRID_ALPHA + j] = 0xFF;//(char)(point * 0xFF);
		      }
	      }
      }
    }
    
    for (i = 0; i < 2 * maxRho; i++) 
      free(bins[i]);
    
    free(bins);
    
    return dstRef;
}

/*
		
			var pixel	:uint;
			var slope	:Number;
			var x1		:Number;
			var y1		:Number;
			
			var lines	:Vector.<Vector.<Number>>	= new Vector.<Vector.<Number>>();			
			
			var NSize	:uint	= 4;
			var dx		:int;
			var dy		:int;
			var da		:int;
			var dr		:int;
			var dt		:int;
			var keep	:Boolean;
			var line	:Vector.<Number>;
			var lenI	:uint;
			
			var outLines:Vector.<Vector.<Point>>;
			
			for (i = 0; i < gridAlpha; i++) {
				keep	= true;
				for (j = NSize; (j < maxRho * 2 - NSize) && keep; j++) { 
					
					// Only consider points above threshold 
					if (bins[j][i] > threshold) { 
						
						pixel = bins[j][i]; 
						
						// Check that this peak is indeed the local maxima 
						for (dx = -NSize; (dx <= NSize) && keep; dx++) { 
							for (dy = -NSize; (dy <= NSize) && keep; dy++) { 
								dt = i + dx; 
								dr = j + dy; 
								if (dt < 0) 
									dt = dt + gridAlpha; 
								else if (dt >= gridAlpha) 
									dt = dt - gridAlpha; 
								if (bins[dr][da] > pixel) { 
									// found a bigger point nearby, skip 
									keep	= false; 
								} 
							} 
						} 
						if(keep){
							line	= new Vector.<Number>(2, true);
							line[0]	= j* 1.0 - maxRho + width/2;
							line[1]	= (i * angStep);
							lines.push(line);
						}
					} 
				} 
			} 			
			
			lenI	= lines.length;
			outLines= new Vector.<Vector.<Point>>(lenI, true);
			//turn bins into intersection points FUCK YEAH!
			for(i = 0; i < lenI; i++){
				currRho			= lines[i][0];
				currAng			= lines[i][1];
				outLines[i]		= new Vector.<Point>(2,true);
				outLines[i][0]	= new Point();
				outLines[i][1]	= new Point();
				
				if(currAng == 0){//horizontal line
					//do it
					outLines[i][0].x	= 0;
					outLines[i][0].y	= currRho;
					outLines[i][1].x	= width;
					outLines[i][1].y	= currRho;
				}else if(currAng == (Math.PI / 2)){//vertical line
					//do it
					outLines[i][0].y	= 0;
					outLines[i][0].x	= currRho;
					outLines[i][1].y	= height;
					outLines[i][1].x	= currRho;					
				}else{
					//take slope
					slope	= Math.tan(currAng + Math.PI / 2);
					x1		= currRho * Math.cos(currAng);
					y1		= currRho * Math.sin(currAng);
					//take y crossing
					outLines[i][0].x		= 0;
					outLines[i][0].y		= slope * (0 -x1) + y1;
					outLines[i][1].x		= Number(width);
					outLines[i][1].y		= slope * (Number(width) -x1) + y1;
					x1					= y1;
					
				}
			}
			return outLines;
		}
*/


extern void asmRoberts(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmPrewitt(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmSobel(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);
extern void asmFreiChen(IplImage * src, IplImage * dst, int ancho, int alto, int xorder, int yorder);

int main( int argc, char** argv ){
	IplImage * src = 0;
	IplImage * dst = 0;
	IplImage * dst_asm = 0;
	IplImage * dst_ini = 0;

	int p[3];
	p[0] = CV_IMWRITE_JPEG_QUALITY;
	p[1] = 60;
	p[2] = 0;
	
	
	//int		tiempos[6][CORRIDAS];
	//long long int	promedios [6];
	
	//char* filename = argc == 2 ? argv[1] : (char*)"img/in/test2.bmp";
	//char* filename = argc == 2 ? argv[1] : (char*)"img/in/lucie12.jpg";
	char *filename = argc == 3? argv[2] : (char*)"img/in/lena-full.jpg";
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

	printf("post carga imagenes\n");

	/*int i;
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
	}*/
	
	/*promedios[0] = promedios[1] = promedios[2] = promedios[3] = promedios[4] = promedios[5] = 0;
	int i;
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
	printf("asmSobel11 tarda en un promedio de %i corridas: %lld\n", CORRIDAS, promedios[5]);*/

	//SOBEL CV
	/*cvSet(dst, CV_RGB(0,0,0),NULL);
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
	printf("cvSobel11 demoro: %i\n", tscl);*/

	//SOBEL
	if (argc > 1){
		if ( !strcmp (argv[1], "r3") ) {
			testOperator(asmSobel,1,0);
		}
		if ( !strcmp (argv[1], "r4") ) {
			testOperator(asmSobel,0,1);
		}
		if ( !strcmp (argv[1], "r5") ) {
			testOperator(asmSobel,1,1);
		}
	
		//PREWITT
		//testOperator(asmPrewitt,1,0);
		//testOperator(asmPrewitt,0,1);
		if ( !strcmp (argv[1], "r2") ) {
			testOperator(asmPrewitt,1,1);
		}
	
		//ROBERTS
		//testOperator(asmRoberts,1,0);	
		//testOperator(asmRoberts,0,1);
		if ( !strcmp (argv[1], "r1") ) {
			testOperator(asmRoberts,1,1);
		}
	
		//FREI-CHEN
		//testOperator(asmFreiChen,1,0);	
		//testOperator(asmFreiChen,0,1);
		if ( !strcmp (argv[1], "r6") ) {
			testOperator(asmFreiChen,1,1);
		}
	}
	
	cvSaveImage("img/res/asm/hough.bmp", applyHough(src, 0x05), p);		
// 	cvReleaseData(src);
// 	cvReleaseData(dst);
// 	cvReleaseData(dst_asm);
// 	cvReleaseData(dst_ini);
// 	cvReleaseImage(&src);
// 	cvReleaseImage(&dst);
// 	cvReleaseImage(&dst_asm);
// 	cvReleaseImage(&dst_ini);

	return 0;
}


