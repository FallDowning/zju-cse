      ORG 0000H
	  LJMP MAIN
	  ORG 0003H
	  LJMP INT00
	  ORG 0013H
	  LJMP INT11
MAIN: 
      SETB EA
      SETB EX1
	  SETB EX0
	  CLR  PX1
	  SETB IT1
	  SETB IT0
	  MOV A,#0FEH
	  MOV R2,#01H
	  MOV R3,#0FEH
	  SJMP $
INT00: 
       LCALL Delay_500ms
K1DOWN:
       MOV C,P3.2
       JNC K1DOWN
       MOV P0,A
	   RL A
       CLR IE0
	   RETI
INT11: 
      CJNE R2,#00H,OPEN
	  MOV R3,#0FFH
	  MOV P0,R3
	  MOV R2,#01H
RETURN:
      MOV R3,#0FEH
      LCALL Delay_1s
      RETI
OPEN: 
      MOV R2,#00H
	  MOV P0,R3
	  LCALL Delay_1s
	  MOV A,R3
      RL A
	  MOV R3,A
	  MOV C,P3.3
	  JNC RETURN
      SJMP OPEN	  

Delay_1s: 
      MOV R5,#10
DEL0:
      MOV R6,#200
DEL1:
      MOV R7,#248
	  NOP
DEL2:
      DJNZ R7,DEL2
	  DJNZ R6,DEL1
	  DJNZ R5,DEL0
	  RET
	  
Delay_500ms:
      MOV R5,#05
DEL00:
      MOV R6,#200
DEL01:
      MOV R7,#248
	  NOP
DEL02:
      DJNZ R7,DEL02
	  DJNZ R6,DEL01
	  DJNZ R5,DEL00
	  RET
	  END
       

	