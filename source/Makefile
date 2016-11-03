#
#   Makefile for making the executable of program MOPAC
#
#
#    Valid Commands of this makefile
#
#	make dynamic	Makes mopac.exe with gfortran
#	make static	Makes mopac.exe statically linked
#	make clean	Clean up source directory
#
EXE		= ../mopac.exe
BUILD		= gfortran
COMPFLAGS	= -c -ffixed-line-length-0 -fno-automatic -frecord-marker=4 -w
LINKFLAGS	= -o $(EXE)
mopac.exe:
		@echo "Usage: make <compiler>"

gfortran:
		gfortran -c -ffixed-line-length-0 -fno-automatic -frecord-marker=4 -w *.f
		gfortran $(FFLAGS) -o $(EXE) *.o

dynamic:
		$(BUILD) $(COMPFLAGS) *.f
		$(BUILD) $(LINKFLAGS) *.o

static:
		$(BUILD) $(COMPFLAGS) *.f
		$(BUILD) $(LINKFLAGS) -static *.o

clean:
		@mv fdate.c fdate.temp
		rm -f *.o
		rm -f *.c
		@mv fdate.temp fdate.c

# Unsupported targets

f2c:
		f2c -w *.f 
		gcc -c *.c
		gcc -o $(EXE) *.o -lf2c -lm -static

g77:
		g77 -c -ffixed-line-length-0 -fno-automatic -finit-local-zero -w *.f
		g77 -o $(EXE) *.o

f77:
		f77 -w -O -static *.f -o $(EXE) 
