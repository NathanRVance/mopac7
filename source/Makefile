#
#   Makefile for making the executable of program MOPAC
#
#
#    Valid Commands of this makefile
#
#	make gfortran	Makes mopac.exe with gfortran
#	make f2c	Makes mopac.exe with f2c
#	make g77	Makes mopac.exe with g77
#	make clean	Clean up source directory
#
EXE		= ../mopac.exe

mopac.exe:
		@echo "Usage: make <compiler>"

gfortran:
		gfortran -c -ffixed-line-length-0 -fno-automatic -frecord-marker=4 -w *.f
		gfortran -static -o $(EXE) *.o

f2c:
		f2c -w *.f 
		gcc -c *.c
		gcc -o $(EXE) *.o -lf2c -lm -static

g77:
		g77 -c -ffixed-line-length-0 -fno-automatic -finit-local-zero -w *.f
		g77 -o $(EXE) *.o

f77:
		f77 -w -O -static *.f -o $(EXE) 

clean:
		@mv fdate.c fdate.temp
		rm -f *.o
		rm -f *.c
		@mv fdate.temp fdate.c
