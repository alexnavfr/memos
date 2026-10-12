#include <stdio.h>
#include <string.h>

int main()
{
	char *hello = "bonjour";
	char *d = hello;
	const char *s = d;
	int i = 1;
	while(*d)
	{
		*d++ = *s;
		s += i;
		if( *s !='o')
		{
			i = -i;
		}
	};
	printf("%s\n", hello);

}