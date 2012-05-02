/* This program converts a string to a hex value and vice versa.
 * Functions included: addition, subtraction, multiplcation, and division of hex values.
 * See proof below.
 *
 * Date Created: March 3rd, 2011
 * Date Modified: March 4th, 2011
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

/* unsigned int - 4 bytes
 * converts a string/array of integers into a hexidecimal value */
unsigned int atob(char * x)
{
	int i, j, k = 0;

	for(i = 0; i < strlen(x); i++)
	{
		// check if value is negative, if so, do not add it
		if(x[i] == '-')
		{
			j = x[i] - '-';
		}
		else
		{
			// subtract ascii value from '0' to obtain integer
			j = x[i] - '0';
			// take the power of the position this value is in and add it
			j *= pow(10, (strlen(x) - 1 - i));
		}
		k += j;;
	}
	// check if value is negative, if so, multiply value by -1
	if(x[0] == '-')
		k *= -1;

	k += 32768; // decimal value for 8000h
	printf("0x%X \n", k);

	return 0;
} 

// converts a hexidecimal value to an integer string/array
void btoa(unsigned int y, char * x)
{
	int i = 0, j, k = 0;
	
	y -= 32768; // decimal value for 8000h

	itoa(y, x, 10);
	printf("%s\n", x);
}

void ehtobe(void)
{
	char * str = (char *) malloc (sizeof(char)+1);

	printf("Enter an integer: ");
	scanf("%s", str);

	// if str is empty, print error msg, then exit
	if(str == NULL) 
	{
		printf("Memory cannot be allocated");
		exit(1);
	}

	atob(str);
}

void betoeh(void)
{
	int * i = 0;
	char * str;

	printf("Enter a hexidecimal: ");
	scanf("%X", &i);

	str = (char *) malloc (sizeof(i+1));
	btoa(i, str);
}

unsigned int badd(unsigned int x, unsigned int y)
{
	int z = 0;

	z = x + y;

	z -= 32768; // decimal value for 8000h

	printf("0x%X \n", z);

	return 0;
}

unsigned int bsub(unsigned int x, unsigned int y)
{
	int z = 0;

	z = x - y;

	z += 32768; // decimal value for 8000h

	printf("0x%X \n", z);

	return 0;
}

unsigned int bmul(unsigned int x, unsigned int y)
{
	int z = 0;

	z = x * y;

	z += 32768; // decimal value for 8000h

	printf("0x%X \n", z);

	return 0;
}

unsigned int bdiv(unsigned int x, unsigned int y)
{
	int z = 0;

	z = x / y;

	z += 32768; // decimal value for 8000h

	printf("0x%X \n", z);

	return 0;
}

void menu(void)
{
	int selection = 0;
	
	int * first = 0;
	int * second = 0;

	printf("Select one of the options below: \n");
	printf("1. Convert string to hexidecimal\n");
	printf("2. Convert hexidecimal to string\n");
	printf("3. Addition\n");
	printf("4. Subtration\n");
	printf("5. Multiplcation\n");
	printf("6. Division\n");
	printf("0. Quit\n");
	printf("You're selection..? ");
	scanf("%d", &selection);

	switch(selection)
	{
	case 1:
		ehtobe();
		menu();
		break;
	case 2:
		betoeh();
		menu();
		break;
	case 3:
		{
			printf("Enter first hexidecimal: ");
			scanf("%X", &first);
			printf("Enter second hexidecimal: ");
			scanf("%X", &second);
			badd(first, second);
		}
		menu();
		break;
	case 4:
		{
			printf("Enter first hexidecimal: ");
			scanf("%X", &first);
			printf("Enter second hexidecimal: ");
			scanf("%X", &second);
			bsub(first, second);
		}
		menu();
		break;
	case 5:
		{
			printf("Enter first hexidecimal: ");
			scanf("%X", &first);
			printf("Enter second hexidecimal: ");
			scanf("%X", &second);
			bmul(first, second);
		}
		menu();
		break;
	case 6:
		{
			printf("Enter first hexidecimal: ");
			scanf("%X", &first);
			printf("Enter second hexidecimal: ");
			scanf("%X", &second);
			bdiv(first, second);
		}
		menu();
		break;
	case 0:
		exit(0);
		break;
	default:
		printf("ERROR, bad input. Please try again >=( \n");
		menu();
		break;
	}
}
int main()
{
	menu();
	return 0;
}





/*
The difference between using the 2s complement and biased notation is how signed or unsigned is represented, for example, 1001, in 2s complement, this would be 0 1001, whereas in biased notation, this would be 1 1001. Another example, -1001, the 2s complement would be 1 0100, whereas the biased notation would be 0 0100. In biased notation, a 0 in the most significant bit position represents a negative integer and a 1 represents a positive integer. On the other hand, in 2s complement, a 0 in the most significant bit position would represent a positive integer and a 1 presents a negative integer.
In our example, 0x7F85 + 0x8064 = 0x7FE9. We have the binary representation of 0x7F85, 0111 1111 1000 0101, and 0x8064, 1000 0000 0110 0100. Our result 0x7FE9, 1111 1111 1110 1001.

	    0111 1111 1000 0101
	+	1000 0000 0110 0100
	-----------------------------
	    1111 1111 1110 1001
	
Starting from the least significant bit, add each value to obtain the final result. This is the same for subtraction. For addition in biased notation, you will need to subtract 8000h from the answer. For subtraction, you will need to add 8000h to the answer.
*/

