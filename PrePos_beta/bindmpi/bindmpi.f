C
C     Bind all files generated by MPI-processes to a unified file.
C     Version 1.1.2 by tmishima, 20240704
C
C     Usage:
C     bindmpi base_file_name(excluding pid such as TEST-MECH.nod)
C
      USE ISO_FORTRAN_ENV
      IMPLICIT NONE
C
      INTEGER, PARAMETER :: FUNIT = 1000
C
      INTEGER :: NPROCS
      INTEGER :: I, J
      INTEGER :: CURRENT
      INTEGER :: STAT
      CHARACTER(64) :: FILE_BASE
      CHARACTER(2) :: FEXT
      CHARACTER(512) :: BUFFER
      CHARACTER(4) :: ENV
      LOGICAL :: LEXIST
      LOGICAL :: LTRECT = .FALSE.
      INTEGER :: TAB1, TAB2
C
C
C     GET BASE_FILE_NAME(FROM COMMAND LINE/INTERACTIVE)
C
      CALL GET_FILE_NAME(FILE_BASE)
C
C
C     INQUIRE EXISTING FILES
C
      NPROCS = 0
      DO 
        WRITE(FEXT, '(I2.2)') NPROCS
        INQUIRE(FILE = TRIM(FILE_BASE)//'.'//FEXT, EXIST = LEXIST)
        IF(.NOT.LEXIST) EXIT
        NPROCS = NPROCS+1
      END DO
      IF(NPROCS .EQ. 0) STOP 'Nothing to do!'
C
C
C     OPEN EXISTING INPUT FILES
C
      DO I = 1, NPROCS
        WRITE(FEXT, '(I2.2)') I-1
        OPEN(FUNIT+I, FILE = TRIM(FILE_BASE)//'.'//FEXT)
        WRITE(*,*) TRIM(FILE_BASE)//'.'//FEXT//' is opened.'
      END DO
C
C
C     OPEN OUTPUT FILE(BASE_FILE_NAME)
C
      OPEN(FUNIT, FILE = TRIM(FILE_BASE))
      WRITE(*,*) 'Writing to '//TRIM(FILE_BASE)//' ...'
C
C
C     BIND FILES TO A UNIFIED ONE
C
      IF(FILE_BASE(INDEX(FILE_BASE, '.'):) .EQ. '.pic') THEN
        CALL GET_ENVIRONMENT_VARIABLE('T-RECT', ENV)
        IF(LEN_TRIM(ENV) .GT. 0) READ(ENV, *) LTRECT
        DO
          DO CURRENT = 1, NPROCS
            READ(FUNIT+CURRENT, '(A)', IOSTAT = STAT) BUFFER
            IF(STAT .EQ. IOSTAT_END) EXIT
            DO J = 1, LEN(BUFFER)
              IF(BUFFER(J:J).NE.' ') EXIT
            END DO
            TAB1 = INDEX(BUFFER(J:), ' ')+J-1
            IF(LTRECT) THEN
              TAB2 = LEN_TRIM(BUFFER)
            ELSE
              TAB2 = INDEX(BUFFER, 'T-RECT')-2
            END IF
            IF(CURRENT .NE. NPROCS) THEN
              IF(CURRENT .EQ. 1) THEN
                WRITE(FUNIT, '(A)', ADVANCE = 'NO') BUFFER(   1: TAB2)
              ELSE
                WRITE(FUNIT, '(A)', ADVANCE = 'NO') BUFFER(TAB1: TAB2)
              END IF
            ELSE
              IF(CURRENT .EQ. 1) THEN
                WRITE(FUNIT, '(A)') BUFFER(   1:TAB2)
              ELSE
                WRITE(FUNIT, '(A)') BUFFER(TAB1:TAB2)
              END IF
            END IF
          END DO
          IF(STAT .EQ. IOSTAT_END) EXIT
        END DO
      ELSE
        CURRENT = 1
        DO
         READ(FUNIT+CURRENT, '(A)', IOSTAT = STAT) BUFFER
         IF(STAT .EQ. IOSTAT_END) THEN
           IF(CURRENT .GE. NPROCS) THEN
             EXIT
           ELSE
             CURRENT = CURRENT+1
           END IF
         ELSE IF(INDEX(BUFFER, 'STEP') .GT. 0) THEN
           IF(CURRENT .GE. NPROCS) THEN
             WRITE(FUNIT, '(A)') TRIM(BUFFER)
             WRITE(*,*)          TRIM(BUFFER)
             READ(FUNIT+CURRENT, '(A)', IOSTAT = STAT) BUFFER
             IF(STAT .NE. 0) STOP 'READ ERROR: MAYBY INVALID FILE!'
             WRITE(FUNIT, '(A)') TRIM(BUFFER)
             CURRENT = 1
           ELSE
             READ(FUNIT+CURRENT, '(A)', IOSTAT = STAT) BUFFER
             IF(STAT .NE. 0) STOP 'READ ERROR: MAYBY INVALID FILE!'
             CURRENT = CURRENT+1
           END IF
         ELSE IF(STAT .EQ. 0) THEN
           WRITE(FUNIT, '(A)') TRIM(BUFFER)
         ELSE
           STOP 'READ ERROR: MAYBY INVALID FILE!'
         END IF
        END DO
      END IF
C
C
C     CLOSE OPENED FILES.
C
      DO I = 0, NPROCS
        CLOSE(FUNIT+I)
      END DO
C
      WRITE(*,*) 'Done!'
C
      CONTAINS
        SUBROUTINE GET_FILE_NAME(FILE_BASE)
        IMPLICIT NONE
        CHARACTER(*), INTENT(OUT) :: FILE_BASE
        INTEGER :: I, LENGTH, STATUS
        CHARACTER(:), ALLOCATABLE :: ARG
        INTRINSIC :: COMMAND_ARGUMENT_COUNT, GET_COMMAND_ARGUMENT
        IF(COMMAND_ARGUMENT_COUNT() .EQ. 1) THEN
          CALL GET_COMMAND_ARGUMENT(1, LENGTH = LENGTH, STATUS = STATUS)
          ALLOCATE (CHARACTER(LENGTH) :: ARG)
          CALL GET_COMMAND_ARGUMENT(1, ARG, STATUS = STATUS)
          FILE_BASE = ARG
          DEALLOCATE (ARG)
        ELSE
          WRITE(*,*)
     +     'INPUT BASE FILE NAME(excluding pid such as TEST-MECH.nod):'
          READ(*,*) FILE_BASE
        END IF
        RETURN
        END
C
      END
