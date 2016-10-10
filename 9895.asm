; HP 9895A floppy disk firmware
; Partially reverse-engineered by Eric Smith <spacewar@gmail.com>
; with assistance from Craig Ruff

; Cross-assembles with Macro Assembler AS:
;   http://john.ccac.rwth-aachen.de:8000/as/

; Marketing blurb about PHI chip:
;   Hewlett-Packard Computer Advances, Volume 2 Number 4, November 1977
;   included in Computerworld, Volume XI Number 46, November 14, 1977
;
; General description of the PHI chip:
;   "PHI, the HP-IB Interface Chip", John W. Figueroa,
;   Hewlett Packard Journal, Volume 29 Number 11, July 1978, pp. 16-16
;
; Detailed information about PHI chip:
;   "HP 12009A HP-IB Interface Reference Manual",
;   manual part number 12009-90001, September 1982

	org	0

fillto	macro	endaddr,value
	while	$<endaddr
	if	(endaddr-$)>1024
	db	1024 dup (value)
	else
	db	(endaddr-$) dup (value)
	endif
	endm
	endm


; I/O ports


; PHI chip (Processor to Hpib Interface)

; XXX While the ports are 10h..17h, I think these specific assignments
; are wrong. Maybe address bits are permuted and/or inverted?  See e.g.
; the sequences that write 00h and 81h to two registers, which could be
; the identify response if written to phi_id1 and phi_id2.

phi0	equ	10h
phi1	equ	11h
phi2	equ	12h
phi3	equ	13h
phi4	equ	14h
phi5	equ	15h
phi6	equ	16h
phi7	equ	17h


;phi_fifo	equ	10h	; bit 15..14: 00 - RX/TX normal data
				;             01 - RX secondary address
				;	      01 - TX interface command
				; 	      10 - TX byte count
				;             11 - RX end
				;	      11 - TX uncounted transfer enable
				; bits 7..0: data

;phi_status	equ	11h	; bits 7..6: high order bit access
				; bit 5: REM
				; bit 4: Controller
				; bit 3: System Controller
				; bit 2: Addressed to talk or identify
				; bit 1: Addressed to listen
				; bit 0: Outbound data freeze

;phi_int_cond	equ	12h	; bit 7: status change
				; bit 6: processor handshake abort
				; bit 5: parallel poll response
				; bit 4: service request
				; bit 3: fifo room available
				; bit 2: fifo bytes available
				; bit 1: fifo idle
				; bit 0: device clear

;phi_int_mask	equ	13h

;phi_id1		equ	14h
;phi_id2		equ	15h

;phi_ctrl	equ	16h	; bit 7: 8-bit processor
				; bit 6: parity freeze
				; bit 5: REN value
				; bit 4: IFC value
				; bit 3: respond to parallel poll
				; bit 2: request service
				; bit 1: DMA fifo select
				; bit 0: initialize outbound FIFO (write only)

;phi_addr	equ	17h	; bit 7: ONL (online)
				; bit 6: TA (talk always)
				; bit 5: LA (listen always)
				; bits 4..0: HP-IB address

fdc0	equ	60h
fdc1	equ	61h
fdc2	equ	62h
fdc3	equ	63h
fdc4	equ	64h
fdc5	equ	65h
fdc6	equ	66h
fdc7	equ	67h


; RAM
	org	6000h
x6000:	ds	1
x6001:	ds	1
x6002:	ds	1
x6003:	ds	1
x6004:	ds	1
x6005:	ds	1
x6006:	ds	1
x6007:	ds	1
x6008:	ds	1
x6009:	ds	1
x600a:	ds	1
x600b:	ds	1
x600c:	ds	1
x600d:	ds	1
x600e:	ds	1
x600f:	ds	1
x6010:	ds	1
x6011:	ds	1
x6012:	ds	1
x6013:	ds	1
x6014:	ds	1
x6015:	ds	2
x6017:	ds	2
x6019:	ds	5
x601e:	ds	40
x6046:	ds	1

x6047:	ds	1	; first byte of command
x6048:	ds	1	; second byte of command
x6049:	ds	1	; third byte of command
x604a:	ds	3	; fourth through sixth bytes of command

x604d:	ds	1
x604e:	ds	1
x604f:	ds	1
x6050:	ds	27
x606b:	ds	9
x6074:	ds	64
x60b4:	ds	7
x60bb:	ds	1

	org	63fch
x63fc:	ds	1
x63fd:	ds	1
x63fe:	ds	1
x63ff:	ds	1


	org	0

rst00:	jp	doreset

x0003:	jp	x012b

	ld	(de),a
	add	a,b

rst08:	jp	do_rst08

x000b:	jp	x0360

	ld	b,26h
	
	jp	do_rst10

x0013:	jp	x0312

	ld	d,54h
	jp	do_rst18

x001b:	jp	x06a8

	ld	c,l
	ld	h,b

	jp	do_rst20

x0023:	jp	x0463

	fillto	0028h,076h

x0028:	jp	do_rst28

x002b:	jp	x0acf

	fillto	0030h,076h

	jp	do_rst30

x0033:	jp	x0bc8

	fillto	0038h,076h

	ex	af,af'
	di
x003a:	in	a,(phi3)
	exx
	ld	hl,x135c
	ex	(sp),hl
	exx
	push	af
	ex	af,af'
	pop	af
	reti

	fillto	0057h,076h

	jp	x154c

	jp	x151a

x005d:	jp	x0e71

x0060:	jp	x1041

x0063:	jp	x0733

	jp	x13b9

	halt

x006a:	jp	sub1

x006d:	jp	x0440

x0070:	ld	a,2
	jr	x0075

x0074:	xor	a
x0075:	ld	(x6000),a
	ld	sp,x63ff
	xor	a
	out	(phi3),a
	ld	(x600c),a
	ld	a,0dh
	out	(phi1),a
	in	a,(phi4)
	res	6,a
	out	(phi4),a
x008b:	xor	a
	ld	(x6001),a
	ld	(x6002),a
	ld	(x6006),a
	call	x124d
	call	x1266
	xor	a
	out	(fdc4),a
	out	(phi3),a
	out	(phi6),a
	ld	a,81h
	out	(phi7),a
	ld	a,41h
	out	(phi3),a
	ld	a,0ffh
	out	(phi0),a
	ld	(iy+0dh),3
x00b2:	ld	a,(x600d)
	cp	0ffh
	jr	z,x010a
	dec	(iy+0dh)
	ld	b,a
	call	x1507
	xor	a
	out	(fdc5),a
	ld	(ix+4),a
	inc	b
	ld	a,10h
x00c9:	rrca
	djnz	x00c9
	ld	(ix+9),a
	out	(fdc6),a
	call	x1612
	jr	z,x00ed
	ld	a,(x6000)
	cp	2
	jr	z,x00ef
	ld	a,(ix+5)
	and	1eh
	ld	d,a
	ld	a,(ix+6)
	and	4bh
	ld	e,a
	and	3
	jr	x00f8

x00ed:	jr	nc,x00f5
x00ef:	ld	d,0
	ld	e,8
	jr	x00f8

x00f5:	ld	e,a
	ld	d,0
x00f8:	ld	(ix+5),d
	ld	(ix+6),e
	rst	8
	jr	z,x0105
	ld	(ix+6),2
x0105:	call	x154c
	jr	x00b2

x010a:	in	a,(phi4)
	and	40h
	or	89h
	ld	b,a
	ld	a,80h
	out	(phi3),a
	ld	a,b
	out	(phi4),a
	in	a,(fdc3)
	and	7
	or	80h
	out	(phi5),a
	im	1
	ld	a,(x6000)
	cp	2
	jr	nz,x012b
	jr	x014a

x012b:	call	x124d
	ld	a,(x6000)
	rlca
	or	10h
	rst	28h
x0135:	ld	b,0
x0137:	call	x1285
	jr	nz,x0145
	djnz	x0137
	ld	d,10h
	call	x155f
	jr	x0135

x0145:	call	x0154
	jr	x012b

x014a:	ld	a,(x6007)
	set	0,a
	cpl
	out	(fdc3),a
	jr	x0135

x0154:	call	x1272
	ld	a,0f9h
	out	(fdc3),a
x015b:	in	a,(phi2)
	ld	c,a
	in	a,(phi3)
	bit	6,a
	jr	nz,x0169
	call	x01ae
	jr	x015b

x0169:	and	0c0h
	cp	40h
	jp	nz,x1473
	ld	a,c
	cp	30h
	jp	z,x03e0
	call	x1290

	ld	a,c		; get secondary address

	cp	10h		; don't look up 10h in table
	jp	z,x0312		;   DSJ (talker), HP-300 clear (listener)

	and	1fh
	ld	hl,x01c9
	ld	de,x0003
	ld	b,9
x0189:	cp	(hl)
	jr	z,x0192
	add	hl,de
	djnz	x0189
	jp	x1473

x0192:	inc	hl
	bit	5,c
	jr	z,x0198
	inc	hl
x0198:	ld	e,(hl)
	ld	hl,x01e4
	add	hl,de


; execute command handler at address pointed to by HL
x019d:	ld	e,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,e
	
	ld	de,x01a6	; call subroutine pointed to by HL
	push	de
	jp	(hl)
x01a6:

	call	x1285
	ret	nz
	call	x1278
	ret


x01ae:	ld	bc,0
	ld	d,1fh
x01b3:	call	x1285
	ret	nz
	in	a,(phi3)
	and	6
	jp	z,x1473
	djnz	x01b3
	dec	c
	jr	nz,x01b3
	dec	d
	jr	nz,x01b3
	jp	x1473


; secondary address dispatch
;   first byte is secondary address
;   second and third bytes are byte indexes into jump table at x01e4
;   xxx possible that second vs. third byte chosen by listen vs talk
x01c9:	db	008h, 004h, 000h
	db	009h, 004h, 000h
	db	00ah, 004h, 000h
	db	00bh, 004h, 000h
	db	00ch, 004h, 000h
	db	00fh, 010h, 000h
	db	011h, 006h, 002h
	db	01eh, 008h, 00ah
	db	01fh, 00ch, 00eh
	
x01e4:	dw	x1473	; invalid
	dw	sub6	; talker   11: HP-IB CRC
	dw	x01f6	; listener 08, 09, 0a, 0b, 0c: commands
	dw	x01a6	; listener 11: HP-IB CRC
	dw	x11ea	; listener 1e: read loopback
	dw	x11db	; talker   1e: write loopback
	dw	x1206	; listener 1f: initiate self-test
	dw	x1225	; talker   1f: read self-test
	dw	x11f2	; listener 0f: download


; listen with secondary address 08, 09, 0a, 0b, 0c
x01f6:	ld	hl,x6046
	push	bc
	push	hl
	ld	e,0
	inc	hl
x01fe:	call	x01ae
	ld	c,12h
	ini
x0205:	in	a,(phi3)
	inc	e
x0208:	bit	6,a
	jr	nz,x0210
	xor	a
	cp	e
	jr	nz,x01fe
x0210:	and	0c0h
	cp	40h
	jr	nz,x0220
	call	x1290
	dec	hl
x021a:	ld	a,(hl)
	cp	10h
	jp	z,x0013
x0220:	pop	hl
	ld	(hl),e
	pop	bc

	ld	hl,x0264
	ld	d,0
x0228:	ld	a,c		; does secondary address match table header?
	cp	(hl)
	jr	z,x0238		; yes
	inc	hl		; no, get length of table
	ld	b,(hl)
	inc	hl

	xor	a		; HL := HL + b * 4
x0230:	add	a,4
	djnz	x0230
	ld	e,a
	add	hl,de
	jr	x0228


; secondary address found
x0238:	inc	hl
	ld	a,(x6047)
	and	1fh
	jr	z,x024a
	ld	b,a
	ld	a,(x6048)
	and	0fh
	ld	(x6048),a
	ld	a,b
x024a:	ld	b,(hl)		; get length of table
	ld	e,4		; DE := 4 (table entry length)
	inc	hl
x024e:	cp	(hl)		; does command match?
	jr	z,x0257		; yes
	add	hl,de		; no, advance to next entry
	djnz	x024e		; hit end of table? if not, loop
	jp	x147c		; command not found


; command found
x0257:	inc	hl		; advance pointer to length byte
	ld	a,(x6046)
	cp	(hl)		; does command length match?
	jp	nz,x1473
	inc	hl		; advance pointer to dispatch vector
	pop	de
	jp	x019d		; dispatch


; command dispatch tables
; a series of tables for each secondary address (08 through 0c)

; each table has a two byte header
;   first byte - secondary address
;   second byte - table length in 4 byte entries

; each table entry is four bytes
;   first byte - command
;   second byte - byte count (including command byte)
;   third and fourth bytes - execution address

x0264:
; secondary address 08
	db	008h,009h

	db	003h,002h
	dw	cmd_request_status

	db	002h,006h
	dw	cmd_seek

	db	005h,002h
	dw	cmd_unbuffered_read

	db	008h,002h
	dw	cmd_unbuffered_write

	db	015h,002h
	dw	cmd_end

	db	014h,002h
	dw	cmd_request_logical_address

	db	007h,004h
	dw	cmd_verify

	db	00bh,002h
	dw	cmd_initialize

	db	000h,002h
	dw	cmd_cold_load_read

; secondary address 09
	db	009h,001h

	db	008h,002h
	dw	cmd_buffered_write

; secondary address 0a
	db	00ah,003h

	db	003h,002h
	dw	cmd_request_status
	
	db	005h,002h
	dw	cmd_buffered_read

	db	014h,002h
	dw	cmd_request_logical_address

; secondary address 0b
	db	00bh,002h

	db	005h,002h
	dw	cmd_buffered_read_verify

	db	006h,002h
	dw	cmd_id_triggered_read

; secondary address 0c
	db	00ch,005h

	db	019h,002h
	dw	cmd_door_lock

	db	01ah,002h
	dw	cmd_door_unlock

	db	005h,002h
	dw	cmd_unbuffered_read_verify

	db	018h,005h
	dw	cmd_format

	db	014h,002h
	dw	cmd_request_physical_address


x02be:	ld	a,(x6000)
	cp	2
	ret	nz
	jp	x1464

x02c7:	ld	a,(x6009)
	cp	2
	jp	z,x149c
	ret

x02d0:	in	a,(fdc2)
	bit	3,a
	jp	nz,x149c
	ret


x02d8:	call	x02eb
	call	x14c1
	ret	z
	ld	a,(x6001)
	cp	1
	ret	z
	cp	0ah
	ret	z
	jp	x1464


x02eb:	ld	a,(iy+48h)
	cp	4
	jp	m,x02fb
	ld	a,17h
	call	sub7
	jp	x1464


x02fb:	call	x151a
	call	x1612
	jp	nc,x149c
	jr	nz,x030a
	set	3,(ix+6)
x030a:	bit	3,(ix+6)
	jp	nz,x149c
	ret


x0312:	ld	bc,0
	ld	d,5eh
x0317:	in	a,(phi0)
	bit	0,a
	jr	nz,x032c
	djnz	x0317
	dec	c
	jr	nz,x0317
	dec	d
	jr	nz,x0317
x0325:	ld	a,1
	out	(phi0),a
	jp	x1473

x032c:	bit	2,a
	jr	z,x0325
	in	a,(phi2)
	ld	b,a
	in	a,(phi3)
	and	0c0h
	cp	0c0h
	jr	nz,x0325
	xor	a
	ld	(x6000),a
	bit	0,b
	jr	z,x0345
	ld	a,40h
x0345:	ld	b,a
	in	a,(phi4)
	or	b
	out	(phi4),a
	ld	a,b
	ld	(x600c),a
	out	(phi3),a
	ld	a,0dh
	out	(phi1),a
	bit	6,b
	jp	nz,x008b
	call	x1290
	jp	x008b

x0360:	push	af
	call	x1272
	in	a,(phi0)
	bit	2,a
	jp	z,x0074
	pop	af
	ret


cmd_end:
	call	x02be
	ld	a,2
	rst	28h
	ld	a,(x6003)
	ld	(x600d),a
	call	x14b1
x037c:	ld	(iy+3),3
x0380:	ld	a,(x6003)
	call	x151a
	ld	e,(ix+6)
	call	x1612
	jr	nz,x039b
	jr	c,x03bd
	ld	b,a
	ld	a,e
	and	3
	cp	2
	jr	z,x039b
	cp	b
	jr	nz,x03bf
x039b:	bit	3,e
	jr	nz,x03bd
	call	x1285
	jr	nz,x03c9
	call	x154c
	dec	(iy+3)
	jp	p,x0380
	ld	b,0
x03af:	call	x1285
	jr	nz,x03c9
	djnz	x03af
	ld	d,12h
	call	x155f
	jr	x037c

x03bd:	set	3,e
x03bf:	set	7,e
	ld	(ix+6),e
	ld	a,1fh
	call	sub7
x03c9:	call	x154c
	ld	a,(x600d)
	ld	(x6003),a
	ret


	fillto	03e0h,076h


x03e0:	in	a,(phi0)
	in	a,(phi3)
	and	40h
	jr	nz,x0427
x03e8:	in	a,(phi4)
	or	1
	out	(phi4),a
	ld	a,81h
	out	(phi3),a
	ld	a,(x6000)
	out	(phi2),a
	in	a,(phi0)
	bit	2,a
	jp	nz,x1467
	ld	a,(x6000)
	sub	2
	ret	c
	ld	a,(x6001)
x0407:	or	a
	jr	z,x0423
	cp	1fh
	jr	nz,x0421
	ld	b,(iy+3)
	call	x1507
	call	x1500
	bit	4,d
	jr	nz,x0421
	bit	2,d
	ld	a,0
	jr	z,x0423
x0421:	ld	a,1
x0423:	ld	(x6000),a
	ret

x0427:	ld	b,40h
	out	(phi3),a
	xor	a
	out	(phi0),a
	ld	(iy+0),3
	jr	x03e8


cmd_request_status
	call	x02be
	ld	a,8
	rst	28h
	ld	a,(x6048)
	call	x0023
x0440:	push	bc
	push	de
	ld	b,28h
	call	x12a3
	pop	de
	pop	bc
	ld	hl,x6046
	ld	(x6047),bc
	ld	(x6049),de
	ld	(iy+4bh),1
	ld	b,3
	ld	a,4
	call	x12f8
	call	x14b1
	ret

x0463:	ld	b,a
	cp	4
	jr	c,x046e
	ld	c,17h
	ld	de,0
	ret

x046e:	call	x151a
	call	x1500
	call	x1612
	jr	z,x0487
	ld	a,0
	bit	3,d
	jr	nz,x0487
	ld	a,d
	and	3
	cp	2
	scf
	jr	nz,x04a6
x0487:	push	af
	cp	3
	jr	nz,x0495
	ld	a,d
	and	3
	cp	2
	jr	z,x0495
	ld	a,3
x0495:	ld	b,a
	pop	af
	ld	a,b
	res	1,d
	res	0,d
	ld	e,0
	res	5,d
	res	6,d
	jr	c,x04a8
	or	d
	ld	d,a
x04a6:	jr	x04c9

x04a8:	set	3,d
	in	a,(fdc2)
	bit	3,a
	jr	z,x04b2
	set	6,d
x04b2:	call	sub10
	res	7,(ix+4)
	rst	30h
	call	x1683
	call	x168d
	jr	z,x04c9
	ld	a,13h
	call	sub7
	set	1,e
x04c9:	ld	c,(iy+1)
	ld	b,(iy+2)
	ld	a,d
	and	17h
	jr	z,x04d6
	set	7,e
x04d6:	ld	a,d
	and	63h
	ld	(ix+6),a
	ld	a,e
	and	7fh
	ld	(ix+5),a
	jp	x154c


	fillto	04f0h,076h


; Seek command:
; byte 0: opcode (02h)
; byte 1: unit number    6048
; byte 2: cylinder high  6049
; byte 3: cylinder low   604a
; byte 4: head           604b
; byte 5: sector         604c
cmd_seek:
	call	x02be
	call	x02eb		; validate unit number?
	call	x02c7
	ld	d,(iy+4bh)	; head
	ld	b,(iy+4ch)	; sector
	ld	a,(iy+49h)	; cylinder high
	or	a
	jp	nz,x1490
	ld	a,(iy+4ah)	; cylinder low
	ld	c,a
	cp	0
	jp	m,x1490
	cp	4dh
	jp	nc,x1490
	call	x163e
	jp	nz,x1490
	xor	a
	cp	d
	jr	z,x052a
	inc	a
	cp	d
	jp	nz,x1490
	bit	3,(ix+5)
	jp	z,x1490
x052a:	ld	a,d
	rrca
	or	c
	ld	c,a
	push	bc
	rst	20h
	pop	bc
	ld	(ix+2),c
	ld	(ix+3),b
	ld	a,(ix+1)
	cp	c
	jr	z,x0556
	rst	18h
	cp	(ix+1)
	jr	z,x0555
	ld	b,(ix+2)
	ld	c,(ix+3)
	push	bc
	rst	8
	pop	bc
	ld	(ix+2),b
	ld	(ix+3),c
	jp	nz,x1480
x0555:	rst	10h
x0556:	set	7,(ix+6)
	ld	a,1fh
	call	sub7
	ld	(iy+0),0
	call	x154c
	ret


do_rst10:
	call	sub1
	ret	z
	jp	c,x1480
	ld	b,(ix+3)
	ld	c,(ix+2)
	push	bc
	cp	1
	call	z,rst08
	pop	bc
	ld	(ix+3),b
	ld	(ix+2),c
	jp	x1490


sub1:	ld	a,1ah
	rst	28h
	ld	(iy+0dh),0ah
	ld	a,(ix+2)
	or	a
	jr	nz,x05a6
	ld	b,(ix+3)
	push	bc
	rst	8
	pop	bc
	ld	(ix+3),b
	jr	z,x059e
	scf
	ret

x059e:	ld	c,0
	ld	b,c
	ld	d,(ix+4)
	jr	x05f9

x05a6:	ld	a,(ix+1)
	xor	(ix+4)
	bit	7,a
	push	af
	ld	a,(ix+1)
	and	7fh
	ld	b,a
	ld	a,(ix+2)
	and	7fh
	sub	b
	ld	b,a
	pop	af
	jr	z,x05d3
	ld	a,(ix+1)
	xor	(ix+2)
	bit	7,a
	jr	z,x05d3
	ld	a,(ix+2)
	inc	b
	bit	7,a
	jr	nz,x05d3
	dec	b
	dec	b
x05d3:	ld	d,(ix+4)
	ld	a,(ix+1)
	xor	(ix+2)
	bit	7,a
	jr	z,x05e8
	bit	7,d
	res	7,d
	jr	nz,x05e8
	set	7,d
x05e8:	xor	a
	cp	b
	ld	c,b
	jr	nz,x05f9
	bit	7,d
	jr	nz,x05f9
	bit	3,(ix+5)
	jr	z,x05f9
	ld	c,0ffh
x05f9:	call	sub2
	jr	nz,x0661
	res	7,(ix+4)
	bit	7,d
	jr	z,x060a
	set	7,(ix+4)
x060a:	rst	30h
	ld	b,0ch
x060d:	push	bc
	rst	18h
	pop	bc
	cp	0ffh
	jp	nz,x064c
	dec	b
	jr	z,x0663
	bit	3,(ix+5)
	jr	z,x063b
	bit	7,(ix+4)
	set	7,(ix+4)
	jr	z,x062c
	res	7,(ix+4)
x062c:	rst	30h
	xor	a
	bit	7,c
	jr	z,x0634
	ld	a,80h
x0634:	xor	(ix+4)
	bit	7,a
	jr	nz,x060d
x063b:	push	bc
	ld	b,1
	bit	7,c
	jr	z,x0644
	ld	b,0ffh
x0644:	call	sub2
	pop	bc
	jr	nz,x0661
	jr	x060d

x064c:	ld	(ix+1),a
	cp	(ix+2)
	call	z,x14eb
	ret	z
	dec	(iy+0dh)
	jp	nz,x05a6
	or	1
	ld	a,0
	ret

x0661:	ld	a,1
x0663:	or	a
	ret


sub2:	ld	a,b
	or	a
	ret	z
	jp	p,x067a
	add	a,(ix+0)
	cp	0
	jp	m,x0677
	in	a,(fdc2)
	bit	2,a
x0677:	ret	nz
	jr	x0684

x067a:	add	a,(ix+0)
	cp	4dh
	jp	m,x0684
	inc	a
	ret

x0684:	push	bc
	xor	a
	ld	c,b
	cp	b
	jp	m,x068f
	ld	a,b
	neg
	ld	b,a
x068f:	call	x001b
	bit	7,c
	jr	z,x069b
	dec	(ix+0)
	jr	x069e

x069b:	inc	(ix+0)
x069e:	djnz	x068f
	ld	b,14h
	call	x1240
	pop	bc
	xor	a
	ret

x06a8:	push	bc
	ld	a,(ix+4)
	and	0f7h
	bit	7,c
	jr	nz,x06b4
	set	1,a
x06b4:	out	(fdc5),a
	set	0,a
	out	(fdc5),a
	res	0,a
	out	(fdc5),a
	rst	30h
	ld	b,3
	call	x1240
	pop	bc
	ret


do_rst08:
	xor	a
	ld	(ix+0),a
	ld	(ix+2),a
	ld	(ix+1),a
	ld	a,(x6009)
	and	1
	ld	(ix+3),a
	res	7,(ix+4)
	rst	30h
	ld	b,50h
x06df:	in	a,(fdc2)
	bit	2,a
	jr	nz,x06ee
	ld	c,0ffh
	call	x001b
	djnz	x06df
	inc	b
	ret

x06ee:	ld	a,50h
	cp	b
	ld	b,14h
	call	nz,x1240
	xor	a
	ret


	fillto	0700h,076h


cmd_buffered_read_verify:
	call	x072a
	set	2,(ix+4)
	jr	x070c


cmd_buffered_read:
	call	x072a
x070c:	rst	20h
	call	x0c87
	ld	hl,xf073
	ld	a,1
	call	x0865
x0718:	push	af
	ld	b,20h
	call	x12a3
	ld	b,3
	pop	af
	call	x0952
	jp	z,x07e4
	jp	x07ed

x072a:	call	x02be
	call	x02d8
	call	x02c7
x0733:	call	x08a4
	jp	nc,x1490
	ret


cmd_unbuffered_read_verify:
	call	x072a
	set	2,(ix+4)
	jr	x0746


cmd_unbuffered_read:
	call	x072a
x0746:	ld	hl,xf073
	push	hl
	rst	20h
	ld	a,1
	call	x0865
	push	af
	ld	b,20h
	call	x12a3
	ld	b,2
	pop	af
	jr	z,x075d
	ld	b,3
x075d:	call	x0952
	jp	nz,x07ed
x0763:	call	x1285
	pop	hl
	jp	nz,x07e4
	in	a,(phi3)
	bit	2,a
	jp	z,x07e4
	call	x0c87
	rst	30h
	xor	a
	call	x0865
	push	hl
	ld	b,0
	jr	z,x0780
	ld	b,1
x0780:	push	af
	call	x0952
	pop	af
	jp	nz,x07ed
	jr	x0763


cmd_verify:
	ld	a,18h
	rst	28h
	call	x02be
	call	x02eb
	call	x02c7
	call	x0063
	ld	a,(x6049)
	cp	0
	jp	m,x1473
	ld	b,(iy+49h)
	ld	c,(iy+4ah)
	push	bc
	ld	a,b
	or	a
	jr	z,x07b2
	cp	1
	jr	c,x07c8
	jr	x07b5

x07b2:	add	a,c
	jr	nz,x07c8
x07b5:	ld	b,4
	push	ix
x07b9:	dec	b
	ld	a,b
	jp	m,x07c6
	cp	(iy+3)
	call	nz,x15d8
	jr	x07b9

x07c6:	pop	ix
x07c8:	rst	20h
	pop	bc
	set	2,(ix+4)
	ld	d,1
x07d0:	ld	hl,xf073
	rst	30h
	push	bc
	ld	a,d
	call	x0865
	jp	nz,x07ed
	pop	bc
	ld	d,0
	cpi
	jp	pe,x07d0
x07e4:	call	x14b1
x07e7:	res	2,(ix+4)
	rst	30h
	ret

x07ed:	call	x07e7
	jp	x1467


cmd_cold_load_read:
	xor	a
	ld	(x6000),a
	call	x0023
	xor	a
	call	x151a
	call	x02c7
	ld	a,(iy+48h)
	and	3fh
	ld	b,a
	call	x163e
	jp	nz,x1490
	ld	a,(iy+48h)
	rlca
	rlca
	and	3
	jr	z,x0823
	cp	2
	jp	nc,x1490
	bit	3,(ix+5)
	jp	z,x1490
	rrca
x0823:	ld	(ix+2),a
	ld	(ix+3),b
	jp	x0746


cmd_id_triggered_read:
	call	x072a
	bit	0,(iy+9)
	jp	nz,x149c
	rst	20h
	call	x08ac
	jr	z,x0842
	jp	c,x148a
	jp	nc,x1490
x0842:	ld	hl,xf073
	call	sub3
	call	x08ca
	jr	nc,x0842
	jp	nz,x1464
	ld	b,2
	call	x1240
	ld	a,6
	call	x0ad9
	call	x08ca
	jr	nc,x0842
	call	z,x0876
	jp	x0718

x0865:	push	af
x0866:	call	x08ac
	jr	nz,x087c
	call	x0acf
	call	x08ca
	jr	nc,x0866
	inc	sp
	inc	sp
	ret	nz
x0876:	push	af
	call	x096d
	pop	af
	ret

x087c:	jr	c,x0892
	cp	1
	jr	nz,x088c
	pop	af
	push	af
	or	a
	jr	nz,x088c
	call	x14b1
	jr	x089f

x088c:	set	2,(ix+6)
	jr	x0896

x0892:	set	4,(ix+6)
x0896:	set	7,(ix+6)
	ld	a,1fh
	call	sub7
x089f:	pop	af
	ld	a,1
	or	a
	ret

x08a4:	ld	a,(ix+2)
	and	7fh
	cp	4dh
	ret

x08ac:	ld	a,(ix+1)
	cp	(ix+2)
	ret	z
	push	hl
	ld	b,(ix+4)
	push	bc
	call	x006a
	pop	bc
	push	af
	ld	a,b
	and	4
	or	(ix+4)
	ld	(ix+4),a
	rst	30h
	pop	af
	pop	hl
	ret

x08ca:	push	af
	ld	b,13h
	bit	4,e
	jr	nz,x0915
	ld	b,9
	bit	0,e
	jr	nz,x094c
	ld	b,7
	bit	6,d
	jr	nz,x091d
	ld	b,9
	bit	5,d
	jr	nz,x091d
	ld	b,31h
	bit	2,e
	jr	nz,x0915
	ld	b,9
	bit	1,e
	jr	nz,x0915
	ld	a,e
	and	l
	ld	b,12h
	bit	6,a
	jr	nz,x091d
	ld	b,8
	bit	5,a
	jr	z,x090b
	bit	2,(ix+4)
	jr	z,x0915
	bit	1,d
	jr	z,x0915
	ld	b,9
	jr	x0915

x090b:	xor	a
x090c:	res	1,(iy+5)
	scf
x0911:	ex	(sp),hl
	ld	a,h
	pop	hl
	ret

x0915:	ld	a,b
	call	sub7
	or	1
	jr	x090c

x091d:	bit	1,(iy+5)
	jr	nz,x0915
	ld	a,(ix+4)
	push	af
	push	hl
	ld	a,(ix+2)
	push	af
	ld	(ix+2),0
	rst	10h
	pop	af
	or	a
	jr	z,x0939
	ld	(ix+2),a
	rst	10h
x0939:	pop	hl
	pop	af
	and	4
	or	(ix+4)
	ld	(ix+4),a
	rst	30h
	set	1,(iy+5)
	or	1
	jr	x0911

x094c:	bit	0,d
	jr	z,x091d
	jr	x0915

x0952:	push	af
	ld	hl,x604d
	cp	1
	jr	z,x095f
	call	x12f8
	pop	af
	ret

x095f:	bit	1,b
	call	nz,x127e
	ld	a,1
	ld	b,80h
	call	x12da
	pop	af
	ret

x096d:	ld	b,(ix+3)
	inc	b
	call	x163e
	jr	z,x0990
	bit	3,(ix+5)
	jr	z,x098a
	bit	7,(ix+2)
	set	7,(ix+2)
	jr	z,x098d
	res	7,(ix+2)
x098a:	inc	(ix+2)
x098d:	ld	b,(iy+9)
x0990:	ld	(ix+3),b
	ret


do_rst18:
	in	a,(fdc2)
	bit	4,a
	jp	z,x1480
	res	2,(ix+4)
	rst	30h
	ld	hl,x1060
	ld	b,2
x09a5:	push	bc
	call	sub3
	jr	z,x09b1
	pop	bc
	djnz	x09a5
	or	0ffh
	ret

x09b1:	pop	hl
	ld	a,b
	ld	b,c
	ret


sub3:	ld	a,3
	out	(fdc2),a
	ld	a,(ix+2)
	and	7fh
	ld	(x600b),a
	ld	de,0
x09c4:	push	hl
	ld	a,d
	and	1
	ld	d,a
	ld	e,0
	push	de
x09cc:	pop	de
	xor	a
	out	(fdc4),a
	ld	a,2
	out	(fdc2),a
	push	de
	ld	a,2
	ld	b,22h
	ld	c,67h
	ld	d,70h
	ld	e,0eh
	bit	0,(iy+9)
	jp	nz,x0a5f
	out	(fdc4),a
x09e8:	db	0edh,70h

	jr	z,x09e8
	jp	p,x0a56
	in	a,(fdc0)
	ld	h,a
	in	a,(fdc1)
	cp	e
	jr	nz,x09cc
	ld	a,b
	out	(fdc4),a
	in	a,(fdc0)
	ld	b,a
	ld	a,h
	sub	d
	rl	a
	jr	nz,x09cc
	in	a,(fdc0)
	pop	de
	push	af
	in	a,(fdc0)
	set	0,d
	call	sub4
	pop	af
	jr	nc,x0a13
	set	2,e
x0a13:	bit	7,a
	res	7,a
	ld	c,a
	jr	z,x0a1c
	set	7,b
x0a1c:	cp	(ix+3)
	jr	z,x0a23
	set	7,d
x0a23:	ld	a,b
	and	7fh
	cp	(iy+0bh)
	jr	z,x0a2d
	set	6,d
x0a2d:	ld	a,b
	xor	(ix+2)
	bit	7,a
	jr	z,x0a37
	set	5,d
x0a37:	ld	a,e
	pop	hl
	and	l
	jr	nz,x0a41
	ld	a,d
	and	h
	jr	nz,x0a41
	ret

x0a41:	ld	a,e
	and	60h
	jp	nz,x09c4
	ld	a,d
	and	60h
	ret	nz
	ld	a,d
	and	90h
	jp	nz,x09c4
x0a51:	or	1
	set	1,d
	ret

x0a56:	xor	a
	out	(fdc4),a
	pop	de
	pop	hl
	set	0,e
	jr	x0a51

x0a5f:	out	(fdc4),a
x0a61:	db	0edh,70h

	jr	z,x0a61
	jp	p,x0a56
	ld	a,b
	out	(fdc4),a
	in	a,(fdc0)
	ld	b,a
	in	a,(fdc1)
	cp	0c7h
	jp	nz,x09cc
	ld	a,b
	cp	0feh
	jp	nz,x09cc
	in	a,(fdc0)
	pop	de
	ld	b,a
	cp	(iy+0bh)
	jr	z,x0a86
	set	6,d
x0a86:	in	a,(fdc0)
	cp	0
	jr	z,x0a8e
	set	5,d
x0a8e:	in	a,(fdc0)
	ld	c,a
	cp	(ix+3)
	jr	z,x0a98
	set	7,d
x0a98:	in	a,(fdc0)
	cp	0
	jr	z,x0aa0
	set	4,d
x0aa0:	in	a,(fdc0)
	set	0,d
	call	sub4
	jp	x0a37


sub4:	in	a,(fdc0)
	ld	a,(ix+4)
	ld	h,a
	and	0f3h
	out	(fdc5),a
	in	a,(fdc0)
	ld	a,h
	and	0f7h
	out	(fdc5),a
x0abb:	in	a,(fdc2)
	ld	l,a
	xor	a
	out	(fdc4),a
	ld	a,l
	and	70h
	or	e
	bit	4,a
	set	4,a
	jr	z,x0acd
	res	4,a
x0acd:	ld	e,a
	ret

x0acf:	ld	a,1eh
	rst	28h
	call	sub3
	ld	a,1
	jr	nz,x0b2e
x0ad9:	push	hl
	ld	h,a
	push	bc
	ld	a,2
	out	(fdc4),a
	set	3,e
	push	de
	ld	b,0beh
	ld	d,0eh
	ld	c,67h
	ld	e,7fh
	ld	l,22h
	bit	0,(iy+9)
	jp	nz,x0b53
x0af4:	db	0edh,70h

	jp	p,x0b32
	in	a,(fdc0)
	and	e
	ld	e,a
	in	a,(fdc1)
	cp	d
	jr	nz,x0b42
	ld	a,l
	out	(fdc4),a
	in	a,(fdc0)
	ld	d,a
	ld	a,e
	cp	50h
	jr	nz,x0b40
	ld	hl,x604f
	ld	(hl),d
	dec	hl
	in	a,(fdc0)
	ld	(hl),a
	inc	hl
	inc	hl
	ld	c,60h
	ld	b,0feh
x0b1b:	inc	hl
	ind
	ini
	inc	hl
	jr	nz,x0b1b
x0b23:	in	a,(fdc0)
	pop	de
	ld	(hl),1
	call	sub4
	ld	a,b
x0b2c:	pop	bc
	pop	hl
x0b2e:	call	x14eb
	ret

x0b32:	djnz	x0af4
	dec	h
	jr	nz,x0af4
x0b37:	xor	a
	out	(fdc4),a
	pop	de
	set	1,e
	inc	a
	jr	x0b2c

x0b40:	ld	d,0eh
x0b42:	ld	e,7fh
	xor	a
	out	(fdc4),a
	ld	a,2
	out	(fdc4),a
	bit	0,(iy+9)
	jr	z,x0b32
	jr	x0b82

x0b53:	db	0edh,70h

	jp	p,x0b82
	ld	a,l
	out	(fdc4),a
	in	a,(fdc0)
	sub	0f8h
	jr	z,x0b65
	cp	3
	jr	nz,x0b42
x0b65:	ld	d,a
	in	a,(fdc1)
	cp	0c7h
	jr	nz,x0b42
	ld	c,60h
	ld	hl,x604e
	ld	b,80h
	inir
	ld	a,d
	pop	de
	cp	3
	jr	z,x0b7d
	set	2,e
x0b7d:	push	de
	ld	b,80h
	jr	x0b23

x0b82:	djnz	x0b53
	jr	x0b37


cmd_unbuffered_write:
	call	x072a
	call	x02d0
	ld	b,0
	call	x12a3
	rst	20h
x0b92:	call	x1455
	call	x0c87
	ld	hl,xf057
	call	x0bc8
	jp	nz,x1467
	ld	a,(x600a)
	cp	0c0h
	jr	nz,x0b92
	call	x14b1
	ret


cmd_buffered_write:
	call	x072a
	call	x02d0
	ld	b,0
	call	x12a3
	rst	20h
	call	x1455
	call	x0c87
	ld	hl,xf057
	call	x0bc8
	call	z,x14b1
	ret

x0bc8:	call	x08ac
	jr	z,x0bd3
	jp	nc,x1490
	jp	c,x1480
x0bd3:	call	x0be1
	call	x08ca
	jr	nc,x0bc8
	ret	nz
	call	x096d
	xor	a
	ret

x0be1:	ld	a,1ch
	rst	28h
	call	x165b
	push	hl
	call	sub3
	jr	nz,x0c44
	ld	hl,x604e
	bit	0,(iy+9)
	jr	nz,x0c4c
	ld	b,2bh
x0bf8:	djnz	x0bf8
	ld	a,4
	out	(fdc4),a
	xor	a
	out	(fdc1),a
	out	(fdc0),a
	ld	a,0ch
	out	(fdc4),a
	xor	a
	out	(fdc0),a
	ld	c,60h
	out	(fdc0),a
	out	(fdc0),a
	ld	b,4
	dec	a
x0c13:	out	(fdc0),a
	djnz	x0c13
	ld	a,38h
	out	(fdc1),a
	ld	a,50h
	out	(fdc0),a
	xor	a
	out	(fdc1),a
	ld	b,a
	ld	a,2ch
	out	(fdc4),a
x0c27:	inc	hl
	outd
	outi
	inc	hl
	jr	nz,x0c27
x0c2f:	ld	a,3ch
	out	(fdc4),a
	xor	a
	out	(fdc0),a
	out	(fdc0),a
	ld	a,0ch
	out	(fdc4),a
	ld	a,b
	out	(fdc0),a
	out	(fdc0),a
	call	x0abb
x0c44:	xor	a
	out	(fdc4),a
	call	x14eb
	pop	hl
	ret

x0c4c:	ld	b,47h
x0c4e:	djnz	x0c4e
	ld	a,4
	out	(fdc4),a
	ld	b,5
	ld	a,0ffh
	out	(fdc1),a
	xor	a
	out	(fdc0),a
	ld	a,0ch
	out	(fdc4),a
	xor	a
x0c62:	out	(fdc0),a
	djnz	x0c62
	ld	a,2ch
	out	(fdc4),a
	ld	a,0c7h
	out	(fdc1),a
	ld	a,0fbh
	bit	2,(iy+5)
	jr	z,x0c78
	ld	a,0f8h
x0c78:	out	(fdc0),a
	ld	a,0ffh
	out	(fdc1),a
	ld	b,80h
	ld	c,60h
	otir
	dec	b
	jr	x0c2f

x0c87:	ld	d,0ffh
	call	x155f
	ret


	fillto	0ca0h,076h


cmd_initialize:
	call	x02be
	call	x02eb
	call	x02c7
	call	x0063
	call	x02d0
	rst	20h
	rst	10h
	bit	0,(iy+9)
	jr	nz,x0cd3
	ld	d,0
	ld	(iy+12h),d
	ld	e,70h
	bit	5,(iy+47h)
	jr	z,x0cc6
	ld	e,0f0h
x0cc6:	ld	c,(ix+2)
	ld	b,2
	call	x005d
	jp	nz,x148a
	jr	x0cdd

x0cd3:	bit	5,(iy+47h)
	jr	z,x0cdd
	set	2,(iy+5)
x0cdd:	ld	b,0
	call	x12a3
	call	x1455
	ld	hl,xf053
	call	x0033
	res	2,(iy+5)
	call	z,x14b1
	ld	a,(x6001)
	cp	31h
	call	z,x14b1
	ret


cmd_format:
	call	x02be
	call	x02eb
	call	x02d0
	ld	a,(x6049)
	and	7fh
	cp	2
	jr	z,x0d12
	cp	8
	jp	nz,x1473
x0d12:	rlca
	ld	b,a
	ld	a,(x604a)
	cp	1
	jp	m,x1473
	ld	c,1eh
	bit	4,b
	jr	z,x0d24
	ld	c,1ah
x0d24:	cp	c
	jp	nc,x1473
	ld	a,(ix+5)
	ld	(x600d),a
	and	8
	or	b
	bit	4,a
	jr	z,x0d3a
	bit	3,a
	jp	nz,x149c
x0d3a:	ld	(ix+5),a
	ld	b,4
x0d3f:	dec	b
	jp	m,x0d4c
	ld	a,b
	cp	(iy+3)
	call	nz,x15d8
	jr	x0d3f

x0d4c:	call	x154c
	ld	a,(x6003)
	call	x151a
	ld	a,0eh
	rst	28h
	rst	20h
	rst	8
	jp	nz,x1480
	ld	bc,0
	ld	(iy+12h),b
	bit	0,(iy+9)
	jp	nz,x0df7
x0d6a:	ld	a,b
	cp	4dh
	jr	z,x0de6
	push	bc
	bit	7,(iy+49h)
	jr	nz,x0d93
	bit	2,(iy+0dh)
	jr	z,x0d93
	rst	18h
	cp	0ffh
	jr	z,x0d85
	bit	2,e
	jr	z,x0d93
x0d85:	ld	c,0ffh
	call	x0dee
	call	x005d
	jp	nz,x148a
	pop	bc
	jr	x0dae

x0d93:	pop	bc
	push	bc
	call	x0dee
	call	x005d
	jp	nz,x148a
	pop	bc
	bit	3,(ix+5)
	jr	z,x0dad
	bit	7,c
	set	7,c
	jr	z,x0dae
	res	7,c
x0dad:	inc	c
x0dae:	bit	3,(ix+5)
	jr	z,x0dc2
	bit	7,(ix+4)
	set	7,(ix+4)
	jr	z,x0dc3
	res	7,(ix+4)
x0dc2:	inc	b
x0dc3:	rst	30h
	bit	7,(ix+4)
	call	z,x0e61
	xor	a
	bit	7,(ix+4)
	ld	a,(x600f)
	jr	nz,x0dd8
	ld	a,(x600e)
x0dd8:	add	a,(iy+10h)
	cp	1eh
	jr	c,x0de1
	sub	1eh
x0de1:	ld	(x6010),a
	jr	x0d6a

x0de6:	rst	8
	jp	nz,x1480
	call	x14b1
	ret

x0dee:	ld	b,(iy+4ah)
	ld	d,(iy+4bh)
	ld	e,70h
	ret

x0df7:	push	bc
	bit	7,(iy+49h)
	jr	nz,x0e04
	bit	4,(iy+0dh)
	jr	nz,x0e1c
x0e04:	pop	bc
	push	bc
	call	x0dee
	call	x0060
	jp	nz,x148a
	pop	bc
	inc	c
x0e11:	inc	b
	ld	a,b
	cp	4dh
	jr	z,x0de6
	call	x0e61
	jr	x0df7

x0e1c:	ld	hl,x0064
	res	2,(ix+4)
x0e23:	call	x002b
	res	7,(iy+12h)
	bit	6,e
	jr	nz,x0e45
	bit	0,d
	jr	z,x0e53
	ld	a,b
	cp	0ffh
	jr	z,x0e53
	bit	1,e
	jr	nz,x0e45
	bit	5,e
	jr	nz,x0e45
	bit	2,e
	jr	nz,x0e53
	jr	x0e04

x0e45:	bit	1,(iy+5)
	set	1,(iy+5)
	jr	z,x0e23
	res	1,(iy+5)
x0e53:	ld	c,0ffh
	call	x0dee
	call	x0060
	jp	nz,x148a
	pop	bc
	jr	x0e11

x0e61:	push	bc
	ld	c,0
	call	x001b
	ld	b,14h
	call	x1240
	pop	bc
	inc	(ix+0)
	ret

x0e71:	bit	7,(iy+12h)
	jr	nz,x0e98
	push	de
	push	bc
	call	x0ffa
	pop	bc
	ld	hl,x0f90
	ld	a,b
	dec	a
	rlca
	ld	e,a
	add	hl,de
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	ld	(x600e),de
	xor	a
	ld	(x6010),a
	pop	de
	call	x0fca
	set	7,(iy+12h)
x0e98:	ld	b,0
	ld	a,c
	cp	0ffh
	jr	z,x0ea2
	ld	b,a
	and	7fh
x0ea2:	push	af
	ld	(iy+0bh),b
	call	x165b
	ld	(iy+11h),1eh
	ld	c,60h
	call	x0f87
	pop	af
	push	ix
	ld	ix,x6074
	ld	(ix+0),a
	ld	b,0
	xor	a
	out	(fdc1),a
x0ec1:	in	a,(fdc2)
	bit	4,a
	jp	z,x0f7f
	bit	0,a
	jr	z,x0ec1
	ld	a,2
	out	(fdc2),a
	ld	a,0ch
	out	(fdc4),a
x0ed4:	out	(c),b
	in	a,(fdc2)
	bit	4,a
	jp	z,x0f7f
	bit	0,a
	jr	nz,x0ed4
x0ee1:	out	(c),b
	in	a,(fdc2)
	bit	4,a
	jp	z,x0f7f
	bit	0,a
	jr	z,x0ee1
x0eee:	out	(c),b
	in	a,(fdc2)
	bit	0,a
	jr	nz,x0eee
x0ef6:	ld	hl,x606b
	outi
	ld	a,(de)
	bit	7,(iy+0bh)
	jr	z,x0f04
	set	7,a
x0f04:	outi
	ld	b,6
	ld	(ix+1),a
	otir
	ld	a,38h
	out	(fdc1),a
	outi
	xor	a
	out	(fdc1),a
	ld	a,2ch
	out	(fdc4),a
	outi
	outi
	ld	a,3ch
	out	(fdc4),a
	outi
	outi
	ld	a,0ch
	out	(fdc4),a
	ld	b,19h
	otir
	ld	a,38h
	out	(fdc1),a
	outi
	xor	a
	out	(fdc1),a
	ld	b,a
	ld	a,2ch
	out	(fdc4),a
	otir
	ld	a,3ch
	out	(fdc4),a
	outi
	outi
	ld	a,0ch
	out	(fdc4),a
	ld	b,23h
	outi
	ld	a,(x6010)
	inc	a
	outi
	cp	1eh
	jr	c,x0f59
	xor	a
x0f59:	ld	(x6010),a
	outi
	ld	de,x604d
	add	a,e
	ld	e,a
	outi
	dec	(iy+11h)
	jr	z,x0f6e
	otir
	jr	x0ef6

x0f6e:	xor	a
	out	(fdc4),a
	in	a,(fdc2)
	bit	6,a
	jr	nz,x0f7f
	ld	b,98h
x0f79:	djnz	x0f79
	xor	a
	pop	ix
	ret

x0f7f:	xor	a
	out	(fdc4),a
	pop	ix
	or	1
	ret

x0f87:	ld	de,x604d
	ld	a,(x6010)
	add	a,e
	ld	e,a
	ret

x0f90:	inc	e
	jr	x0faf

	jr	x0fb1

	jr	x0fb4

	ld	a,(de)
	ld	a,(de)
	jr	x0fb4

	jr	x0f9d

x0f9d:	nop
	dec	e
	dec	e
	inc	e
	inc	e
	dec	d
	dec	d
	nop
	nop
	add	hl,de
	add	hl,de
	nop
	nop
	dec	e
	dec	e
	djnz	x0fbe
	dec	e
x0faf:	dec	e
	nop
x0fb1:	nop
	add	hl,de
	add	hl,de
x0fb4:	nop
	nop
	dec	d
	dec	d
	inc	e
	inc	e
	dec	e
	dec	e
	nop
	nop
x0fbe:	add	hl,de
	add	hl,de
	ld	a,(de)
	ld	a,(de)
	dec	e
	dec	e
	inc	e
	inc	e
	dec	e
	dec	e
	nop
	nop
x0fca:	ld	hl,x606b
	xor	a
	ld	b,4
	call	x0ff5
	dec	a
	ld	b,4
	call	x0ff5
	ld	(hl),e
	inc	hl
	xor	a
	ld	b,19h
	call	x0ff5
	dec	a
	ld	b,4
	call	x0ff5
	ld	(hl),50h
	inc	hl
	ld	a,d
	call	x0ff5
	xor	a
	ld	b,25h
	call	x0ff5
	ret

x0ff5:	ld	(hl),a
	inc	hl
	djnz	x0ff5
	ret

x0ffa:	ld	hl,x604d
	push	hl
	ld	(iy+12h),b
	ld	b,1eh
	ld	a,0ffh
	call	x0ff5
	pop	hl
	ld	c,1eh
	bit	0,(iy+9)
	jr	z,x1014
	inc	b
	ld	c,1ah
x1014:	ld	de,0
	ld	(hl),b
	inc	b
x1019:	push	hl
	ld	a,e
	add	a,(iy+12h)
x101e:	cp	c
	jr	c,x1022
	sub	c
x1022:	ld	e,a
	add	hl,de
	ld	a,(hl)
	cp	0ffh
	jr	z,x102f
	inc	e
	pop	hl
	push	hl
	ld	a,e
	jr	x101e

x102f:	ld	(hl),b
	inc	b
	ld	a,b
	cp	c
	pop	hl
	jr	nz,x1019
	bit	0,(iy+9)
	ret	z
	cp	1bh
	ret	z
	inc	c
	jr	x1019

x1041:	xor	a
	ld	(x6010),a
	bit	7,(iy+12h)
	jr	nz,x1059
	push	bc
	push	de
	call	x0ffa
	pop	de
	call	x1135
	set	7,(iy+12h)
	pop	bc
x1059:	ld	a,1ah
	ld	(x6011),a
	ld	b,c
	push	bc
x1060:	ld	b,2eh
	ld	c,60h
	call	x0f87
	ld	hl,x606b
	pop	af
	push	ix
	ld	ix,x60bb
	ld	(ix+0),a
	cp	0ffh
	jr	nz,x107e
	ld	(ix+1),a
	ld	(ix+3),a
x107e:	ld	a,0ffh
	out	(fdc1),a
x1082:	in	a,(fdc2)
	bit	4,a
	jp	z,x0f7f
	bit	0,a
	jr	nz,x1082
x108d:	in	a,(fdc2)
	bit	4,a
	jp	z,x0f7f
	bit	0,a
	jr	z,x108d
	ld	a,2
	out	(fdc2),a
	ld	a,0ch
	out	(fdc4),a
	otir
	ld	a,0d7h
	out	(fdc1),a
	outi
	ld	a,0ffh
	out	(fdc1),a
	ld	b,1ah
	otir
x10b0:	ld	b,6
	outi
	ld	a,(ix+0)
	cp	0ffh
	jr	z,x10bc
	ld	a,(de)
x10bc:	ld	(ix+2),a
	otir
	ld	a,2ch
	out	(fdc4),a
	ld	a,0c7h
	out	(fdc1),a
	outi
	ld	a,0ffh
	out	(fdc1),a
	ld	b,4
	otir
	ld	a,3ch
	out	(fdc4),a
	outi
	outi
	ld	a,0ch
	out	(fdc4),a
	ld	b,11h
	otir
	ld	a,2ch
	out	(fdc4),a
	ld	a,0c7h
	out	(fdc1),a
	outi
	ld	a,0ffh
	out	(fdc1),a
	ld	b,80h
	otir
	ld	a,3ch
	out	(fdc4),a
	outi
	outi
	ld	a,0ch
	out	(fdc4),a
	ld	b,1ah
	outi
	ld	a,(x6010)
	inc	a
	ld	de,x604d
	outi
	cp	1ah
	jr	c,x1113
	xor	a
x1113:	ld	(x6010),a
	add	a,e
	ld	e,a
	otir
	ld	hl,x60b4
	dec	(iy+11h)
	jr	nz,x10b0
	dec	b
x1123:	out	(c),b
	in	a,(fdc2)
	bit	4,a
	jp	z,x0f7f
	bit	0,a
	jr	z,x1123
	out	(c),b
	jp	x0f6e

x1135:	ld	hl,x606b
	ld	a,0ffh
	ld	b,28h
	call	x0ff5
	xor	a
	ld	b,6
	call	x0ff5
	ld	(hl),0fch
	inc	hl
	dec	a
	ld	b,1ah
	call	x0ff5
	xor	a
	ld	b,6
	call	x0ff5
	ld	(hl),0feh
	inc	hl
	ld	b,6
	call	x0ff5
	dec	a
	ld	b,0bh
	call	x0ff5
	xor	a
	ld	b,6
	call	x0ff5
	ld	(hl),0fbh
	inc	hl
	ld	a,d
	ld	b,80h
	call	x0ff5
	xor	a
	ld	b,2
	call	x0ff5
	dec	a
	ld	b,1ah
	call	x0ff5
	ret

	halt
	halt


cmd_door_lock:
	call	x02be
	call	x02d8
	call	sub10
	ld	a,(ix+9)
	cpl
	and	(iy+6)
	ld	(x6006),a
	set	5,(ix+4)
	jr	x11a9


cmd_door_unlock:
	call	x02be
	call	x02d8
	res	5,(ix+4)
	ld	b,(iy+3)
	call	x15d8
x11a9:	call	x14b1
	ret


cmd_request_logical_address:
	ld	a,(x6003)
	call	x151a
	ld	b,(ix+2)
	bit	7,b
	res	7,b
	ld	d,(ix+3)
	jr	x11ce


cmd_request_physical_address:
	ld	a,(x6003)
	call	x151a
	ld	b,(ix+0)
	ld	d,0
	bit	7,(ix+4)
x11ce:	ld	e,0
	jr	z,x11d3
	inc	e
x11d3:	ld	c,0
	call	x02be
	jp	x006d


; write loopback
x11db:	ld	a,0ffh
x11dd:	ld	hl,x604d
	ld	b,3
	call	x12f8
	xor	a
	ld	(x6001),a
	ret


; read loopback
x11ea:	ld	hl,x604d
	xor	a
	call	x1344
	ret


; download
x11f2:	call	x11ea
	ld	a,(x600a)
	cp	0c0h
	jp	nz,x1473
	ld	hl,x6050
	ex	de,hl
	call	x124d
	ex	de,hl
	jp	(hl)


; initiate self-test
x1206:	ld	hl,x604d
	xor	a
	call	x1344
	ld	a,(x604d)
	cp	1
	ld	d,(iy+4eh)
	ld	e,0
	jr	z,x121c
	ld	e,(iy+4fh)
x121c:	ld	a,d
	cp	4dh
	jp	nc,x1490
	jp	x1722


; read self-test
x1225:	ld	hl,(x6007)
	ld	a,h
	ld	h,l
	ld	l,a
	ld	(x604e),hl
	ld	a,1
	jr	x11dd


	fillto	01240h,076h


x1240:	push	bc
	ld	b,0
x1243:	djnz	x1243
	ld	b,28h
x1247:	djnz	x1247
	pop	bc
	djnz	x1240
	ret


x124d:	pop	hl
	xor	a
	ld	(x6005),a
	ld	sp,x63ff
	ld	iy,x6019
	ld	(x6017),iy
	ld	iy,x6000
	ld	ix,x601e
	jp	(hl)


x1266:	in	a,(phi1)
	ld	b,a
	ld	a,(x600c)
	out	(phi3),a
	ld	a,b
	out	(phi1),a
	ret


x1272:	in	a,(phi4)
	and	0f7h
	jr	x1282

x1278:	in	a,(phi4)
	or	8
	jr	x1282

x127e:	in	a,(phi4)
	or	1
x1282:	out	(phi4),a
	ret

x1285:	in	a,(phi0)
	bit	2,a
	ret	nz
	bit	0,a
	call	nz,x000b
	ret

x1290:	in	a,(phi0)
	in	a,(phi3)
	bit	6,a
	ret	z
	ld	b,40h
	out	(phi3),a
	xor	a
	out	(phi0),a
	ld	(iy+0),3
	ret

x12a3:	push	bc
	ld	a,6
	call	x0028
	call	x1278
	ld	bc,0
	ld	d,29h
x12b1:	call	x1285
	jr	nz,x12c1
	djnz	x12b1
	dec	c
	jr	nz,x12b1
	dec	d
	jr	nz,x12b1
	jp	x1473

x12c1:	call	x1272
	in	a,(phi2)
	ld	c,a
	in	a,(phi3)
	bit	6,a
	jp	z,x1473
	call	x1290
	ld	a,c
	pop	bc
	cp	b
	jp	nz,x1473
	jp	x14eb

x12da:	push	af
	ld	a,1
	out	(phi3),a
	call	x1285
	jp	nz,x1467
	ld	a,b
	out	(phi3),a
	pop	af
	out	(phi2),a
	ret


sub6:	ld	a,1
	ld	b,80h
	push	af
	call	x127e
	pop	af
	jp	x12da

x12f8:	ld	(hl),a
	ld	a,4
	call	x0028
	push	bc
	bit	1,b
	call	nz,x127e
	ld	a,1
	out	(phi3),a
	in	a,(phi0)
	bit	2,a
	jr	nz,x132f
	set	4,(iy+5)
	call	x13ac
	xor	a
	out	(phi3),a
	ld	b,(hl)
	inc	hl
x131a:	ld	c,12h
	otir
	pop	bc
	bit	0,b
	jr	z,x132e
	ld	b,0
	push	bc
	ld	b,1
	ld	a,80h
	out	(phi3),a
	jr	x131a

x132e:	push	bc
x132f:	res	4,(iy+5)
	pop	bc
	call	x13a2
	call	x14eb
	ret

x133b:	pop	bc
	call	x13a2
	call	x000b
	jr	x132f

x1344:	push	bc
	push	de
	push	hl
	push	af
	ld	a,6
	call	x0028
	inc	hl
	pop	bc
	set	5,(iy+5)
x1353:	call	x13ac
	ld	c,12h
	xor	a
	ei
	inir
x135c:	di
	res	5,(iy+5)
	ld	c,a
	call	x1266
	pop	de
	push	hl
	push	de
	xor	a
	sbc	hl,de
	ld	b,l
	dec	b
	pop	hl
	pop	de
	ld	(hl),b
	ld	a,c
	and	0c0h
	ld	(x600a),a
	cp	40h
	call	x13a2
	jr	nz,x1384
	dec	de
	ld	a,(de)
	cp	10h
	jp	z,x0013
x1384:	call	x14eb
	pop	de
	pop	bc
	ret

x138a:	res	5,(iy+5)
	call	x13a2
	call	x000b
	dec	hl
	inc	b
	jr	x1353

x1398:	res	5,(iy+5)
	call	x13a2
	jp	x1473

x13a2:	ld	a,(x600c)
	out	(phi3),a
	ld	a,0dh
	out	(phi1),a
	ret

x13ac:	ld	a,40h
	out	(phi1),a
	ld	a,80h
	out	(phi3),a
	ld	a,40h
	out	(phi1),a
	ret

x13b9:	ex	af,af'
	exx
	in	a,(phi3)
	push	af
	bit	5,(iy+5)
	jp	nz,x1422
	in	a,(phi0)
	push	af
	xor	a
	out	(phi3),a
	ld	a,0dh
	out	(phi1),a
	ld	bc,0
	ld	d,26h
x13d4:	in	a,(phi0)
	bit	3,a
	jr	nz,x13f5
	bit	0,a
	jr	nz,x140e
	bit	2,a
	jr	nz,x1413
	in	a,(phi3)
	bit	2,a
	jr	z,x1416
	djnz	x13d4
	dec	c
	jr	nz,x13d4
	dec	d
	jr	nz,x13d4
x13f0:	ld	hl,x1398
	jr	x1419

x13f5:	pop	af
	out	(phi0),a
	call	x13ac
	pop	af
	ex	af,af'
	ex	(sp),hl
	jr	nz,x1402
	dec	hl
	dec	hl
x1402:	exx
	dec	hl
	inc	b
	exx
	ex	af,af'
x1407:	ex	(sp),hl
	out	(phi3),a
	ex	af,af'
	exx
	retn

x140e:	ld	hl,x133b
	jr	x1419

x1413:	call	x1272
x1416:	ld	hl,x132f
x1419:	call	x1266
	pop	af
	out	(phi0),a
	pop	af
	jr	x1407

x1422:	di
	in	a,(phi0)
	push	af
	xor	a
	out	(phi3),a
	ld	a,5
	out	(phi1),a
	ld	bc,0
	ld	d,2dh
x1432:	in	a,(phi0)
	bit	2,a
	jr	nz,x144c
	bit	0,a
	jr	nz,x144f
	in	a,(phi3)
	bit	1,a
	jr	z,x13f0
	djnz	x1432
	dec	c
	jr	nz,x1432
	dec	d
	jr	nz,x1432
	jr	x13f0

x144c:	ei
	jr	x13f5

x144f:	ld	hl,x138a
	jp	x1419

x1455:	xor	a
	bit	0,(iy+9)
	jr	z,x145e
	ld	a,80h
x145e:	ld	hl,x604d
	jp	x1344

x1464:	call	sub6
x1467:	call	x124d
	call	x154c
	call	x1278
	jp	x0003

x1473:	call	x14c1
	jr	nz,x1464
	ld	a,0ah
	jr	x149e

x147c:	ld	a,1
	jr	x149e

x1480:	set	4,(ix+6)
	set	7,(ix+6)
	jr	x1498

x148a:	set	4,(ix+6)
	jr	x149c

x1490:	set	2,(ix+6)
	set	7,(ix+6)
x1498:	ld	a,1fh
	jr	x149e

x149c:	ld	a,13h
x149e:	call	sub7
	jr	x1464


sub7:	call	sub8
	ld	a,(x6000)
	cp	2
	ret	p
	ld	(iy+0),1
	ret

x14b1:	call	x154c
	ld	(x6000),a

sub8:	ld	(x6001),a
	ld	a,(x6003)
	ld	(x6002),a
	ret

x14c1:	ld	a,(x6000)
	or	a
	ret	z
	cp	3
	ret	nz
	ld	a,(x6001)
	or	a
	ret	z
	cp	1fh
	ret	nz
	ld	a,(ix+6)
	and	14h
	ret	z
	ret


do_rst28:
	push	af
	call	sub9
	push	hl
	ld	hl,(x6017)
	inc	hl
	ld	(hl),a
x14e2:	ld	(x6017),hl
	cpl
	out	(fdc3),a
	pop	hl
	pop	af
	ret

x14eb:	push	af
	call	sub9
	push	hl
	ld	hl,(x6017)
	dec	hl
	ld	a,(hl)
	jr	x14e2


sub9:	bit	0,(iy+5)
	ret	z
	inc	sp
	inc	sp
	pop	af
	ret


x1500:	ld	d,(ix+6)
	ld	e,(ix+5)
	ret

x1507:	push	bc
	ld	ix,x601e
	ld	c,0ah
	xor	a
	cp	b
	jr	z,x1518
x1512:	add	a,c
	djnz	x1512
	ld	c,a
	add	ix,bc
x1518:	pop	bc
	ret

x151a:	push	de
	ld	(x6003),a
	ld	(x6004),a
	ld	b,a
	call	x1507
	call	x1500
	ld	b,0
	bit	2,e
	jr	nz,x1536
	ld	b,1
	bit	4,e
	jr	nz,x1536
	ld	b,2
x1536:	ld	(iy+9),b
	ld	a,(ix+9)
	and	0fh
	bit	0,b
	jr	nz,x1544
	set	4,a
x1544:	ld	(ix+9),a
	call	x15fd
	pop	de
	ret

x154c:	in	a,(fdc2)
	bit	1,a
	jr	z,x1556
	set	7,(ix+9)
x1556:	ld	a,4
	ld	(x6004),a
	xor	a
	out	(fdc6),a
	ret

x155f:	ld	a,(x6006)
	and	0fh
	ret	z
	ld	c,a
	ld	b,4
	push	ix
x156a:	srl	c
	dec	b
	jp	m,x159c
	jr	nc,x156a
	ld	a,(x6004)
	cp	b
	jr	z,x156a
	call	x1507
	ld	a,(ix+8)
	sub	d
	ld	(ix+8),a
	jr	nc,x156a
	dec	(ix+7)
	jp	p,x156a
	call	x15d8
	ld	a,(x6004)
	cp	4
	jr	z,x1599
	pop	ix
	jp	sub12

x1599:	call	x154c
x159c:	pop	ix
	ret


do_rst20:
	ld	a,0ah
	rst	28h
	call	sub10
	ld	b,3ch
	call	z,x1240
	in	a,(fdc2)
	bit	4,a
	jp	nz,x14eb
	call	sub11
	jp	x148a


sub10:	bit	3,(ix+4)
	push	af
	set	3,(ix+4)
	call	sub12
	bit	5,(ix+4)
	jr	nz,x15d6
	ld	a,(x6006)
	or	(ix+9)
	ld	(x6006),a
	ld	(ix+7),18h
x15d6:	pop	af
	ret


x15d8:	call	x1507
	bit	5,(ix+4)
	jr	nz,x15e8

sub11:	res	3,(ix+4)
	call	sub12
x15e8:	ld	a,(ix+9)
	cpl
	and	(iy+6)
	ld	(x6006),a
	ret


sub12:	in	a,(fdc2)
	bit	1,a
	jr	z,x15fd
	set	7,(ix+9)
x15fd:	xor	a
	out	(fdc6),a
	ld	a,(ix+4)
	out	(fdc5),a
	ld	a,(ix+9)
	out	(fdc6),a

do_rst30:
	ld	a,(ix+4)
	and	0f7h
	out	(fdc5),a
	ret

x1612:	in	a,(fdc2)
	bit	1,a
	jr	nz,x162a
	bit	7,(ix+9)
	jr	nz,x162a
	bit	4,a
	jr	nz,x1635
x1622:	ld	a,3
	res	5,(ix+4)
	cp	a
	ret

x162a:	res	7,(ix+9)
	bit	4,a
	jr	z,x1622
x1632:	xor	a
	scf
	ret

x1635:	bit	1,(ix+6)
	jr	nz,x1632
	or	a
	scf
	ret

x163e:	push	hl
	ld	hl,x1657
	bit	0,(iy+9)
	jr	z,x1649
	inc	hl
x1649:	ld	a,b
	cp	(hl)
	jr	c,x1655
	inc	hl
	inc	hl
	cp	(hl)
	jr	z,x1655
	jr	nc,x1655
	xor	a
x1655:	pop	hl
	ret

x1657:	nop
	ld	bc,x1a1d
x165b:	ld	a,(ix+0)
	bit	0,(iy+9)
	jr	nz,x1670
	res	5,(ix+9)
	cp	37h
	jr	c,x1670
	set	5,(ix+9)
x1670:	res	4,(ix+4)
	cp	2bh
	jr	c,x167c
	set	4,(ix+4)
x167c:	rst	30h
	ld	a,(ix+9)
	out	(fdc6),a
	ret

x1683:	res	3,e
	in	a,(fdc2)
	bit	7,a
	ret	z
	set	3,e
	ret

x168d:	push	de
	ld	a,4
	call	x16fa
	jr	z,x16f5
	rst	8
	jr	z,x169d
	pop	de
	set	2,d
	jr	x16f8

x169d:	ld	(iy+0eh),5
x16a1:	ld	a,4
	call	x16fa
	jr	z,x16f5
	rst	18h
	ld	a,4
	jr	z,x16ef
	pop	de
	push	de
	bit	3,e
	jr	nz,x16c5
	ld	a,10h
	call	x16fa
	jr	z,x16f5
	rst	18h
	jr	nz,x16c5
	ld	(ix+3),1
	ld	a,10h
	jr	x16ef

x16c5:	dec	(iy+0eh)
	ld	a,2
	jr	z,x16ef
	bit	3,e
	jr	z,x16e5
	bit	7,(ix+4)
	set	7,(ix+4)
	jr	z,x16de
	res	7,(ix+4)
x16de:	rst	30h
	bit	7,(ix+4)
	jr	nz,x16a1
x16e5:	ld	c,0
	call	x001b
	inc	(ix+0)
	jr	x16a1

x16ef:	pop	de
	push	af
	or	e
	ld	e,a
	pop	af
	ret

x16f5:	pop	de
	set	4,d
x16f8:	inc	a
	ret

x16fa:	ld	(ix+5),a
	call	x154c
	ld	a,(x6003)
	call	x151a
	call	sub10
	in	a,(fdc2)
	bit	4,a
	ret	nz
	ret	z


	fillto	1720h, 076h

doreset:
	jr	x1724

x1722:	jr	x1733

x1724:	xor	a
	ld	d,a
	out	(fdc3),a
	set	7,a
	out	(fdc7),a
	in	a,(fdc3)
	and	8
	ld	e,a
	set	4,e
x1733:	di
	ld	a,8
	out	(fdc2),a
	xor	a
	out	(fdc4),a
	ld	sp,x63ff
	jp	x17e3

x1741:	ld	iy,x6000
	bit	6,(iy+15h)
	jr	nz,x1784
	ld	b,0
x174d:	call	x1507
	push	bc
	inc	b
	ld	a,10h
x1754:	rrca
	djnz	x1754
	ld	(ix+9),a
	push	af
	out	(fdc6),a
	rst	8
	jr	z,x1769
	pop	af
	or	(iy+46h)
	ld	(x6046),a
	jr	x1777

x1769:	ld	c,0
	call	x001b
	call	x17ad
	ld	b,4
	call	x1c15
	pop	af
x1777:	pop	bc
	inc	b
	bit	2,b
	jr	z,x174d
	xor	a
	out	(fdc6),a
	set	6,(iy+13h)
x1784:	ld	bc,x17b2
	ld	(x6015),bc
	ld	hl,x6005
	set	0,(hl)
x1790:	ld	iy,(x6015)
	ld	l,(iy+0)
	inc	iy
	ld	h,(iy+0)
	inc	iy
	ld	(x6015),iy
	ld	iy,x6000
	ld	bc,x17ab
	push	bc
	jp	(hl)

x17ab:	jr	x1790

x17ad:	ld	b,14h
	jp	x1240

x17b2:	dec	hl
	ld	a,(de)
	ld	l,h
	ld	a,(de)
	sub	(hl)
	ld	a,(de)
	cp	a
	ld	a,(de)
	ld	c,l
	dec	de
x17bc:	and	l
	dec	de
	jr	nz,x17dc
	ld	(hl),h
	inc	e
	xor	e
	inc	e
	exx
	inc	e
x17c6:	ex	(sp),hl
	dec	e
x17c8:	sbc	a,h
	ld	e,0f3h
	ld	e,0d9h
	ld	e,38h
	rla

sub13:	ld	b,a
	ld	(x6007),bc
	cpl
	out	(fdc7),a
	ld	a,c
	cpl
	out	(fdc3),a
x17dc:	ret


x17dd:	ld	bc,(x6007)
	ld	a,b
	ret

x17e3:	ld	a,0c0h
	out	(fdc3),a
	ld	a,0ffh
	out	(fdc7),a
	ld	a,0
	add	a,a
	jr	z,x17f2
x17f0:	jr	x17f0

x17f2:	jr	nz,x17f2
	add	a,0fh
	jp	p,x17fb
x17f9:	jr	x17f9

x17fb:	jp	m,x17fb
	cp	0eh
x1800:	jp	m,x1800
	cp	0fh
x1805:	jr	nz,x1805
x1807:	cp	10h
x1809:	jp	p,x1809
	sub	10h
	jp	m,x1813
x1811:	jr	x1811

x1813:	jp	p,x1813
	ld	b,a
	ld	c,b
	ld	h,c
	ld	l,h
	inc	l
	ld	h,l
	ld	c,h
	ld	b,c
	ld	a,b
	dec	a
	and	5ah
	ld	b,a
	or	99h
	ld	c,a
	xor	0dbh
	cpl
	res	3,a
	ld	h,a
	scf
	adc	a,b
	ld	l,a
	ccf
	sbc	a,c
	set	7,a
	neg
	rrca
	rl	b
	rlc	c
	rr	h
	sla	l
	sra	a
	srl	h
	jr	c,x1846
x1844:	jr	x1844

x1846:	jr	nc,x1846
	add	a,b
	add	a,c
	add	a,h
	add	a,l
	ld	b,d
	ld	c,e
	ld	d,54h
	add	a,d
	ld	e,0a2h
	set	0,e
	cp	e
x1856:	jr	nz,x1856
	bit	6,h
x185a:	jr	z,x185a
	ld	d,b
	ld	e,c
	ld	hl,startup1
	jp	(hl)

x1862:	jr	x1862


startup1:
	ld	a,0a0h
	out	(fdc3),a
	ld	a,0ffh
	out	(fdc7),a
	ld	b,0a5h
	push	bc
	pop	af
	cp	b
x1871:	jr	nz,x1871
	xor	a
	ld	hl,x63fe
	ld	a,(hl)
	cp	b
x1879:	jr	nz,x1879
	ld	ix,x63fe
	ld	iy,x63fc
	cp	(ix+0)
x1886:	jr	nz,x1886
	cp	(iy+2)
x188b:	jr	nz,x188b
	call	sub14
x1890:	jr	x1890

	jp	x18a4


sub14:	ld	bc,x1890
	ld	a,(hl)
	cp	b
x189a:	jr	nz,x189a
	dec	hl
	ld	a,(hl)
	cp	c
x189f:	jr	nz,x189f
	inc	(hl)
	inc	(hl)
	ret

x18a4:	ld	a,0fch
	out	(fdc3),a
	ld	a,0ffh
	out	(fdc7),a

romcsum:
	ld	ix,x1ffe-1
	ld	bc,x1ffe
	push	de
	xor	a
	ld	d,a
	ld	h,a
	ld	l,a

romcsum_loop:
	dec	bc
	ld	e,(ix+0)
	add	hl,de
	dec	ix
	cp	b
	jr	nz,romcsum_loop
	cp	c
	jr	nz,romcsum_loop
	ld	a,(x1ffe)
	cp	l
romcsum_fail_l:
	jr	nz,romcsum_fail_l
	ld	a,(x1fff)
	cp	h
romcsum_fail_h:
	jr	nz,romcsum_fail_h
	pop	de

ramtest:
	ld	hl,x6000
	ld	bc,0400h
x18d8:	ld	a,l
	add	a,h
	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,x18d8
	djnz	x18d8
	ld	hl,x6000
	ld	bc,0400h
x18e7:	ld	a,l
	add	a,h
	cp	(hl)
	jr	nz,x1942
	inc	hl
	dec	c
	jr	nz,x18e7
	djnz	x18e7
	ld	iy,x194c
x18f6:	ld	a,(iy+0)
	call	sub15
	inc	iy
	or	a
	jr	nz,x18f6
	ld	(x6013),de
	jr	x1950


sub15:	pop	ix
	ld	bc,0400h
	ld	hl,x6000
x190f:	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,x190f
	djnz	x190f
	ld	bc,0400h
	ld	hl,x6000
x191c:	ld	a,(hl)
	cp	(iy+0)
	jr	nz,x192b
	inc	hl
	dec	c
	jr	nz,x191c
	djnz	x191c
	push	ix
	ret

x192b:	and	0f0h
	ld	c,a
	ld	a,(iy+0)
	and	0f0h
	cp	c
	ld	a,0f4h
	jr	nz,x193a
	ld	a,0f2h
x193a:	out	(fdc3),a
	ld	a,0ffh
	out	(fdc7),a
x1940:	jr	x1940

x1942:	ld	a,0f6h
	out	(fdc3),a
	ld	a,0ffh
	out	(fdc7),a
x194a:	jr	x194a

x194c:	rst	38h
	and	l
	ld	e,d
	nop
x1950:	ld	a,0
	ld	c,0fh
	call	sub13
	xor	a
	out	(phi3),a
	ld	a,80h
	out	(phi4),a
	out	(phi4),a

; XXX this might be the identify response
	ld	a,0
	out	(phi6),a
	ld	a,81h
	out	(phi7),a

	xor	a
	out	(phi3),a
	ld	a,7fh
	out	(phi1),a
	xor	a
	out	(phi3),a
	ld	a,20h
	out	(phi5),a
	ld	a,41h
	out	(phi0),a
x197a:	in	a,(phi0)
	bit	2,a
	jr	z,x1984
	in	a,(phi2)
	jr	x197a

x1984:	ld	a,1
	out	(phi3),a
	ld	a,10h
	out	(phi4),a
	ld	a,89h
	out	(phi4),a
	ld	d,0ah
	ld	c,0
	call	sub16
	ld	a,40h
	out	(phi3),a
	ld	a,5fh
	out	(phi2),a
	ld	a,7eh
	out	(phi2),a
	ld	a,0c0h
	out	(phi3),a
	ld	a,2
	out	(phi2),a
	ld	b,1
	call	x1240
	ld	d,0eh
	call	sub16
	ld	c,0
	ld	d,0
	call	sub17
	ld	c,0c0h
	ld	d,81h
	call	sub17
	ld	c,0
	ld	d,0ah
	call	sub16
	xor	a
	out	(phi3),a
	out	(phi5),a
	ld	a,40h
	out	(phi3),a
	ld	a,3fh
	out	(phi2),a
	ld	a,49h
	out	(phi2),a
	ld	a,9
	out	(phi2),a
	call	sub16
	xor	a
	out	(phi3),a
	ld	a,40h
	out	(phi5),a
	ld	a,60h
	out	(phi5),a
	ld	a,0ffh
	ld	b,10h
x19f1:	out	(phi2),a
	dec	a
	djnz	x19f1
	ld	c,0
	ld	d,4
	call	sub16
	ld	c,0
	ld	d,0ffh
	ld	b,10h
x1a03:	call	sub17
	dec	d
	djnz	x1a03
	ld	c,0
	ld	d,0ah
	call	sub16

; XXX this might be the identify response
	xor	a
	out	(phi3),a
	ld	a,81h
	out	(phi4),a

	jp	x1741


sub16:	in	a,(phi0)
	jr	x1a20

sub17:	in	a,(phi2)
x1a20:	cp	d
x1a21:	jr	nz,x1a21
	in	a,(phi3)
	and	0c0h
	cp	c
x1a28:	jr	nz,x1a28
	ret

	ld	a,0
	ld	c,11h
	call	sub13
	ld	a,(x6013)
	and	3
	jr	nz,x1a3d
	set	1,(iy+13h)
x1a3d:	ld	b,0fah
	ld	a,1
	out	(fdc2),a
	call	x1240
	out	(fdc2),a
	call	x1240
	out	(fdc2),a
	call	x1240
	ld	b,64h
	call	x1240
	in	a,(fdc3)
	bit	6,a
	jp	nz,x1f3d
	call	x1240
	ld	b,0fah
	call	x1240
	in	a,(fdc3)
	bit	6,a
	jp	z,x1f3e
	ret

	ld	a,0
	ld	c,11h
	call	sub13
	xor	a
	out	(fdc6),a
	ld	a,4
	out	(fdc4),a
	out	(fdc0),a
	ld	a,2
	out	(fdc2),a
	in	a,(fdc2)
	bit	6,a
	jp	nz,x1f3f
	ld	b,0ah
x1a89:	djnz	x1a89
	in	a,(fdc2)
	bit	6,a
	jp	z,x1f40
	xor	a
	out	(fdc4),a
	ret

	ld	a,1
	out	(fdc2),a
	ld	a,0
	ld	c,13h
	call	sub13
	ld	a,6
	out	(fdc4),a
	ld	a,0e7h
	out	(fdc1),a
	ld	a,0cah
	out	(fdc0),a
	in	a,(fdc0)
	cp	0cah
	jp	nz,x1f3d
	in	a,(fdc1)
	cp	0e7h
	jp	nz,x1f3e
	xor	a
	out	(fdc4),a
	ret

	ld	a,1
	out	(fdc2),a
	ld	a,0
	ld	c,13h
	call	sub13
	ld	a,10h
	out	(fdc6),a
	ld	l,0
	call	x1af3
	jr	nz,x1ae6
	ld	a,l
	cp	28h
	jp	nz,x1f40
	ld	l,38h
	call	x1af3
	jr	nz,x1ae6
	xor	a
	out	(fdc4),a
	ret

x1ae6:	bit	3,a
	jp	nz,x1f41
	bit	2,a
	jp	nz,x1f42
	jp	x1f3f

x1af3:	xor	a
	out	(fdc4),a
	out	(fdc1),a
	ld	a,6
	out	(fdc4),a
	ld	a,0cch
	out	(fdc0),a
	ld	b,2
	ld	c,60h
	ld	d,0ffh
	ld	e,50h
x1b08:	out	(c),d
	djnz	x1b08
	ld	a,26h
	out	(fdc4),a
	out	(c),d
	out	(c),d
	in	a,(fdc3)
	and	80h
	jr	nz,x1b41
	ld	a,l
	out	(fdc1),a
	out	(c),e
	in	a,(fdc3)
	in	b,(c)
	ld	h,a
	in	a,(fdc1)
	ld	l,a
	xor	a
	out	(fdc1),a
	out	(c),e
	bit	7,h
	jr	z,x1b45
	ld	a,b
	cp	43h
	jr	nz,x1b49
	out	(c),e
	ld	a,6
	out	(fdc4),a
	xor	a
x1b3c:	and	0ffh
	out	(c),e
	ret

x1b41:	ld	a,8
	jr	x1b3c

x1b45:	ld	a,4
	jr	x1b3c

x1b49:	ld	a,1
	jr	x1b3c

	ld	a,1
	out	(fdc2),a
	ld	a,0
	ld	c,15h
	call	sub13
	xor	a
	out	(fdc6),a
	ld	a,4
	out	(fdc4),a
	out	(fdc0),a
	ld	a,24h
	out	(fdc4),a
	ld	a,5ch
	out	(fdc0),a
	in	a,(fdc2)
	bit	5,a
	jp	z,x1f3d
	ld	a,56h
	out	(fdc0),a
	ld	a,36h
	out	(fdc4),a
	in	a,(fdc0)
	in	a,(fdc0)
	cp	6ch
	jp	nz,x1f3e
	in	a,(fdc0)
	cp	0eeh
	jp	nz,x1f3e
	in	a,(fdc2)
	bit	5,a
	jp	nz,x1f3f
	xor	a
	out	(fdc4),a
	ld	a,(x6013)
	dec	a
	ld	(x6013),a
	and	3
	jr	nz,x1b9e
	ret

x1b9e:	ld	hl,x17b2
	ld	(x6015),hl
	ret

	ld	a,(x6003)
	call	x151a
	ld	a,(x6003)
	rlca
	rlca
	rlca
	rlca
	ld	c,17h
	call	sub13
	ld	a,(x6046)
	and	(ix+9)
	jr	z,x1bc6
	ld	hl,x17c8
	ld	(x6015),hl
	ret

x1bc6:	set	5,(iy+13h)
	bit	4,(iy+13h)
	jr	z,x1bd5
	ld	a,(x6014)
	or	a
	ret	nz
x1bd5:	rst	8
	jp	nz,x1f40
	call	sub10
	ld	c,0
	ld	b,4ch
	call	x1c15
	jp	nz,x1f41
	call	x17ad
	dec	c
	ld	b,4bh
	call	x1c15
	jp	nz,x1f42
	ld	b,1
	call	x1c15
	jp	z,x1f43
	bit	4,(iy+13h)
	ret	nz
	xor	a
	ld	c,a
	ld	b,(iy+14h)
	ld	(ix+0),b
	cp	b
	ret	z
	push	bc
	call	x17ad
	pop	bc
	call	x1c15
	jp	nz,x1f41
	ret	z
x1c15:	call	x001b
	in	a,(fdc2)
	bit	2,a
	ret	nz
	djnz	x1c15
	ret

	ld	a,(x6008)
	ld	c,19h
	call	sub13
	in	a,(fdc2)
	bit	4,a
	ret	z
	xor	a
	ld	c,62h
	call	x1c49
	jp	z,x1f3d
	call	x1c49
	ld	bc,031e8h
	ld	de,02e87h
	call	x1c64
	ret	z
	jp	m,x1f3e
	jp	p,x1f3f
x1c49:	ld	l,a
	ld	h,a
x1c4b:	inc	hl
	cp	l
	jr	nz,x1c51
	cp	h
	ret	z
x1c51:	in	b,(c)
	bit	0,b
	jr	nz,x1c4b
x1c57:	inc	hl
	cp	l
	jr	nz,x1c5d
	cp	h
	ret	z
x1c5d:	in	b,(c)
	bit	0,b
	jr	z,x1c57
	ret

x1c64:	push	hl
	scf
	ccf
	sbc	hl,bc
	pop	hl
	ret	p
	push	hl
	scf
	ccf
	sbc	hl,de
	pop	hl
	ret	m
	xor	a
	ret

	ld	a,(x6008)
	ld	c,1bh
	call	sub13
	bit	3,(iy+13h)
	jr	nz,x1c89
	ld	hl,x17c6
	ld	(x6015),hl
	ret

x1c89:	in	a,(fdc2)
	bit	4,a
	jp	z,x1f3e
	bit	3,a
	jp	nz,x1f3f
	bit	4,(iy+13h)
	ret	z
	ld	a,(x6014)
	and	7fh
	ld	(ix+0),a
	ret	z
	ld	c,1
	call	x001b
	jp	x17ad

	ld	a,(x6008)
	ld	c,1bh
	call	sub13
	call	x1d64
	call	x1d47
	call	x0060
	jp	nz,x1f3d
	ld	a,(x6008)
	ld	c,1dh
	call	sub13
	ld	c,40h
	ld	b,1
x1ccb:	call	x1d98
	call	x1cd4
	jr	nz,x1ccb
	ret

x1cd4:	inc	b
	ld	a,b
	cp	1bh
	ret

	ld	a,(x6008)
	set	3,a
	ld	c,1bh
	call	sub13
	call	x1d64
	call	x1d37
	call	x005d
	jp	nz,x1f3d
	ld	e,(ix+5)
	ld	d,(ix+6)
	call	x1683
	jr	z,x1d12
	call	x1d6e
	set	3,(ix+5)
	call	x17dd
	set	6,a
	call	sub13
	call	x1d37
	call	x005d
	jp	nz,x1f3d
x1d12:	ld	h,0
	call	x1d78
x1d17:	call	x1d98
	call	x1d32
	jr	nz,x1d17
	ld	h,40h
	call	x1d78
	ret	z
x1d25:	call	x1d98
	call	x1d32
	jr	nz,x1d25
	res	7,(iy+14h)
	ret

x1d32:	inc	b
	ld	a,b
	cp	1eh
	ret

x1d37:	ld	a,(ix+5)
	and	0edh
	set	2,a
	ld	(ix+5),a
	ld	e,70h
	ld	d,0c6h
	jr	x1d53

x1d47:	ld	a,(ix+5)
	and	0f9h
	set	4,a
	ld	(ix+5),a
	ld	d,40h
x1d53:	ld	a,(x6003)
	call	x151a
	ld	b,1
	ld	a,(x6014)
	ld	c,a
	xor	a
	ld	(x6012),a
	ret

x1d64:	res	7,(ix+4)
	res	7,(iy+14h)
	jr	x1d76

x1d6e:	set	7,(ix+4)
	set	7,(iy+14h)
x1d76:	rst	30h
	ret

x1d78:	ld	a,(x6008)
	res	6,a
	or	h
	ld	c,1dh
	call	sub13
	ld	b,0
	ld	c,0c6h
	bit	6,h
	jr	nz,x1d8e
	jp	x1d64

x1d8e:	bit	3,(ix+5)
	ret	z
	call	x1d6e
	or	a
	ret

x1d98:	ld	(ix+3),b
	ld	a,(x6014)
	ld	(ix+2),a
	ld	hl,xf07f
	in	a,(fdc3)
	bit	3,a
	jr	z,x1dae
	set	2,(ix+4)
x1dae:	push	bc
	call	x002b
	pop	bc
	ld	a,e
	and	l
	ld	e,a
	pop	hl
	bit	4,e
	jp	nz,x1f3d
	bit	3,e
	jr	nz,x1dcd
	bit	0,e
	jp	z,x1f3e
	bit	0,d
	jp	z,x1f3f
	jp	x1f40

x1dcd:	bit	1,e
	jp	nz,x1f41
	bit	5,e
	jr	z,x1de0
	bit	2,(ix+4)
	jp	nz,x1f45
	jp	x1f42

x1de0:	jp	x1fcb

	bit	3,(iy+13h)
	ret	nz
	in	a,(fdc3)
	bit	4,a
	ret	z
	ld	a,(x6008)
	res	6,a
	set	1,a
	ld	c,1dh
	call	sub13
	in	a,(fdc2)
	bit	4,a
	jp	z,x1f40
	xor	a
	cp	(ix+5)
	jr	nz,x1e17
	ld	d,a
	ld	e,a
	call	x1683
	call	x168d
	jp	nz,x1f3d
	ld	(ix+5),e
	ld	(ix+6),d
x1e17:	bit	1,(ix+5)
	jp	nz,x1f3e
	ld	a,(x6003)
	call	x151a
	res	7,(iy+14h)
	call	x1e95
	call	x006a
	jr	z,x1e36
x1e30:	jp	nc,x1f3f
	jp	c,x1f3d
x1e36:	bit	0,(iy+9)
	jr	nz,x1e80
	call	x17dd
	set	3,a
	and	0bdh
	call	sub13
	ld	b,0
x1e48:	call	x1d98
	call	x1d32
	jr	nz,x1e48
	bit	3,(ix+5)
	ret	z
	call	x17dd
	or	42h
	call	sub13
	set	7,(iy+14h)
	call	x1e95
	call	x006a
	jr	nz,x1e30
	call	x17dd
	res	1,a
	call	sub13
	ld	b,0
x1e73:	call	x1d98
	call	x1d32
	jr	nz,x1e73
	res	7,(iy+14h)
	ret

x1e80:	call	x17dd
	res	3,a
	and	0bdh
	call	sub13
	ld	b,1
x1e8c:	call	x1d98
	call	x1cd4
	jr	nz,x1e8c
	ret

x1e95:	ld	a,(x6014)
	ld	(ix+2),a
	ret

	call	x1556
	xor	a
	out	(fdc4),a
	ld	hl,x6003
	inc	(hl)
	ld	a,4
	sub	(hl)
	jr	nz,x1eb5
	ld	(hl),a
	ld	(x6008),a
	bit	5,(iy+13h)
	jr	nz,x1ec3
x1eb5:	ld	hl,x17bc
	jr	nz,x1ebc
	inc	hl
	inc	hl
x1ebc:	ld	(x6015),hl
	ret	nz
	jp	x1f44

x1ec3:	ld	hl,x6014
	res	7,(hl)
	inc	(hl)
	ld	a,4dh
	sub	(hl)
	jr	z,x1ed7
	res	5,(iy+13h)
	set	7,(iy+13h)
	ret

x1ed7:	ld	(hl),a
	ret

	pop	bc
	ld	de,(x6007)
	xor	a
	ld	bc,0400h
	ld	hl,x6000
x1ee5:	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,x1ee5
	djnz	x1ee5
	ld	(x6007),de
	jp	x0070

	xor	a
	out	(fdc4),a
	ld	(x6007),a
	ld	(x6008),a
	cpl
	out	(fdc7),a
	res	0,a
	out	(fdc3),a
	bit	4,(iy+13h)
	ret	z
	in	a,(fdc3)
	bit	5,a
	jr	nz,x1f19
	bit	4,a
	ret	z
	ld	b,0fah
	call	x1240
	call	x1240
x1f19:	ld	b,a
	ld	a,(x6014)
	or	a
	jr	z,x1f2a
	bit	3,(iy+13h)
	jr	nz,x1f36
	bit	4,b
	jr	nz,x1f36
x1f2a:	ld	d,0
	ld	e,(iy+13h)
	inc	(iy+15h)
	inc	(iy+15h)
	ret

x1f36:	ld	hl,x17bc
	ld	(x6015),hl
	ret

x1f3d:	inc	sp
x1f3e:	inc	sp
x1f3f:	inc	sp
x1f40:	inc	sp
x1f41:	inc	sp
x1f42:	inc	sp
x1f43:	inc	sp
x1f44:	inc	sp
x1f45:	ld	hl,x6405
	scf
	ccf
	sbc	hl,sp
	ld	sp,x63fd
	ld	b,5
x1f51:	sla	l
	djnz	x1f51
	ld	a,(x6008)
	adc	a,b
	set	7,a
	push	af
	ld	a,(x6007)
	or	l
	ld	c,a
	pop	af
	call	sub13
	xor	a
	out	(fdc4),a
	bit	4,(iy+13h)
	jr	z,x1fc4
	in	a,(fdc3)
	bit	4,a
	jr	z,x1fa0
	bit	5,a
	jr	z,x1f90
	ld	b,0c8h
	call	x1240
	ld	a,(x6008)
	and	30h
	ld	(x6008),a
	res	7,(iy+14h)
	dec	(iy+15h)
	dec	(iy+15h)
	ret

x1f90:	call	x1556
x1f93:	ld	d,20h
	call	x155f
	in	a,(fdc3)
	bit	4,a
	jr	nz,x1f93
	jr	x1fc4

x1fa0:	call	x1556
	ld	a,0ceh
x1fa5:	push	af
	ld	d,80h
	call	x155f
	ld	b,64h
	call	x1240
	pop	af
	dec	a
	jr	nz,x1fa5
	in	a,(fdc3)
	bit	5,a
	jr	z,x1fc4
	xor	a
	ld	d,a
	ld	e,(iy+13h)
	ld	hl,x17ce
	jr	x1fc7

x1fc4:	ld	hl,x17cc
x1fc7:	ld	(x6015),hl
	ret

x1fcb:	bit	6,e
	jp	nz,x1f43
	ld	a,(x6013)
	bit	3,a
	jr	z,x1fde
	ld	a,(x604e)
	cp	c
	jp	nz,x1f44
x1fde:	res	2,(ix+4)
	jp	(hl)

	fillto	01ffeh, 076h

x1ffe:	or	b
x1fff:	cp	0ffh


x0064	equ	64h
x17cc	equ	17cch
x17ce	equ	17ceh
x1a1d	equ	1a1dh

x6405	equ	6405h
xf053	equ	0f053h
xf057	equ	0f057h
xf073	equ	0f073h
xf07f	equ	0f07fh

	end

