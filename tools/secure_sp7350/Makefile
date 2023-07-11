#
# (C) Copyright 2012 The Chromium Authors
#
# SPDX-License-Identifier:	GPL-2.0+
#

OPENSSL=./openssl

SZ:=$(shell wc -c $(IMG)|cut -f1 -d" ")
SZ:=$(shell echo "(16 - ($(SZ) % 16)) % 16" | bc)

KEY1_BIN=../secure_hsm/secure/otp_Device_keys/x_priv_0.bin
KEY1=$(shell cat ../secure_hsm/secure/otp_Device_keys/x_priv_0.hex)
KEY2=$(shell cat ../secure_hsm/secure/otp_Sb_keys/ed_pub_0.hex)
KEY3=$(shell $(OPENSSL) enc -aes-256-ctr -K $(KEY2) -iv $(KEY2) -nosalt -in $(KEY1_BIN) | xxd -ps -c 32)

pk.pem:
	$(OPENSSL) genrsa -out pk.pem 2048

rsakey_N.h: pk.pem
	$(OPENSSL) rsa -in pk.pem -modulus -noout | cut -c 9- | xxd -ps -r | xxd -i > rsakey_N.h

padding:
	@dd if=/dev/zero bs=1 count=$(SZ) >> $(IMG)

sign: pk.pem padding
	@echo SB=$(SB) $(KEY3)
	@[ "$(SB)" = "3" ] && $(OPENSSL) enc -aes-256-ctr -K $(KEY3) -iv $(KEY1) -nosalt -in $(IMG) -out ~t && mv ~t $(IMG) || true
	@$(OPENSSL) sha3-512 -binary $(IMG) | $(OPENSSL) pkeyutl -sign -inkey pk.pem | xxd -p -c1 | tac | xxd -p -r >> $(IMG)
	@$(OPENSSL) rsa -in pk.pem -modulus -noout | cut -c 9- | xxd -ps -r | xxd -p -c1 | tac | xxd -p -r >> $(IMG)

clean:
	rm -f pk.pem rsakey_N.h
