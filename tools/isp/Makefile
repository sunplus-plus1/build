.PHONY: all clean

ifeq ($(FREERTOS),1)
CFLAGS = -DFREERTOS=1
endif

ifeq ($(CHIP),Q645)
CFLAGS = -DQ645=1
endif

ifeq ($(CHIP),SP7350)
CFLAGS = -DSP7350=1
ifeq ($(PNAND_FLASH),1)
CFLAGS += -DPNAND_PAGE_SIZE=2048
else ifeq ($(PNAND_FLASH),2)
CFLAGS += -DPNAND_PAGE_SIZE=4096
else ifeq ($(PNAND_FLASH),3)
CFLAGS += -DPNAND_PAGE_SIZE=2048
else ifeq ($(PNAND_FLASH),4)
CFLAGS += -DPNAND_PAGE_SIZE=2048
endif
endif


all: isp

isp: isp.o
	gcc -o $@ $^

isp.o: isp.c
	gcc -c $(CFLAGS) -o $@ $^

clean:
	@rm -rf *.o isp

