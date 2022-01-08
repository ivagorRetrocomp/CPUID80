;CPUID for 8080/8085/z80 and compatibles
;Version 1.6
;Ivan Gorodetsky 20.01.2014, 08.01.2022
;
;Usage:
;CPUID16	- without port 01 writing/reading
;CPUID16 /P	- with port 01 writing/reading for detection of CMOS/NMOS Z80 or U880 and clones
;
;Used some code and ideas from
; Ermolaev Sergey (SES)
; Perlin Vitaly (PPC)
; Slavinsky Vjacheslav (svofski)
;
;Compile with The Telemark Assembler (TASM) 3.2


		.org 100h

		lxi	h, 80h
		xra	a
		ora	m
		jz	SkipP
		inx	h
		inx	h
		mvi	a,'/'
		cmp	m
		jnz	SkipP
		inx	h
		mov	a, m
		cpi	'P'
		jz	UseP
		cpi	'p'
		jnz	SkipP
UseP:
		xra a
		sta SetRet
SkipP:
		lxi 	d, msg_cpu
		mvi 	c, 9
		call 	5
		call 	cpudetect
		mvi	c, 9
		call 	5
		jmp 0
msg_cpu		.db	"CPU: $"
msg_z80		.db	"Z80$"
msg_cmosz80	.db	"CMOS Z80$"
msg_nmosz80	.db	"NMOS Z80$"
msg_u880	.db	"U880 OR RUSSIAN/UKRAINIAN CLONE$"
msg_r800	.db	"R800$"
msg_i8080	.db	"I8080$"
msg_amd8080	.db	"AMD8080$"
msg_8085	.db	"8085$"
msg_vm1		.db	"580VM1$"
cpudetect:	sub	a
		jpo	difz80
		push	psw
		pop	h
		mov	e, l
		mvi	a, 00100010b
		xra	l
		mov	l, a
		push	h
		pop	psw
		push	psw
		pop	h
		mov	a,l
		xra	e
		jz	dif8080
		lxi	d, msg_8085
		rpe
		lxi	d, msg_vm1
		ret
dif8080:
		ani	00001000b
		daa
		lxi	d, msg_amd8080
		rz
		lxi	d, msg_i8080
		ret

difz80:
		mvi	e,1
		mov	l,e
		.db 0EDh,0D9h	;mulub a,e for r800 / nop for z80
		ora	l
		lxi	d, msg_r800
		rz
		lxi d, msg_z80
SetRet:
		ret
		lxi b,1
		.db 0EDh,71h	;out (c),0 for NMOS Z80 / out (c),255 for CMOS Z80
		in 1
		ani 1111b
		lxi d,msg_cmosz80
		mvi a,0
		out 1
		rnz
		lxi h,200h
		mvi m,255
		xra a
		.db 0EDh,0A3h	;outi
		lxi d, msg_nmosz80
		rc
		lxi d, msg_u880
		ret

		.end
