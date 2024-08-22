#include <reg51.h>
#include "intrins.h"
unsigned char status1,status2;
unsigned char flag = 0;
unsigned char temp1 = 0XFE;
unsigned char temp2 = 0xFE;
unsigned char open = 0;
void delay (unsigned int time);
sbit P3_3 = P3^3 ;
sbit P3_2 = P3^2 ;
void_service_int0 () interrupt 0
{
	flag = 1;
}

void_service_int1 () interrupt 2
{
	flag = 2;
	delay(500);
	while(!P3_3)
	{
    ;
	}
	open = !open;
	IE1 = 0;
}

main()
{

	EA = 1; EX0 = 1; EX1 = 1; IT0 = 1; IT1 = 1;
	while(1)
	{
		if(flag == 1)
		{
			delay(500);
			while(!P3_2)
			{
				;
			}
			P0 = temp1;
			temp1 = _crol_(temp1,1);
			
			flag = 0;
		}
		if(flag == 2)
		{ 
			 while(open)
			{
				temp2 = _crol_(temp2,1);
				P0 = temp2;
				delay(1000);
			}
			if(open == 0)
			{
				temp2 = 0xFE;
				P0 = 0xFF;
				delay(2000);
			}
			flag = 0;
		}
	}
}
// delaytime is parameter time times 5e-4
void delay (unsigned int time)
{
	unsigned int i,j;
	for(i=time;i>0;i--)
	{
		;
		for(j=124;j>0;j--)
		;
	}
}

