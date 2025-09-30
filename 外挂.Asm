;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;Code For Dynamic Memory Patch （简单的Win32外挂制作模板）
;
;函数_PatchMem是我自己写的，其在RadAsm中的调用规范举例如下:
;	ToPatchAddr	equ	004023D5h			;需要动态修改的目标进程关键地址
;	szDestName	db	'Plants vs. Zombies',0		;目标进程窗口名，若想使用类名查找窗口句柄，请自行修改相关代码
;	szPatchData	db	78h,03h,0FFh,25h		;要写入的字节，可直接从OD中复制过来，无需翻转代码
;	invoke	_PatchMem,addr szDestName,ToPatchAddr,addr szPatchData,4   ;应写入四的倍数个字节，否则很容易出错
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.386
		.model	flat,stdcall
		option	casemap:none
		
include		外挂.inc

_ProDlgMain		PROTO	:HWND,:UINT,:WPARAM,:LPARAM
_EnableDebugPrivilege	PROTO
_PatchMem		PROTO	:DWORD,:DWORD,:DWORD,:DWORD


		.code
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,IDD_DLG1,NULL,addr _ProDlgMain,NULL
		invoke	ExitProcess,NULL
		



		
_ProDlgMain	proc	uses ebx edi esi,hWnd,wMsg,wParam,lParam
		
		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL	
	
;应用程序初始化进行的各种操作，可自由定制	
	
		.elseif	eax == WM_INITDIALOG
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			
			invoke	CheckDlgButton,hWnd,IDC_ReSet,BST_CHECKED

;下面是在处理控件消息，使用时可酌情更改

		.elseif	eax == WM_COMMAND
			invoke	_EnableDebugPrivilege 
			
			mov eax,wParam
			.if	ax == IDC_Add
				invoke	CheckDlgButton,hWnd,IDC_ReSet,BST_UNCHECKED
				invoke	IsDlgButtonChecked,hWnd,IDC_Add
				.if	eax == BST_CHECKED
					invoke	_PatchMem,addr szDestName,ToPatchAddr,addr szPatchData,4
				.else
					invoke	_PatchMem,addr szDestName,ToPatchAddr,addr szOriginalData,4
				.endif
			.elseif	ax == IDC_ReSet
				invoke	IsDlgButtonChecked,hWnd,IDC_ReSet
				.if	eax == BST_CHECKED
					invoke	CheckDlgButton,hWnd,IDC_Add,BST_UNCHECKED
					invoke	CheckDlgButton,hWnd,IDC_BigSun,BST_UNCHECKED
					invoke	CheckDlgButton,hWnd,IDC_BToD,BST_UNCHECKED
					invoke	CheckDlgButton,hWnd,IDC_SToB,BST_UNCHECKED				
				
					invoke	_PatchMem,addr szDestName,ToPatchAddr,addr szOriginalData,4
					invoke	_PatchMem,addr szDestName,ToPatchAddr1,addr szOriginalData1,4
					invoke	_PatchMem,addr szDestName,ToPatchAddr2,addr szOriginalData2,4
					invoke	_PatchMem,addr szDestName,ToPatchAddr3,addr szOriginalData3,4
					invoke	_PatchMem,addr szDestName,ToPatchAddr4,addr szOriginalData4,4
				.endif
				
				
			.elseif	ax == IDC_BigSun
				invoke	CheckDlgButton,hWnd,IDC_ReSet,BST_UNCHECKED
				invoke	IsDlgButtonChecked,hWnd,IDC_BigSun
				.if	eax == BST_CHECKED
					invoke	_PatchMem,addr szDestName,ToPatchAddr1,addr szPatchBigSun,4
				.else
					invoke	_PatchMem,addr szDestName,ToPatchAddr1,addr szOriginalData1,4
				.endif
			.elseif	ax == IDC_BToD
				invoke	CheckDlgButton,hWnd,IDC_ReSet,BST_UNCHECKED
				invoke	IsDlgButtonChecked,hWnd,IDC_BToD
				.if	eax == BST_CHECKED
					invoke	_PatchMem,addr szDestName,ToPatchAddr2,addr szBToD1,4
					invoke	_PatchMem,addr szDestName,ToPatchAddr3,addr szBToD2,4
				.else
					invoke	_PatchMem,addr szDestName,ToPatchAddr2,addr szOriginalData2,4
					invoke	_PatchMem,addr szDestName,ToPatchAddr3,addr szOriginalData3,4
				.endif
			.elseif	ax == IDC_SToB
				invoke	CheckDlgButton,hWnd,IDC_ReSet,BST_UNCHECKED
				invoke	IsDlgButtonChecked,hWnd,IDC_SToB
				.if	eax == BST_CHECKED
					invoke	_PatchMem,addr szDestName,ToPatchAddr4,addr szSToB,4
				.else
					invoke	_PatchMem,addr szDestName,ToPatchAddr4,addr szOriginalData4,4
				.endif
				
			.endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProDlgMain	endp

;提升本进程权限(常量、变量尽量都在模块内定义，以方便使用和代码维护)
_EnableDebugPrivilege  proc						
    		local  @hToken
    		local  @tp:TOKEN_PRIVILEGES    				;结构数据组的每个项指明了权限的类型和要进行的操作

    		invoke  GetCurrentProcess
   		lea  	ecx,@hToken
    		invoke  OpenProcessToken,eax,TOKEN_ALL_ACCESS,ecx	;进行指定了写相关的访问权的OpenProcess操作
    		mov  	@tp.PrivilegeCount,1
    		mov	ecx,@F
    		invoke  LookupPrivilegeValue,NULL,ecx,addr @tp.Privileges[0].Luid	;得到一个权限对应的LUID值
    		mov  	@tp.Privileges[0].Attributes,SE_PRIVILEGE_ENABLED
    		invoke  AdjustTokenPrivileges,@hToken,FALSE,addr @tp,sizeof @tp,NULL,NULL  		;开始提升权限
    		push  	eax
    		invoke  CloseHandle,@hToken
    		pop  	eax
    		ret
    	@@:	
		db 	'SeDebugPrivilege',0

_EnableDebugPrivilege  endp

_PatchMem	proc	lpDestWndName,PatchAddr,lpPatchData,nSize
		LOCAL	@hDestWnd,@hDestId
		
		pushad
		invoke	FindWindow,NULL,lpDestWndName
		.if	eax
			mov	@hDestWnd,eax						;@hDestWnd此处保存目标进程窗口句柄
			invoke	GetWindowThreadProcessId,@hDestWnd,addr @hDestId	;一定要注意，最后一个参数要加上addr
			invoke	OpenProcess,PROCESS_ALL_ACCESS,FALSE,@hDestId
			.if	eax
				mov	@hDestWnd,eax					;@hDestWnd此处保存目标进程句柄
				invoke	WriteProcessMemory,@hDestWnd,PatchAddr,lpPatchData,nSize,NULL
			.else	
				invoke	MessageBeep,MB_ICONASTERISK
			.endif
			invoke	CloseHandle,@hDestWnd					;适时释放相关句柄值
		.else
			invoke	MessageBeep,MB_ICONASTERISK
		.endif
		popad
		
		mov	eax,TRUE
		ret

_PatchMem	endp

end	start