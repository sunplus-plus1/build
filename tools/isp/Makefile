.PHONY: all clean

NAND_PAGE_SIZE ?= 2

ifeq ($(FREERTOS),1)
CFLAGS = -DFREERTOS=1
endif

ifeq ($(CHIP),Q645)
CFLAGS = -DQ645=1
endif

ifeq ($(CHIP),SP7350)
CFLAGS = -DSP7350=1
CFLAGS += -DNAND_PAGE_SIZE=$(NAND_PAGE_SIZE)*1024
endif


all: isp

isp: isp.o
	gcc -o $@ $^

isp.o: isp.c
	gcc -c $(CFLAGS) -o $@ $^

clean:
	@rm -rf *.o isp

