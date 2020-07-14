
.PHONY: all
all: isp

isp: isp.o
	gcc -o $@ $^

isp.o: isp.c
	@if [ $(FREERTOS) -eq 1 ]; then \
		gcc -c -DFREERTOS=1 -o $@ $^; \
	else \
		gcc -c -o $@ $^; \
	fi

.PHONY: clean install

clean:
	@rm -rf *.o isp
