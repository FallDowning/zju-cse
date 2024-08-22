## <center>定时器实验
- **汇编代码：**
    ```assembly
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
    ```
- **C代码：**
    ```c
    #include <reg51.h>
    unsigned char time[4] = {0, 0, 0, 0};
    unsigned char flag[2] = {0, 0};
    unsigned char light_code[10] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
    unsigned char button = 0;

    void Timer1() interrupt 3
    {
        TH1 = 0X3C;
        TL1 = 0XB0;
        time[0]++;
        if (time[0] == 20)
        {
            time[0] = 0;
            time[1]++;
            if (time[1] == 60)
            {
                time[1] = 0;
                time[2]++;
                if (time[2] == 60)
                {
                    time[2] = 0;
                    time[3]++;
                    if (time[3] == 12)
                    {
                        time[3] = 0;
                        flag[1] = !flag[1];
                    }
                }
            }
        }
    }

    void Timer1Init()
    {
        EA = 1;
        ET1 = 1;
        TMOD = 0X10;
        TH1 = 0x3C;
        TL1 = 0xB0;
        TR1 = 1;
    }

    // delaytime is parameter time times 5e-4 s
    void delay(unsigned int time)
    {
        unsigned int i, j;
        for (i = time; i > 0; i--)
        {
            ;
            for (j = 124; j > 0; j--)
                ;
        }
    }

    void DisPlay()
    {
        unsigned char temp1, temp2;
        if (time[1] >= 10)
        {
            P2 = 0X07;
            temp1 = time[1] / 10;
            temp2 = time[1] % 10;
            P0 = light_code[temp2];
            P0 = 0;
            P2 = 0X06;
            P0 = light_code[temp1];
            P0 = 0;
        }
        else
        {
            P2 = 0X07;
            P0 = light_code[time[1]];
            P0 = 0;
            P2 = 0X06;
            P0 = light_code[0];
            P0 = 0;
        }

        if (time[2] >= 10)
        {
            P2 = 0X05;
            temp1 = time[2] / 10;
            temp2 = time[2] % 10;
            P0 = light_code[temp2];
            P0 = 0;
            P2 = 0X04;
            P0 = light_code[temp1];
            P0 = 0;
        }
        else
        {
            P2 = 0X05;
            P0 = light_code[time[2]];
            P0 = 0;
            P2 = 0X04;
            P0 = light_code[0];
            P0 = 0;
        }

        if (time[3] >= 10)
        {
            P2 = 0X03;
            temp1 = time[3] / 10;
            temp2 = time[3] % 10;
            P0 = light_code[temp2];
            P0 = 0;
            P2 = 0X02;
            P0 = light_code[temp1];
            P0 = 0;
        }
        else
        {
            P2 = 0X03;
            P0 = light_code[time[3]];
            P0 = 0;
            P2 = 0X02;
            P0 = light_code[0];
            P0 = 0;
        }

        if (flag[0] == 1)
        {
            P2 = 0X01;
            P0 = 0X40;
            P0 = 0;
            if (flag[1] == 0)
            {
                P2 = 0X00;
                P0 = 0X77;
                P0 = 0;
            }
            else
            {
                P2 = 0X00;
                P0 = 0X73;
                P0 = 0;
            }
        }
    }

    void KeyDown()
    {
        P1 = 0XF0;
        if (P1 != 0XF0)
        {
            delay(10);
            if (P1 != 0XF0)
            {
                P1 = 0XF0;
                switch (P1)
                {
                case 0XE0:
                    button = 1;
                    break;
                case 0XD0:
                    button = 2;
                    break;
                case 0XB0:
                    button = 3;
                    break;
                case 0X70:
                    button = 4;
                    break;
                }
                P1 = 0X0F;
                switch (P1)
                {
                case 0X0E:
                    button = button;
                    break;
                case 0X0D:
                    button = button + 4;
                    break;
                case 0X0B:
                    button = button + 8;
                    break;
                case 0X07:
                    button = button + 12;
                    break;
                }
            }
            while (P1 != 0X0F)
            {
                delay(20);
            }
        }
    }

    void KeyHandle()
    {

        switch (button)
        {
        case 0:
            break;
        case 1:
            flag[0] = 1;
            break;
        case 2:
            time[3]++;
            if (time[3] == 12)
            {
                time[3] = 0;
                flag[1] = !flag[1];
            }
            break;
        case 3:
            time[2]++;
            if (time[2] == 60)
            {
                time[2] = 0;
            }
            break;
        case 4:
            time[1]++;
            if (time[1] == 60)
            {
                time[1] = 0;
            }
            break;
        case 5:
            flag[0] = 0;
            break;
        case 6:
            time[3]--;
            if (time[3] == 0xFF)
            {
                time[3] = 11;
                flag[1] = !flag[1];
            }
            break;
        case 7:
            time[2]--;
            if (time[2] == 0xFF)
            {
                time[2] = 59;
            }
            break;
        case 8:
            time[1]--;
            if (time[1] == 0XFF)
            {
                time[1] = 59;
            }
            break;
        }
    }

    int main()
    {
        Timer1Init();
        while (1)
        {
            KeyDown();
            KeyHandle();
            DisPlay();
            button = 0;
        }
    }
    ```
- **原理分析：**
  c与汇编代码的原理基本相同，都是通过定时器中断来实现定时器功能，通过矩阵键盘来实现按键功能，通过数码管来显示时间。
  具体来说，c和汇编用到了四个核心函数：中断定时函数，在数码管显示时间的display函数，处理按键并获取按键序号的KeyDown函数，以及处理对应按键的函数KeyHandle
- **中断定时函数**
  中断定时函数采取定时器1的工作方式1，由于此方式的最大计时时间为62ms左右（不足1s），所以采取50ms为一个计时周期，即触发20次定时中断为1s，在汇编中采用连续的内存来储存时、分、秒，c51则采用数组来储存；秒达到60清零，分加一；分达到60清零，时加一；时达到12清零，转换A/P
- **display函数**
  数码管采用共阳段码表示，所以预先采用Table来储存字符‘0’ ~‘9’的段码，然后A、B、C三个端口的0-1组合用来控制8个数码管，其中000对应最左侧的数码管，111对应最右侧的数码管，所以在display的时候，先改变ABC的值，控制不同的数码管，再将对应的时分秒转化为段码输出
- **KeyDown函数**
   先将行全变为低电平（即输出0F0H），矩阵键盘的前四个I/O口对应行，后四个I/O口对应列，然后检测I/O口是否为0F0H，若不为，则延时7.5ms防抖动（汇编中测试，延时5ms容易出现连击，延时10ms容易出现屏闪，故采用7.5ms），再检测I/O口是否为0F0H，若仍不为，则表示有按键按下，接着，令每一行逐一输出低电平，然后获取列的输出信息，得到行与列组合的按键特征码，接着查表得到具体按键的序号（c语言中可以直接通过switch分支程序来获取）
- **KeyHandle函数**
  汇编代码中用寄存器R5来储存按键的序号，c51则采用变量button来储存按键的序号，然后采用条件分支程序，在对应的序号下执行相应的操作
  <br>

&ensp; &ensp;&ensp;&ensp;**实验结果如视频所示**

  
