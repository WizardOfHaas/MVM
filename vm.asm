cpu2:
	.ip db 0,0
	.0 db 0,0
	.1 db 0,0
	.2 db 0,0
	.stat db 0,0
	.flag db 0,0
	.sp db 255,0
	.id db 1
times 2 db 0
cpu1:
	.ip db 0,0
	.0 db 0,0
	.1 db 0,0
	.2 db 0,0
	.stat db 0,0
	.flag db 0,0
	.sp db 255,0
	.id db 1
times 2 db 0
cpu0:
	.ip db 0,0
	.0 db 0,0
	.1 db 0,0
	.2 db 0,0
	.stat db 0,0
	.flag db 0,0
	.sp db 255,0
	.id db 0

%INCLUDE "rom.asm"

nodemaster:
	xor bx,bx
.schedloop
	cmp word[.romlist + bx],0
	je .runloop
	cmp word[.cpulist + bx],0
	je .runloop
	mov dx,bx
	mov si,word[.romlist + bx]
	mov di,word[.cpulist + bx]
	mov ax,runcpu
	call schedule
	call getregs
	add bx,2
	cmp word[.romlist + bx],0
	je .runloop
	cmp word[.cpulist + bx],0
	je .runloop
	add byte[.numvm],2
	jmp .schedloop
.runloop
	cmp byte[startvm.comp],2
	je .done
	call yield
	jmp .runloop
.done
ret
	.cpulist times 8 db 0
	.romlist times 8 db 0
	.int db 0,0
	.numvm db 0,0

startvm:
	call killque

	mov word[nodemaster.cpulist],cpu0
	mov word[nodemaster.romlist],ram0
	mov word[nodemaster.cpulist + 2],cpu1
	mov word[nodemaster.romlist + 2],ram1
	mov word[nodemaster.cpulist + 4],cpu2
	mov word[nodemaster.romlist + 4],ram2
	call nodemaster

	call killque
	mov ax,shell
	call schedule
ret
	.file db 'RUN',0
	.comp db 0,0

runcpu:
	pusha
.loop
	cmp byte[di + 9],'S'
	je .done
	cmp byte[di + 9],'W'
	je .wait
	cmp byte[.int],0
	jne .doint
	call runop
	call vmhud
	call yield
	jmp .loop
.wait
	call yield
	cmp byte[di + 9],'W'
	je .wait
	jmp .loop
.doint
	mov al,byte[.int]
	mov byte[.int],0
	call doint
	jmp .loop
.done
	add byte[startvm.comp],1
	popa
ret
	.int db 0,0

vmhud:
	pusha
	mov ax,dx
	call tostring
	mov si,ax
	call print
	call printcol
	movzx ax,byte[di + 3]
	call tostring
	mov si,ax
	call print
	call printdash
	movzx ax,byte[di + 5]
	call tostring
	mov si,ax
	call print
	call printdash
	movzx ax,byte[di + 7]
	call tostring
	mov si,ax
	call print
	call printcol
	movzx ax,byte[di]
	call tostring
	mov si,ax
	call print
	call printcol
	movzx ax,byte[di + 11]
	call tostring
	mov si,ax
	call print
	movzx ax,byte[di + 9]
	call tostring
	mov si,ax
	call print
	call printret
	popa
ret

printdash:
	pusha
	mov si,.dash
	call print
	popa
ret
	.dash db '-',0

runop:
	pusha
	mov cx,si
	mov si,[di]
	add si,cx
	cmp byte[di + 9],'w'
	je .waitloop
	add byte[di],1

	cmp byte[si],0
	je .stop
	cmp byte[si],1
	je .set
	cmp byte[si],2
	je .and
	cmp byte[si],3
	je .or
	cmp byte[si],4
	je .getmem
	cmp byte[si],41
	je .getmemreg
	cmp byte[si],5
	je .setmem
	cmp byte[si],51
	je .setmemreg
	cmp byte[si],6
	je .nop
	cmp byte[si],7
	je .jmp
	cmp byte[si],8
	je .cmp
	cmp byte[si],9
	je .mov
	cmp byte[si],10
	je .jne
	cmp byte[si],11
	je .je
	cmp byte[si],12
	je .jg
	cmp byte[si],13
	je .jl
	cmp byte[si],14
	je .call
	cmp byte[si],15
	je .ret
	cmp byte[si],16
	je .wait
	cmp byte[si],17
	je .run
	cmp byte[si],20
	je .add
	cmp byte[si],21
	je .inc
	cmp byte[si],22
	je .addreg
	cmp byte[si],23
	je .sub
	cmp byte[si],24
	je .dec
	cmp byte[si],25
	je .subreg
	cmp byte[si],30
	je .int
	cmp byte[si],35
	je .putscreen
	cmp byte[si],36
	je .putregscreen
	cmp byte[si],40
	je .getkeybd
.stop
	mov byte[di + 9],'S'
	jmp .done
.mov
	mov cx,di
	add byte[di],2
	movzx bx,byte[si + 1]
	call calcreg
	add di,ax
	movzx bx,byte[si + 2]
	call calcreg
	mov bx,ax
	add bx,cx
	xor ax,ax
	mov al,byte[bx]
	mov byte[di],al
	jmp .done
.set
	add byte[di],2
	movzx bx,[si + 1]
	call calcreg
	add di,ax
	mov bl,byte[si + 2]
	mov byte[di],bl
	jmp .done
.and
	mov al,byte[di + 3]
	mov bl,byte[di + 5]
	and al,bl
	mov byte[di + 7],al
	jmp .done
.or
	mov al,byte[di + 3]
	mov bl,byte[di + 5]
	or al,bl
	mov byte[di + 7],al
	jmp .done
.getmem
	add byte[di],2
	movzx bx,byte[si + 1]
	call calcreg
	movzx bx,[si + 2]
	add bx,ram
	mov cl,byte[bx]
	add di,ax
	mov byte[di],cl
	jmp .done
.getmemreg
	add byte[di],2
	call calc2regs
	mov si,di
	add di,ax
	add si,bx
	movzx bx,byte[si]
	mov al,byte[ram + bx]
	mov byte[di],al
	jmp .done
.setmem
	add byte[di],2
	movzx bx,byte[si + 1]
	call calcreg
	movzx bx,[si + 2]
	add bx,ram
	add di,ax
	mov cl,byte[di]
	mov byte[bx],cl
	jmp .done
.setmemreg
	add byte[di],2
	call calc2regs
	mov si,di
	add di,ax
	add si,bx
	mov al,byte[di]
	movzx bx,byte[si]
	mov byte[ram + bx],al
	jmp .done
.jmp
	mov al,byte[si + 1]
	mov byte[di],al
	jmp .done
.jne
	cmp byte[di + 11],1
	jne .jmp
	add byte[di],1
	jmp .done
.je
	cmp byte[di + 11],1
	je .jmp
	add byte[di],1
	jmp .done
.jg
	cmp byte[di + 11],2
	je .jmp
	add byte[di],1
	jmp .done
.jl
	cmp byte[di + 11],3
	je .jmp
	add byte[di],1
	jmp .done
.call
	movzx bx,byte[di + 13]
	mov al,byte[di]
	add al,2
	add bx,ram
	mov byte[bx],bl
	sub byte[di + 13],1
	jmp .jmp
.ret
	movzx bx,byte[di + 13]
	add bx,ram
	mov al,byte[bx]
	mov byte[di],al
	add byte[di + 13],1
	jmp .done
.wait
	mov byte[di + 9],'w'
	add byte[di],2
	add si,1
	xor ax,ax
	mov al,byte[si + 1]
	movzx bx,byte[si]
	.waitloop
	movzx bx,byte[ram + bx]
	cmp byte[ram + bx],al
	je .waitdone
	call yield
	jmp .waitloop
.waitdone
	mov byte[di + 9],0
	jmp .done
.run
	movzx bx,byte[si + 1]
	cmp bx,255
	je .runreg
	mov si,ram
	add si,bx
	mov al,byte[di]
	.regok
	movzx bx,byte[di]
	sub si,bx
	call runop
	call vmhud
	mov byte[di],al
	add byte[di],1
	jmp .done
.runreg
	push dx
	push di
	movzx bx,byte[si + 2]
	call calcreg
	add di,ax
	movzx si,byte[di]
	add si,ram
	pop di
	pop dx
	mov al,byte[di]
	add al,1
	jmp .regok
.cmp
	add byte[di],2
	movzx bx,byte[si + 1]
	call calcreg
	add ax,di
	mov bx,ax
	mov al,byte[bx]
	mov ah,byte[si + 2]
.docmp
	cmp al,ah
	je .cmpe
	jg .cmpg
	jl .cmpl
	mov byte[di + 11],0
	jmp .done
.cmpe
	mov byte[di + 11],1
	jmp .done
.cmpg
	mov byte[di + 11],2
	jmp .done
.cmpl
	mov byte[di + 11],3
	jmp .done
.add
	mov al,byte[di + 3]
	mov ah,byte[di + 5]
	add al,ah
	mov byte[di + 7],al
	jmp .done
.addreg
	movzx bx,byte[si + 1]
	call calcreg
	push di
	mov bl,byte[si + 2]
	add di,ax
	add byte[di],bl
	pop di
	add byte[di],2
	jmp .done
.sub
	mov al,byte[di + 3]
	mov ah,byte[di + 5]
	sub al,ah
	mov byte[di + 7],al
	jmp .done
.subreg
	movzx bx,byte[si + 1]
	call calcreg
	push di
	mov bl,byte[si + 2]
	add di,ax
	sub byte[di],bl
	pop di
	add byte[di],2
	jmp .done
.inc
	add byte[di],1
	movzx bx,byte[si + 1]
	call calcreg
	add di,ax
	add byte[di],1
	jmp .done
.dec
	add byte[di],1
	movzx bx,byte[si + 1]
	call calcreg
	add di,ax
	sub byte[di],1
	jmp .done
.int
	add byte[di],1
	mov al,byte[si + 1]
	mov ah,byte[di + 15]
	mov byte[runcpu.int],al
	mov [doint.caller],di
	jmp .done
.putscreen
	add byte[di],1
	mov al,byte[si + 1]
	mov byte[.buf],al
	.print
	mov si,.buf
	mov ah,byte[doterm]
	mov byte[doterm],0
	call print
	mov byte[doterm],ah
	jmp .done
.putregscreen
	add byte[di],1
	movzx bx,byte[si + 1]
	call calcreg
	add di,ax
	mov al,byte[di]
	mov byte[.buf],al
	jmp .print
.getkeybd
	add byte[di],1
	call waitkey
	push ax
	movzx bx,byte[si + 1]
	call calcreg
	add di,ax
	pop ax
	mov byte[di],al
	jmp .done
.nop
.done
	popa
ret
	.buf db 0,0,0

calc2regs:
	movzx bx,byte[si + 1]
	call calcreg
	push ax
	movzx bx,byte[si + 2]
	call calcreg
	mov bx,ax
	pop ax
ret

calcreg:
	mov ax,2
	mul bx
	add ax,3
ret

clearW:
	pusha
	xor bx,bx
.loop
	cmp word[nodemaster.cpulist + bx],0
	je .done
	mov si,word[nodemaster.cpulist + bx]
	add bx,2
	cmp byte[si + 9],'W'
	jne .loop
	mov byte[si + 9],0
	jmp .loop
.done
	popa
ret

doint:
	pusha
	mov dx,[.caller]
	cmp al,1
	je .getcpulist
	cmp al,2
	je .wait
	cmp al,3
	je .endlich
	cmp al,4
	je .tott
	jmp .done
.getcpulist
	mov di,dx
	mov al,byte[nodemaster.numvm]
	mov byte[di + 3],al
	jmp .done
.wait
	mov di,dx
	mov byte[di + 9],'W'
	jmp .done
.endlich
	call clearW
	jmp .done
.tott
	call killvms
	call killque
	mov ax,shell
	call schedule
.done	
	popa
ret
	.caller db 0,0

killvms:
	mov si,nodemaster.cpulist
	xor bx,bx
.loop
	mov di,word[nodemaster.cpulist + bx]
	cmp di,0
	je .done
	mov byte[di + 9],'S'
	add bx,2
	jmp .loop
.done
ret

ram:
times 256 db 0