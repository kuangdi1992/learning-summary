;GRUB的head，GRUB用来识别硬件厂商客制化的GRUB头的，包括魔数，GRUB1和GRUB2的支持
MBT_HDR_FLAGS	EQU 0x00010003
MBT_HDR_MAGIC	EQU 0x1BADB002
MBT2_MAGIC	EQU 0xe85250d6
global _start
extern inithead_entry
[section .text]
[bits 32]
_start: ;用来做定位，jmp到_entry中
	jmp _entry
align 4
mbt_hdr:
	dd MBT_HDR_MAGIC
	dd MBT_HDR_FLAGS
	dd -(MBT_HDR_MAGIC+MBT_HDR_FLAGS)
	dd mbt_hdr
	dd _start
	dd 0
	dd 0
	dd _entry
	;
	; multiboot header
	;
ALIGN 8
mbhdr:
	DD	0xE85250D6
	DD	0
	DD	mhdrend - mbhdr
	DD	-(0xE85250D6 + 0 + (mhdrend - mbhdr))
	DW	2, 0
	DD	24
	DD	mbhdr
	DD	_start
	DD	0
	DD	0
	DW	3, 0
	DD	12
	DD	_entry 
	DD      0  
	DW	0, 0
	DD	8
mhdrend:
//关中断cli，并加载GDT
_entry:
	cli

	in al, 0x70 //将0x70端口写入
	or al, 0x80	//将0x80即1000 0000和al寄存器按位与，也就是将AL的最高位置为1
	out 0x70,al //然后写端口0x70，端口0x70的最高位是控制NMI中断的开关，当为1时，阻断所有的NMI信号。【也就关闭了不可屏蔽中断】

	lgdt [GDT_PTR] //加载GDT（全局描述表）地址到GDTR寄存器 为什么要加载？有什么作用？感觉是从实模式跳转到保护模式的过程但是又不太一样，保护模式在加载GRUB的时候就进入了，这里只是进行了从新加载
	jmp dword 0x8 :_32bits_mode ;长跳转刷新CS影子寄存器，加载 CS 段寄存器，即段选择子

;初始化段寄存器、通用寄存器、栈寄存器
_32bits_mode:
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	xor esi,esi
	xor ebp,ebp
	xor esp,esp
	mov esp,0x7c00 ;设置栈顶为0x7c00
	call inithead_entry ;调用inithead_entry函数在inithead.c中实现
	jmp 0x200000 ;跳转到0x200000


;全局段描述符表GDT
GDT_START:
knull_dsc: dq 0
kcode_dsc: dq 0x00cf9e000000ffff
kdata_dsc: dq 0x00cf92000000ffff
k16cd_dsc: dq 0x00009e000000ffff ;16位代码段描述符
k16da_dsc: dq 0x000092000000ffff ;16位数据段描述符
GDT_END:
GDT_PTR:
GDTLEN	dw GDT_END-GDT_START-1	;GDT界限
GDTBASE	dd GDT_START
