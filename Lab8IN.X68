*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    		ORG     $3000      
*Clock variables              
HOUR        DC.B    23
MINUTE      DC.B    59
SECOND      DC.B    55
COUNTER     DC.B    39

*Display Variables
HARDWARE    EQU     $E00000     ;base address of hardware devices
CONVERT     DC.B    $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F ; 0, 1, 2, 3, 4, 5, 6, 7, 8, 9. 
DIGIT1      EQU     $0
DIGIT2      EQU     $2
DIGIT3      EQU     $4
DIGIT4      EQU     $6
DIGIT5      EQU     $8
DIGIT6      EQU     $A
DIGIT7      EQU     $C
DIGIT8      EQU     $E



            ORG    $8000  
START:      MOVE.L   #ISR6,$78
            MOVE.L   #ISR7,$7C 

* Place interupt program in vector table
MAIN        MOVE.L  #32,D0          ;task number 32
            CLR.B   D1              ;parameter: display window
            TRAP    #15             ;system call
            
            *HARDWARE CLOCK*
            LEA      CONVERT,A1
            
            LEA      HARDWARE,A0        ;writing '-'s to clock
            MOVE.B   #$40,DIGIT3(A0)
            MOVE.B   #$40,DIGIT6(A0)   
            
            CLR.L    D0                 ;hours
            MOVE.B   HOUR,D0
            DIVS     #10,D0
            MOVE.B   (A1,D0),DIGIT1(A0)
            SWAP     D0
            MOVE.B   (A1,D0),DIGIT2(A0)
            
            CLR.L    D0                 ;minutes
            MOVE.B   MINUTE,D0
            DIVS     #10,D0
            MOVE.B   (A1,D0),DIGIT4(A0)
            SWAP     D0
            MOVE.B   (A1,D0),DIGIT5(A0)
            
            CLR.L    D0                 ;seconds
            MOVE.B   SECOND,D0
            DIVS     #10,D0
            MOVE.B   (A1,D0),DIGIT7(A0)
            SWAP     D0
            MOVE.B   (A1,D0),DIGIT8(A0)           
            
            BRA      MAIN

*System time clock exception*
            
ISR6        ORI.W    #$0700,SR          ;set priority level to 7
            MOVEM.L  A1/D0/D1,-(A7)     ;transparency
            ANDI.W   #$FDFF,SR          ;set priority level to 6

* updating counter
            SUBI.B   #1,COUNTER
            CMPI.B   #0,COUNTER
            BEQ      US
            BRA      EXIT
            
* counter has finished, updating seconds
US          MOVE.B   #39,COUNTER      ;reset counter            
            ADDI.B   #1,SECOND        ;update seconds            
            CMPI.B   #60,SECOND       ;check seconds
            BEQ      UM
            BRA      EXIT
            
* updating minutes            
UM          MOVE.B   #0,SECOND        ;reset seconds
            ADDI.B   #1,MINUTE        ;update minutes
            CMPI.B   #60,MINUTE       ;check minutes
            BEQ      UH
            BRA      EXIT
            
* updating hours   
UH          MOVE.B   #0,MINUTE        ;reset minutes
            ADDI.B   #1,HOUR          ;update hours
            CMPI.B   #24,HOUR         ;check hours
            BEQ      UA
            BRA      EXIT
            
* clock is full, reseting           
UA          MOVE.B   #0,SECOND        ;reseting clock
            MOVE.B   #0,MINUTE
            MOVE.B   #0,HOUR
            BRA      EXIT        
            
EXIT        MOVEM.L (A7)+,A1/D0/D1     ;restoring
            RTE

* clock reset exception
ISR7        ORI.W   #$0700,SR          ;set priority level to 7
            MOVEM.L A1/D0/D1,-(A7)     ;save working registers
            ANDI.W  #$FEFF,SR          ;set priority level to 7
            
            MOVE.B  #0,HOUR 
            MOVE.B  #0,MINUTE
            MOVE.B  #0,SECOND
            MOVE.B  #39,COUNTER
            
            MOVEM.L (A7)+,A1/D0/D1     ;restore working registers
            RTE                        ;use RTE to return from interrupt

    		END    START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
