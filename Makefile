#
# Simple Makefile for programming Atmel AVR MCUs using avra and avrdude
#
# Assemble with 'make', flash hexfile to microcontroller with 'make flash'.
#
# Configuration:
#
# MCU     -> name of microcontroller to program (see 'avrdude -p ?' for a list)
# AVRDUDE_PROGRAMMER  -> target board/programmer to use (see 'avrdude -c ?' for a list)
# AVRDUDE_PORT  -> linux device file refering to the interface your programmer is plugged in to
# INCPATH -> path to the AVR include files
# SRCFILE -> single assembler file that contains the source
#
 
MCU = atmega328p
AVRDUDE_PROGRAMMER = arduino
AVRDUDE_PORT = /dev/ttyUSB0
INCPATH = third_party
TARGET = main
 
$(TARGET).hex: $(TARGET).asm
	avra -l $(TARGET).lst -I $(INCPATH) $(TARGET).asm
 
flash:
	avrdude -c $(AVRDUDE_PROGRAMMER) -p $(MCU) -P $(AVRDUDE_PORT) -U flash:w:$(TARGET).hex:i
 
showfuses:
	avrdude -c $(AVRDUDE_PROGRAMMER) -p $(MCU) -P $(AVRDUDE_PORT) -v 2>&1 |  grep "fuse reads" | tail -n2
 
clean:
	rm *.hex *.obj *.cof *.lst
