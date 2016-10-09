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


rst00:	jp	doreset

X0003:	jp	X012b

	ld	(de),a
	add	a,b

rst08:	jp	do_rst08

X000b:	jp	X0360

	ld	b,26h
	
	jp	do_rst10

X0013:	jp	X0312

	ld	d,54h
	jp	do_rst18

X001b:	jp	X06a8

	ld	c,l
	ld	h,b

	jp	do_rst20

X0023:	jp	X0463

	fillto	0028h,076h

X0028:	jp	do_rst28

X002b:	jp	X0acf

	fillto	0030h,076h

	jp	do_rst30

X0033:	jp	X0bc8

	fillto	0038h,076h

	ex	af,af'
	di
X003a:	in	a,(13h)
	exx
	ld	hl,X135c
	ex	(sp),hl
	exx
	push	af
	ex	af,af'
	pop	af
	reti

	fillto	0057h,076h

	jp	X154c

	jp	X151a

X005d:	jp	X0e71

X0060:	jp	X1041

X0063:	jp	X0733

	jp	X13b9

	halt

X006a:	jp	sub1

X006d:	jp	X0440

X0070:	ld	a,2
	jr	X0075

X0074:	xor	a
X0075:	ld	(X6000),a
	ld	sp,X63ff
	xor	a
	out	(13h),a
	ld	(X600c),a
	ld	a,0dh
	out	(11h),a
	in	a,(14h)
	res	6,a
	out	(14h),a
X008b:	xor	a
	ld	(X6001),a
	ld	(X6002),a
	ld	(X6006),a
	call	X124d
	call	X1266
	xor	a
	out	(64h),a
	out	(13h),a
	out	(16h),a
	ld	a,81h
	out	(17h),a
	ld	a,41h
	out	(13h),a
	ld	a,0ffh
	out	(10h),a
	ld	(iy+0dh),3
X00b2:	ld	a,(X600d)
	cp	0ffh
	jr	z,X010a
	dec	(iy+0dh)
	ld	b,a
	call	X1507
	xor	a
	out	(65h),a
	ld	(ix+4),a
	inc	b
	ld	a,10h
X00c9:	rrca
	djnz	X00c9
	ld	(ix+9),a
	out	(66h),a
	call	X1612
	jr	z,X00ed
	ld	a,(X6000)
	cp	2
	jr	z,X00ef
	ld	a,(ix+5)
	and	1eh
	ld	d,a
	ld	a,(ix+6)
	and	4bh
	ld	e,a
	and	3
	jr	X00f8

X00ed:	jr	nc,X00f5
X00ef:	ld	d,0
	ld	e,8
	jr	X00f8

X00f5:	ld	e,a
	ld	d,0
X00f8:	ld	(ix+5),d
	ld	(ix+6),e
	rst	8
	jr	z,X0105
	ld	(ix+6),2
X0105:	call	X154c
	jr	X00b2

X010a:	in	a,(14h)
	and	40h
	or	89h
	ld	b,a
	ld	a,80h
	out	(13h),a
	ld	a,b
	out	(14h),a
	in	a,(63h)
	and	7
	or	80h
	out	(15h),a
	im	1
	ld	a,(X6000)
	cp	2
	jr	nz,X012b
	jr	X014a

X012b:	call	X124d
	ld	a,(X6000)
	rlca
	or	10h
	rst	28h
X0135:	ld	b,0
X0137:	call	X1285
	jr	nz,X0145
	djnz	X0137
	ld	d,10h
	call	X155f
	jr	X0135

X0145:	call	X0154
	jr	X012b

X014a:	ld	a,(X6007)
	set	0,a
	cpl
	out	(63h),a
	jr	X0135

X0154:	call	X1272
	ld	a,0f9h
	out	(63h),a
X015b:	in	a,(12h)
	ld	c,a
	in	a,(13h)
	bit	6,a
	jr	nz,X0169
	call	X01ae
	jr	X015b

X0169:	and	0c0h
	cp	40h
	jp	nz,X1473
	ld	a,c
	cp	30h
	jp	z,X03e0
	call	X1290

	ld	a,c		; get secondary address

	cp	10h		; don't look up 10h in table
	jp	z,X0312		;   DSJ (talker), HP-300 clear (listener)

	and	1fh
	ld	hl,X01c9
	ld	de,X0003
	ld	b,9
X0189:	cp	(hl)
	jr	z,X0192
	add	hl,de
	djnz	X0189
	jp	X1473

X0192:	inc	hl
	bit	5,c
	jr	z,X0198
	inc	hl
X0198:	ld	e,(hl)
	ld	hl,X01e4
	add	hl,de
X019d:	ld	e,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,e
	
	ld	de,X01a6	; call subroutine pointed to by HL
	push	de
	jp	(hl)
X01a6:

	call	X1285
	ret	nz
	call	X1278
	ret


X01ae:	ld	bc,0
	ld	d,1fh
X01b3:	call	X1285
	ret	nz
	in	a,(13h)
	and	6
	jp	z,X1473
	djnz	X01b3
	dec	c
	jr	nz,X01b3
	dec	d
	jr	nz,X01b3
	jp	X1473


; secondary address dispatch
;   first byte is secondary address
;   second and third bytes are byte indexes into jump table at X01e4
;   XXX possible that second vs. third byte chosen by listen vs talk
X01c9:	db	008h, 004h, 000h
	db	009h, 004h, 000h
	db	00ah, 004h, 000h
	db	00bh, 004h, 000h
	db	00ch, 004h, 000h
	db	00fh, 010h, 000h
	db	011h, 006h, 002h
	db	01eh, 008h, 00ah
	db	01fh, 00ch, 00eh
	
X01e4:	dw	X1473
	dw	sub6
	dw	X01f6
	dw	X01a6
	dw	X11ea
	dw	X11db
	dw	X1206
	dw	X1225
	dw	X11f2	; download command


; listen with secondary address 08, 09, 0a, 0b, 0c
X01f6:	ld	hl,X6046
	push	bc
	push	hl
	ld	e,0
	inc	hl
X01fe:	call	X01ae
	ld	c,12h
	ini
X0205:	in	a,(13h)
	inc	e
X0208:	bit	6,a
	jr	nz,X0210
	xor	a
	cp	e
	jr	nz,X01fe
X0210:	and	0c0h
	cp	40h
	jr	nz,X0220
	call	X1290
	dec	hl
X021a:	ld	a,(hl)
	cp	10h
	jp	z,X0013
X0220:	pop	hl
	ld	(hl),e
	pop	bc

	ld	hl,X0264
	ld	d,0
X0228:	ld	a,c
	cp	(hl)
	jr	z,X0238
	inc	hl
	ld	b,(hl)
	inc	hl

	xor	a		; E := b * 4
X0230:	add	a,4
	djnz	X0230
	ld	e,a
	add	hl,de
	jr	X0228

X0238:	inc	hl
	ld	a,(X6047)
	and	1fh
	jr	z,X024a
	ld	b,a
	ld	a,(X6048)
	and	0fh
	ld	(X6048),a
	ld	a,b
X024a:	ld	b,(hl)
	ld	e,4
	inc	hl
X024e:	cp	(hl)
	jr	z,X0257
	add	hl,de
	djnz	X024e
	jp	X147c

X0257:	inc	hl
	ld	a,(X6046)
	cp	(hl)
	jp	nz,X1473
	inc	hl
	pop	de
	jp	X019d


; command dispatch tables
; a series of tables for each secondary address (08 through 0c)

; each table has a two byte header
;   first byte - secondary address
;   second byte - table length in 4 byte entries

; each table entry is four bytes
;   first byte - command
;   second byte - byte count (including command byte)
;   third and fourth bytes - execution address

X0264:
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


X02be:	ld	a,(X6000)
	cp	2
	ret	nz
	jp	X1464

X02c7:	ld	a,(X6009)
	cp	2
	jp	z,X149c
	ret

X02d0:	in	a,(62h)
	bit	3,a
	jp	nz,X149c
	ret

X02d8:	call	X02eb
	call	X14c1
	ret	z
	ld	a,(X6001)
	cp	1
	ret	z
	cp	0ah
	ret	z
	jp	X1464

X02eb:	ld	a,(iy+48h)
	cp	4
	jp	m,X02fb
	ld	a,17h
	call	sub7
	jp	X1464

X02fb:	call	X151a
	call	X1612
	jp	nc,X149c
	jr	nz,X030a
	set	3,(ix+6)
X030a:	bit	3,(ix+6)
	jp	nz,X149c
	ret

X0312:	ld	bc,0
	ld	d,5eh
X0317:	in	a,(10h)
	bit	0,a
	jr	nz,X032c
	djnz	X0317
	dec	c
	jr	nz,X0317
	dec	d
	jr	nz,X0317
X0325:	ld	a,1
	out	(10h),a
	jp	X1473

X032c:	bit	2,a
	jr	z,X0325
	in	a,(12h)
	ld	b,a
	in	a,(13h)
	and	0c0h
	cp	0c0h
	jr	nz,X0325
	xor	a
	ld	(X6000),a
	bit	0,b
	jr	z,X0345
	ld	a,40h
X0345:	ld	b,a
	in	a,(14h)
	or	b
	out	(14h),a
	ld	a,b
	ld	(X600c),a
	out	(13h),a
	ld	a,0dh
	out	(11h),a
	bit	6,b
	jp	nz,X008b
	call	X1290
	jp	X008b

X0360:	push	af
	call	X1272
	in	a,(10h)
	bit	2,a
	jp	z,X0074
	pop	af
	ret


cmd_end:
	call	X02be
	ld	a,2
	rst	28h
	ld	a,(X6003)
	ld	(X600d),a
	call	X14b1
X037c:	ld	(iy+3),3
X0380:	ld	a,(X6003)
	call	X151a
	ld	e,(ix+6)
	call	X1612
	jr	nz,X039b
	jr	c,X03bd
	ld	b,a
	ld	a,e
	and	3
	cp	2
	jr	z,X039b
	cp	b
	jr	nz,X03bf
X039b:	bit	3,e
	jr	nz,X03bd
	call	X1285
	jr	nz,X03c9
	call	X154c
	dec	(iy+3)
	jp	p,X0380
	ld	b,0
X03af:	call	X1285
	jr	nz,X03c9
	djnz	X03af
	ld	d,12h
	call	X155f
	jr	X037c

X03bd:	set	3,e
X03bf:	set	7,e
	ld	(ix+6),e
	ld	a,1fh
	call	sub7
X03c9:	call	X154c
	ld	a,(X600d)
	ld	(X6003),a
	ret


	fillto	03e0h,076h


X03e0:	in	a,(10h)
	in	a,(13h)
	and	40h
	jr	nz,X0427
X03e8:	in	a,(14h)
	or	1
	out	(14h),a
	ld	a,81h
	out	(13h),a
	ld	a,(X6000)
	out	(12h),a
	in	a,(10h)
	bit	2,a
	jp	nz,X1467
	ld	a,(X6000)
	sub	2
	ret	c
	ld	a,(X6001)
X0407:	or	a
	jr	z,X0423
	cp	1fh
	jr	nz,X0421
	ld	b,(iy+3)
	call	X1507
	call	X1500
	bit	4,d
	jr	nz,X0421
	bit	2,d
	ld	a,0
	jr	z,X0423
X0421:	ld	a,1
X0423:	ld	(X6000),a
	ret

X0427:	ld	b,40h
	out	(13h),a
	xor	a
	out	(10h),a
	ld	(iy+0),3
	jr	X03e8


cmd_request_status
	call	X02be
	ld	a,8
	rst	28h
	ld	a,(X6048)
	call	X0023
X0440:	push	bc
	push	de
	ld	b,28h
	call	X12a3
	pop	de
	pop	bc
	ld	hl,X6046
	ld	(X6047),bc
	ld	(X6049),de
	ld	(iy+4bh),1
	ld	b,3
	ld	a,4
	call	X12f8
	call	X14b1
	ret

X0463:	ld	b,a
	cp	4
	jr	c,X046e
	ld	c,17h
	ld	de,0
	ret

X046e:	call	X151a
	call	X1500
	call	X1612
	jr	z,X0487
	ld	a,0
	bit	3,d
	jr	nz,X0487
	ld	a,d
	and	3
	cp	2
	scf
	jr	nz,X04a6
X0487:	push	af
	cp	3
	jr	nz,X0495
	ld	a,d
	and	3
	cp	2
	jr	z,X0495
	ld	a,3
X0495:	ld	b,a
	pop	af
	ld	a,b
	res	1,d
	res	0,d
	ld	e,0
	res	5,d
	res	6,d
	jr	c,X04a8
	or	d
	ld	d,a
X04a6:	jr	X04c9

X04a8:	set	3,d
	in	a,(62h)
	bit	3,a
	jr	z,X04b2
	set	6,d
X04b2:	call	sub10
	res	7,(ix+4)
	rst	30h
	call	X1683
	call	X168d
	jr	z,X04c9
	ld	a,13h
	call	sub7
	set	1,e
X04c9:	ld	c,(iy+1)
	ld	b,(iy+2)
	ld	a,d
	and	17h
	jr	z,X04d6
	set	7,e
X04d6:	ld	a,d
	and	63h
	ld	(ix+6),a
	ld	a,e
	and	7fh
	ld	(ix+5),a
	jp	X154c


	fillto	04f0h,076h


cmd_seek:
	call	X02be
	call	X02eb
	call	X02c7
	ld	d,(iy+4bh)
	ld	b,(iy+4ch)
	ld	a,(iy+49h)
	or	a
	jp	nz,X1490
	ld	a,(iy+4ah)
	ld	c,a
	cp	0
	jp	m,X1490
	cp	4dh
	jp	nc,X1490
	call	X163e
	jp	nz,X1490
	xor	a
	cp	d
	jr	z,X052a
	inc	a
	cp	d
	jp	nz,X1490
	bit	3,(ix+5)
	jp	z,X1490
X052a:	ld	a,d
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
	jr	z,X0556
	rst	18h
	cp	(ix+1)
	jr	z,X0555
	ld	b,(ix+2)
	ld	c,(ix+3)
	push	bc
	rst	8
	pop	bc
	ld	(ix+2),b
	ld	(ix+3),c
	jp	nz,X1480
X0555:	rst	10h
X0556:	set	7,(ix+6)
	ld	a,1fh
	call	sub7
	ld	(iy+0),0
	call	X154c
	ret


do_rst10:
	call	sub1
	ret	z
	jp	c,X1480
	ld	b,(ix+3)
	ld	c,(ix+2)
	push	bc
	cp	1
	call	z,rst08
	pop	bc
	ld	(ix+3),b
	ld	(ix+2),c
	jp	X1490


sub1:	ld	a,1ah
	rst	28h
	ld	(iy+0dh),0ah
	ld	a,(ix+2)
	or	a
	jr	nz,X05a6
	ld	b,(ix+3)
	push	bc
	rst	8
	pop	bc
	ld	(ix+3),b
	jr	z,X059e
	scf
	ret

X059e:	ld	c,0
	ld	b,c
	ld	d,(ix+4)
	jr	X05f9

X05a6:	ld	a,(ix+1)
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
	jr	z,X05d3
	ld	a,(ix+1)
	xor	(ix+2)
	bit	7,a
	jr	z,X05d3
	ld	a,(ix+2)
	inc	b
	bit	7,a
	jr	nz,X05d3
	dec	b
	dec	b
X05d3:	ld	d,(ix+4)
	ld	a,(ix+1)
	xor	(ix+2)
	bit	7,a
	jr	z,X05e8
	bit	7,d
	res	7,d
	jr	nz,X05e8
	set	7,d
X05e8:	xor	a
	cp	b
	ld	c,b
	jr	nz,X05f9
	bit	7,d
	jr	nz,X05f9
	bit	3,(ix+5)
	jr	z,X05f9
	ld	c,0ffh
X05f9:	call	sub2
	jr	nz,X0661
	res	7,(ix+4)
	bit	7,d
	jr	z,X060a
	set	7,(ix+4)
X060a:	rst	30h
	ld	b,0ch
X060d:	push	bc
	rst	18h
	pop	bc
	cp	0ffh
	jp	nz,X064c
	dec	b
	jr	z,X0663
	bit	3,(ix+5)
	jr	z,X063b
	bit	7,(ix+4)
	set	7,(ix+4)
	jr	z,X062c
	res	7,(ix+4)
X062c:	rst	30h
	xor	a
	bit	7,c
	jr	z,X0634
	ld	a,80h
X0634:	xor	(ix+4)
	bit	7,a
	jr	nz,X060d
X063b:	push	bc
	ld	b,1
	bit	7,c
	jr	z,X0644
	ld	b,0ffh
X0644:	call	sub2
	pop	bc
	jr	nz,X0661
	jr	X060d

X064c:	ld	(ix+1),a
	cp	(ix+2)
	call	z,X14eb
	ret	z
	dec	(iy+0dh)
	jp	nz,X05a6
	or	1
	ld	a,0
	ret

X0661:	ld	a,1
X0663:	or	a
	ret


sub2:	ld	a,b
	or	a
	ret	z
	jp	p,X067a
	add	a,(ix+0)
	cp	0
	jp	m,X0677
	in	a,(62h)
	bit	2,a
X0677:	ret	nz
	jr	X0684

X067a:	add	a,(ix+0)
	cp	4dh
	jp	m,X0684
	inc	a
	ret

X0684:	push	bc
	xor	a
	ld	c,b
	cp	b
	jp	m,X068f
	ld	a,b
	neg
	ld	b,a
X068f:	call	X001b
	bit	7,c
	jr	z,X069b
	dec	(ix+0)
	jr	X069e

X069b:	inc	(ix+0)
X069e:	djnz	X068f
	ld	b,14h
	call	X1240
	pop	bc
	xor	a
	ret

X06a8:	push	bc
	ld	a,(ix+4)
	and	0f7h
	bit	7,c
	jr	nz,X06b4
	set	1,a
X06b4:	out	(65h),a
	set	0,a
	out	(65h),a
	res	0,a
	out	(65h),a
	rst	30h
	ld	b,3
	call	X1240
	pop	bc
	ret


do_rst08:
	xor	a
	ld	(ix+0),a
	ld	(ix+2),a
	ld	(ix+1),a
	ld	a,(X6009)
	and	1
	ld	(ix+3),a
	res	7,(ix+4)
	rst	30h
	ld	b,50h
X06df:	in	a,(62h)
	bit	2,a
	jr	nz,X06ee
	ld	c,0ffh
	call	X001b
	djnz	X06df
	inc	b
	ret

X06ee:	ld	a,50h
	cp	b
	ld	b,14h
	call	nz,X1240
	xor	a
	ret


	fillto	0700h,076h


cmd_buffered_read_verify:
	call	X072a
	set	2,(ix+4)
	jr	X070c


cmd_buffered_read:
	call	X072a
X070c:	rst	20h
	call	X0c87
	ld	hl,Xf073
	ld	a,1
	call	X0865
X0718:	push	af
	ld	b,20h
	call	X12a3
	ld	b,3
	pop	af
	call	X0952
	jp	z,X07e4
	jp	X07ed

X072a:	call	X02be
	call	X02d8
	call	X02c7
X0733:	call	X08a4
	jp	nc,X1490
	ret


cmd_unbuffered_read_verify:
	call	X072a
	set	2,(ix+4)
	jr	X0746


cmd_unbuffered_read:
	call	X072a
X0746:	ld	hl,Xf073
	push	hl
	rst	20h
	ld	a,1
	call	X0865
	push	af
	ld	b,20h
	call	X12a3
	ld	b,2
	pop	af
	jr	z,X075d
	ld	b,3
X075d:	call	X0952
	jp	nz,X07ed
X0763:	call	X1285
	pop	hl
	jp	nz,X07e4
	in	a,(13h)
	bit	2,a
	jp	z,X07e4
	call	X0c87
	rst	30h
	xor	a
	call	X0865
	push	hl
	ld	b,0
	jr	z,X0780
	ld	b,1
X0780:	push	af
	call	X0952
	pop	af
	jp	nz,X07ed
	jr	X0763


cmd_verify:
	ld	a,18h
	rst	28h
	call	X02be
	call	X02eb
	call	X02c7
	call	X0063
	ld	a,(X6049)
	cp	0
	jp	m,X1473
	ld	b,(iy+49h)
	ld	c,(iy+4ah)
	push	bc
	ld	a,b
	or	a
	jr	z,X07b2
	cp	1
	jr	c,X07c8
	jr	X07b5

X07b2:	add	a,c
	jr	nz,X07c8
X07b5:	ld	b,4
	push	ix
X07b9:	dec	b
	ld	a,b
	jp	m,X07c6
	cp	(iy+3)
	call	nz,X15d8
	jr	X07b9

X07c6:	pop	ix
X07c8:	rst	20h
	pop	bc
	set	2,(ix+4)
	ld	d,1
X07d0:	ld	hl,Xf073
	rst	30h
	push	bc
	ld	a,d
	call	X0865
	jp	nz,X07ed
	pop	bc
	ld	d,0
	cpi
	jp	pe,X07d0
X07e4:	call	X14b1
X07e7:	res	2,(ix+4)
	rst	30h
	ret

X07ed:	call	X07e7
	jp	X1467


cmd_cold_load_read:
	xor	a
	ld	(X6000),a
	call	X0023
	xor	a
	call	X151a
	call	X02c7
	ld	a,(iy+48h)
	and	3fh
	ld	b,a
	call	X163e
	jp	nz,X1490
	ld	a,(iy+48h)
	rlca
	rlca
	and	3
	jr	z,X0823
	cp	2
	jp	nc,X1490
	bit	3,(ix+5)
	jp	z,X1490
	rrca
X0823:	ld	(ix+2),a
	ld	(ix+3),b
	jp	X0746


cmd_id_triggered_read:
	call	X072a
	bit	0,(iy+9)
	jp	nz,X149c
	rst	20h
	call	X08ac
	jr	z,X0842
	jp	c,X148a
	jp	nc,X1490
X0842:	ld	hl,Xf073
	call	sub3
	call	X08ca
	jr	nc,X0842
	jp	nz,X1464
	ld	b,2
	call	X1240
	ld	a,6
	call	X0ad9
	call	X08ca
	jr	nc,X0842
	call	z,X0876
	jp	X0718

X0865:	push	af
X0866:	call	X08ac
	jr	nz,X087c
	call	X0acf
	call	X08ca
	jr	nc,X0866
	inc	sp
	inc	sp
	ret	nz
X0876:	push	af
	call	X096d
	pop	af
	ret

X087c:	jr	c,X0892
	cp	1
	jr	nz,X088c
	pop	af
	push	af
	or	a
	jr	nz,X088c
	call	X14b1
	jr	X089f

X088c:	set	2,(ix+6)
	jr	X0896

X0892:	set	4,(ix+6)
X0896:	set	7,(ix+6)
	ld	a,1fh
	call	sub7
X089f:	pop	af
	ld	a,1
	or	a
	ret

X08a4:	ld	a,(ix+2)
	and	7fh
	cp	4dh
	ret

X08ac:	ld	a,(ix+1)
	cp	(ix+2)
	ret	z
	push	hl
	ld	b,(ix+4)
	push	bc
	call	X006a
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

X08ca:	push	af
	ld	b,13h
	bit	4,e
	jr	nz,X0915
	ld	b,9
	bit	0,e
	jr	nz,X094c
	ld	b,7
	bit	6,d
	jr	nz,X091d
	ld	b,9
	bit	5,d
	jr	nz,X091d
	ld	b,31h
	bit	2,e
	jr	nz,X0915
	ld	b,9
	bit	1,e
	jr	nz,X0915
	ld	a,e
	and	l
	ld	b,12h
	bit	6,a
	jr	nz,X091d
	ld	b,8
	bit	5,a
	jr	z,X090b
	bit	2,(ix+4)
	jr	z,X0915
	bit	1,d
	jr	z,X0915
	ld	b,9
	jr	X0915

X090b:	xor	a
X090c:	res	1,(iy+5)
	scf
X0911:	ex	(sp),hl
	ld	a,h
	pop	hl
	ret

X0915:	ld	a,b
	call	sub7
	or	1
	jr	X090c

X091d:	bit	1,(iy+5)
	jr	nz,X0915
	ld	a,(ix+4)
	push	af
	push	hl
	ld	a,(ix+2)
	push	af
	ld	(ix+2),0
	rst	10h
	pop	af
	or	a
	jr	z,X0939
	ld	(ix+2),a
	rst	10h
X0939:	pop	hl
	pop	af
	and	4
	or	(ix+4)
	ld	(ix+4),a
	rst	30h
	set	1,(iy+5)
	or	1
	jr	X0911

X094c:	bit	0,d
	jr	z,X091d
	jr	X0915

X0952:	push	af
	ld	hl,X604d
	cp	1
	jr	z,X095f
	call	X12f8
	pop	af
	ret

X095f:	bit	1,b
	call	nz,X127e
	ld	a,1
	ld	b,80h
	call	X12da
	pop	af
	ret

X096d:	ld	b,(ix+3)
	inc	b
	call	X163e
	jr	z,X0990
	bit	3,(ix+5)
	jr	z,X098a
	bit	7,(ix+2)
	set	7,(ix+2)
	jr	z,X098d
	res	7,(ix+2)
X098a:	inc	(ix+2)
X098d:	ld	b,(iy+9)
X0990:	ld	(ix+3),b
	ret


do_rst18:
	in	a,(62h)
	bit	4,a
	jp	z,X1480
	res	2,(ix+4)
	rst	30h
	ld	hl,X1060
	ld	b,2
X09a5:	push	bc
	call	sub3
	jr	z,X09b1
	pop	bc
	djnz	X09a5
	or	0ffh
	ret

X09b1:	pop	hl
	ld	a,b
	ld	b,c
	ret


sub3:	ld	a,3
	out	(62h),a
	ld	a,(ix+2)
	and	7fh
	ld	(X600b),a
	ld	de,0
X09c4:	push	hl
	ld	a,d
	and	1
	ld	d,a
	ld	e,0
	push	de
X09cc:	pop	de
	xor	a
	out	(64h),a
	ld	a,2
	out	(62h),a
	push	de
	ld	a,2
	ld	b,22h
	ld	c,67h
	ld	d,70h
	ld	e,0eh
	bit	0,(iy+9)
	jp	nz,X0a5f
	out	(64h),a
X09e8:	db	0edh,70h

	jr	z,X09e8
	jp	p,X0a56
	in	a,(60h)
	ld	h,a
	in	a,(61h)
	cp	e
	jr	nz,X09cc
	ld	a,b
	out	(64h),a
	in	a,(60h)
	ld	b,a
	ld	a,h
	sub	d
	rl	a
	jr	nz,X09cc
	in	a,(60h)
	pop	de
	push	af
	in	a,(60h)
	set	0,d
	call	sub4
	pop	af
	jr	nc,X0a13
	set	2,e
X0a13:	bit	7,a
	res	7,a
	ld	c,a
	jr	z,X0a1c
	set	7,b
X0a1c:	cp	(ix+3)
	jr	z,X0a23
	set	7,d
X0a23:	ld	a,b
	and	7fh
	cp	(iy+0bh)
	jr	z,X0a2d
	set	6,d
X0a2d:	ld	a,b
	xor	(ix+2)
	bit	7,a
	jr	z,X0a37
	set	5,d
X0a37:	ld	a,e
	pop	hl
	and	l
	jr	nz,X0a41
	ld	a,d
	and	h
	jr	nz,X0a41
	ret

X0a41:	ld	a,e
	and	60h
	jp	nz,X09c4
	ld	a,d
	and	60h
	ret	nz
	ld	a,d
	and	90h
	jp	nz,X09c4
X0a51:	or	1
	set	1,d
	ret

X0a56:	xor	a
	out	(64h),a
	pop	de
	pop	hl
	set	0,e
	jr	X0a51

X0a5f:	out	(64h),a
X0a61:	db	0edh,70h

	jr	z,X0a61
	jp	p,X0a56
	ld	a,b
	out	(64h),a
	in	a,(60h)
	ld	b,a
	in	a,(61h)
	cp	0c7h
	jp	nz,X09cc
	ld	a,b
	cp	0feh
	jp	nz,X09cc
	in	a,(60h)
	pop	de
	ld	b,a
	cp	(iy+0bh)
	jr	z,X0a86
	set	6,d
X0a86:	in	a,(60h)
	cp	0
	jr	z,X0a8e
	set	5,d
X0a8e:	in	a,(60h)
	ld	c,a
	cp	(ix+3)
	jr	z,X0a98
	set	7,d
X0a98:	in	a,(60h)
	cp	0
	jr	z,X0aa0
	set	4,d
X0aa0:	in	a,(60h)
	set	0,d
	call	sub4
	jp	X0a37


sub4:	in	a,(60h)
	ld	a,(ix+4)
	ld	h,a
	and	0f3h
	out	(65h),a
	in	a,(60h)
	ld	a,h
	and	0f7h
	out	(65h),a
X0abb:	in	a,(62h)
	ld	l,a
	xor	a
	out	(64h),a
	ld	a,l
	and	70h
	or	e
	bit	4,a
	set	4,a
	jr	z,X0acd
	res	4,a
X0acd:	ld	e,a
	ret

X0acf:	ld	a,1eh
	rst	28h
	call	sub3
	ld	a,1
	jr	nz,X0b2e
X0ad9:	push	hl
	ld	h,a
	push	bc
	ld	a,2
	out	(64h),a
	set	3,e
	push	de
	ld	b,0beh
	ld	d,0eh
	ld	c,67h
	ld	e,7fh
	ld	l,22h
	bit	0,(iy+9)
	jp	nz,X0b53
X0af4:	db	0edh,70h

	jp	p,X0b32
	in	a,(60h)
	and	e
	ld	e,a
	in	a,(61h)
	cp	d
	jr	nz,X0b42
	ld	a,l
	out	(64h),a
	in	a,(60h)
	ld	d,a
	ld	a,e
	cp	50h
	jr	nz,X0b40
	ld	hl,X604f
	ld	(hl),d
	dec	hl
	in	a,(60h)
	ld	(hl),a
	inc	hl
	inc	hl
	ld	c,60h
	ld	b,0feh
X0b1b:	inc	hl
	ind
	ini
	inc	hl
	jr	nz,X0b1b
X0b23:	in	a,(60h)
	pop	de
	ld	(hl),1
	call	sub4
	ld	a,b
X0b2c:	pop	bc
	pop	hl
X0b2e:	call	X14eb
	ret

X0b32:	djnz	X0af4
	dec	h
	jr	nz,X0af4
X0b37:	xor	a
	out	(64h),a
	pop	de
	set	1,e
	inc	a
	jr	X0b2c

X0b40:	ld	d,0eh
X0b42:	ld	e,7fh
	xor	a
	out	(64h),a
	ld	a,2
	out	(64h),a
	bit	0,(iy+9)
	jr	z,X0b32
	jr	X0b82

X0b53:	db	0edh,70h

	jp	p,X0b82
	ld	a,l
	out	(64h),a
	in	a,(60h)
	sub	0f8h
	jr	z,X0b65
	cp	3
	jr	nz,X0b42
X0b65:	ld	d,a
	in	a,(61h)
	cp	0c7h
	jr	nz,X0b42
	ld	c,60h
	ld	hl,X604e
	ld	b,80h
	inir
	ld	a,d
	pop	de
	cp	3
	jr	z,X0b7d
	set	2,e
X0b7d:	push	de
	ld	b,80h
	jr	X0b23

X0b82:	djnz	X0b53
	jr	X0b37


cmd_unbuffered_write:
	call	X072a
	call	X02d0
	ld	b,0
	call	X12a3
	rst	20h
X0b92:	call	X1455
	call	X0c87
	ld	hl,Xf057
	call	X0bc8
	jp	nz,X1467
	ld	a,(X600a)
	cp	0c0h
	jr	nz,X0b92
	call	X14b1
	ret


cmd_buffered_write:
	call	X072a
	call	X02d0
	ld	b,0
	call	X12a3
	rst	20h
	call	X1455
	call	X0c87
	ld	hl,Xf057
	call	X0bc8
	call	z,X14b1
	ret

X0bc8:	call	X08ac
	jr	z,X0bd3
	jp	nc,X1490
	jp	c,X1480
X0bd3:	call	X0be1
	call	X08ca
	jr	nc,X0bc8
	ret	nz
	call	X096d
	xor	a
	ret

X0be1:	ld	a,1ch
	rst	28h
	call	X165b
	push	hl
	call	sub3
	jr	nz,X0c44
	ld	hl,X604e
	bit	0,(iy+9)
	jr	nz,X0c4c
	ld	b,2bh
X0bf8:	djnz	X0bf8
	ld	a,4
	out	(64h),a
	xor	a
	out	(61h),a
	out	(60h),a
	ld	a,0ch
	out	(64h),a
	xor	a
	out	(60h),a
	ld	c,60h
	out	(60h),a
	out	(60h),a
	ld	b,4
	dec	a
X0c13:	out	(60h),a
	djnz	X0c13
	ld	a,38h
	out	(61h),a
	ld	a,50h
	out	(60h),a
	xor	a
	out	(61h),a
	ld	b,a
	ld	a,2ch
	out	(64h),a
X0c27:	inc	hl
	outd
	outi
	inc	hl
	jr	nz,X0c27
X0c2f:	ld	a,3ch
	out	(64h),a
	xor	a
	out	(60h),a
	out	(60h),a
	ld	a,0ch
	out	(64h),a
	ld	a,b
	out	(60h),a
	out	(60h),a
	call	X0abb
X0c44:	xor	a
	out	(64h),a
	call	X14eb
	pop	hl
	ret

X0c4c:	ld	b,47h
X0c4e:	djnz	X0c4e
	ld	a,4
	out	(64h),a
	ld	b,5
	ld	a,0ffh
	out	(61h),a
	xor	a
	out	(60h),a
	ld	a,0ch
	out	(64h),a
	xor	a
X0c62:	out	(60h),a
	djnz	X0c62
	ld	a,2ch
	out	(64h),a
	ld	a,0c7h
	out	(61h),a
	ld	a,0fbh
	bit	2,(iy+5)
	jr	z,X0c78
	ld	a,0f8h
X0c78:	out	(60h),a
	ld	a,0ffh
	out	(61h),a
	ld	b,80h
	ld	c,60h
	otir
	dec	b
	jr	X0c2f

X0c87:	ld	d,0ffh
	call	X155f
	ret


	fillto	0ca0h,076h


cmd_initialize:
	call	X02be
	call	X02eb
	call	X02c7
	call	X0063
	call	X02d0
	rst	20h
	rst	10h
	bit	0,(iy+9)
	jr	nz,X0cd3
	ld	d,0
	ld	(iy+12h),d
	ld	e,70h
	bit	5,(iy+47h)
	jr	z,X0cc6
	ld	e,0f0h
X0cc6:	ld	c,(ix+2)
	ld	b,2
	call	X005d
	jp	nz,X148a
	jr	X0cdd

X0cd3:	bit	5,(iy+47h)
	jr	z,X0cdd
	set	2,(iy+5)
X0cdd:	ld	b,0
	call	X12a3
	call	X1455
	ld	hl,Xf053
	call	X0033
	res	2,(iy+5)
	call	z,X14b1
	ld	a,(X6001)
	cp	31h
	call	z,X14b1
	ret


cmd_format:
	call	X02be
	call	X02eb
	call	X02d0
	ld	a,(X6049)
	and	7fh
	cp	2
	jr	z,X0d12
	cp	8
	jp	nz,X1473
X0d12:	rlca
	ld	b,a
	ld	a,(X604a)
	cp	1
	jp	m,X1473
	ld	c,1eh
	bit	4,b
	jr	z,X0d24
	ld	c,1ah
X0d24:	cp	c
	jp	nc,X1473
	ld	a,(ix+5)
	ld	(X600d),a
	and	8
	or	b
	bit	4,a
	jr	z,X0d3a
	bit	3,a
	jp	nz,X149c
X0d3a:	ld	(ix+5),a
	ld	b,4
X0d3f:	dec	b
	jp	m,X0d4c
	ld	a,b
	cp	(iy+3)
	call	nz,X15d8
	jr	X0d3f

X0d4c:	call	X154c
	ld	a,(X6003)
	call	X151a
	ld	a,0eh
	rst	28h
	rst	20h
	rst	8
	jp	nz,X1480
	ld	bc,0
	ld	(iy+12h),b
	bit	0,(iy+9)
	jp	nz,X0df7
X0d6a:	ld	a,b
	cp	4dh
	jr	z,X0de6
	push	bc
	bit	7,(iy+49h)
	jr	nz,X0d93
	bit	2,(iy+0dh)
	jr	z,X0d93
	rst	18h
	cp	0ffh
	jr	z,X0d85
	bit	2,e
	jr	z,X0d93
X0d85:	ld	c,0ffh
	call	X0dee
	call	X005d
	jp	nz,X148a
	pop	bc
	jr	X0dae

X0d93:	pop	bc
	push	bc
	call	X0dee
	call	X005d
	jp	nz,X148a
	pop	bc
	bit	3,(ix+5)
	jr	z,X0dad
	bit	7,c
	set	7,c
	jr	z,X0dae
	res	7,c
X0dad:	inc	c
X0dae:	bit	3,(ix+5)
	jr	z,X0dc2
	bit	7,(ix+4)
	set	7,(ix+4)
	jr	z,X0dc3
	res	7,(ix+4)
X0dc2:	inc	b
X0dc3:	rst	30h
	bit	7,(ix+4)
	call	z,X0e61
	xor	a
	bit	7,(ix+4)
	ld	a,(X600f)
	jr	nz,X0dd8
	ld	a,(X600e)
X0dd8:	add	a,(iy+10h)
	cp	1eh
	jr	c,X0de1
	sub	1eh
X0de1:	ld	(X6010),a
	jr	X0d6a

X0de6:	rst	8
	jp	nz,X1480
	call	X14b1
	ret

X0dee:	ld	b,(iy+4ah)
	ld	d,(iy+4bh)
	ld	e,70h
	ret

X0df7:	push	bc
	bit	7,(iy+49h)
	jr	nz,X0e04
	bit	4,(iy+0dh)
	jr	nz,X0e1c
X0e04:	pop	bc
	push	bc
	call	X0dee
	call	X0060
	jp	nz,X148a
	pop	bc
	inc	c
X0e11:	inc	b
	ld	a,b
	cp	4dh
	jr	z,X0de6
	call	X0e61
	jr	X0df7

X0e1c:	ld	hl,X0064
	res	2,(ix+4)
X0e23:	call	X002b
	res	7,(iy+12h)
	bit	6,e
	jr	nz,X0e45
	bit	0,d
	jr	z,X0e53
	ld	a,b
	cp	0ffh
	jr	z,X0e53
	bit	1,e
	jr	nz,X0e45
	bit	5,e
	jr	nz,X0e45
	bit	2,e
	jr	nz,X0e53
	jr	X0e04

X0e45:	bit	1,(iy+5)
	set	1,(iy+5)
	jr	z,X0e23
	res	1,(iy+5)
X0e53:	ld	c,0ffh
	call	X0dee
	call	X0060
	jp	nz,X148a
	pop	bc
	jr	X0e11

X0e61:	push	bc
	ld	c,0
	call	X001b
	ld	b,14h
	call	X1240
	pop	bc
	inc	(ix+0)
	ret

X0e71:	bit	7,(iy+12h)
	jr	nz,X0e98
	push	de
	push	bc
	call	X0ffa
	pop	bc
	ld	hl,X0f90
	ld	a,b
	dec	a
	rlca
	ld	e,a
	add	hl,de
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	ld	(X600e),de
	xor	a
	ld	(X6010),a
	pop	de
	call	X0fca
	set	7,(iy+12h)
X0e98:	ld	b,0
	ld	a,c
	cp	0ffh
	jr	z,X0ea2
	ld	b,a
	and	7fh
X0ea2:	push	af
	ld	(iy+0bh),b
	call	X165b
	ld	(iy+11h),1eh
	ld	c,60h
	call	X0f87
	pop	af
	push	ix
	ld	ix,X6074
	ld	(ix+0),a
	ld	b,0
	xor	a
	out	(61h),a
X0ec1:	in	a,(62h)
	bit	4,a
	jp	z,X0f7f
	bit	0,a
	jr	z,X0ec1
	ld	a,2
	out	(62h),a
	ld	a,0ch
	out	(64h),a
X0ed4:	out	(c),b
	in	a,(62h)
	bit	4,a
	jp	z,X0f7f
	bit	0,a
	jr	nz,X0ed4
X0ee1:	out	(c),b
	in	a,(62h)
	bit	4,a
	jp	z,X0f7f
	bit	0,a
	jr	z,X0ee1
X0eee:	out	(c),b
	in	a,(62h)
	bit	0,a
	jr	nz,X0eee
X0ef6:	ld	hl,X606b
	outi
	ld	a,(de)
	bit	7,(iy+0bh)
	jr	z,X0f04
	set	7,a
X0f04:	outi
	ld	b,6
	ld	(ix+1),a
	otir
	ld	a,38h
	out	(61h),a
	outi
	xor	a
	out	(61h),a
	ld	a,2ch
	out	(64h),a
	outi
	outi
	ld	a,3ch
	out	(64h),a
	outi
	outi
	ld	a,0ch
	out	(64h),a
	ld	b,19h
	otir
	ld	a,38h
	out	(61h),a
	outi
	xor	a
	out	(61h),a
	ld	b,a
	ld	a,2ch
	out	(64h),a
	otir
	ld	a,3ch
	out	(64h),a
	outi
	outi
	ld	a,0ch
	out	(64h),a
	ld	b,23h
	outi
	ld	a,(X6010)
	inc	a
	outi
	cp	1eh
	jr	c,X0f59
	xor	a
X0f59:	ld	(X6010),a
	outi
	ld	de,X604d
	add	a,e
	ld	e,a
	outi
	dec	(iy+11h)
	jr	z,X0f6e
	otir
	jr	X0ef6

X0f6e:	xor	a
	out	(64h),a
	in	a,(62h)
	bit	6,a
	jr	nz,X0f7f
	ld	b,98h
X0f79:	djnz	X0f79
	xor	a
	pop	ix
	ret

X0f7f:	xor	a
	out	(64h),a
	pop	ix
	or	1
	ret

X0f87:	ld	de,X604d
	ld	a,(X6010)
	add	a,e
	ld	e,a
	ret

X0f90:	inc	e
	jr	X0faf

	jr	X0fb1

	jr	X0fb4

	ld	a,(de)
	ld	a,(de)
	jr	X0fb4

	jr	X0f9d

X0f9d:	nop
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
	djnz	X0fbe
	dec	e
X0faf:	dec	e
	nop
X0fb1:	nop
	add	hl,de
	add	hl,de
X0fb4:	nop
	nop
	dec	d
	dec	d
	inc	e
	inc	e
	dec	e
	dec	e
	nop
	nop
X0fbe:	add	hl,de
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
X0fca:	ld	hl,X606b
	xor	a
	ld	b,4
	call	X0ff5
	dec	a
	ld	b,4
	call	X0ff5
	ld	(hl),e
	inc	hl
	xor	a
	ld	b,19h
	call	X0ff5
	dec	a
	ld	b,4
	call	X0ff5
	ld	(hl),50h
	inc	hl
	ld	a,d
	call	X0ff5
	xor	a
	ld	b,25h
	call	X0ff5
	ret

X0ff5:	ld	(hl),a
	inc	hl
	djnz	X0ff5
	ret

X0ffa:	ld	hl,X604d
	push	hl
	ld	(iy+12h),b
	ld	b,1eh
	ld	a,0ffh
	call	X0ff5
	pop	hl
	ld	c,1eh
	bit	0,(iy+9)
	jr	z,X1014
	inc	b
	ld	c,1ah
X1014:	ld	de,0
	ld	(hl),b
	inc	b
X1019:	push	hl
	ld	a,e
	add	a,(iy+12h)
X101e:	cp	c
	jr	c,X1022
	sub	c
X1022:	ld	e,a
	add	hl,de
	ld	a,(hl)
	cp	0ffh
	jr	z,X102f
	inc	e
	pop	hl
	push	hl
	ld	a,e
	jr	X101e

X102f:	ld	(hl),b
	inc	b
	ld	a,b
	cp	c
	pop	hl
	jr	nz,X1019
	bit	0,(iy+9)
	ret	z
	cp	1bh
	ret	z
	inc	c
	jr	X1019

X1041:	xor	a
	ld	(X6010),a
	bit	7,(iy+12h)
	jr	nz,X1059
	push	bc
	push	de
	call	X0ffa
	pop	de
	call	X1135
	set	7,(iy+12h)
	pop	bc
X1059:	ld	a,1ah
	ld	(X6011),a
	ld	b,c
	push	bc
X1060:	ld	b,2eh
	ld	c,60h
	call	X0f87
	ld	hl,X606b
	pop	af
	push	ix
	ld	ix,X60bb
	ld	(ix+0),a
	cp	0ffh
	jr	nz,X107e
	ld	(ix+1),a
	ld	(ix+3),a
X107e:	ld	a,0ffh
	out	(61h),a
X1082:	in	a,(62h)
	bit	4,a
	jp	z,X0f7f
	bit	0,a
	jr	nz,X1082
X108d:	in	a,(62h)
	bit	4,a
	jp	z,X0f7f
	bit	0,a
	jr	z,X108d
	ld	a,2
	out	(62h),a
	ld	a,0ch
	out	(64h),a
	otir
	ld	a,0d7h
	out	(61h),a
	outi
	ld	a,0ffh
	out	(61h),a
	ld	b,1ah
	otir
X10b0:	ld	b,6
	outi
	ld	a,(ix+0)
	cp	0ffh
	jr	z,X10bc
	ld	a,(de)
X10bc:	ld	(ix+2),a
	otir
	ld	a,2ch
	out	(64h),a
	ld	a,0c7h
	out	(61h),a
	outi
	ld	a,0ffh
	out	(61h),a
	ld	b,4
	otir
	ld	a,3ch
	out	(64h),a
	outi
	outi
	ld	a,0ch
	out	(64h),a
	ld	b,11h
	otir
	ld	a,2ch
	out	(64h),a
	ld	a,0c7h
	out	(61h),a
	outi
	ld	a,0ffh
	out	(61h),a
	ld	b,80h
	otir
	ld	a,3ch
	out	(64h),a
	outi
	outi
	ld	a,0ch
	out	(64h),a
	ld	b,1ah
	outi
	ld	a,(X6010)
	inc	a
	ld	de,X604d
	outi
	cp	1ah
	jr	c,X1113
	xor	a
X1113:	ld	(X6010),a
	add	a,e
	ld	e,a
	otir
	ld	hl,X60b4
	dec	(iy+11h)
	jr	nz,X10b0
	dec	b
X1123:	out	(c),b
	in	a,(62h)
	bit	4,a
	jp	z,X0f7f
	bit	0,a
	jr	z,X1123
	out	(c),b
	jp	X0f6e

X1135:	ld	hl,X606b
	ld	a,0ffh
	ld	b,28h
	call	X0ff5
	xor	a
	ld	b,6
	call	X0ff5
	ld	(hl),0fch
	inc	hl
	dec	a
	ld	b,1ah
	call	X0ff5
	xor	a
	ld	b,6
	call	X0ff5
	ld	(hl),0feh
	inc	hl
	ld	b,6
	call	X0ff5
	dec	a
	ld	b,0bh
	call	X0ff5
	xor	a
	ld	b,6
	call	X0ff5
	ld	(hl),0fbh
	inc	hl
	ld	a,d
	ld	b,80h
	call	X0ff5
	xor	a
	ld	b,2
	call	X0ff5
	dec	a
	ld	b,1ah
	call	X0ff5
	ret

	halt
	halt


cmd_door_lock:
	call	X02be
	call	X02d8
	call	sub10
	ld	a,(ix+9)
	cpl
	and	(iy+6)
	ld	(X6006),a
	set	5,(ix+4)
	jr	X11a9


cmd_door_unlock:
	call	X02be
	call	X02d8
	res	5,(ix+4)
	ld	b,(iy+3)
	call	X15d8
X11a9:	call	X14b1
	ret


cmd_request_logical_address:
	ld	a,(X6003)
	call	X151a
	ld	b,(ix+2)
	bit	7,b
	res	7,b
	ld	d,(ix+3)
	jr	X11ce


cmd_request_physical_address:
	ld	a,(X6003)
	call	X151a
	ld	b,(ix+0)
	ld	d,0
	bit	7,(ix+4)
X11ce:	ld	e,0
	jr	z,X11d3
	inc	e
X11d3:	ld	c,0
	call	X02be
	jp	X006d

X11db:	ld	a,0ffh
X11dd:	ld	hl,X604d
	ld	b,3
	call	X12f8
	xor	a
	ld	(X6001),a
	ret

X11ea:	ld	hl,X604d
	xor	a
	call	X1344
	ret


; download command
X11f2:	call	X11ea
	ld	a,(X600a)
	cp	0c0h
	jp	nz,X1473
	ld	hl,X6050
	ex	de,hl
	call	X124d
	ex	de,hl
	jp	(hl)


X1206:	ld	hl,X604d
	xor	a
	call	X1344
	ld	a,(X604d)
	cp	1
	ld	d,(iy+4eh)
	ld	e,0
	jr	z,X121c
	ld	e,(iy+4fh)
X121c:	ld	a,d
	cp	4dh
	jp	nc,X1490
	jp	X1722

X1225:	ld	hl,(X6007)
	ld	a,h
	ld	h,l
	ld	l,a
	ld	(X604e),hl
	ld	a,1
	jr	X11dd


	fillto	01240h,076h


X1240:	push	bc
	ld	b,0
X1243:	djnz	X1243
	ld	b,28h
X1247:	djnz	X1247
	pop	bc
	djnz	X1240
	ret

X124d:	pop	hl
	xor	a
	ld	(X6005),a
	ld	sp,X63ff
	ld	iy,X6019
	ld	(X6017),iy
	ld	iy,X6000
	ld	ix,X601e
	jp	(hl)

X1266:	in	a,(11h)
	ld	b,a
	ld	a,(X600c)
	out	(13h),a
	ld	a,b
	out	(11h),a
	ret

X1272:	in	a,(14h)
	and	0f7h
	jr	X1282

X1278:	in	a,(14h)
	or	8
	jr	X1282

X127e:	in	a,(14h)
	or	1
X1282:	out	(14h),a
	ret

X1285:	in	a,(10h)
	bit	2,a
	ret	nz
	bit	0,a
	call	nz,X000b
	ret

X1290:	in	a,(10h)
	in	a,(13h)
	bit	6,a
	ret	z
	ld	b,40h
	out	(13h),a
	xor	a
	out	(10h),a
	ld	(iy+0),3
	ret

X12a3:	push	bc
	ld	a,6
	call	X0028
	call	X1278
	ld	bc,0
	ld	d,29h
X12b1:	call	X1285
	jr	nz,X12c1
	djnz	X12b1
	dec	c
	jr	nz,X12b1
	dec	d
	jr	nz,X12b1
	jp	X1473

X12c1:	call	X1272
	in	a,(12h)
	ld	c,a
	in	a,(13h)
	bit	6,a
	jp	z,X1473
	call	X1290
	ld	a,c
	pop	bc
	cp	b
	jp	nz,X1473
	jp	X14eb

X12da:	push	af
	ld	a,1
	out	(13h),a
	call	X1285
	jp	nz,X1467
	ld	a,b
	out	(13h),a
	pop	af
	out	(12h),a
	ret


sub6:	ld	a,1
	ld	b,80h
	push	af
	call	X127e
	pop	af
	jp	X12da

X12f8:	ld	(hl),a
	ld	a,4
	call	X0028
	push	bc
	bit	1,b
	call	nz,X127e
	ld	a,1
	out	(13h),a
	in	a,(10h)
	bit	2,a
	jr	nz,X132f
	set	4,(iy+5)
	call	X13ac
	xor	a
	out	(13h),a
	ld	b,(hl)
	inc	hl
X131a:	ld	c,12h
	otir
	pop	bc
	bit	0,b
	jr	z,X132e
	ld	b,0
	push	bc
	ld	b,1
	ld	a,80h
	out	(13h),a
	jr	X131a

X132e:	push	bc
X132f:	res	4,(iy+5)
	pop	bc
	call	X13a2
	call	X14eb
	ret

X133b:	pop	bc
	call	X13a2
	call	X000b
	jr	X132f

X1344:	push	bc
	push	de
	push	hl
	push	af
	ld	a,6
	call	X0028
	inc	hl
	pop	bc
	set	5,(iy+5)
X1353:	call	X13ac
	ld	c,12h
	xor	a
	ei
	inir
X135c:	di
	res	5,(iy+5)
	ld	c,a
	call	X1266
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
	ld	(X600a),a
	cp	40h
	call	X13a2
	jr	nz,X1384
	dec	de
	ld	a,(de)
	cp	10h
	jp	z,X0013
X1384:	call	X14eb
	pop	de
	pop	bc
	ret

X138a:	res	5,(iy+5)
	call	X13a2
	call	X000b
	dec	hl
	inc	b
	jr	X1353

X1398:	res	5,(iy+5)
	call	X13a2
	jp	X1473

X13a2:	ld	a,(X600c)
	out	(13h),a
	ld	a,0dh
	out	(11h),a
	ret

X13ac:	ld	a,40h
	out	(11h),a
	ld	a,80h
	out	(13h),a
	ld	a,40h
	out	(11h),a
	ret

X13b9:	ex	af,af'
	exx
	in	a,(13h)
	push	af
	bit	5,(iy+5)
	jp	nz,X1422
	in	a,(10h)
	push	af
	xor	a
	out	(13h),a
	ld	a,0dh
	out	(11h),a
	ld	bc,0
	ld	d,26h
X13d4:	in	a,(10h)
	bit	3,a
	jr	nz,X13f5
	bit	0,a
	jr	nz,X140e
	bit	2,a
	jr	nz,X1413
	in	a,(13h)
	bit	2,a
	jr	z,X1416
	djnz	X13d4
	dec	c
	jr	nz,X13d4
	dec	d
	jr	nz,X13d4
X13f0:	ld	hl,X1398
	jr	X1419

X13f5:	pop	af
	out	(10h),a
	call	X13ac
	pop	af
	ex	af,af'
	ex	(sp),hl
	jr	nz,X1402
	dec	hl
	dec	hl
X1402:	exx
	dec	hl
	inc	b
	exx
	ex	af,af'
X1407:	ex	(sp),hl
	out	(13h),a
	ex	af,af'
	exx
	retn

X140e:	ld	hl,X133b
	jr	X1419

X1413:	call	X1272
X1416:	ld	hl,X132f
X1419:	call	X1266
	pop	af
	out	(10h),a
	pop	af
	jr	X1407

X1422:	di
	in	a,(10h)
	push	af
	xor	a
	out	(13h),a
	ld	a,5
	out	(11h),a
	ld	bc,0
	ld	d,2dh
X1432:	in	a,(10h)
	bit	2,a
	jr	nz,X144c
	bit	0,a
	jr	nz,X144f
	in	a,(13h)
	bit	1,a
	jr	z,X13f0
	djnz	X1432
	dec	c
	jr	nz,X1432
	dec	d
	jr	nz,X1432
	jr	X13f0

X144c:	ei
	jr	X13f5

X144f:	ld	hl,X138a
	jp	X1419

X1455:	xor	a
	bit	0,(iy+9)
	jr	z,X145e
	ld	a,80h
X145e:	ld	hl,X604d
	jp	X1344

X1464:	call	sub6
X1467:	call	X124d
	call	X154c
	call	X1278
	jp	X0003

X1473:	call	X14c1
	jr	nz,X1464
	ld	a,0ah
	jr	X149e

X147c:	ld	a,1
	jr	X149e

X1480:	set	4,(ix+6)
	set	7,(ix+6)
	jr	X1498

X148a:	set	4,(ix+6)
	jr	X149c

X1490:	set	2,(ix+6)
	set	7,(ix+6)
X1498:	ld	a,1fh
	jr	X149e

X149c:	ld	a,13h
X149e:	call	sub7
	jr	X1464


sub7:	call	sub8
	ld	a,(X6000)
	cp	2
	ret	p
	ld	(iy+0),1
	ret

X14b1:	call	X154c
	ld	(X6000),a

sub8:	ld	(X6001),a
	ld	a,(X6003)
	ld	(X6002),a
	ret

X14c1:	ld	a,(X6000)
	or	a
	ret	z
	cp	3
	ret	nz
	ld	a,(X6001)
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
	ld	hl,(X6017)
	inc	hl
	ld	(hl),a
X14e2:	ld	(X6017),hl
	cpl
	out	(63h),a
	pop	hl
	pop	af
	ret

X14eb:	push	af
	call	sub9
	push	hl
	ld	hl,(X6017)
	dec	hl
	ld	a,(hl)
	jr	X14e2


sub9:	bit	0,(iy+5)
	ret	z
	inc	sp
	inc	sp
	pop	af
	ret


X1500:	ld	d,(ix+6)
	ld	e,(ix+5)
	ret

X1507:	push	bc
	ld	ix,X601e
	ld	c,0ah
	xor	a
	cp	b
	jr	z,X1518
X1512:	add	a,c
	djnz	X1512
	ld	c,a
	add	ix,bc
X1518:	pop	bc
	ret

X151a:	push	de
	ld	(X6003),a
	ld	(X6004),a
	ld	b,a
	call	X1507
	call	X1500
	ld	b,0
	bit	2,e
	jr	nz,X1536
	ld	b,1
	bit	4,e
	jr	nz,X1536
	ld	b,2
X1536:	ld	(iy+9),b
	ld	a,(ix+9)
	and	0fh
	bit	0,b
	jr	nz,X1544
	set	4,a
X1544:	ld	(ix+9),a
	call	X15fd
	pop	de
	ret

X154c:	in	a,(62h)
	bit	1,a
	jr	z,X1556
	set	7,(ix+9)
X1556:	ld	a,4
	ld	(X6004),a
	xor	a
	out	(66h),a
	ret

X155f:	ld	a,(X6006)
	and	0fh
	ret	z
	ld	c,a
	ld	b,4
	push	ix
X156a:	srl	c
	dec	b
	jp	m,X159c
	jr	nc,X156a
	ld	a,(X6004)
	cp	b
	jr	z,X156a
	call	X1507
	ld	a,(ix+8)
	sub	d
	ld	(ix+8),a
	jr	nc,X156a
	dec	(ix+7)
	jp	p,X156a
	call	X15d8
	ld	a,(X6004)
	cp	4
	jr	z,X1599
	pop	ix
	jp	sub12

X1599:	call	X154c
X159c:	pop	ix
	ret


do_rst20:
	ld	a,0ah
	rst	28h
	call	sub10
	ld	b,3ch
	call	z,X1240
	in	a,(62h)
	bit	4,a
	jp	nz,X14eb
	call	sub11
	jp	X148a


sub10:	bit	3,(ix+4)
	push	af
	set	3,(ix+4)
	call	sub12
	bit	5,(ix+4)
	jr	nz,X15d6
	ld	a,(X6006)
	or	(ix+9)
	ld	(X6006),a
	ld	(ix+7),18h
X15d6:	pop	af
	ret


X15d8:	call	X1507
	bit	5,(ix+4)
	jr	nz,X15e8

sub11:	res	3,(ix+4)
	call	sub12
X15e8:	ld	a,(ix+9)
	cpl
	and	(iy+6)
	ld	(X6006),a
	ret


sub12:	in	a,(62h)
	bit	1,a
	jr	z,X15fd
	set	7,(ix+9)
X15fd:	xor	a
	out	(66h),a
	ld	a,(ix+4)
	out	(65h),a
	ld	a,(ix+9)
	out	(66h),a

do_rst30:
	ld	a,(ix+4)
	and	0f7h
	out	(65h),a
	ret

X1612:	in	a,(62h)
	bit	1,a
	jr	nz,X162a
	bit	7,(ix+9)
	jr	nz,X162a
	bit	4,a
	jr	nz,X1635
X1622:	ld	a,3
	res	5,(ix+4)
	cp	a
	ret

X162a:	res	7,(ix+9)
	bit	4,a
	jr	z,X1622
X1632:	xor	a
	scf
	ret

X1635:	bit	1,(ix+6)
	jr	nz,X1632
	or	a
	scf
	ret

X163e:	push	hl
	ld	hl,X1657
	bit	0,(iy+9)
	jr	z,X1649
	inc	hl
X1649:	ld	a,b
	cp	(hl)
	jr	c,X1655
	inc	hl
	inc	hl
	cp	(hl)
	jr	z,X1655
	jr	nc,X1655
	xor	a
X1655:	pop	hl
	ret

X1657:	nop
	ld	bc,X1a1d
X165b:	ld	a,(ix+0)
	bit	0,(iy+9)
	jr	nz,X1670
	res	5,(ix+9)
	cp	37h
	jr	c,X1670
	set	5,(ix+9)
X1670:	res	4,(ix+4)
	cp	2bh
	jr	c,X167c
	set	4,(ix+4)
X167c:	rst	30h
	ld	a,(ix+9)
	out	(66h),a
	ret

X1683:	res	3,e
	in	a,(62h)
	bit	7,a
	ret	z
	set	3,e
	ret

X168d:	push	de
	ld	a,4
	call	X16fa
	jr	z,X16f5
	rst	8
	jr	z,X169d
	pop	de
	set	2,d
	jr	X16f8

X169d:	ld	(iy+0eh),5
X16a1:	ld	a,4
	call	X16fa
	jr	z,X16f5
	rst	18h
	ld	a,4
	jr	z,X16ef
	pop	de
	push	de
	bit	3,e
	jr	nz,X16c5
	ld	a,10h
	call	X16fa
	jr	z,X16f5
	rst	18h
	jr	nz,X16c5
	ld	(ix+3),1
	ld	a,10h
	jr	X16ef

X16c5:	dec	(iy+0eh)
	ld	a,2
	jr	z,X16ef
	bit	3,e
	jr	z,X16e5
	bit	7,(ix+4)
	set	7,(ix+4)
	jr	z,X16de
	res	7,(ix+4)
X16de:	rst	30h
	bit	7,(ix+4)
	jr	nz,X16a1
X16e5:	ld	c,0
	call	X001b
	inc	(ix+0)
	jr	X16a1

X16ef:	pop	de
	push	af
	or	e
	ld	e,a
	pop	af
	ret

X16f5:	pop	de
	set	4,d
X16f8:	inc	a
	ret

X16fa:	ld	(ix+5),a
	call	X154c
	ld	a,(X6003)
	call	X151a
	call	sub10
	in	a,(62h)
	bit	4,a
	ret	nz
	ret	z


	fillto	1720h, 076h

doreset:
	jr	X1724

X1722:	jr	X1733

X1724:	xor	a
	ld	d,a
	out	(63h),a
	set	7,a
	out	(67h),a
	in	a,(63h)
	and	8
	ld	e,a
	set	4,e
X1733:	di
	ld	a,8
	out	(62h),a
	xor	a
	out	(64h),a
	ld	sp,X63ff
	jp	X17e3

X1741:	ld	iy,X6000
	bit	6,(iy+15h)
	jr	nz,X1784
	ld	b,0
X174d:	call	X1507
	push	bc
	inc	b
	ld	a,10h
X1754:	rrca
	djnz	X1754
	ld	(ix+9),a
	push	af
	out	(66h),a
	rst	8
	jr	z,X1769
	pop	af
	or	(iy+46h)
	ld	(X6046),a
	jr	X1777

X1769:	ld	c,0
	call	X001b
	call	X17ad
	ld	b,4
	call	X1c15
	pop	af
X1777:	pop	bc
	inc	b
	bit	2,b
	jr	z,X174d
	xor	a
	out	(66h),a
	set	6,(iy+13h)
X1784:	ld	bc,X17b2
	ld	(X6015),bc
	ld	hl,X6005
	set	0,(hl)
X1790:	ld	iy,(X6015)
	ld	l,(iy+0)
	inc	iy
	ld	h,(iy+0)
	inc	iy
	ld	(X6015),iy
	ld	iy,X6000
	ld	bc,X17ab
	push	bc
	jp	(hl)

X17ab:	jr	X1790

X17ad:	ld	b,14h
	jp	X1240

X17b2:	dec	hl
	ld	a,(de)
	ld	l,h
	ld	a,(de)
	sub	(hl)
	ld	a,(de)
	cp	a
	ld	a,(de)
	ld	c,l
	dec	de
X17bc:	and	l
	dec	de
	jr	nz,X17dc
	ld	(hl),h
	inc	e
	xor	e
	inc	e
	exx
	inc	e
X17c6:	ex	(sp),hl
	dec	e
X17c8:	sbc	a,h
	ld	e,0f3h
	ld	e,0d9h
	ld	e,38h
	rla

sub13:	ld	b,a
	ld	(X6007),bc
	cpl
	out	(67h),a
	ld	a,c
	cpl
	out	(63h),a
X17dc:	ret


X17dd:	ld	bc,(X6007)
	ld	a,b
	ret

X17e3:	ld	a,0c0h
	out	(63h),a
	ld	a,0ffh
	out	(67h),a
	ld	a,0
	add	a,a
	jr	z,X17f2
X17f0:	jr	X17f0

X17f2:	jr	nz,X17f2
	add	a,0fh
	jp	p,X17fb
X17f9:	jr	X17f9

X17fb:	jp	m,X17fb
	cp	0eh
X1800:	jp	m,X1800
	cp	0fh
X1805:	jr	nz,X1805
X1807:	cp	10h
X1809:	jp	p,X1809
	sub	10h
	jp	m,X1813
X1811:	jr	X1811

X1813:	jp	p,X1813
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
	jr	c,X1846
X1844:	jr	X1844

X1846:	jr	nc,X1846
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
X1856:	jr	nz,X1856
	bit	6,h
X185a:	jr	z,X185a
	ld	d,b
	ld	e,c
	ld	hl,startup1
	jp	(hl)

X1862:	jr	X1862


startup1:
	ld	a,0a0h
	out	(63h),a
	ld	a,0ffh
	out	(67h),a
	ld	b,0a5h
	push	bc
	pop	af
	cp	b
X1871:	jr	nz,X1871
	xor	a
	ld	hl,X63fe
	ld	a,(hl)
	cp	b
X1879:	jr	nz,X1879
	ld	ix,X63fe
	ld	iy,X63fc
	cp	(ix+0)
X1886:	jr	nz,X1886
	cp	(iy+2)
X188b:	jr	nz,X188b
	call	sub14
X1890:	jr	X1890

	jp	X18a4


sub14:	ld	bc,X1890
	ld	a,(hl)
	cp	b
X189a:	jr	nz,X189a
	dec	hl
	ld	a,(hl)
	cp	c
X189f:	jr	nz,X189f
	inc	(hl)
	inc	(hl)
	ret

X18a4:	ld	a,0fch
	out	(63h),a
	ld	a,0ffh
	out	(67h),a

romcsum:
	ld	ix,X1ffe-1
	ld	bc,X1ffe
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
	ld	a,(X1ffe)
	cp	l
romcsum_fail_l:
	jr	nz,romcsum_fail_l
	ld	a,(X1fff)
	cp	h
romcsum_fail_h:
	jr	nz,romcsum_fail_h
	pop	de

ramtest:
	ld	hl,X6000
	ld	bc,0400h
X18d8:	ld	a,l
	add	a,h
	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,X18d8
	djnz	X18d8
	ld	hl,X6000
	ld	bc,0400h
X18e7:	ld	a,l
	add	a,h
	cp	(hl)
	jr	nz,X1942
	inc	hl
	dec	c
	jr	nz,X18e7
	djnz	X18e7
	ld	iy,X194c
X18f6:	ld	a,(iy+0)
	call	sub15
	inc	iy
	or	a
	jr	nz,X18f6
	ld	(X6013),de
	jr	X1950


sub15:	pop	ix
	ld	bc,0400h
	ld	hl,X6000
X190f:	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,X190f
	djnz	X190f
	ld	bc,0400h
	ld	hl,X6000
X191c:	ld	a,(hl)
	cp	(iy+0)
	jr	nz,X192b
	inc	hl
	dec	c
	jr	nz,X191c
	djnz	X191c
	push	ix
	ret

X192b:	and	0f0h
	ld	c,a
	ld	a,(iy+0)
	and	0f0h
	cp	c
	ld	a,0f4h
	jr	nz,X193a
	ld	a,0f2h
X193a:	out	(63h),a
	ld	a,0ffh
	out	(67h),a
X1940:	jr	X1940

X1942:	ld	a,0f6h
	out	(63h),a
	ld	a,0ffh
	out	(67h),a
X194a:	jr	X194a

X194c:	rst	38h
	and	l
	ld	e,d
	nop
X1950:	ld	a,0
	ld	c,0fh
	call	sub13
	xor	a
	out	(13h),a
	ld	a,80h
	out	(14h),a
	out	(14h),a
	ld	a,0
	out	(16h),a
	ld	a,81h
	out	(17h),a
	xor	a
	out	(13h),a
	ld	a,7fh
	out	(11h),a
	xor	a
	out	(13h),a
	ld	a,20h
	out	(15h),a
	ld	a,41h
	out	(10h),a
X197a:	in	a,(10h)
	bit	2,a
	jr	z,X1984
	in	a,(12h)
	jr	X197a

X1984:	ld	a,1
	out	(13h),a
	ld	a,10h
	out	(14h),a
	ld	a,89h
	out	(14h),a
	ld	d,0ah
	ld	c,0
	call	sub16
	ld	a,40h
	out	(13h),a
	ld	a,5fh
	out	(12h),a
	ld	a,7eh
	out	(12h),a
	ld	a,0c0h
	out	(13h),a
	ld	a,2
	out	(12h),a
	ld	b,1
	call	X1240
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
	out	(13h),a
	out	(15h),a
	ld	a,40h
	out	(13h),a
	ld	a,3fh
	out	(12h),a
	ld	a,49h
	out	(12h),a
	ld	a,9
	out	(12h),a
	call	sub16
	xor	a
	out	(13h),a
	ld	a,40h
	out	(15h),a
	ld	a,60h
	out	(15h),a
	ld	a,0ffh
	ld	b,10h
X19f1:	out	(12h),a
	dec	a
	djnz	X19f1
	ld	c,0
	ld	d,4
	call	sub16
	ld	c,0
	ld	d,0ffh
	ld	b,10h
X1a03:	call	sub17
	dec	d
	djnz	X1a03
	ld	c,0
	ld	d,0ah
	call	sub16
	xor	a
	out	(13h),a
	ld	a,81h
	out	(14h),a
	jp	X1741


sub16:	in	a,(10h)
	jr	X1a20

sub17:	in	a,(12h)
X1a20:	cp	d
X1a21:	jr	nz,X1a21
	in	a,(13h)
	and	0c0h
	cp	c
X1a28:	jr	nz,X1a28
	ret

	ld	a,0
	ld	c,11h
	call	sub13
	ld	a,(X6013)
	and	3
	jr	nz,X1a3d
	set	1,(iy+13h)
X1a3d:	ld	b,0fah
	ld	a,1
	out	(62h),a
	call	X1240
	out	(62h),a
	call	X1240
	out	(62h),a
	call	X1240
	ld	b,64h
	call	X1240
	in	a,(63h)
	bit	6,a
	jp	nz,X1f3d
	call	X1240
	ld	b,0fah
	call	X1240
	in	a,(63h)
	bit	6,a
	jp	z,X1f3e
	ret

	ld	a,0
	ld	c,11h
	call	sub13
	xor	a
	out	(66h),a
	ld	a,4
	out	(64h),a
	out	(60h),a
	ld	a,2
	out	(62h),a
	in	a,(62h)
	bit	6,a
	jp	nz,X1f3f
	ld	b,0ah
X1a89:	djnz	X1a89
	in	a,(62h)
	bit	6,a
	jp	z,X1f40
	xor	a
	out	(64h),a
	ret

	ld	a,1
	out	(62h),a
	ld	a,0
	ld	c,13h
	call	sub13
	ld	a,6
	out	(64h),a
	ld	a,0e7h
	out	(61h),a
	ld	a,0cah
	out	(60h),a
	in	a,(60h)
	cp	0cah
	jp	nz,X1f3d
	in	a,(61h)
	cp	0e7h
	jp	nz,X1f3e
	xor	a
	out	(64h),a
	ret

	ld	a,1
	out	(62h),a
	ld	a,0
	ld	c,13h
	call	sub13
	ld	a,10h
	out	(66h),a
	ld	l,0
	call	X1af3
	jr	nz,X1ae6
	ld	a,l
	cp	28h
	jp	nz,X1f40
	ld	l,38h
	call	X1af3
	jr	nz,X1ae6
	xor	a
	out	(64h),a
	ret

X1ae6:	bit	3,a
	jp	nz,X1f41
	bit	2,a
	jp	nz,X1f42
	jp	X1f3f

X1af3:	xor	a
	out	(64h),a
	out	(61h),a
	ld	a,6
	out	(64h),a
	ld	a,0cch
	out	(60h),a
	ld	b,2
	ld	c,60h
	ld	d,0ffh
	ld	e,50h
X1b08:	out	(c),d
	djnz	X1b08
	ld	a,26h
	out	(64h),a
	out	(c),d
	out	(c),d
	in	a,(63h)
	and	80h
	jr	nz,X1b41
	ld	a,l
	out	(61h),a
	out	(c),e
	in	a,(63h)
	in	b,(c)
	ld	h,a
	in	a,(61h)
	ld	l,a
	xor	a
	out	(61h),a
	out	(c),e
	bit	7,h
	jr	z,X1b45
	ld	a,b
	cp	43h
	jr	nz,X1b49
	out	(c),e
	ld	a,6
	out	(64h),a
	xor	a
X1b3c:	and	0ffh
	out	(c),e
	ret

X1b41:	ld	a,8
	jr	X1b3c

X1b45:	ld	a,4
	jr	X1b3c

X1b49:	ld	a,1
	jr	X1b3c

	ld	a,1
	out	(62h),a
	ld	a,0
	ld	c,15h
	call	sub13
	xor	a
	out	(66h),a
	ld	a,4
	out	(64h),a
	out	(60h),a
	ld	a,24h
	out	(64h),a
	ld	a,5ch
	out	(60h),a
	in	a,(62h)
	bit	5,a
	jp	z,X1f3d
	ld	a,56h
	out	(60h),a
	ld	a,36h
	out	(64h),a
	in	a,(60h)
	in	a,(60h)
	cp	6ch
	jp	nz,X1f3e
	in	a,(60h)
	cp	0eeh
	jp	nz,X1f3e
	in	a,(62h)
	bit	5,a
	jp	nz,X1f3f
	xor	a
	out	(64h),a
	ld	a,(X6013)
	dec	a
	ld	(X6013),a
	and	3
	jr	nz,X1b9e
	ret

X1b9e:	ld	hl,X17b2
	ld	(X6015),hl
	ret

	ld	a,(X6003)
	call	X151a
	ld	a,(X6003)
	rlca
	rlca
	rlca
	rlca
	ld	c,17h
	call	sub13
	ld	a,(X6046)
	and	(ix+9)
	jr	z,X1bc6
	ld	hl,X17c8
	ld	(X6015),hl
	ret

X1bc6:	set	5,(iy+13h)
	bit	4,(iy+13h)
	jr	z,X1bd5
	ld	a,(X6014)
	or	a
	ret	nz
X1bd5:	rst	8
	jp	nz,X1f40
	call	sub10
	ld	c,0
	ld	b,4ch
	call	X1c15
	jp	nz,X1f41
	call	X17ad
	dec	c
	ld	b,4bh
	call	X1c15
	jp	nz,X1f42
	ld	b,1
	call	X1c15
	jp	z,X1f43
	bit	4,(iy+13h)
	ret	nz
	xor	a
	ld	c,a
	ld	b,(iy+14h)
	ld	(ix+0),b
	cp	b
	ret	z
	push	bc
	call	X17ad
	pop	bc
	call	X1c15
	jp	nz,X1f41
	ret	z
X1c15:	call	X001b
	in	a,(62h)
	bit	2,a
	ret	nz
	djnz	X1c15
	ret

	ld	a,(X6008)
	ld	c,19h
	call	sub13
	in	a,(62h)
	bit	4,a
	ret	z
	xor	a
	ld	c,62h
	call	X1c49
	jp	z,X1f3d
	call	X1c49
	ld	bc,031e8h
	ld	de,02e87h
	call	X1c64
	ret	z
	jp	m,X1f3e
	jp	p,X1f3f
X1c49:	ld	l,a
	ld	h,a
X1c4b:	inc	hl
	cp	l
	jr	nz,X1c51
	cp	h
	ret	z
X1c51:	in	b,(c)
	bit	0,b
	jr	nz,X1c4b
X1c57:	inc	hl
	cp	l
	jr	nz,X1c5d
	cp	h
	ret	z
X1c5d:	in	b,(c)
	bit	0,b
	jr	z,X1c57
	ret

X1c64:	push	hl
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

	ld	a,(X6008)
	ld	c,1bh
	call	sub13
	bit	3,(iy+13h)
	jr	nz,X1c89
	ld	hl,X17c6
	ld	(X6015),hl
	ret

X1c89:	in	a,(62h)
	bit	4,a
	jp	z,X1f3e
	bit	3,a
	jp	nz,X1f3f
	bit	4,(iy+13h)
	ret	z
	ld	a,(X6014)
	and	7fh
	ld	(ix+0),a
	ret	z
	ld	c,1
	call	X001b
	jp	X17ad

	ld	a,(X6008)
	ld	c,1bh
	call	sub13
	call	X1d64
	call	X1d47
	call	X0060
	jp	nz,X1f3d
	ld	a,(X6008)
	ld	c,1dh
	call	sub13
	ld	c,40h
	ld	b,1
X1ccb:	call	X1d98
	call	X1cd4
	jr	nz,X1ccb
	ret

X1cd4:	inc	b
	ld	a,b
	cp	1bh
	ret

	ld	a,(X6008)
	set	3,a
	ld	c,1bh
	call	sub13
	call	X1d64
	call	X1d37
	call	X005d
	jp	nz,X1f3d
	ld	e,(ix+5)
	ld	d,(ix+6)
	call	X1683
	jr	z,X1d12
	call	X1d6e
	set	3,(ix+5)
	call	X17dd
	set	6,a
	call	sub13
	call	X1d37
	call	X005d
	jp	nz,X1f3d
X1d12:	ld	h,0
	call	X1d78
X1d17:	call	X1d98
	call	X1d32
	jr	nz,X1d17
	ld	h,40h
	call	X1d78
	ret	z
X1d25:	call	X1d98
	call	X1d32
	jr	nz,X1d25
	res	7,(iy+14h)
	ret

X1d32:	inc	b
	ld	a,b
	cp	1eh
	ret

X1d37:	ld	a,(ix+5)
	and	0edh
	set	2,a
	ld	(ix+5),a
	ld	e,70h
	ld	d,0c6h
	jr	X1d53

X1d47:	ld	a,(ix+5)
	and	0f9h
	set	4,a
	ld	(ix+5),a
	ld	d,40h
X1d53:	ld	a,(X6003)
	call	X151a
	ld	b,1
	ld	a,(X6014)
	ld	c,a
	xor	a
	ld	(X6012),a
	ret

X1d64:	res	7,(ix+4)
	res	7,(iy+14h)
	jr	X1d76

X1d6e:	set	7,(ix+4)
	set	7,(iy+14h)
X1d76:	rst	30h
	ret

X1d78:	ld	a,(X6008)
	res	6,a
	or	h
	ld	c,1dh
	call	sub13
	ld	b,0
	ld	c,0c6h
	bit	6,h
	jr	nz,X1d8e
	jp	X1d64

X1d8e:	bit	3,(ix+5)
	ret	z
	call	X1d6e
	or	a
	ret

X1d98:	ld	(ix+3),b
	ld	a,(X6014)
	ld	(ix+2),a
	ld	hl,Xf07f
	in	a,(63h)
	bit	3,a
	jr	z,X1dae
	set	2,(ix+4)
X1dae:	push	bc
	call	X002b
	pop	bc
	ld	a,e
	and	l
	ld	e,a
	pop	hl
	bit	4,e
	jp	nz,X1f3d
	bit	3,e
	jr	nz,X1dcd
	bit	0,e
	jp	z,X1f3e
	bit	0,d
	jp	z,X1f3f
	jp	X1f40

X1dcd:	bit	1,e
	jp	nz,X1f41
	bit	5,e
	jr	z,X1de0
	bit	2,(ix+4)
	jp	nz,X1f45
	jp	X1f42

X1de0:	jp	X1fcb

	bit	3,(iy+13h)
	ret	nz
	in	a,(63h)
	bit	4,a
	ret	z
	ld	a,(X6008)
	res	6,a
	set	1,a
	ld	c,1dh
	call	sub13
	in	a,(62h)
	bit	4,a
	jp	z,X1f40
	xor	a
	cp	(ix+5)
	jr	nz,X1e17
	ld	d,a
	ld	e,a
	call	X1683
	call	X168d
	jp	nz,X1f3d
	ld	(ix+5),e
	ld	(ix+6),d
X1e17:	bit	1,(ix+5)
	jp	nz,X1f3e
	ld	a,(X6003)
	call	X151a
	res	7,(iy+14h)
	call	X1e95
	call	X006a
	jr	z,X1e36
X1e30:	jp	nc,X1f3f
	jp	c,X1f3d
X1e36:	bit	0,(iy+9)
	jr	nz,X1e80
	call	X17dd
	set	3,a
	and	0bdh
	call	sub13
	ld	b,0
X1e48:	call	X1d98
	call	X1d32
	jr	nz,X1e48
	bit	3,(ix+5)
	ret	z
	call	X17dd
	or	42h
	call	sub13
	set	7,(iy+14h)
	call	X1e95
	call	X006a
	jr	nz,X1e30
	call	X17dd
	res	1,a
	call	sub13
	ld	b,0
X1e73:	call	X1d98
	call	X1d32
	jr	nz,X1e73
	res	7,(iy+14h)
	ret

X1e80:	call	X17dd
	res	3,a
	and	0bdh
	call	sub13
	ld	b,1
X1e8c:	call	X1d98
	call	X1cd4
	jr	nz,X1e8c
	ret

X1e95:	ld	a,(X6014)
	ld	(ix+2),a
	ret

	call	X1556
	xor	a
	out	(64h),a
	ld	hl,X6003
	inc	(hl)
	ld	a,4
	sub	(hl)
	jr	nz,X1eb5
	ld	(hl),a
	ld	(X6008),a
	bit	5,(iy+13h)
	jr	nz,X1ec3
X1eb5:	ld	hl,X17bc
	jr	nz,X1ebc
	inc	hl
	inc	hl
X1ebc:	ld	(X6015),hl
	ret	nz
	jp	X1f44

X1ec3:	ld	hl,X6014
	res	7,(hl)
	inc	(hl)
	ld	a,4dh
	sub	(hl)
	jr	z,X1ed7
	res	5,(iy+13h)
	set	7,(iy+13h)
	ret

X1ed7:	ld	(hl),a
	ret

	pop	bc
	ld	de,(X6007)
	xor	a
	ld	bc,0400h
	ld	hl,X6000
X1ee5:	ld	(hl),a
	inc	hl
	dec	c
	jr	nz,X1ee5
	djnz	X1ee5
	ld	(X6007),de
	jp	X0070

	xor	a
	out	(64h),a
	ld	(X6007),a
	ld	(X6008),a
	cpl
	out	(67h),a
	res	0,a
	out	(63h),a
	bit	4,(iy+13h)
	ret	z
	in	a,(63h)
	bit	5,a
	jr	nz,X1f19
	bit	4,a
	ret	z
	ld	b,0fah
	call	X1240
	call	X1240
X1f19:	ld	b,a
	ld	a,(X6014)
	or	a
	jr	z,X1f2a
	bit	3,(iy+13h)
	jr	nz,X1f36
	bit	4,b
	jr	nz,X1f36
X1f2a:	ld	d,0
	ld	e,(iy+13h)
	inc	(iy+15h)
	inc	(iy+15h)
	ret

X1f36:	ld	hl,X17bc
	ld	(X6015),hl
	ret

X1f3d:	inc	sp
X1f3e:	inc	sp
X1f3f:	inc	sp
X1f40:	inc	sp
X1f41:	inc	sp
X1f42:	inc	sp
X1f43:	inc	sp
X1f44:	inc	sp
X1f45:	ld	hl,X6405
	scf
	ccf
	sbc	hl,sp
	ld	sp,X63fd
	ld	b,5
X1f51:	sla	l
	djnz	X1f51
	ld	a,(X6008)
	adc	a,b
	set	7,a
	push	af
	ld	a,(X6007)
	or	l
	ld	c,a
	pop	af
	call	sub13
	xor	a
	out	(64h),a
	bit	4,(iy+13h)
	jr	z,X1fc4
	in	a,(63h)
	bit	4,a
	jr	z,X1fa0
	bit	5,a
	jr	z,X1f90
	ld	b,0c8h
	call	X1240
	ld	a,(X6008)
	and	30h
	ld	(X6008),a
	res	7,(iy+14h)
	dec	(iy+15h)
	dec	(iy+15h)
	ret

X1f90:	call	X1556
X1f93:	ld	d,20h
	call	X155f
	in	a,(63h)
	bit	4,a
	jr	nz,X1f93
	jr	X1fc4

X1fa0:	call	X1556
	ld	a,0ceh
X1fa5:	push	af
	ld	d,80h
	call	X155f
	ld	b,64h
	call	X1240
	pop	af
	dec	a
	jr	nz,X1fa5
	in	a,(63h)
	bit	5,a
	jr	z,X1fc4
	xor	a
	ld	d,a
	ld	e,(iy+13h)
	ld	hl,X17ce
	jr	X1fc7

X1fc4:	ld	hl,X17cc
X1fc7:	ld	(X6015),hl
	ret

X1fcb:	bit	6,e
	jp	nz,X1f43
	ld	a,(X6013)
	bit	3,a
	jr	z,X1fde
	ld	a,(X604e)
	cp	c
	jp	nz,X1f44
X1fde:	res	2,(ix+4)
	jp	(hl)

	fillto	01ffeh, 076h

X1ffe:	or	b
X1fff:	cp	0ffh


X0064	equ	64h
X17cc	equ	17cch
X17ce	equ	17ceh
X1a1d	equ	1a1dh
X6000	equ	6000h
X6001	equ	6001h
X6002	equ	6002h
X6003	equ	6003h
X6004	equ	6004h
X6005	equ	6005h
X6006	equ	6006h
X6007	equ	6007h
X6008	equ	6008h
X6009	equ	6009h
X600a	equ	600ah
X600b	equ	600bh
X600c	equ	600ch
X600d	equ	600dh
X600e	equ	600eh
X600f	equ	600fh
X6010	equ	6010h
X6011	equ	6011h
X6012	equ	6012h
X6013	equ	6013h
X6014	equ	6014h
X6015	equ	6015h
X6017	equ	6017h
X6019	equ	6019h
X601e	equ	601eh
X6046	equ	6046h
X6047	equ	6047h
X6048	equ	6048h
X6049	equ	6049h
X604a	equ	604ah
X604d	equ	604dh
X604e	equ	604eh
X604f	equ	604fh
X6050	equ	6050h
X606b	equ	606bh
X6074	equ	6074h
X60b4	equ	60b4h
X60bb	equ	60bbh
X63fc	equ	63fch
X63fd	equ	63fdh
X63fe	equ	63feh
X63ff	equ	63ffh
X6405	equ	6405h
Xf053	equ	0f053h
Xf057	equ	0f057h
Xf073	equ	0f073h
Xf07f	equ	0f07fh

	end

