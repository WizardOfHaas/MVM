shell:
	mov si,prompt
        call print

        mov di,buffer
        call input

	mov di,buffer
	call commands
	cmp ax,'fl'
	jne .done

	mov si,buffer
	call parse
	mov si,vm
	mov di,ax
	call compare
	jc .vm


	mov di,buffer
	call runrom
	cmp ax,'fl'
	jne .done

.vm
	call cmdlinevm
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

parse:
	push si

	mov ax, si			

	mov bx, 0
	mov cx, 0
	mov dx, 0

	push ax			

.loop1:
	lodsb				
	cmp al, 0			
	je .finish
	cmp al, ' '			
	jne .loop1
	dec si
	mov byte [si], 0		

	inc si				
	mov bx, si

.loop2:					
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop2
	dec si
	mov byte [si], 0

	inc si
	mov cx, si

.loop3:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop3
	dec si
	mov byte [si], 0

	inc si
	mov dx, si

.finish:
	
	pop ax
	pop si
ret