all: 9895.bin

orig_bin=1818-1391a.bin

9895.bin: 9895.asm

9895.dis:${orig_bin}
	dz80 -d -x0 ${orig_bin}
	mv ${patsubst %.bin,%.z80} 9895.dis

#9895.asm: ${orig_bin}
#	dz80 -x0 ${orig_bin}
#	mv ${patsubst %.bin,%.z80} 9895.asm

%.bin: %.p
	p2bin -r 0-8191 $< $@

%.hex: %.p
	p2hex F Intel -r 0-8191 $< $@

%.lst %.p: %.asm
	rm -f $*.lst
	asl -cpu z80 -L -C $<
	chmod -w $*.lst

diff:
	./hexdiff ${orig_bin} 9895.bin

clean:
	rm -f 9895.bin 9895.ctl 9895.dis
