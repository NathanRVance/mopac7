      SUBROUTINE BRLZON(FMATRX,FMAT2D,N3,SEC,VEC, B, MONO3, STEP,MODE)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      DIMENSION FMATRX((N3*(N3+1))/2), FMAT2D(N3,N3), B(MONO3,*)
      COMPLEX SEC(MONO3,MONO3), VEC(MONO3,MONO3)
***********************************************************************
*
*   IF MODE IS 1 THEN
*   BRLZON COMPUTES THE PHONON SPECTRUM OF A LINEAR POLYMER GIVEN
*   THE WEIGHTED HESSIAN MATRIX.
*   IF MODE IS 2 THEN
*   BRLZON COMPUTES THE ELECTRONIC ENERGY BAND STRUCTURE OF A LINEAR
*   POLYMER GIVEN THE FOCK MATRIX.
*
*                 ON INPUT
*
*   IF MODE IS 1 THEN
*         FMATRX IS THE MASS-WEIGHTED HESSIAN MATRIX, PACKED LOWER
*                   HALF TRIANGLE
*         N3     IS 3*(NUMBER OF ATOMS IN UNIT CELL) = SIZE OF FMATRX
*         MONO3  IS 3*(NUMBER OF ATOMS IN PRIMITIVE UNIT CELL)
*         FMAT2D, SEC, VEC ARE SCRATCH ARRAYS
*   IF MODE IS 2 THEN
*         FMATRX IS THE FOCK MATRIX, PACKED LOWER HALF TRIANGLE
*         N3     IS NUMBER OF ATOMIC ORBITALS IN SYSTEM = SIZE OF FMATRX
*         MONO3  IS NUMBER OF ATOMIC ORBITALS IN FUNDAMENTAL UNIT CELL
*         FMAT2D, SEC, VEC ARE SCRATCH ARRAYS
*
***********************************************************************
      COMMON /KEYWRD/ KEYWRD
      CHARACTER KEYWRD*241
      REAL EIGS(MAXPAR)
      COMPLEX PHASE
      FACT=6.023D23
      C=2.998D10
      TWOPI=2.D0*ACOS(-1.D0)
C
C  NCELLS IS THE NUMBER OF PRIMITIVE UNIT CELLS IN THE UNIT CELL
C
      NCELLS=N3/MONO3
C
C  PUT THE ENERGY MATRIX INTO SQUARE MATRIX FORM
C
      K=0
      DO 10 I=1,N3
         DO 10 J=1,I
            K=K+1
   10 FMAT2D(I,J)=FMATRX(K)
C
C   STEP IS THE STEP SIZE IN THE BRILLOUIN ZONE (BOUNDARIES: 0.0 - 0.5),
C   THERE ARE M OF THESE.
C   MONO3 IS THE SIZE OF ONE MER (MONOMERIC UNIT)
C
      M=0.5D0/STEP+1
      DO 70 LOOP=1,M
         DO 20 I=1,MONO3
            DO 20 J=1,MONO3
   20    SEC(I,J)=0
         CAY=(LOOP-1)*STEP
         DO 40 I=1,N3,MONO3
            RI=(I-1)/MONO3
C
C IF THE PRIMITIVE UNIT CELL IS MORE THAN HALF WAY ACROSS THE UNIT CELL,
C CONSIDER IT AS BEING LESS THAN HALF WAY ACROSS, BUT IN THE OPPOSITE
C DIRECTION.
C
            IF(RI.GT.NCELLS/2) RI=RI-NCELLS
C
C  PHASE IS THE COMPLEX PHASE EXP(I.K.R(I)*(2PI))
C
            PHASE=EXP(SQRT(CMPLX(-1.D0,0.D0))*CAY*RI*TWOPI)
            DO 30 II=1,MONO3
               III=II+I-1
               DO 30 JJ=1,II
   30       SEC(II,JJ)=SEC(II,JJ)+FMAT2D(III,JJ)*PHASE
   40    CONTINUE
         CALL CDIAG(SEC,EIGS,VEC,MONO3)
         IF(MODE.EQ.1)THEN
C
C  CONVERT INTO RECIPRICAL CENTIMETERS
C
            DO 50 I=1,MONO3
   50       B(I,LOOP)=SIGN(SQRT(FACT*ABS(EIGS(I)*1.D5))/(C*TWOPI),
     1                DBLE(EIGS(I)))
         ELSE
            DO 60 I=1,MONO3
   60       B(I,LOOP)=EIGS(I)
         ENDIF
   70 CONTINUE
      BOTTOM=1.D6
      TOP=-1.D6
      DO 80 I=1,MONO3
         DO 80 J=1,M
            BOTTOM=MIN(BOTTOM,B(I,J))
   80 TOP=MAX(TOP,B(I,J))
      IF(MODE.EQ.1)THEN
         WRITE(6,'(//,A,F6.3,/)')
     1' FREQUENCIES IN CM(-1) FOR PHONON SPECTRUM ACROSS BRILLOUIN ZONE'
         DO 90 I=1,MONO3
            WRITE(6,'(/,A,I4,/)')'  BAND:',I
   90    WRITE(6,'(6(F6.3,F7.1))')((J-1)*STEP,B(I,J),J=1,M)
         STOP
      ELSE
         WRITE(6,'(//,A,F6.3,/)')
     1' ENERGIES (IN EV) OF ELECTRONIC BANDS IN BAND STRUCTURE'
         DO 100 I=1,MONO3
            WRITE(6,'(A,/,A,I4,/,A)')'  .','  CURVE',I,'CURVE DATA ARE'
  100    WRITE(6,'(6(F6.3,F7.2))')((J-1)*STEP,B(I,J),J=1,M)
      ENDIF
      CALL DOFS(B,MONO3,M,FMAT2D,500,BOTTOM,TOP)
      RETURN
      END
