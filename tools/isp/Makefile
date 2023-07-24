.PHONY: all clean

ifeq ($(NAND_PAGE_SIZE),)
NAND_PAGE_SIZE_TEMP = 2048
else
NAND_PAGE_SIZE_TEMP = $(NAND_PAGE_SIZE)*1024
endif

ifeq ($(FREERTOS),1)
CFLAGS = -DFREERTOS=1
endif

ifeq ($(CHIP),Q645)
CFLAGS = -DQ645=1
endif

ifeq ($(CHIP),SP7350)
CFLAGS = -DSP7350=1
endif

CFLAGS += -DNAND_PAGE_SIZE=$(NAND_PAGE_SIZE_TEMP)

all: isp

isp: isp.o
	gcc -o $@ $^

isp.o: isp.c
	gcc -c $(CFLAGS) -o $@ $^

clean:
	@rm -rf *.o isp

