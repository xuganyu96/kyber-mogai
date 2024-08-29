CC = /usr/bin/cc
DEVPORT = 8888

# Flags copied from kyber/ref/Makefile
KYBERDIR = kyber/ref
KYBERSOURCES = $(KYBERDIR)/kem.c $(KYBERDIR)/indcpa.c $(KYBERDIR)/polyvec.c $(KYBERDIR)/poly.c $(KYBERDIR)/ntt.c $(KYBERDIR)/cbd.c $(KYBERDIR)/reduce.c $(KYBERDIR)/verify.c $(KYBERDIR)/randombytes.c
KYBERSOURCESKECCAK = $(KYBERSOURCES) $(KYBERDIR)/fips202.c $(KYBERDIR)/symmetric-shake.c
KYBERHEADERS = $(KYBERDIR)/params.h $(KYBERDIR)/kem.h $(KYBERDIR)/indcpa.h $(KYBERDIR)/polyvec.h $(KYBERDIR)/poly.h $(KYBERDIR)/ntt.h $(KYBERDIR)/cbd.h $(KYBERDIR)/reduce.c $(KYBERDIR)/verify.h $(KYBERDIR)/symmetric.h
KYBERHEADERSKECCAK = $(KYBERHEADERS) $(KYBERDIR)/fips202.h
CFLAGS += -Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls \
  -Wshadow -Wpointer-arith -O3 -fomit-frame-pointer 
NISTFLAGS += -Wno-unused-result -O3 -fomit-frame-pointer

SOURCES = $(KYBERSOURCESKECCAK) authenticators.c etm.c kex.c
HEADERS = $(KYBERHEADERSKECCAK) authenticators.h etm.h kex.h

.PHONY: test clean speed run_kex_server512 run_kex_client512

main: $(SOURCES) $(HEADERS) main.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -lcrypto main.c -o $@
	./main

test: \
	test/test_authenticators512 \
	test/test_authenticators768 \
	test/test_authenticators1024 \
	test/test_etm512_poly1305 \
	test/test_etm768_poly1305 \
	test/test_etm1024_poly1305 \
	test/test_etm512_gmac \
	test/test_etm768_gmac \
	test/test_etm1024_gmac \
	test/test_speed512 \
	test/test_speed768 \
	test/test_speed1024
	./test/test_authenticators512
	./test/test_authenticators768
	./test/test_authenticators1024
	./test/test_etm512_poly1305
	./test/test_etm768_poly1305
	./test/test_etm1024_poly1305
	./test/test_etm512_gmac
	./test/test_etm768_gmac
	./test/test_etm1024_gmac

speed: \
	test/test_speed512 \
	test/test_speed768 \
	test/test_speed1024

test/test_authenticators512: $(SOURCES) $(HEADERS) test/test_authenticators.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/cpucycles.h $(KYBERDIR)/test/speed_print.c $(KYBERDIR)/test/speed_print.h
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DKYBER_K=2 $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/speed_print.c test/test_authenticators.c -o $@

test/test_authenticators768: $(SOURCES) $(HEADERS) test/test_authenticators.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/cpucycles.h $(KYBERDIR)/test/speed_print.c $(KYBERDIR)/test/speed_print.h
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DKYBER_K=3 $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/speed_print.c test/test_authenticators.c -o $@

test/test_authenticators1024: $(SOURCES) $(HEADERS) test/test_authenticators.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/cpucycles.h $(KYBERDIR)/test/speed_print.c $(KYBERDIR)/test/speed_print.h
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DKYBER_K=4 $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/speed_print.c test/test_authenticators.c -o $@

test/test_etm512_poly1305: $(SOURCES) $(HEADERS) test/test_etm.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DKYBER_K=2 test/test_etm.c -o $@

test/test_etm768_poly1305: $(SOURCES) $(HEADERS) test/test_etm.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DKYBER_K=3 test/test_etm.c -o $@

test/test_etm1024_poly1305: $(SOURCES) $(HEADERS) test/test_etm.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DKYBER_K=4 test/test_etm.c -o $@

test/test_etm512_gmac: $(SOURCES) $(HEADERS) test/test_etm.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DMACNAME=GMAC -DKYBER_K=2 test/test_etm.c -o $@

test/test_etm768_gmac: $(SOURCES) $(HEADERS) test/test_etm.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DMACNAME=GMAC -DKYBER_K=3 test/test_etm.c -o $@

test/test_etm1024_gmac: $(SOURCES) $(HEADERS) test/test_etm.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) -DMACNAME=GMAC -DKYBER_K=4 test/test_etm.c -o $@

test/test_speed512: $(SOURCES) $(HEADERS) test/test_speed.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/cpucycles.h $(KYBERDIR)/test/speed_print.c $(KYBERDIR)/test/speed_print.h
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) test/test_speed.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/speed_print.c -DKYBER_K=2 -o $@

test/test_speed768: $(SOURCES) $(HEADERS) test/test_speed.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/cpucycles.h $(KYBERDIR)/test/speed_print.c $(KYBERDIR)/test/speed_print.h
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) test/test_speed.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/speed_print.c -DKYBER_K=3 -o $@

test/test_speed1024: $(SOURCES) $(HEADERS) test/test_speed.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/cpucycles.h $(KYBERDIR)/test/speed_print.c $(KYBERDIR)/test/speed_print.h
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) test/test_speed.c $(KYBERDIR)/test/cpucycles.c $(KYBERDIR)/test/speed_print.c -DKYBER_K=4 -o $@

kex_server512: $(SOURCES) $(HEADERS) kex_server.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) kex_server.c -DKYBER_K=2 -o $@

run_kex_server512: kex_server512
	./kex_server512 $(DEVPORT)

kex_client512: $(SOURCES) $(HEADERS) kex_client.c
	$(CC) $(CFLAGS) $(LDFLAGS) -lcrypto $(SOURCES) kex_client.c -DKYBER_K=2 -o $@

run_kex_client512: kex_client512
	./kex_client512

clean:
	$(RM) main
	$(RM) kex_server512
	$(RM) kex_client512
	$(RM) test/test_authenticators512
	$(RM) test/test_authenticators768
	$(RM) test/test_authenticators1024
	$(RM) test/test_etm1024_gmac
	$(RM) test/test_etm1024_poly1305
	$(RM) test/test_etm512_gmac
	$(RM) test/test_etm512_poly1305
	$(RM) test/test_etm768_gmac
	$(RM) test/test_etm768_poly1305
	$(RM) test/test_speed512
	$(RM) test/test_speed768
	$(RM) test/test_speed1024
