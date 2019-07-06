#define __SFR_OFFSET 0	
#include   "avr/io.h"

start:
    sbi     DDRB,5      ; PB5 is pin 13 on the Uno which is the built-in LED.

loop:
    ldi     r20,250
    call    delay_ms
    ldi     r20,250
    call    delay_ms
    sbi     PORTB,5     ; Turn on LED.
    ldi     r20,250
    call    delay_ms
    cbi     PORTB,5     ; Turn off LED.
    jmp     loop

delay_ms:
    ;; Delay N millis, based on value of r20.
    ;; Destroys r20, r30 and r31.
    ;; On millisecond is about 3000 iterations at 16MHz.
	ldi     31, 3000>>8
	ldi     30, 3000&255
loop_1ms:
	sbiw    r30, 1      ; Decrement 16-bit counter.
	brne    loop_1ms
	subi    r20, 1      ; Decrement millis by 1.
	brne    delay_ms
	ret