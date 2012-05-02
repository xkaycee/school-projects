; Date Created: Dec. 05, 2010
; Date Modified: Dec. 08, 2010

; Description: Converts input value to hex. Includes two test cases, ABCD (hexadecimal, base 16) and 1234 (decimal, base 10).
; Expected output: ABCD \n 04D2

myStack segment stack
	DB 512 DUP("!")
myStack ends

myData segment
	crlf db 0dh, 0ah, '$'
myData ends

code segment
assume cs:code, ds:myData

main proc

start:
	mov ax, myData
	mov ds, ax
	
	mov ax, 0ABCDh	; set ax to ABCDh
	call printHex
	mov ax, 1234		; converts this to 04D2h
	call printHex
	
byebye:					; exits the program
	mov ah, 4Ch
	mov al, 0
	int 21h
	
endp main

printHex proc
	mov cx, 10h			; mod 10h  in order to print last value in AX
	xor dx, dx			; clears memory
	mov bx, 4				; counter
	
divide:
	div cx					; divide ax by cx and place in dx
	cmp dx, 09h			; compare if dx is equal to 9
	jg isLetter 			; if greater than 9, then it is a letter (A-E). Jump to isLetter

isNumber: 
	add dx, 030h		; add 30 for numbers
	jmp process
	
isLetter:
	add dx, 037h		; add 37 for letters
	
process:
	dec bx					; decrement by 1
	push dx				; push current value in dx into the stack
	XOR dx, dx			; clear the memory in dx
	cmp bx, 	0			; compare ax to 0 to determine end of hex
	jg divide				; jump if greater than 0, 
	
	mov cx, 4				; counter for printOut loop
	
printOut:
	pop dx					; pop the stack
	mov ah, 02h			; print out to dos
	int 21h
	LOOP printOut		; loops 4x
	
printLine:					; prints a new line
	lea dx, crlf
	mov ah, 09h
	int 21h
	
	ret						; return to main procedure
	
printHex endp

code ends
end start