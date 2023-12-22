curspos macro a,b
	mov dh,a
	mov dl,b 
	mov ah,02
	mov bh,0
	int 10h
endm 
p1 macro f1 ; B���� ��������� �� �����
	push ax
	push dx
	mov dx,offset f1
	mov ah,9
	int 21h
	pop dx
	pop ax
endm

p2 macro f2 ; ���� ������ ��������
	push ax
	push dx
	mov dx,offset f2
	mov ah,0ah
	int 21h
	pop dx
	pop ax
endm
draw_window macro attr_value, wup_str_value, wup_col_value, wdn_str_value, wdn_col_value
    mov ax, 0600h
    mov bh, attr_value
    mov ch, wup_str_value
    mov cl, wup_col_value
    mov dh, wdn_str_value
    mov dl, wdn_col_value
    int 10h
endm
idraw macro a,b,c ;��������� ���� � ��������
IFB <c>
	mov ax,0600h 
	mov cx,a
	mov dx,b	
	int 10h			
ELSE
	mov ax,0600h 
	mov cx,a
	mov dx,b
	mov bh,c	
	int 10h	
ENDIF
endm 


mul_neg macro value
    mov ax, value
    imul ax
	jo overflow	
    mov value, ax
endm

;>>>>>>>>>>>>>>>>>>������� ������<<<<<<<<<<<<<<<<<<<

d1 segment para public 'data'
wup_col db 0,2,4,6,8,10,12,14,16,1,21,42,63 ; ���������� �������� ������
wup_str db 0,3,2,9,8,10,9,18,17,24,24,24,24
wdn_col db 79,78,77,76,75,74,73,72,71,19,40,61,78 ; ���������� �������� ������
wdn_str db 23,6,5,15,14,14,14,21,20,24,24,24,24
attr db 20h,1,3eh,1,8ah,1,3eh,0ech,0ech,0ech,0bch,0bch,0bch ; ���������� �������� ������ � ���������
curs_str db 3,9,9,24,24,24,24
curs_col db 17,15,56,3,26,46,62
text1 db 'Enter 5 numbers in [-29999,29999]$'
text2 db 'Input: $'
text3 db 'Result: $'
text4 db 'F1-break my heart $'
text5 db 'F2-ilka$'
text6 db 'F3-exit $'
text7 db 'Break me complet! $'
text8 db 'What is pokemon? $'
text9 db 'F5-Light? $'
perevod db 10,13,'$'
mess3        db '               $'
messok db 'Okey! $'
text_err1 db 'Input Error!','$'
messovf db 'Overflow!','$' ;��������� � ������������

inp_str db 10,11,12,13,14
inp_col db 15,15,15,15,15

output_str db 10,11,12,13,14 ; ���������
output_col db 56

output_strh db 24;HNY
output_colh db 64 

err_str db 19 ;  ������
err_col db 19 ;



in_str label byte 	; ������ �������� (�� ����� 6)
razmer db 7
kol db (?)
stroka db 7 dup (?) ; ���� ����� (��� �������������), 5 ����, enter
	
number dw 5 dup (0)   ; ������ �����
siz dw 5              ; ���������� �����
out_str db 6 dup (' '),'$' ; �������� ������
flag_err equ 1

d1 ends

;>>>>>>>>>>>>>>>>>>������� ����<<<<<<<<<<<<<<<<<<<



c1 segment para public 'code'
assume cs:c1,ds:d1,ss:st1

start: mov ax,d1
	   mov ds,ax
;�������� ���������� (����)

;*****************
	xor si, si
	mov cx,13; ���������� ����
round_1:push cx
	draw_window attr+si, wup_str+si, wup_col+si, wdn_str+si, wdn_col+si
	inc si
	pop cx
	loop round_1
;********************
	xor si,si
	curspos curs_str+si, curs_col+si
	p1 text1
	inc si 
	curspos curs_str+si, curs_col+si
	p1 text2
	inc si
	curspos curs_str+si, curs_col+si
	p1 text3
	inc si
	curspos curs_str+si, curs_col+si
	p1 text4
	inc si
	curspos curs_str+si, curs_col+si
	p1 text5
	inc si
	curspos curs_str+si, curs_col+si
	p1 text6
	inc si
	curspos curs_str+si, curs_col+si
	p1 text8
	dec si

	
	xor di,di  ;���� �����, di - ����� ����� � �������
    mov cx, siz ; � cx - ������ �������
	xor si,si
	curspos inp_str, inp_col

input:	push cx
	

m1:	p2 in_str
	p1 perevod
	p1 mess3

	call diapazon ;�������� ��������� �������� ����� (-29999,+29999)
	cmp bh,flag_err  ;������� bh � flag_err
	je err1          ;���� ����� -��������� �� ������ �����

	call dopust ;�������� ������������ �������� ��������
	cmp bh,flag_err
	je err1
	
	call AscToBin ;�������������� ������ � �����

	inc di
	inc di
	pop cx

	loop input
	jmp m2

err1:   curspos err_str, err_col
	p1 text_err1	
	jmp exit


;>>>>>>>>>>>>>>>>>>�������������� ���������<<<<<<<<<<<<<<<<<<<


m2: mov cx, siz  ; � (cx) - ������ �������
    mov si, offset number

multiply_negatives:
    mov ax, [si]
    cmp ax, 0
    jl multiply_negative
    inc si
    inc si
    loop multiply_negatives
    jmp continue_processing

start1:
jmp start

multiply_negative:
    ; �������� ������������� ����� �� ����
    mul_neg [si]
    inc si
    inc si
    loop multiply_negatives


continue_processing:
	mov di, offset number
    mov cx, 5
    lea dx, [out_str]
    mov si, 0

print_num_loop:  ; ����� ������� �� �����
		curspos output_str, output_col
        mov ax, [di]
        call BinToAsc
        p1 out_str
		mov ah,0
		int 16h
        add di, 2
		add output_str, 1
        inc si
		inc si
		xor si,si
clear:	mov [out_str+si],' '
		inc si
		mov [out_str+si],' '
		inc si
		mov [out_str+si],' '
		inc si
		mov [out_str+si],' '
		inc si
		mov [out_str+si],' '
		inc si
		mov [out_str+si],' '
		inc si
        loop print_num_loop
		add output_str, -5
		jmp menu

overflow:	
		curspos err_str, err_col
		p1 messovf
		mov ah, 07h
		int 21h
		jmp menu

exit:	
	mov ax,4c00h
	int 21h

restart:
		mov di, offset number ; ����� ������ �������
		mov cx, 5            ; ���������� ��������� � �������

; ������� ������� (���������� ������� ��������)
	clear_array:
		mov word ptr [di], 0 ; ���������� �������� �������� �������� ��������
		add di, 2            ; ������� � ���������� ��������
		loop clear_array     ; ���������� ��� ��������� ���������
		;������� � ������ ���������
		jmp start1

menu:	mov ah,0
	int 16h
	cmp ax,3b00h  ;cod F1, slomat` vse
	je restart
	cmp ax,3c00h ;cod F2, ilca
	je clear_screen1
	cmp ax,3d00h  ;cod F3, exit
	je exit
	cmp ax,3e00h  ;cod F4, ���������
	je hap
	cmp ax,3f00h ;cod F5
	je ogni
	jmp menu

ogni: 
	call drawin ;vizov smeny cveta elki
	curspos curs_str+3, curs_col+3
	p1 text4
	curspos curs_str+4, curs_col+4
	p1 text5
	curspos curs_str+5, curs_col+5
	p1 text6
	curspos curs_str+6, curs_col+6
	p1 text8
	add bh,10h
	jmp menu

clear_screen1 :jmp clear_screen

hap:
	call drawpoc
	add bh,10h
    jmp menu

clear_screen:
	idraw 0,184Fh,7Ch ;otrisovka elki i fona
	idraw 1027h,1228h,65h
	idraw 0F20h,0F2Fh,2Ah
	idraw 0E21h,0E2Eh,2Ah
	idraw 0D22h,0D2Dh,2Ah
	idraw 0C23h,0C2Ch,2Ah
	idraw 0B22h,0B2Dh,2Ah
	idraw 0A24h,0A2Bh,2Ah
	idraw 0925h,092Ah,2Ah
	idraw 0826h,0829h,2Ah
	idraw 0727h,0728h,2Ah
	idraw 0628h,0627h,2Ah
	idraw 2000h,3090h,7Ch
	curspos curs_str+3, curs_col+3
	p1 text4
	curspos curs_str+4, curs_col+4
	p1 text5
	curspos curs_str+5, curs_col+5
	p1 text6
	curspos curs_str+6, curs_col+6
	p1 text9
    jmp menu


;>>>>>>�������� ��������� �������� ����� -29999,+29999<<<<<<<<

DIAPAZON PROC
;����� ����� - stroka
;����� bh ������������ ���� ������ �����
        xor bh,bh;
		xor si,si;      ����� ������� � �������� �����

		cmp kol,5 ;�������� �� ������������ ��������, ���� ������� ����� 5
		jb dop

		cmp stroka,2dh	;���� ����� 5 ��� ����� �������� �������� �������� �� ������ �������
		jne plus 	;���� 1 ������ �� �����,�������� ����� ��������

		cmp kol,6 ; ���� ������ - ����� � �������� ������ 6 �������� ������������ �������� 
		jb dop        
		inc si	;����� �������� ������ �����
		jmp first

plus:   cmp kol,6	;������� 6 �������� � ������ - �� ����� 
		je error1	;������

first:  cmp stroka[si],32h		;������� ������ ������ � 2
		jna dop		;���� ������ <=2 -�������� ������������ ��������

error1:	mov bh,flag_err	;����� bh=flag_err

dop:	ret

DIAPAZON ENDP


;>>>>>>>>>>�������� ������������ �������� ��������<<<<<<<<<<<

DOPUST PROC
;����� ����� - stroka
;si - ����� ������� � ������
;����� bh ������������ ���� ������ �����
		xor bh,bh
        xor si,si
		xor ah,ah
		xor ch,ch
		mov cl,kol	;� ch ���������� ��������� ��������

m11:	mov al,[stroka+si]		;� al - ������ ������
		cmp al,2dh		;�������� �� ������ �������
		jne testdop		;���� �� ����� - �������� ������������
		cmp si,0		;���� �����  - �������� �� �� ������ ��������
		jne error2		;���� ����� �� ������ -������
		jmp m13

testdop:cmp al,30h		;�������� �� ��������� ������ ������
		jb error2
		cmp al,39h
		ja error2

m13: 	inc si
		loop m11
		jmp m14

error2:	mov bh, flag_err		;��� �������������� ������� bh=flag_err

m14:	ret

DOPUST ENDP

;>>>>>>>>>>�������������� � ������ �� ASCII<<<<<<<<<<<

AscToBin PROC
;� cx ���������� ��������� ��������
;� bx - ����� ������� ������� � ���������� 
;����� ����� - number, � di - ����� ����� � �������
		xor ch,ch
		mov cl,kol
		xor bh,bh
		mov bl,cl
		dec bl
		mov si,1  	;� si ��� �������

n1:		mov al,[stroka+bx]
		xor ah,ah
		cmp al,2dh	;�������� ���� �����
		je otr    	;���� ����� �������������
		sub al,30h
		mul si
		add [number+di],ax
		mov ax,si
		mov si,10
		mul si
		mov si,ax
		dec bx
		loop n1
		jmp n2

otr:	neg [number+di]		;���������� ������������� ����� � �������������� ����

n2:		ret
AscToBin ENDP

;>>>>>>>>>>�������������� � ASCII �� ������<<<<<<<<<<<
BinToAsc PROC
;�������������� ����� � ������
;����� ���������� ����� ax
		xor si,si
		add si,5
		mov bx,10
		push ax
		cmp ax,0
		jnl mm1
		neg ax

mm1:	cwd
		idiv bx
		add dl,30h
		mov [out_str+si],dl
		dec si
		cmp ax,0
		jne mm1
		pop ax
		cmp ax,0
		jge mm2
		mov [out_str+si],2dh

mm2:	ret

BinToAsc ENDP
;______________________________________________________________
drawin proc
	idraw 0F21h,0F21h
	idraw 0F29h,0F29h
	idraw 0E2Ch,0E2Ch
	idraw 0D24h,0D24h
	idraw 0C2Bh,0C2Bh
	idraw 0B27h,0B27h
	idraw 0A2Ah,0A2Ah
	idraw 0926h,0926h
	idraw 0829h,0829h
	ret
drawin endp

drawpoc proc
	idraw 0327h,032eh
	idraw 0426h,0428h
	idraw 0525h,0527h
	idraw 0624h,0628h
	idraw 0724h,0729h
	idraw 0824h,0829h
	idraw 0924h,0929h
	idraw 0a25h,0a28h
	idraw 042ch,042fh
	idraw 052eh,0530h
	idraw 062eh,0631h
	idraw 072eh,0731h
	idraw 082eh,0831h
	idraw 092eh,0931h
	idraw 0a2eh,0a31h
	idraw 0b2ch,0b30h
	idraw 0c2ch,0c2fh
	idraw 0d2bh,0d2eh
	idraw 0e2ah,0e2ch
	idraw 0f2ah,0f2bh
	idraw 102ah,102bh
	idraw 112ah,112bh
	idraw 1329h,132ch
	idraw 1428h,142dh
	idraw 1528h,152dh
	idraw 1628h,162dh
	idraw 1729h,172ch
	ret
drawpoc endp
c1 ends

;>>>>>>>>>>>>>>>>>>������� �����<<<<<<<<<<<<<<<<<<<

st1 segment para stack 'stack'
    dw 100 dup (?)
st1 ends
end start