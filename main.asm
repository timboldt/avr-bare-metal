; Copyright 2019 Google LLC
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     https://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; ********************************************
; * AVR Assembler Experiments                *
; ********************************************

.NOLIST
.INCLUDE "m328Pdef.inc"
.LIST

; ============================================
;      P O R T S   A N D   P I N S 
; ============================================
.EQU ledPort = PORTB
.EQU ledPinNumber = PB5

; ============================================
;    C O N S T A N T S   T O   C H A N G E 
; ============================================
.EQU blinksPerSecond = 1

; ============================================
;  F I X + D E R I V E D   C O N S T A N T S 
; ============================================
.EQU cpuMHz = 16000000
.EQU timer0ClockPeriod = 256*1024 ; 8-bit timer with 1024 prescalar.
.EQU overflowsPerSecond = cpuMHz / timer0ClockPeriod
.EQU maxTimer0Overflow = overflowsPerSecond \
        / blinksPerSecond / 2  ; On+off == 2.

; ============================================
;   R E G I S T E R   D E F I N I T I O N S
; ============================================
.DEF rgeneral = R16     ; General purpose working register.
.DEF rint1 = R17        ; Temporary working register in interrupts.
.DEF rint2 = R18        ; Temporary working register in interrupts.
.DEF rcounter = R19     ; Timer 0 overflow counter.

; ============================================
;       S R A M   D E F I N I T I O N S
; ============================================
.DSEG
.ORG  0x0100
; Format: Label: .BYTE N ; reserve N Bytes from Label:

; ============================================
;   R E S E T   A N D   I N T   V E C T O R S
; ============================================
.CSEG
.ORG $0000
	rjmp Main
.ORG OVF0addr
    rjmp TIMER0_OVF_ISR

; ============================================
;     I N T E R R U P T   S E R V I C E S
; ============================================
TIMER0_OVF_ISR:
    ; Save status register on stack.
    in rint1, SREG
    push rint1

    ; Increase the counter.
    ; After `maxTimer0Overflow` overflows, toggle the state.
    inc rcounter
    cpi rcounter, maxTimer0Overflow
    brne TIMER0_OVF_Return

    ; Toggle the LED state.
    in rint1, ledPort ; Get current LED output pin value.
    ldi rint2, 1<<ledPinNumber
    eor rint1, rint2 ; Toggle it.
    out ledPort, rint1 ; Write it back.

    ; Clear counters.
    clr rcounter
    clr rint1
    out TCNT0, rint1

TIMER0_OVF_Return:
    pop rint1
    out SREG, rint1
    reti

; ============================================
;     M A I N    P R O G R A M    I N I T
; ============================================
;
Main:
    ; Init stack
	ldi rgeneral, LOW(RAMEND) ; Init LSB stack
	out SPL,rgeneral

    ; Set ledPinNumber as an output pin.
    sbi DDRB, ledPinNumber

    ; Init counter.
    clr rcounter

    ; Set up timer 0 to trigger every 4ms.
    clr rgeneral
    out TCNT0, rgeneral ; Clear timer counter.
    ldi rgeneral, (1<<CS02) | (1<<CS00) ; Prescaler 1024
    out TCCR0B, rgeneral
    ldi rgeneral, (1<<TOIE0) ; Enable overflow interrupt
    sts TIMSK0, rgeneral

    ; Turn LED on to start with.
    ldi rgeneral, 1<<ledPinNumber
    out ledPort, rgeneral

    ; Enable sleep.
	ldi rgeneral,1<<SE
	out MCUCR,rgeneral

    ; Enable interrupts and go.
	sei
;
; ============================================
;         P R O G R A M    L O O P
; ============================================
;
MainLoop:
	sleep
	nop ; dummy for wake up
	rjmp MainLoop
