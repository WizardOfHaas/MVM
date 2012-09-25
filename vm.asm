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
	.ipu db 0,0

startvm:
	call killque

	mov word[nodemaster.cpulist],cpu0
	mov word[nodemaster.romlist],ram0
	mov word[nodemaster.cpulist + 2],cpu1
	mov word[nodemaster.romlist + 2],ram1
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
	movzx ax,byte[di + 5]
	call tostring
	mov si,ax
	call print
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

runop:
	pusha
	mov dx,si
	mov si,[di]
	add si,dx
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
	cmp byte[si],5
	je .setmem
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
	cmp byte[si],20
	je .add
	cmp byte[si],21
	je .inc
	cmp byte[si],23
	je .sub
	cmp byte[si],24
	je .dec
	cmp byte[si],30
	je .int
.stop
	mov byte[di + 9],'S'
	jmp .done
.mov
	add si,2
	add byte[di],2
	cmp byte[si - 1],1
	je .mov1
	cmp byte[si],1
	je .mov01
	mov al,byte[di + 7]
	mov byte[di + 3],al
	jmp .done
.mov01
	mov al,byte[di + 5]
	mov byte[di + 3],al
	jmp .done
.mov1
	cmp byte[si],0
	je .mov10
	mov al,byte[di + 7]
	mov byte[di + 5],al
	jmp .done
.mov10
	mov al,byte[di + 3]
	mov byte[di + 5],al
	jmp .done
.set
	add si,1
	cmp byte[si],0xFF
	je .mov
	add byte[di],2
	cmp byte[si],1
	je .set1
	mov al,byte[si + 1]
	mov byte[di + 3],al
	jmp .done
.set1
	mov al,byte[si + 1]
	mov byte[di + 5],al
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
	add si,2
	movzx bx,byte[si]
	add bx,void + 3072
	mov al,byte[bx]
	cmp byte[si - 1],1
	je .getmem1
	mov byte[di + 3],al
	jmp .done
.getmem1
	mov byte[di + 5],al
	jmp .done
.setmem
	add byte[di],2
	add si,2
	movzx bx,byte[si]
	add bx,void + 3072
	cmp byte[si -1],1
	je .setmem1
	mov al,byte[di + 3]
	mov byte[bx],al
	jmp .done
.setmem1
	mov al,byte[di + 5]
	mov byte[bx],al
	jmp .done
.jmp
	add si,1
	mov al,byte[si]
	sub al,1
	mov byte[di],al
	jmp .done
.jne
	cmp byte[di + 11],1
	jne .jmp
	jmp .done
.je
	cmp byte[di + 11],1
	je .jmp
	jmp .done
.jg
	cmp byte[di + 11],2
	je .jmp
	jmp .done
.jl
	cmp byte[di + 11],3
	je .jmp
	jmp .done
.call
	movzx bx,byte[di + 13]
	mov al,byte[di]
	add al,2
	add bx,void + 3072
	mov byte[bx],bl
	sub byte[di + 13],1
	jmp .jmp
.ret
	movzx bx,byte[di + 13]
	add bx,void + 3072
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
	movzx bx,byte[void + 3072 + bx]
	cmp byte[void + 3072 + bx],al
	je .waitdone
	call yield
	jmp .waitloop
.waitdone
	mov byte[di + 9],0
	jmp .done
.cmp
	add byte[di],2
	add si,1
	mov ah,byte[si + 1]
	cmp byte[si],1
	je .cmp1
	mov al,byte[di + 3]
	jmp .docmp
.cmp1
	mov al,byte[di + 3]
	jmp .docmp
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
.sub
	mov al,byte[di + 3]
	mov ah,byte[di + 5]
	sub al,ah
	mov byte[di + 7],al
	jmp .done
.inc
	add byte[di],1
	add si,1
	cmp byte[si],1
	je .inc1
	add byte[di + 3],1
	jmp .done
.inc1
	add byte[di + 7],1
	jmp .done
.dec
	add byte[di],1
	add si,1
	cmp byte[si],1
	je .dec1
	sub byte[di + 3],1
	jmp .done
.dec1
	sub byte[di + 7],1
	jmp .done
.int
	add byte[di],1
	mov al,byte[si + 1]
	mov ah,byte[di + 15]
	mov byte[runcpu.int],al
	mov [doint.caller],di
	jmp .done
.nop
.done
	popa
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
	call clearW
	cmp al,1
	je .push2
	cmp al,2
	je .wait
	jmp .done
.push2
	mov di,dx
	movzx bx,byte[di + 3]
	mov si,word[nodemaster.cpulist + bx]
	xor ax,ax
	mov al,byte[si + 5]
	mov byte[di + 5],al
	jmp .done
.wait
	mov di,dx
	mov byte[di + 9],'W'
	jmp .done
.done	
	popa
ret
	.caller db 0,0