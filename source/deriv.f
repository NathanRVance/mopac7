      SUBROUTINE DERIV(GEO,GRAD)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      DIMENSION GRAD(*), GEO(3,*)
************************************************************************
*
*    DERIV CALCULATES THE DERIVATIVES OF THE ENERGY WITH RESPECT TO THE
*          INTERNAL COORDINATES. THIS IS DONE BY FINITE DIFFERENCES.
*
*    THE MAIN ARRAYS IN DERIV ARE:
*        LOC    INTEGER ARRAY, LOC(1,I) CONTAINS THE ADDRESS OF THE ATOM
*               INTERNAL COORDINATE LOC(2,I) IS TO BE USED IN THE
*               DERIVATIVE CALCULATION.
*        GEO    ARRAY \GEO\ HOLDS THE INTERNAL COORDINATES.
*        GRAD   ON EXIT, CONTAINS THE DERIVATIVES
*
************************************************************************
      COMMON / EULER/ TVEC(3,3), ID
      COMMON /OKMANY/ ISOK
      COMMON /GEOVAR/ NVAR,LOC(2,MAXPAR), IDUMY, DUMMY(MAXPAR)
      COMMON /MOLKST/ NUMAT,NAT(NUMATM),NFIRST(NUMATM),NMIDLE(NUMATM),
     1                NLAST(NUMATM), NORBS, NELECS,NALPHA,NBETA,
     2                NCLOSE,NOPEN,NDUMY,FRACT
      COMMON /GEOKST/ NATOMS,LABELS(NUMATM),
     1NA(NUMATM),NB(NUMATM),NC(NUMATM)
      COMMON /GRAVEC/ COSINE
      COMMON /GEOSYM/ NDEP, LOCPAR(MAXPAR), IDEPFN(MAXPAR),
     1LOCDEP(MAXPAR)
      COMMON /PATH  / LATOM,LPARAM,REACT(200)
      COMMON /UCELL / L1L,L2L,L3L,L1U,L2U,L3U
      COMMON /XYZGRA/ DXYZ(9*NUMATM)
      COMMON /ENUCLR/ ENUCLR
      COMMON /NUMCAL/ NUMCAL
      COMMON /HMATRX/ H(MPACK)
      COMMON /ATHEAT/ ATHEAT
      COMMON /KEYWRD/ KEYWRD
      COMMON /ERRFN / ERRFN(MAXPAR), AICORR(MAXPAR)
      COMMON /WORK3 / WORK2(4*MPACK)
      COMMON /GENRAL/ COORD(3,NUMATM), COLD(3,NUMATM*3), GOLD(MAXPAR),
     1 XPARAM(MAXPAR)
      CHARACTER*241 KEYWRD, LINE*80, GETNAM*80
      DIMENSION CHANGE(3), XJUC(3), AIDREF(MAXPAR)
      SAVE SCF1, HALFE, IDELTA, SLOW
      LOGICAL DEBUG, HALFE, SCF1, CI, PRECIS, SLOW, AIC, NOANCI,
     1AIFRST, ISOK, GEOOK, INT
      DATA ICALCN /0/
      IF(ICALCN.NE.NUMCAL) THEN
         AIFRST= (INDEX(KEYWRD,'RESTART').EQ.0)
         DEBUG = (INDEX(KEYWRD,'DERIV') .NE. 0)
         PRECIS= (INDEX(KEYWRD,'PREC') .NE. 0)
         INT   = (INDEX(KEYWRD,' XYZ') .EQ. 0)
         GEOOK = (INDEX(KEYWRD,'GEO-OK') .NE. 0)
         CI    = (INDEX(KEYWRD,'C.I.') .NE. 0)
         SCF1  = (INDEX(KEYWRD,'1SCF') .NE. 0)
         AIC=(INDEX(KEYWRD,'AIDER').NE.0)
         ICAPA=ICHAR('A')
         ILOWA=ICHAR('a')
         ILOWZ=ICHAR('z')
         IF(AIC.AND.AIFRST)THEN
            OPEN(UNIT=5,FILE=GETNAM('FOR005'),STATUS='OLD',BLANK='ZERO')
            REWIND 5
C
C  ISOK IS SET FALSE: ONLY ONE SYSTEM ALLOWED
C
            ISOK=.FALSE.
            DO 10 I=1,3
   10       READ(5,'(A)')LINE
            DO 30 J=1,1000
               READ(5,'(A)',END=40,ERR=40)LINE
************************************************************************
               DO 20 I=1,80
                  ILINE=ICHAR(LINE(I:I))
                  IF(ILINE.GE.ILOWA.AND.ILINE.LE.ILOWZ) THEN
                     LINE(I:I)=CHAR(ILINE+ICAPA-ILOWA)
                  ENDIF
   20          CONTINUE
************************************************************************
   30       IF(INDEX(LINE,'AIDER').NE.0)GOTO 60
   40       WRITE(6,'(//,A)')' KEYWORD "AIDER" SPECIFIED, BUT NOT'
            WRITE(6,'(A)')' PRESENT AFTER Z-MATRIX.  JOB STOPPED'
            STOP
   50       WRITE(6,'(//,A)')'  FAULT IN READ OF AB INITIO DERIVATIVES'
            WRITE(6,'(A)')'  DERIVATIVES READ IN ARE AS FOLLOWS'
            WRITE(6,'(6F12.6)')(AIDREF(J),J=1,I)
            STOP
   60       CONTINUE
            IF(NATOMS.GT.2)THEN
               J=3*NATOMS-6
            ELSE
               J=1
            ENDIF
            READ(5,*,END=50,ERR=50)(AIDREF(I),I=1,J)
            WRITE(6,'(/,A,/)')
     1' AB-INITIO DERIVATIVES IN KCAL/MOL/(ANGSTROM OR RADIAN)'
            WRITE(6,'(5F12.6)')(AIDREF(I),I=1,J)
            DO 70 I=1,NVAR
               IF(LOC(1,I).GT.3)THEN
                  J=3*LOC(1,I)+LOC(2,I)-9
               ELSEIF(LOC(1,I).EQ.3)THEN
                  J=LOC(2,I)+1
               ELSE
                  J=1
               ENDIF
   70       AIDREF(I)=AIDREF(J)
            WRITE(6,'(/,A,/)')
     1' AB-INITIO DERIVATIVES FOR VARIABLES'
            WRITE(6,'(5F12.6)')(AIDREF(I),I=1,NVAR)
            IF(NDEP.NE.0)THEN
               DO 90 I=1,NVAR
                  SUM=AIDREF(I)
                  DO 80 J=1,NDEP
                     IF(LOC(1,I).EQ.LOCPAR(J).AND.(LOC(2,I).EQ.IDEPFN(J)
     1.OR.LOC(2,I).EQ.3.AND.IDEPFN(J).EQ.14)) AIDREF(I)=AIDREF(I)+SUM
   80             CONTINUE
   90          CONTINUE
               WRITE(6,'(/,A,/)')
     1' AB-INITIO DERIVATIVES AFTER SYMMETRY WEIGHTING'
               WRITE(6,'(5F12.6)')(AIDREF(J),J=1,NVAR)
            ENDIF
         ENDIF
         ICALCN=NUMCAL
         IF(INDEX(KEYWRD,'RESTART') .EQ. 0) THEN
            DO 100 I=1,NVAR
  100       ERRFN(I)=0.D0
         ENDIF
         GRLIM=0.01D0
         IF(PRECIS)GRLIM=0.0001D0
         HALFE = (NOPEN.GT.NCLOSE.AND.FRACT.NE.2.D0.AND.FRACT.NE.0.D0
     1 .OR. CI)
         IDELTA=-7
*
*   IDELTA IS A MACHINE-PRECISION DEPENDANT INTEGER
*
         CHANGE(1)= 10.D0**IDELTA
         CHANGE(2)= 10.D0**IDELTA
         CHANGE(3)= 10.D0**IDELTA
C
C    CHANGE(I) IS THE STEP SIZE USED IN CALCULATING THE DERIVATIVES.
C    FOR "CARTESIAN" DERIVATIVES, CALCULATED USING DCART,AN
C    INFINITESIMAL STEP, HERE 0.000001, IS ACCEPTABLE. IN THE
C    HALF-ELECTRON METHOD A QUITE LARGE STEP IS NEEDED AS FULL SCF
C    CALCULATIONS ARE NEEDED, AND THE DIFFERENCE BETWEEN THE TOTAL
C    ENERGIES IS USED. THE STEP CANNOT BE VERY LARGE, AS THE SECOND
C    DERIVITIVE IN FLEPO IS CALCULATED FROM THE DIFFERENCES OF TWO
C    FIRST DERIVATIVES. CHANGE(1) IS FOR CHANGE IN BOND LENGTH,
C    (2) FOR ANGLE, AND (3) FOR DIHEDRAL.
C
      ENDIF
      IF(NVAR.EQ.0) RETURN
      IF(DEBUG)THEN
         WRITE(6,'('' GEO AT START OF DERIV'')')
         WRITE(6,'(F19.5,2F12.5)')((GEO(J,I),J=1,3),I=1,NATOMS)
      ENDIF
      GNORM=0.D0
      DO 110 I=1,NVAR
         GOLD(I)=GRAD(I)
         XPARAM(I)=GEO(LOC(2,I),LOC(1,I))
  110 GNORM=GNORM+GRAD(I)**2
      GNORM=SQRT(GNORM)
      SLOW=.FALSE.
      NOANCI=.FALSE.
      IF(HALFE) THEN
         NOANCI=(INDEX(KEYWRD,'NOANCI').NE.0 .OR. NOPEN.EQ.NORBS)
         SLOW=(NOANCI.AND.(GNORM .LT. GRLIM .OR. SCF1))
      ENDIF
      IF(NDEP.NE.0) CALL SYMTRY
      CALL GMETRY(GEO,COORD)
C
C  COORD NOW HOLDS THE CARTESIAN COORDINATES
C
      IF(HALFE.AND..NOT.NOANCI) THEN
         IF(DEBUG)WRITE(6,*) 'DOING ANALYTICAL C.I. DERIVATIVES'
         CALL DERNVO(COORD,DXYZ)
      ELSE
         IF(DEBUG)WRITE(6,*) 'DOING VARIATIONALLY OPIMIZED DERIVATIVES'
         CALL DCART(COORD,DXYZ)
      ENDIF
      IJ=0
      DO 150 II=1,NUMAT
         DO 140 IL=L1L,L1U
            DO 140 JL=L2L,L2U
               DO 140 KL=L3L,L3U
C$DOIT ASIS
                  DO 120 LL=1,3
  120             XJUC(LL)=COORD(LL,II)+TVEC(LL,1)*IL+TVEC(LL,2)*JL+TVEC
     1(LL,3)*KL
                  IJ=IJ+1
C$DOIT ASIS
                  DO 130 KK=1,3
                     COLD(KK,IJ)=XJUC(KK)
  130             CONTINUE
  140    CONTINUE
  150 CONTINUE
      STEP=CHANGE(1)
      CALL JCARIN (COORD,XPARAM,STEP,PRECIS,WORK2,NCOL)
      CALL MXM (WORK2,NVAR,DXYZ,NCOL,GRAD,1)
      IF (PRECIS) THEN
         STEP=0.5D0/STEP
      ELSE
         STEP=1.0D0/STEP
      ENDIF
      DO 160 I=1,NVAR
  160 GRAD(I)=GRAD(I)*STEP
C
C  NOW TO ENSURE THAT INTERNAL DERIVATIVES ACCURATELY REFLECT CARTESIAN
C  DERIVATIVES
C
      IF(INT.AND. .NOT. GEOOK .AND. NVAR.GE.NUMAT*3-6.AND.ID.EQ.0)THEN
C
C  NUMBER OF VARIABLES LOOKS O.K.
C
         SUM=DOT(GRAD,GRAD,NVAR)
         IF(SUM.LT.2.D0.AND.DOT(DXYZ,DXYZ,3*NUMAT).GT.MAX(4.D0,SUM*4.D0)
     1)THEN
C
C OOPS, LOOKS LIKE AN ERROR.
C
            DO 170 I=1,NVAR
               J=XPARAM(I)/3.141D0
               IF(LOC(2,I).EQ.2.AND.LOC(1,I).GT.3.AND.
     1 ABS(XPARAM(I)-J*3.1415926D0).LT.0.005D0 )THEN
C
C  ERROR LOCATED, BUT CANNOT CORRECT IN THIS RUN
C
                  WRITE(6,'(//,3(A,/),I3,A)')
     1' INTERNAL COORDINATE DERIVATIVES DO NOT REFLECT',
     2' CARTESIAN COORDINATE DERIVATIVES',
     3' TO CORRECT ERROR, INCREASE DIHEDRAL OF ATOM',LOC(1,I),
     4' BY 90 DEGREES'
                  WRITE(6,'(//,A)')'     CURRENT GEOMETRY'
                  CALL GEOUT(6)
                  STOP
               ENDIF
  170       CONTINUE
         ENDIF
      ENDIF
C
C  THIS CODE IS ONLY USED IF THE KEYWORD NOANCI IS SPECIFIED
      IF(SLOW)THEN
         IF(DEBUG)WRITE(6,*) 'DOING FULL SCF DERIVATIVES'
         CALL DERITR(ERRFN,GEO)
C
C THE ARRAY ERRFN HOLDS THE EXACT DERIVATIVES MINUS THE APPROXIMATE
C DERIVATIVES
         DO 180 I=1,NVAR
  180    ERRFN(I)=ERRFN(I)-GRAD(I)
      ENDIF
      COSINE=DOT(GRAD,GOLD,NVAR)/
     1SQRT(DOT(GRAD,GRAD,NVAR)*DOT(GOLD,GOLD,NVAR)+1.D-20)
      DO 190 I=1,NVAR
  190 GRAD(I)=GRAD(I)+ERRFN(I)
      IF(AIC)THEN
         IF(AIFRST)THEN
            AIFRST=.FALSE.
            DO 200 I=1,NVAR
  200       AICORR(I)=-AIDREF(I)-GRAD(I)
         ENDIF
C#         WRITE(6,'('' GRADIENTS BEFORE AI CORRECTION'')')
C#         WRITE(6,'(10F8.3)')(GRAD(I),I=1,NVAR)
         DO 210 I=1,NVAR
  210    GRAD(I)=GRAD(I)+AICORR(I)
      ENDIF
  220 IF(DEBUG) THEN
         WRITE(6,'('' GRADIENTS'')')
         WRITE(6,'(10F8.3)')(GRAD(I),I=1,NVAR)
         IF(SLOW)THEN
            WRITE(6,'('' ERROR FUNCTION'')')
            WRITE(6,'(10F8.3)')(ERRFN(I),I=1,NVAR)
         ENDIF
      ENDIF
      IF(DEBUG)
     1WRITE(6,'('' COSINE OF SEARCH DIRECTION ='',F30.6)')COSINE
      RETURN
      END
