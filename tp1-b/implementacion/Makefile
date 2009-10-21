#
# ORGANIZACION Y ARQUITECTURA DEL COMPUTADOR II 
#
# Trabajo Practico Nro. 1
#
#

OSDEF := -D'OS_LINUX="1"'

SVNDEF := -D'SVN_REV="$(shell svnversion -n .)"'

VPATH = src:

CC = gcc -g

GG = g++ -g

LD = ld

NASM = nasm

NASMFLAGS = -f elf -g

INCLUDES = `pkg-config --cflags --libs opencv`

#CFLAGS = -Wall $(SVNDEF) $(OSDEF) $(INCLUDES)
CFLAGS = -Wall $(INCLUDES)

GFLAGS = -c -Wall $(SVNDEF) $(OSDEF) $(INCLUDES)

LDFLAGS = 

SOURCES = bordes.c
<<<<<<< .mine
ASMSOURCES = asm_sobelf.asm
=======
ASMSOURCES = asm_sobel.asm asm_prewitt.asm asm_roberts.asm
>>>>>>> .r21

ASMOBJECTS = $(ASMSOURCES:.asm=.o)
OBJECTS = $(SOURCES:.c=.o)

EXECUTABLE = tp1

VERDE="\e[1;32m"
BLANCO="\e[0;29m"
AZUL="\e[1;34m"

all: start $(SOURCES) $(ASMSOURCES) $(EXECUTABLE) listo

start:
	@echo -e $(VERDE)Instalando TP 1 v.$(shell svnversion -n .)$(BLANCO);

$(EXECUTABLE): $(OBJECTS) $(ASMOBJECTS)
	@echo -en $(BLANCO)"Linking TP 1...";
	@$(CC) $(CFLAGS) $(addprefix out/, $(+F)) -o $@
	@echo -e "                                  "$(AZUL)[ $(VERDE)OK $(AZUL)] $(BLANCO)

%.o: %.asm
	@$(NASM) $(NASMFLAGS) $< -o out/$@;
	@longitud=`echo "Compiling $*..." | wc -c`; \
	cantEsp=`expr 60 - $$longitud`; \
	a=""; \
	while [ $$cantEsp -ne 0 ]; do a="$$a\0040"; cantEsp=`expr $$cantEsp - 1`; done; \
	echo -e $(BLANCO)"Compiling $*..."$$a$(AZUL)[ $(VERDE)OK $(AZUL)] $(BLANCO)

.c.o:
	@$(CC) $(GFLAGS) $< -o out/$@;
	@longitud=`echo "Compiling $*..." | wc -c`; \
	cantEsp=`expr 60 - $$longitud`; \
	a=""; \
	while [ $$cantEsp -ne 0 ]; do a="$$a\0040"; cantEsp=`expr $$cantEsp - 1`; done; \
	echo -e $(BLANCO)"Compiling $*..."$$a$(AZUL)[ $(VERDE)OK $(AZUL)] $(BLANCO)

clean:
	@rm -f $(EXECUTABLE) out/*.o
	@echo -en $(BLANCO)"Cleaning objects and executables files...       "
	@echo -e $(AZUL)[ $(VERDE)OK $(AZUL)] $(BLANCO)

listo:
	@echo -e $(AZUL)"Tp1 is ready!, enjoy." $(BLANCO);
