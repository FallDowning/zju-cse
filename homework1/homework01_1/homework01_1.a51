     	  ORG 0000H
		  LJMP MAIN
		  ORG 0100H
MAIN:     MOV A, #07H             
		  CJNE A, #16,NEXT         
		  MOV DPTR,#TABLE2
		  MOV A, #0
		  MOVC A,@A+DPTR
		  MOV R6,A
		  MOV A, #01H
		  MOVC A,@A+DPTR
		  MOV R7,A
		  SJMP $
			  
NEXT:     JC SMALL
		  MOV DPTR,#TABLE2
		  SUBB A, #10H
		  MOV B,#02H
		  MUL AB
		  MOV R1,A
		  MOVC A,@A+DPTR
		  MOV R6,A
		  MOV A,R1
		  INC A
		  MOVC A,@A+DPTR
		  MOV R7,A
		  SJMP $
SMALL:    MOV DPTR,#TABLE1
		  MOV R6,0
		  DEC A
		  MOVC A, @A+DPTR
		  MOV R7,A
		  SJMP $
          ORG 0150H
TABLE1:   DB 01,04,09,16,25,36,49,64,81,100,121,144,169,196,225 
          ORG 0160H
TABLE2:   DW 256,289,324,361,400 
          END  
	      