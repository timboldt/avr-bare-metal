#define __SFR_OFFSET 0	
#include   "avr/io.h"

; Reset- and vector table
;
.ORG 0 ; Address to zero (Reset- and interrupt vectors start at zero)
    rjmp start ; Reset Vector, jump to init
    reti ; INT0-Int, inactive
    reti ; PCINT-Int, inactive
    reti ; TIM0_OVF, inactive
    reti ; EE_RDY-Int, inactive
    reti ; ANA_COMP-Int, inactive
    reti ; TIM0_COMPA-Int, inactive
    reti ; TIM0_COMPB-Int, inactive
    reti ; WDT-Int, inactive
    reti ; ADC-Int, inactive
;
; Program init at Reset
;
start:
    ; TODO: Init stack.
    sbi     DDRB,5      ; PB5 is pin 13 on the Uno which is the built-in LED.

loop:
    ldi     r20, 250
    call    delay_ms
    ldi     r20, 250
    call    delay_ms
    sbi     PORTB, 5    ; Turn on LED.
    ldi     r20, 250
    call    delay_ms
    cbi     PORTB, 5    ; Turn off LED.
    jmp     loop

delay_ms:
    ;; Delay N millis, based on value of r20.
    ;; Destroys r20, r30 and r31.
    ;; One millisecond is about 3000 iterations at 16MHz.
one_ms = 3000
	ldi     30, lo8(one_ms)
	ldi     31, hi8(one_ms)
loop_1ms:
	sbiw    r30, 1      ; Decrement 16-bit counter.
	brne    loop_1ms
	subi    r20, 1      ; Decrement millis by 1.
	brne    delay_ms
	ret