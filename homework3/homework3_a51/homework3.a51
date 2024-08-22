	ORG 0000H
    LJMP MAIN
	ORG 001BH
	LJMP L1
	ORG 0030H
MAIN:
	CLR A
	MOV 50H,A         ;clear 50ms
	MOV 51H,A        ;clear second
	MOV 52H,A         ;clear minute
	MOV 53H,A         ;clear hour
	MOV 54H,A         ; whether display A/P or not
	MOV 55H,A         ; A/P
	MOV R5,#0
	; some initialization
	SETB EA             ;open interrupt 
	SETB ET1            ;open T1
	MOV TMOD, #10H         
	MOV TH1, #3CH
	MOV TL1,#0B0H
	SETB TR1
LOOP:
	LCALL KEY_JUDGE
	; SX(x = 2,3,4...)represents different cases when different button is pressed
	CJNE R5,#1,S2
	MOV 54H,#1
S2:
    CJNE R5,#2,S3
	MOV A,53H
	INC A
	CJNE A,#12,S2_NEXT
	MOV A,#0
	MOV 53H,A
	MOV A,55H
	CPL ACC.7
	MOV 55H,A
	AJMP DIS
S2_NEXT:
	MOV 53H,A
	AJMP DIS
	
S3:
    CJNE R5,#3,S4
	MOV A,52H
	INC A
	CJNE A,#60,S3_NEXT
	MOV A,0
	MOV 52H,A
	AJMP DIS
S3_NEXT:
	MOV 52H,A
	AJMP DIS

S4:
    CJNE R5,#4,S5
	MOV A,51H
	INC A
	CJNE A,#60,S4_NEXT
	MOV A,#0
	MOV 51H,A
	AJMP DIS
S4_NEXT:
	MOV 51H,A
	AJMP DIS

S5:
    CJNE R5,#5,S6
	MOV 54H,#0
	
S6:
	CJNE R5,#6,S7
	MOV A,53H
	DEC A
	CJNE A,#0FFH,S6_NEXT
	MOV A,#11
	MOV 53H,A
	MOV A,55H
	CPL ACC.7
	MOV 55H,A
	AJMP DIS
S6_NEXT:
    MOV 53H,A
	AJMP DIS

S7:
    CJNE R5,#7,S8
	MOV A,52H
	DEC A
	CJNE A,#0FFH,S7_NEXT
	MOV A,#59
	MOV 52H,A
	AJMP DIS
S7_NEXT:
    MOV 52H,A
	AJMP DIS
	
	
S8:
    CJNE R5,#8,DIS
    MOV A,51H
	DEC A
	CJNE A,#0FFH,S8_NEXT
	MOV A,#59
	MOV 51H,A
	AJMP DIS
S8_NEXT:
    MOV 51H,A
	
DIS:
    LCALL DISPLAY
	MOV R5,#0
	LJMP LOOP

; interrupt function
L1:
	MOV TH1,#3CH
	MOV TL1,#0B0H
	INC 50H
	MOV A,50H
	CJNE A,#20,L2
	MOV 50H,#00H
	INC 51H
	MOV A,51H
	CJNE A,#60,L2
	MOV 51H,#00H
	INC 52H
	MOV A,52H
	CJNE A,#60,L2
	MOV 52H,#00H
	INC 53H
	MOV A,53H
	CJNE A,#12,L2
	MOV 53H,#00H   ; when hour is larger than 12 ,transform A/P
	MOV A,55H    
	CPL ACC.7
	MOV 55H,A
L2:
	RETI
    

	
	
; display  seconds,minutes,hours
DISPLAY:
    MOV DPTR, #TABLE
    MOV A, 51H
	CJNE A,#10,SECONDS
	MOV P2,#00000111B          ; this part outputs 10th seconds
	MOV A,#0
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#0
	MOV P2,#00000110B 	       
	MOV A,#1
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	SJMP THIRD
SECONDS:		              ; this part outputs 11~59seconds
    JC ONE_SECONDS
	MOV B, #10
	DIV AB
	MOV R0,A
	MOV A,B
	MOV P2,#00000111B          ; the first light  of seconds
	MOVC A,@A+DPTR 
	MOV P0,A
	MOV P0,#0
	MOV A,R0
	MOV P2,#00000110B 	       ; the second light of seconds
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	SJMP THIRD
ONE_SECONDS:                   ; this part outputs 0~9seconds
    MOV P2,#00000111B          ; the first light  of seconds
	MOVC A,@A+DPTR 
	MOV P0,A
	MOV P0,#0
	MOV P2,#00000110B 	       ; the second light  of seconds
	MOV A,#0
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
THIRD:
    MOV A, 52H
	CJNE A,#10,MINUTES
	MOV P2,#00000101B          ; this part outputs 10th minutes
	MOV A,#0
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#0
	MOV P2,#00000100B 	       
	MOV A,#1
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	SJMP FOURTH
MINUTES:		              ; this part outputs 11~59minutes
    JC ONE_MINUTES
	MOV B, #10
	DIV AB
	MOV R0,A
	MOV A,B
	MOV P2,#00000101B          ; the first light of minutes
	MOVC A,@A+DPTR 
	MOV P0,A
	MOV P0,#0
	MOV A,R0
	MOV P2,#00000100B 	       ; the second light of minutes
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	SJMP FOURTH
ONE_MINUTES:                   ; this part outputs 0~9minutes
    MOV P2,#00000101B          ; the first light of minutes
	MOVC A,@A+DPTR 
	MOV P0,A
	MOV P0,#0
	MOV P2,#00000100B 	       ; the second light of minutes
	MOV A,#0
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	
FOURTH:
    MOV A, 53H
	CJNE A,#10,HOURS
	MOV P2,#00000011B          ; this part outputs 10th hours
	MOV A,#0
	MOVC A,@A+DPTR
	MOV P0,A
	MOV P0,#0
	MOV P2,#00000010B 	       
	MOV A,#1
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	SJMP LAST
HOURS:		              ; this part outputs 11~12hours
    JC ONE_HOURS
	MOV B, #10
	DIV AB
	MOV R0,A
	MOV A,B
	MOV P2,#00000011B          ; the first light of hours
	MOVC A,@A+DPTR 
	MOV P0,A
	MOV P0,#0
	MOV A,R0
	MOV P2,#00000010B 	       ; the second light of hours
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
	SJMP LAST
ONE_HOURS:                   ; this part outputs 0~9hours
    MOV P2,#00000011B          ; the first light 
	MOVC A,@A+DPTR 
	MOV P0,A
	MOV P0,#0
	MOV P2,#00000010B 	       ; the second light of hours
	MOV A,#0
	MOVC A,@A+DPTR
	MOV P0,A
    MOV P0,#0
LAST:                        
    MOV A,54H
    CJNE A,#0,LAST_1
	SJMP DIS_RETURN
LAST_1:
    MOV P2,#00000001B        ; display '-'
	MOV P0,#40H
	MOV P0,#0
	MOV P2,#00000000B
    MOV A,55H
	CJNE A,#0,LAST_2
	MOV P0,#77H               ; display 'A'
	MOV P0,#0
LAST_2:
    MOV P0,#73H               ; display 'p'
	MOV P0,#0
DIS_RETURN:    
	RET
	
	
KEY_JUDGE:
    MOV P1, #0F0H
	MOV A,P1
	ANL A,#0F0H               ; P1.0~P1.3 reprsents row0 ~ row3 while P1.4 ~P1.7 represents column0 ~ column3
	XRL A,#0F0H
	JZ RETURN
    LCALL DELAY_10MS          ; debounce
    MOV A,P1
	ANL A,#0F0H
	XRL A,#0F0H
	JZ RETURN
	MOV R2,#11111110B         ; detect from row0 
SCAN:
    MOV A,R2
	MOV P1,A
	MOV A,P1
	ANL A,#11110000B
	MOV R3,A
	CJNE A,#0F0H,KEY_DOWN
	MOV A,R2
	RL A
	MOV R2,A
	XRL A,#11101111B          ; end after row3 has been detected
	JNZ SCAN
KEY_DOWN:
    MOV A,R2
	ANL A,#00001111B          
	ORL A,R3                  ; gets button's code
	MOV R4,A
	MOV R5,#1
	MOV DPTR,#KEY_TABLE
CAL:
    MOV A,R5                 ;  transform button's code to button's index
	MOVC A,@A+DPTR
	XRL A,R4
	JZ FIXED
	INC R5
	SJMP CAL
FIXED:
    MOV A,P1
	ANL A,#0F0H
	XRL A,#0F0H                ; restore button's code in R5
	JNZ FIXED
RETURN:
    RET 
	
TABLE: 
    DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH  ; the code of character '0' ~ '9'
KEY_TABLE:
    DB 0,0EEH,0DEH,0BEH,7EH,0EDH,0DDH,0BDH,7DH  ; this repesents the feature code of buttons s1~s8, 0 represents nothing, it's just a placeholder 

; Actually, it's delay 7.5ms, but I'm too lazy to modify it's name ^_^ 
DELAY_10MS:
      MOV R6,#15
DEL01:
      MOV R7,#248
	  NOP
DEL02:
      DJNZ R7,DEL02
	  DJNZ R6,DEL01
	  RET
	  	
end 
	
    
	



