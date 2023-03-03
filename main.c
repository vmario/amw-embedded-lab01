#include <avr/io.h>

#include <stdlib.h>

int main(void)
{
	DDRC = _BV(0);
	PORTC = _BV(7);

	for (;;) {
	}

	return EXIT_SUCCESS;
}