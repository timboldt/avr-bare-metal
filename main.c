#include <avr/io.h>
#include <stdbool.h>
#include <util/delay.h>

int main() {
  const int kDelay = 250;

  // Note: PB5 is pin 13 on the Uno which is the built-in LED.
  DDRB |= _BV(DDB5);

  while (true) {
    PORTB |= _BV(PORTB5);
    _delay_ms(kDelay);
    PORTB &= ~_BV(PORTB5);
    _delay_ms(kDelay);
  }

  return 0;
}
