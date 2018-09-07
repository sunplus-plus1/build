
.PHONY: all
all: isp

isp: isp.o
	gcc -o $@ $^
	ls -lF

isp.o: isp.c
	gcc -c -o $@ $^

.PHONY: clean
clean:
	@rm -rf *.o isp
	ls -lF
