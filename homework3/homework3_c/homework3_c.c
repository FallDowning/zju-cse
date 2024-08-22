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

    if(flag[0] == 1)
    {
        P2 = 0X01;
        P0 = 0X40;
        P0 = 0;
        if(flag[1] == 0)
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
        if(P1 != 0XF0)
        {
            P1 = 0XF0;
            switch(P1)
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
            switch(P1)
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
        while(P1 != 0X0F)
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