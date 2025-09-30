
include		windows.inc
include		user32.inc
include		kernel32.inc
include		advapi32.inc

includelib	advapi32.lib
includelib	user32.lib
includelib	kernel32.lib

;Res\外挂.dlg
IDD_DLG1			equ 1000
IDC_SHP1			equ 1011
IDC_STC3			equ -1
IDC_GRP1			equ -1
IDC_BigSun			equ 1002
IDC_Add				equ 1003
IDC_ReSet			equ 1004
IDC_BToD			equ 1005
IDC_SToB			equ 1006
IDC_IMG1			equ 1001
IDC_Name			equ -1
IDC_o_0				equ -1
ICO_MAIN			equ 0

ToPatchAddr	equ	0041BA74h	;太阳值变减为加的地址
ToPatchAddr1	equ	004309EFh	;一个太阳加100阳光
ToPatchAddr2	equ	004309DEh	;太阳变钻石——两处地址
ToPatchAddr3	equ	00430A58h
ToPatchAddr4	equ	004309E3h	;小太阳变大太阳


		.data?
hInstance	dd	?


		.const
szDestName	db	'Plants vs. Zombies',0
szPatchData	db	03h,0F3h,89h,0B7h	
szOriginalData	db	2Bh,0F3h,89h,0B7h	;程序中原本的字节代码，和上面的patch地址是一一对应的

szPatchBigSun	db	0B9h,64h,00h,00h
szOriginalData1	db	0B9h,19h,00h,00h

szBToD1		db	74h,76h,83h,0F8h
szOriginalData2	db	74h,0Fh,83h,0F8h
szBToD2		db	83h,0F8h,04h,0Fh
szOriginalData3	db	83h,0F8h,03h,0Fh

szSToB		db	74h,0Ah,83h,0F8h
szOriginalData4	db	74h,05h,83h,0F8h
