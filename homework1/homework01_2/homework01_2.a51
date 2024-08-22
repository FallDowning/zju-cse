	      ORG 0000H
		  LJMP MAIN
          ORG 0030H
 MAIN:    MOV R0,#0AH
          MOV R1,#05H
		  MOV R2,#0
		  MOV 30H,#0
          MOV 31H,#0
		  MOV 32H,#64H
		  MOV 33H,#0
          MOV 34H,#0
          MOV 35H,#0		  
 LOOP:    MOV A,32H
          RRC A
		  JC ODD
          MOV A,30H
          RRC A
		  MOV 30H,A
		  MOV A,31H
		  RRC A
		  MOV 31H,A
		  MOV A,32H
		  RRC A
		  MOV 32H,A
		  SJMP JUDGE
 ODD:     CLR C
          MOV A,32H
          MOV B,R1
		  MUL AB
		  MOV 32H,A
		  MOV 34H,B
		  MOV A,31H
		  MOV B,R1
		  MUL AB
		  MOV 35H,B
		  ADD A,34H
		  MOV 31H,A
		  MOV A,30H
		  MOV B,R1
		  MUL AB
		  ADDC A,35H
		  MOV 30H,A
		  MOV A,33H
		  INC A
		  MOV 33H,A
 JUDGE:    DJNZ R0,LOOP
		  SJMP $
          end 