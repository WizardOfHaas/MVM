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
	mov bx,[si]
	cmp byte[si],0
	je .done
	push si
	call bf2mvm
	pop si
	add si,1
	jmp .loop
.done
	mov byte[di],0
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
	cmp byte[si],','
	je .getchar
	cmp byte[si],'['
	je .setjmp
	cmp byte[si],']'
	je .dojmp
	jmp .end
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
	mov byte[di],1
	add di,1
	mov byte[di],0
	add di,1
	mov byte[di],36
	add di,1
	mov byte[di],1
	jmp .done
.getchar
	mov byte[di],40
	add di,1
	mov byte[di],1
	add di,1
	mov byte[di],51
	add di,1
	mov byte[di],1
	add di,1
	mov byte[di],0
	jmp .done
.setjmp
	mov byte[di],6
	mov ax,di
	sub ax,void
	mov [.jmp],ax
	jmp .done
.dojmp
	mov byte[di],41
	add di,1
	mov byte[di],1
	add di,1
	mov byte[di],0
	add di,1
	mov byte[di],8
	add di,1
	mov byte[di],1
	add di,1
	mov byte[di],0
	add di,1
	mov byte[di],10
	add di,1
	mov ax,[.jmp]
	mov byte[di],al
	jmp .done
.done
	add di,1
.end
ret
	.jmp dw 0