bfcmd:
	mov si,.p
	call print
	mov di,buffer
	call input
	mov si,buffer
	call runbf
ret
	.p db '>',0

runbf:
	call compbf

	call killque
	call alocvm
	mov bx,void
	mov [nodemaster.romlist],bx
	mov byte[doterm],1
	call startvm.run
	call killque	

	mov ax,shell
	call schedule
ret

compbf:
	mov di,void
.loop
	cmp byte[si],0
	je .done
	call bf2mvm
	add si,1
	jmp .loop
.done
ret

bf2mvm:
	cmp byte[si],'>'
	je .incP
	cmp byte[si],'<'
	je .decP
	cmp byte[si],'+'
	je .inc
	cmp byte[si],'-'
	je .dec
	cmp byte[si],'.'
	je .putchar
	jmp .done
.incP
	mov byte[di],21
	add di,1
	mov byte[di],0
	jmp .done
.decP
	mov byte[di],24
	add di,1
	mov byte[di],0
	jmp .done
.inc
	mov byte[di],38
	add di,1
	mov byte[di],0
	jmp .done
.dec
	mov byte[di],39
	add di,1
	mov byte[di],0
	jmp .done
.putchar
	mov byte[di],41
	add di,1
	mov byte[di],0
	add di,1
	mov byte[di],1
	add di,1
	mov byte[di],36
	add di,1
	mov byte[di],1
	jmp .done
.done
	add di,1
ret