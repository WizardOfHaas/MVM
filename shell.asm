shell:
	mov si,prompt
        call print

        mov di,buffer
        call input

	mov di,buffer
	call commands
	cmp ax,'fl'
	jne .done

	.script
	call findfile
	cmp ax,0
	je .err
	call gotask.runcmd
	cmp ax,'fl'
	jne .done
.err
	call err
.done
ret

savecurs:
	pusha
	mov ah,03h
	mov bx,0
	int 10h
	mov byte[.x],dl
	mov byte[.y],dh
	popa
ret
	.x db 0,0
	.y db 0,0

loadcurs:
	pusha
	mov ah,02h
	mov bx,0
	mov dl,byte[savecurs.x]
	mov dh,byte[savecurs.y]
	int 10h
	popa
ret

movecurs:
	pusha
	mov ah,02h
	mov bx,0
	int 10h
	popa
ret

pswin:
	pusha
	call savecurs
	mov dh,72
	mov dl,1
	call movecurs
	call tasklist
.done
	call loadcurs
	popa
ret