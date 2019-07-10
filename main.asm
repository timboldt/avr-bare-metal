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
.EQU clockOverflowCount = 256*1024

; ============================================
;  F I X + D E R I V E D   C O N S T A N T S 
; ============================================
.EQU clockFrequency = 16000000
.EQU overflowsPerSecond = clockFrequency / clockOverflowCount
.EQU repetitions = overflowsPerSecond / 2  ; Counter overflow repititions for LED.

; ============================================
;   R E G I S T E R   D E F I N I T I O N S
; ============================================
.DEF rgeneral = R16     ; General purpose working register.
.DEF rtempintr1 = R17   ; Temporary working register in interrupts.
.DEF rtempintr2 = R17   ; Temporary working register in interrupts.
.DEF rcounter = R18     ; Blink counter.
.DEF rledstate = R19    ; LED state.

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
    in rtempintr1, SREG
    push rtempintr1

    ; Increase the counter.
    ; After `repetitions` overflows, toggle the state.
    inc rcounter
    cpi rcounter, repetitions
    brne TIMER0_OVF_Return

    ; Toggle the LED state.
    ldi rtempintr1, 1<<ledPinNumber
    eor rledstate, rtempintr1
    out ledPort, rledstate

    ; Clear counters.
    clr rcounter
    clr rtempintr1
    out TCNT0, rtempintr1

TIMER0_OVF_Return:
    pop rtempintr1
    out SREG, rtempintr1
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
    ;ldi rgeneral, 1<<WGM01 ; CTC mode
    ;out TCCR0A, rgeneral
    clr rgeneral
    out TCNT0, rgeneral
    ldi rgeneral, (1<<CS02) | (1<<CS00) ; Prescaler 1024
    out TCCR0B, rgeneral
    ldi rgeneral, (1<<TOIE0) ; Enable overflow interrupt
    sts TIMSK0, rgeneral

    ldi rledstate, 1<<ledPinNumber
    out ledPort, rledstate

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
