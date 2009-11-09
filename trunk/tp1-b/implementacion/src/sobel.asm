%include "include/offset.inc"
%include "include/macros.mac"
%include "include/tp1bSobelPrewitt.mac"

%define SRC		[ebp + 8]
%define DST		[ebp + 12]
%define WIDTH 		[ebp + 16]
%define HEIGHT		[ebp + 20]
%define XORDER		[ebp + 24]
%define YORDER		[ebp + 28]

global	asmSobel,	asmPrewitt

section .text

asmSobel:
	sobelPrewitt 1	

asmPrewitt:
	sobelPrewitt 0