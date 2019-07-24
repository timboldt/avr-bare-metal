MCU=atmega328p
F_CPU=16000000UL
CC=avr-gcc
OBJ_DUMP=avr-objdump
STDLIB=__AVR_ATmega328P__
OBJCOPY=avr-objcopy
IDIR=/usr/lib/avr/include
CFLAGS=-std=c99 -Wall -g -Os -mmcu=${MCU} -DF_CPU=${F_CPU} -D${STDLIB} -I. -I${IDIR}

TARGET=main
SRCS=main.c
LINUX_PORT=/dev/ttyS3

all:
	${CC} ${CFLAGS} -o ${TARGET}.bin ${SRCS}
	${OBJCOPY} -j .text -j .data -O ihex ${TARGET}.bin ${TARGET}.hex

compile:
	${CC} ${CFLAGS} -c ${SRCS}

link:
	${CC} ${CFLAGS} -o ${TARGET}.elf ${TARGET}.o

elf:
	${CC} ${CFLAGS} -c ${SRCS}
	${CC} ${CFLAGS} -o ${TARGET}.elf ${TARGET}.o
dump:
	${OBJ_DUMP} -h -S ${TARGET}.elf > ${TARGET}.lst

flash:
	avrdude -F -V -v -y -c arduino -p ${MCU} -P ${LINUX_PORT} -b 115200 -U flash:w:${TARGET}.hex:i

clean:
	rm -f *.bin *.hex