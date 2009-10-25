; typedef struct _IplImage
; {
;     int nSize;
;     int ID;
;     int nChannels;
;     int alphaChannel;
;     int depth;
;     char colorModel[4];
;     char channelSeq[4];
;     int dataOrder;
;     int origin;
;     int align;
;     int width;
;     int height;
;     struct _IplROI *roi;
;     struct _IplImage *maskROI;
;     void *imageId;
;     struct _IplTileInfo *tileInfo;
;     int imageSize;
;     char *imageData;
;     int widthStep;
;     int BorderMode[4];
;     int BorderConst[4];
;     char *imageDataOrigin;
; }
; IplImage;

%define DEPTH		16
%define WIDTH		40
%define HEIGHT		44
%define IMAGE_DATA 	68
%define WIDTH_STEP	72