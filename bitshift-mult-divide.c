/* This program performs multiplication and division without the use of * and /.
 * Instead, bit shifting is used. (Booth's Algorithm)
 * Functions included: multiplcation and division.
 *
 * Date Created: March 12th, 2011
 * Date Modified: March 13th, 2011
 */

#include <stdio.h>
#include <stdlib.h>

// 2^64 - 8byte long as opposed to 4byte int
long long cmul(int x, int y)
{
	int i = 0, tmp;
	int extrabit = 0;
	long long product = 0;
	long long multiplicand;

	// check which integer is larger
	if(x > y)
	{
		tmp = x;
		x = y;
		y = tmp;
		
		product = x;
		multiplicand = y << sizeof(product)*2;
	}
	else
	{
		product = x;
		multiplicand = y << sizeof(product)*2;
	}

	// if extrabit and LSD of product is either 11 or 00, do nothing
	for ( i = 0; i < sizeof(product)*2; i++ )
	{
		if((product & 1) && !extrabit)
		{
			product -= multiplicand;
		}
		else if(!(product & 1) && extrabit)
		{
			product += multiplicand;
		}

		// shift bit over to the right
		extrabit = (product & 1);
		product >>= 1;
	}

	// check if any of the values were negative and adjust product
	if(product < 0)
		product += 1;
	else if(x < 0 && y < 0)
		product += 1;

	return product;
}

int cdiv(int x, int y, int * q, int * r)
{
	// x = divisor; y = dividend
	int i = 0;
	long long divisor;
	long long quotient = 0;
	long long remainder;

	// memory allocation for q and r
	q = (int*) malloc (sizeof(quotient)*2);
	r = (int*) malloc (sizeof(remainder)*2);

	// shift the divisor over 32bits
	divisor = x << (sizeof(remainder)*2);
	// set the remainder equal to dividend
	remainder = y;

	// abs divisor and dividend
	if(divisor < 0)
		divisor *= -1;
	if(remainder < 0)
		remainder *=-1;

	for(i = 0; i < (sizeof(quotient)*2)+1; i++) 
	{
		remainder -= divisor;
		// if remainder >= 0, shift quotient left and place a 1 at the end
		if(remainder >= 0)
		{
			quotient <<= 1;
			quotient += 1;
		}
		// if remainder < 0, shift quotient left and place a 0 at the end
		else
		{
			quotient <<= 1;
			// restore remainder by adding divisor
			remainder += divisor;
		}
		divisor >>= 1;
	}

	if((x > 0 && y < 0) || (x < 0 && y > 0))
	{
		remainder *= -1;
		quotient *= -1;
	}

	*r = remainder;
	*q = quotient;

	printf("%d / %d = %dR%d\n\n", y, x, *q, *r);

	return 0;
}

void multiply(void)
{
	int op1, op2;
	printf("Enter multiplier: ");
	scanf_s("%i", &op1);

	printf("Enter multiplicand: ");
	scanf_s("%i", &op2);

	printf("%d x %d = %d\n\n", op1, op2, cmul(op1, op2));
}

void divide(void)
{
	int * quotient = 0;
	int * remainder = 0;
	int divisor;
	int dividend;

	printf("Enter divisor: ");
	scanf_s("%i", &divisor);

	printf("Enter dividend: ");
	scanf_s("%i", &dividend);

	cdiv(divisor, dividend, quotient, remainder);
}

void menu(void)
{
	int selection = 0;
	
	int * op1 = 0;
	int * op2 = 0;

	printf("Select one of the options below: \n");
	printf("1. Multiplcation\n");
	printf("2. Division\n");
	printf("0. Quit\n");
	printf("You're selection..? ");
	scanf_s("%d", &selection);

	switch(selection)
	{
	case 1:
		multiply();
		menu();
		break;
	case 2:
		divide();
		menu();
		break;
	case 0:
		exit(0);
		break;
	default:
		printf("ERROR, bad input. Please try again >=( \n\n");
		menu();
		break;
	}
}

int main()
{
	menu();
	return 0;
}