#include <avr/io.h>

#include <stdlib.h>

/**
 * Numery pinów powiązane z LED-ami.
 */
enum PIN_LED {
	PIN_LED1 = 0,
	PIN_LED2 = 1,
	PIN_LED3 = 2,
	PIN_LED4 = 3,
	PIN_LED5 = 4,
};

/**
 * Numery pinów powiązane z przyciskami.
 */
enum PIN_KEY {
	PIN_KEY1 = 3,
	PIN_KEY2 = 4,
	PIN_KEY3 = 5,
	PIN_KEY4 = 6,
	PIN_KEY5 = 7,
};

/**
 * Zaświeca diodę na wskazanym pinie.
 * 
 * @param pinLed Wskazany pin.
 */
void ledOn(enum PIN_LED pinLed)
{
	PORTC &= ~_BV(pinLed);
}

/**
 * Gasi diodę na wskazanym pinie.
 * 
 * @param pinLed Wskazany pin.
 */
void ledOff(enum PIN_LED pinLed)
{
	PORTC |= _BV(pinLed);
}

/**
 * Inicjalizuje porty GPIO.
 */
void gpioInitialize()
{
	DDRC = _BV(PIN_LED1);
}

/**
 * Pętla główna.
 */
void mainLoop()
{
}

/**
 * Funkcja główna.
 */
int main()
{
	gpioInitialize();
	ledOn(PIN_LED1);

	while (true) {
		mainLoop();
	}

	return EXIT_SUCCESS;
}