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

NASMFLAGS = -f elf

INCLUDES = `pkg-config --cflags --libs opencv`

CFLAGS = -Wall $(SVNDEF) $(OSDEF) $(INCLUDES)

GFLAGS = -c -Wall $(SVNDEF) $(OSDEF) $(INCLUDES)

LDFLAGS = 

SOURCES = bordes.c

ASMOBJECTS = $(SOURCES:.asm=.o)
OBJECTS = $(SOURCES:.c=.o)

EXECUTABLE = tp1

VERDE="\e[1;32m"
BLANCO="\e[0;29m"
AZUL="\e[1;34m"

all: start $(SOURCES) $(EXECUTABLE) listo

start:
	@echo -e $(VERDE)Instalando TP 1 v.$(shell svnversion -n .)$(BLANCO);

$(EXECUTABLE): $(OBJECTS)
	@echo -en $(BLANCO)"Linking TP 1...";
#$(CC) $(CFLAGS) $(addprefix out/, $(+F)) -o $@
	@$(CC) $(CFLAGS) -o $@ $(addprefix out/, $(+F))
	@echo -e "                                  "$(AZUL)[ $(VERDE)OK $(AZUL)]

%.o: %.asm
	@$(NASM) $(NASMFLAGS) $< -o out/$@;
	@longitud=`echo "Compiling $*..." | wc -c`; \
	cantEsp=`expr 60 - $$longitud`; \
	a=""; \
	while [ $$cantEsp -ne 0 ]; do a="$$a\0040"; cantEsp=`expr $$cantEsp - 1`; done; \
	echo -e $(BLANCO)"Compiling $*..."$$a$(AZUL)[ $(VERDE)OK $(AZUL)] $(BLANCO)

.c.o:
	@$(CC) $(CFLAGS) $< -o out/$@;
	@longitud=`echo "Compiling $*..." | wc -c`; \
	cantEsp=`expr 60 - $$longitud`; \
	a=""; \
	while [ $$cantEsp -ne 0 ]; do a="$$a\0040"; cantEsp=`expr $$cantEsp - 1`; done; \
	echo -e $(BLANCO)"Compiling $*..."$$a$(AZUL)[ $(VERDE)OK $(AZUL)] $(BLANCO)

clean:
	@rm -f $(EXECUTABLE) out/*.o
	@echo -en $(BLANCO)"Cleaning objects and executables files...       "
	@echo -e $(AZUL)[ $(VERDE)OK $(AZUL)]

listo:
	@echo -e $(AZUL)"Tp1 is ready!, enjoy."; \
	echo "Want execute Tp1 now? (y/n): "; \
	read key; if [ $$key == "y" ]; then ./tp1; fi;
