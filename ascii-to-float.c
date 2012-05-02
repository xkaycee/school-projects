/*
 * This program converts a string to a float value.
 *
 * Date Created: March 18th, 2011
 * Date Modified: March 22nd, 2011
 */
 
#include <stdio.h>
#include <string.h>
#include <math.h>

typedef unsigned long dword;

union
{
	float f;
	dword k;
} u, v;

dword otof(const char * x)
{
	int i = 0;
	int decimal = 0;
	float p = 0.0f;

	// find the decimal point and check whether its pos/neg
	for(i = 0; i < strlen(x); i++)
	{
		// check if value is negative, if so, do not add it
		if(x[i] == '-')
		{
			u.f = x[i] - '-';
		}
		// checks for the decimal point
		else if(x[i] == '.')
		{
			// store location of decimal point 
			decimal = i;
			break;
		}
		else
		{
			// subtract ascii value from '0' to obtain integer
			u.f = x[i] - '0';
			// take the power of the position this value is in and add it
			u.f *= pow(10, (strlen(x) - 1 - i));
		}
		v.f += u.f;
	}

	// check if it's a decimal number
	if(decimal != 0)
	{
		// divide to obtain correct significand
		v.f /= pow(10, (strlen(x) - decimal));
		
		for(i = decimal+1; i < strlen(x); ++i)
		{		
			// subtract ascii '0' to obtain int value
			p = x[i] - '0';
			// proper numeral position
			p /= pow(10, (i - decimal));
			v.f += p;
		}
	}

	// check if value is negative, if so, multiply value by -1
	if(x[0] == '-')
		v.f *= -1;
			
	printf("%E\n", v.f);
	printf("%70.40f\n", v.f);
	return 0;
} 


int main()
{ 
	char s[80];
	
	scanf("%s", &s);
	otof(s);
	
	return 0;
}