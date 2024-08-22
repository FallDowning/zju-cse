#include <reg51.h>
main()
{
	sfr  = 0x1E;
	unsigned char data *R6 = 0x1E;
	unsigned char data *R7 = 0x1F;
	unsigned char Table1[15] = {1,4,9,16,25,36,49,64,81,100,121,144,169,196,225};
	unsigned int Table2[5] = {256,289,324,361,400};
	char x = 9;	
	*R7 = 0;
	if(x<16)
	{
		*R6 = 0;
		*R7 = Table1[x-1];
	}
	else
	{
		unsigned char *p;
		p = Table2;
		x -= 16;
		p += 2*x;
		*R6 = *p; 
		p++;
		*R7 = *p;	
	}
}