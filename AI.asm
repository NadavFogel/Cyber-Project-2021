IDEAL

MODEL small


STACK 256


DATASEG

	;◄■■► Game logic ◄■■►
	Quit db 0
	isLeaveGame db 0
	isPressed db 0
	
	;◄■■► Crosshair ◄■■►
	crosshairX dw ?
	crosshairY dw ?
	crosshairSize dw 2
	
	
	;◄■■► Text files & handles ◄■■►
	filename db "number.txt",0
	handle dw ? 
	resultFile db "result.txt",0
	resultHandle dw ?
	result dw 0, '$'
	updateToFile db 0
	SquareSize dw 112
	startX dw ?
	startY dw ?
	defaultX dw ?
	
	loading db "loading...", '$'
	welcome1 db "welcome to ", '$'
	welcome2 db "AI", '$'
	welcome3 db "Number", '$'
	welcome4 db "Recognition", '$'
	
	instructions1 db "Please write", '$'
	instructions2 db "a Number", '$'
	instructions3 db "in the frame", '$'
	
	
	;◄■■► Bmp files & handles ◄■■►
	filehandle dw ?
	FileNameOffset dw ?
	Header db 54 dup (0)
	home db 'home.bmp',0
	frame db 'framepic.bmp',0
	activate db 'activate.bmp',0
	offBtn db 'off.bmp',0
	calcBtn db 'calc.bmp',0
	isThisBtn db "isThis.bmp",0
	trashIcon db "trash.bmp",0
	backArrow db "back.bmp",0
		
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10 ,'$'
	
	startXbmp dw 0
	startYbmp dw 0
	
	PIC_WIDTH equ [word ptr header + 12h]
	PIC_HIGHT equ [word ptr header + 16h]
	
	
	;◄■■► Array of pixels to send ◄■■►
	numOfBytes dw 03100h
	pixelsArray db 03100h dup(30h)
	
	
CODESEG
    ORG 100h
	
start:
	mov ax, @data
	mov ds,ax
	 
    call SetGraphic
	
	call ClearResultFile
main:
	call delay
	call HomePage
	cmp [isLeaveGame], 1 					; ◄■■ Checking if user wants to leave game
	je EXIT
	
	; ◄■■► Clearing screen ◄■■►
	; al = color cx = col dx= row si = height di = width
	mov al, 0
	mov cx, 0
	mov dx, 0
	mov si, 200
	mov di, 320
	call Rect
	call delay
	call SecondPage
	
	
	jmp main
	
EXIT:
	
	
	mov ax,2
	int 10h
	
	mov ax, 4C00h ; returns control to dos
  	int 21h

; ◄■■► Description: Loads the home page & the logic of the page ◄■■►
; ◄■■► Leave: when user presses the off button 				    ◄■■►
proc HomePage
	
	call LoadHomePageImages
	
	
	mov ax, 1 								; ◄■■ Activate mouse
	int 33h
	
homeMouseLP: 								; ◄■■ Loop untill left click occures or user wants to quit
	
	mov bx, 0
	mov ax, 3h
	int 33h
	
	cmp bx, 01h
	jne homeMouseLP
	
	shr cx, 1 								; ◄■■ Returns 640 pixels so we divid by 2
	
	; ◄■■ Check if off button is pressed
	push cx 								; ◄■■ X of crosshair
	push dx 								; ◄■■ Y of crosshair
	push 5									; ◄■■ First X of target
	push 45									; ◄■■ Second X of target
	push 5									; ◄■■ First Y of target
	push 45									; ◄■■ Second Y of target
    call isBtnPressed
	
	cmp [isPressed], 0
	je nextCheck
	mov [isLeaveGame], 1  					; ◄■■ Set leave game flag to true
	jmp ENDHOME
	
nextCheck:	
	; ◄■■ Check if activate button is pressed
	push cx 								; ◄■■ X of crosshair
	push dx 								; ◄■■ Y of crosshair
	push 18									; ◄■■ First X of target
	push 112								; ◄■■ Second X of target
	push 155								; ◄■■ First Y of target
	push 184								; ◄■■ Second Y of target
    call isBtnPressed
	
	cmp [isPressed], 0
	je homeMouseLP
	
ENDHOME:
	
	mov ax, 0 								; ◄■■ Deactivate mouse before leaving
	int 33h
	mov [Quit], 0
	ret
endp HomePage


; ◄■■► Description: Loads the second page & the logic of the page    ◄■■►
; ◄■■► Leave: when user presses the back arrow button or presses esc ◄■■►
proc SecondPage
	
	call LoadSecondPageImages
	
	
	mov ax, 1 								; ◄■■ Activate mouse
	int 33h
	
secondMain:
	
secondMouseLP: ; ◄■■ Loop untill left click occures or user wants to quit
	call KeyboardFunctions
	cmp [Quit], 1
	jne continue
	
	; ◄■■ Quit procedure
	mov ax, 0
	int 33h
	mov [Quit], 0
	ret
	
continue:

	mov bx, 0
	mov ax, 3h
	int 33h
	cmp bx, 01h
	jne secondMouseLP
	
	shr cx, 1
	
	; ◄■■ Check if calc button is pressed
	push cx 								; ◄■■ X of crosshair
	push dx 								; ◄■■ Y of crosshair
	push 90									; ◄■■ First X of target
	push 199								; ◄■■ Second X of target
	push 150								; ◄■■ First Y of target
	push 309								; ◄■■ Second Y of target
    call isBtnPressed
	
	cmp [isPressed], 0
	je noCalcBtn
	
	jmp sendData
	
noCalcBtn:
	; ◄■■ Check if trash icon is pressed
	push cx 								; ◄■■ X of crosshair
	push dx 								; ◄■■ Y of crosshair
	push 50									; ◄■■ First X of target
	push 78									; ◄■■ Second X of target
	push 20									; ◄■■ First Y of target
	push 50									; ◄■■ Second Y of target
    call isBtnPressed
	
	cmp [isPressed], 0
	je noTrashBtn
	
	call ClearFrame 						; ◄■■ Clear frame from paint
	jmp nextLoop 							; ◄■■ Start all over again
	
noTrashBtn:
	; ◄■■ Check if back arrow icon is pressed
	push cx 								; ◄■■ X of crosshair
	push dx 								; ◄■■ Y of crosshair
	push 0									; ◄■■ First X of target
	push 29									; ◄■■ Second X of target
	push 0									; ◄■■ First Y of target
	push 29									; ◄■■ Second Y of target
    call isBtnPressed
	
	cmp [isPressed], 0
	je noArrowBtn
	
	; ◄■■ Quit procedure
	mov ax, 0
	int 33h
	mov [Quit], 0
	ret
	
noArrowBtn:

	; ◄■■ Check if user wants to draw in the drawing box
	push cx 								; ◄■■ X of crosshair
	push dx 								; ◄■■ Y of crosshair
	push 92									; ◄■■ First X of target
	push 200								; ◄■■ Second X of target
	push 36									; ◄■■ First Y of target
	push 144								; ◄■■ Second Y of target
    call isBtnPressed
	
	cmp [isPressed], 0
	je nextLoop
	
	; ◄■■ Inside of drawing square
	sub dx, 1
	mov bh, 0
	mov al, 1111b
	mov ah, 0Ch
	int 10h
	
	; ◄■■ Draw crosshair
	mov [crosshairX], cx
	sub dx, 3
	mov [crosshairY], dx
	call DrawCrosshair
	jmp nextLoop
	
	

sendData: 									; ◄■■ Send data to python
	
	mov [SquareSize], 112d					; ◄■■ Moving the size of the drawing frame
	mov [startX], 91d 						; ◄■■ Moving start X of the drawing frame
	mov [startY], 31d						; ◄■■ Moving start Y of the drawing frame
	call PictureToPixels
	call UpdateNumberFile


	; ◄■■ Print loading text
	mov dl, 28 								; ◄■■ Row
	mov dh, 7								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset loading 				; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	call DelayForPyton
	call ReadFile

	
	; ◄■■ Clear "loading" text
	mov al,0
	mov cx,225
	mov dx,55
	mov si,10
	mov di,80
	call Rect
	
	mov dl, 37
	mov dh, 5
	mov bh, 0
	mov ah, 02h
	int 10h
	
	mov  dx, offset result 					; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	mov [result], 0
	call ClearResultFile
nextLoop:	

	jmp secondMain
	
	ret
endp SecondPage


; ◄■■► Enter: X,Y -> of the crosshair & X,Y,X,Y -> of target (by that order)◄■■►
; ◄■■► Description: Checks if the mouse is at the corrent postion at the moment  ◄■■►
proc isBtnPressed
	push bp
	mov bp, sp
	
	
	mov ax, [bp+10]
	cmp [bp+14], ax 
	jng notPressed
	
	mov ax, [bp+8]
	cmp [bp+14], ax
	jnl notPressed
	
	mov ax, [bp+6]
	cmp [bp+12], ax
	jng notPressed
	
	mov ax, [bp+4]
	cmp [bp+12], ax
	jnl notPressed
	
	mov [isPressed], 1
	pop bp
	ret 12
	
notPressed:
	
	mov [isPressed], 0
	pop bp
	ret 12
endp isBtnPressed

; ◄■■► Description: Loads all the images required for the home page ◄■■►
proc LoadHomePageImages
	
	; ◄■■ Home page background
	mov [startXbmp], 0
	mov [startYbmp], 0
	mov ax, offset home
	mov [FileNameOffset], ax
	call OpenImage
	
	
	; ◄■■ Activate button
	mov [startXbmp], 15
	mov [startYbmp], 150
	mov ax, offset activate
	mov [FileNameOffset], ax
	call OpenImage
	
	; ◄■■ Off button
	mov [startXbmp], 0
	mov [startYbmp], 0
	mov ax, offset offBtn
	mov [FileNameOffset], ax
	call OpenImage
	
	
	call WriteHomeText
	
	
	ret
endp LoadHomePageImages

; ◄■■ Description: Clears the frame Loads all the ◄■■►
; ◄■■ images required for the second page 		  ◄■■►
proc LoadSecondPageImages
	; ◄■■ Is this your number:
	mov [startXbmp], 222
	mov [startYbmp], 14
	mov ax, offset isThisBtn
	mov [FileNameOffset], ax
	call OpenImage
	
	; ◄■■ Printing the frame picture to sreen
	mov [startXbmp], 76
	mov [startYbmp], 14
	mov ax, offset frame
	mov [FileNameOffset], ax
	call OpenImage
	
	; ◄■■ Calculate button
	mov [startXbmp], 90
	mov [startYbmp], 150
	mov ax, offset calcBtn
	mov [FileNameOffset], ax
	call OpenImage
	
	; ◄■■ Back arrow icon
	mov [startXbmp], 0
	mov [startYbmp], 0
	mov ax, offset backArrow
	mov [FileNameOffset], ax
	call OpenImage
	
	; ◄■■ Trash icon
	mov [startXbmp], 50
	mov [startYbmp], 20
	mov ax, offset trashIcon
	mov [FileNameOffset], ax
	call OpenImage
	
	call WriteInstructionsText
	
	ret
endp LoadSecondPageImages

; ◄■■ Description: Writes text to the second screen ◄■■►
proc WriteInstructionsText
	; ◄■■ Print Instructions text
	mov dl, 27								; ◄■■ Row
	mov dh, 10								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset instructions1 			; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	; ◄■■ Print Instructions text
	mov dl, 27								; ◄■■ Row
	mov dh, 11								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset instructions2 			; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	; ◄■■ Print Instructions text
	mov dl, 27 								; ◄■■ Row
	mov dh, 12								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset instructions3 			; ◄■■ Text to print
    mov  ah, 9
    int  21h
	ret
endp WriteInstructionsText

; ◄■■ Description: Writes text to the home screen ◄■■►
proc WriteHomeText
	; ◄■■ Print Home text
	mov dl, 2 								; ◄■■ Row
	mov dh, 8								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset welcome1 				; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	; ◄■■ Print Home text
	mov dl, 5 								; ◄■■ Row
	mov dh, 10								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset welcome2 				; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	; ◄■■ Print Home text
	mov dl, 3 								; ◄■■ Row
	mov dh, 11								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset welcome3 				; ◄■■ Text to print
    mov  ah, 9
    int  21h
	
	; ◄■■ Print Home text
	mov dl, 2 								; ◄■■ Row
	mov dh, 12								; ◄■■ Col
	mov bh, 0 								; ◄■■ Display page
	mov ah, 02h
	int 10h	
	
	mov  dx, offset welcome4 				; ◄■■ Text to print
    mov  ah, 9
    int  21h
	ret
endp WriteHomeText


; ◄■■► Description: Clears the frame ◄■■►
proc ClearFrame

	mov al,0
	mov cx,91
	mov dx,31
	mov si,112
	mov di,112
	call Rect
	ret
endp ClearFrame

; ◄■■► Enter: Pixels array & file name 				   ◄■■►
; ◄■■► Description: Sends gathered data to a text file ◄■■►
proc UpdateNumberFile
	
	mov ah, 03Dh
	mov al, 1 								; ◄■■ Open attribute: 0 - read-only, 1 - write-only, 2 -read&write
	mov dx, offset filename 				; ◄■■ Filename to open
	int 21h
	mov [handle], ax
	
	mov ah, 040h
	mov bx, [handle] 						; ◄■■ File handle
	mov cx, [numOfBytes] 					; ◄■■ Num of bytes to write
	mov dx, offset pixelsArray 				; ◄■■ Data to write
	int 21h
	
	mov ah, 03Eh
	mov bx, [handle]
	int 21h
	
	ret
endp UpdateNumberFile

; ◄■■► Enter: Result file name 		   ◄■■►
; ◄■■► Description: Clears result file ◄■■►
proc ClearResultFile
	
	mov ah, 03Dh
	mov al, 1 								; ◄■■ Open attribute: 0 - read-only, 1 - write-only, 2 -read&write
	mov dx, offset resultFile 				; ◄■■ filename to open
	int 21h
	mov [handle], ax
	
	mov ah, 040h
	mov bx, [handle] 						; ◄■■ File handle
	mov cx, 1 								; ◄■■ Num of bytes to write
	mov dx, 0 								; ◄■■ Data to write
	int 21h
	
	mov ah, 03Eh
	mov bx, [handle]
	int 21h
	
	ret
endp ClearResultFile

; ◄■■► Enter: Result file name 							   ◄■■►
; ◄■■► Description: Reads the result file send from python ◄■■►
proc ReadFile

	mov ah, 3Dh
	mov al, 0 								; ◄■■ Open attribute: 0 - read-only, 1 - write-only, 2 -read&write
	mov dx, offset resultFile 				; ◄■■ Filename to open
	int 21h
	mov [resultHandle], ax
	
	mov ah, 3Fh
	mov bx, [resultHandle] 					; ◄■■ Handle we get when opening a file
	mov cx, 1 								; ◄■■ Number of bytes to read
	mov dx, offset result 					; ◄■■ Where to put read data
	int 21h

	ret
endp ReadFile

; ◄■■► Enter: Result file name & number file name 		     ◄■■►
; ◄■■► Description: Creates the files 						 ◄■■►
proc CreateFiles
	mov ah, 3Ch ; DOS create file
	mov cx, 0 ; attribute
	mov dx, offset filename ; offset of filename 
	int 21h
	
	mov ah, 3Ch ; DOS create file
	mov cx, 0 ; attribute
	mov dx, offset resultFile ; offset of filename 
	int 21h
	ret
endp CreateFiles

; ◄■■► Enter: X,Y of the starting point of the frame & frame size ◄■■►
; ◄■■► Description: Convertes user drawing to an array of pixels  ◄■■►
proc PictureToPixels
	
	
	; ◄■■ Setting params
	mov si, 0
	mov di, 0
	mov ax, [startX]
	mov [defaultX], ax
	
outerLoop:

	cmp si, [SquareSize]
	je done
	mov bx, 0
	mov ax, [defaultX]
	mov [startX], ax
	
innerLoop:
	; ◄■■ Get pixel color of X&Y
	mov ah,0Dh
	mov cx, [startX]
	mov dx, [startY]
	int 10H ; AL = COLOR
	
	cmp al, 0
	je write0
	
	; ◄■■ Write '1' to array = pixel was colored
	mov [pixelsArray + di], 31h
	jmp nextWrite
	
write0:

	; ◄■■ Write '0' to array = pixel was not colored
	mov [pixelsArray + di], 30h
nextWrite:

	inc di
	inc bx
	inc [startX]
	
	cmp bx, [SquareSize]
	je innerLoopDone
	
	
	jmp innerLoop

innerLoopDone:
	inc [startY]
	inc si
	jmp outerLoop
	
done:

	ret
endp PictureToPixels


; ◄■■► Enter: X,Y of the Crosshair position & crosshair size ◄■■►
; ◄■■► Description: Draws the crosshair on the sreen in  	 ◄■■►
; ◄■■► the mouse location									 ◄■■►
proc DrawCrosshair
	
	; ◄■■ al = color cx = col dx= row si = height di = width
	mov al,1111b
	mov cx,[crosshairX]
	mov dx,[crosshairY]
	mov si,[crosshairSize]
	mov di,[crosshairSize]
	call Rect
	
	mov al,1111b
	mov cx,[crosshairX]
	sub cx, 2
	mov dx,[crosshairY]
	mov si,[crosshairSize]
	mov di,[crosshairSize]
	call Rect
	
	mov al,1111b
	mov cx,[crosshairX]
	mov dx,[crosshairY]
	sub dx, 2
	mov si,[crosshairSize]
	mov di,[crosshairSize]
	call Rect
	
	mov al,1111b
	mov cx,[crosshairX]
	add cx, 2
	mov dx,[crosshairY]
	mov si,[crosshairSize]
	mov di,[crosshairSize]
	call Rect
	
	mov al,1111b
	mov cx,[crosshairX]
	mov dx,[crosshairY]
	add dx, 2
	mov si,[crosshairSize]
	mov di,[crosshairSize]
	call Rect
	ret
	
	ret
endp DrawCrosshair

; ◄■■► Description: Reads from keyboard buffer and  ◄■■►
; ◄■■► changes data based on the input 			    ◄■■►
proc KeyboardFunctions

	call ReadChar
	
    cmp dl, 1bh
    je next_1

	jmp end_next
	
next_1:
	mov [Quit], 1
end_next:
	ret
endp KeyboardFunctions 


; ◄■■► Dl contains the ascii character if keypressed, ◄■■►
; ◄■■► else dl contains 0							  ◄■■►
; ◄■■► Uses dx and ax, preserves other registers 	  ◄■■►
proc ReadChar 
    mov ah, 01H
    int 16H
    jnz keybdpressed
    xor dl, dl
    ret
keybdpressed:

    ; ◄■■ Extract the keystroke from the buffer
    mov ah, 00H
    int 16H
    mov dl,al
    ret
endp ReadChar

; ◄■■► Description: Draws a horizontal line ◄■■►
proc DrawHorizontalLine	near
	push si
	push cx
DrawLine:
	cmp si,0
	jz ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp DrawLine
	
	
ExitDrawLine:
	pop cx
    pop si
	ret
endp DrawHorizontalLine


; ◄■■► Description: Draws a Vertical line ◄■■►
proc DrawVerticalLine	near
	push si
	push dx
 
DrawVertical:
	cmp si,0
	jz @@ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    								; ◄■■ Put pixel
	
	 
	
	inc dx
	dec si
	jmp DrawVertical
	
	
@@ExitDrawLine:
	pop dx
    pop si
	ret
endp DrawVerticalLine


; ◄■■► Description: Draws a rectangle 					  ◄■■►
; ◄■■► cx = col dx= row al = color si = height di = width ◄■■►
proc Rect
	push cx
	push di
NextVerticalLine:	
	
	cmp di,0
	jz @@EndRect
	
	cmp si,0
	jz @@EndRect
	call DrawVerticalLine
	inc cx
	dec di
	jmp NextVerticalLine
	
	
@@EndRect:
	pop di
	pop cx
	ret
endp Rect

; ◄■■► Description: Delay between screen changes ◄■■►
proc Delay
	mov cx, 04h
	mov dx, 00000h
	mov ah, 86h
	int 15h
	ret
endp Delay

; ◄■■► Description: Delay between checks to ◄■■►
; ◄■■► let python time to run data analysis ◄■■►
proc DelayForPyton
	mov cx, 06h
	mov dx, 00000h 
	mov ah, 86h
	int 15h
	ret
endp DelayForPyton

; ◄■■► Enter: The file offset in the data segment ◄■■►
; ◄■■► Description: Opens a bmp image 			  ◄■■►
proc OpenImage
	; ◄■■ Open Image
	mov ah, 3Dh
	xor al, al
	mov dx, [FileNameOffset]
	int 21h
	jc openerror
	mov [filehandle], ax
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	call CloseFile
	ret
	openerror : 							; ◄■■ Returnes error if file doesnt work
		mov dx, 'E'
		mov ah, 9h
		int 21h
	ret
endp OpenImage

; ◄■■► Enter: File handle 		 ◄■■►
; ◄■■► Description: Closes file  ◄■■►
proc CloseFile
	mov ah, 3Eh
	mov bx, [filehandle]
	int 21h
	ret
endp CloseFile

; ◄■■► Enter: File handle 			  ◄■■►
; ◄■■► Description: Reads file header ◄■■►
proc ReadHeader
	; ◄■■ Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader

; ◄■■► Description: Reads file palette ◄■■►
proc ReadPalette
	; ◄■■ Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette


; ◄■■► Enter: offset of palette in data segment ◄■■►
; ◄■■► Description: Reads file palette		    ◄■■►
proc CopyPal
	; ◄■■ Copy the colors palette to the video memory
	; ◄■■ The number of the first color should be sent to port 3C8h
	; ◄■■ The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; ◄■■ Copy starting color to port 3C8h
	out dx,al
	; ◄■■ Copy palette itself to port 3C9h
	inc dx
	PalLoop:
		; ◄■■ Note: Colors in a BMP file are saved as BGR values rather than RGB .
		mov al,[si+2] 						; ◄■■ Get red value .
		shr al,2 							; ◄■■ Max. is 255, but video palette maximal
		; ◄■■ value is 63. Therefore dividing by 4.
		out dx,al 							; ◄■■ Send it .
		mov al,[si+1] 						; ◄■■ Get green value .
		shr al,2
		out dx,al 							; ◄■■ Send it .
		mov al,[si] 						; ◄■■ Get blue value .
		shr al,2
		out dx,al 							; ◄■■ Send it .
		add si,4 							; ◄■■ Point to next color .
		; ◄■■ (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal

; ◄■■► Enter: Offset of ScrLine in data segment, ◄■■►
; ◄■■► X,Y to start print from & dimensions  	 ◄■■►
; ◄■■► Description: Copys bitmap of bmp			 ◄■■►
proc CopyBitmap
	push bp
	mov bp, sp
	sub sp, 6
	; ◄■■ BMP graphics are saved upside-down .
	; ◄■■ Read the graphic line by line (200 lines in VGA format),
	; ◄■■ displaying the lines from bottom to top.
	
	
	mov ax, 0A000h
	mov es, ax
	mov cx, PIC_HIGHT
	mov ax, 320
	mov di, cx
	add di, [startYbmp]
	mul di
	mov di, ax
	add di, [startXbmp]
	mov cx, PIC_HIGHT
	PrintBMPLoop :
		push cx
		
		; ◄■■ Read one line
		mov ah,3fh
		mov cx, PIC_WIDTH
		mov dx, offset ScrLine
		mov bx, [filehandle]
		int 21h
		; ◄■■ Copy one line into video memory
		cld 								; ◄■■ Clear direction flag, for movsb
		mov cx, PIC_WIDTH
		mov si,offset ScrLine
		
		rep movsb 							; ◄■■ Copy line to the screen
		 ;rep movsb is same as the following code :
		 ;mov es:di, ds:si
		 ;inc si
		 ;inc di
		 ;dec cx
		;loop until cx=0
		sub di, 320
		sub di, PIC_WIDTH					; ◄■■ 320 + width
		; sub di, PIC_WIDTH
		
		pop cx
	loop PrintBMPLoop
	mov sp, bp
	pop bp
		ret		
endp CopyBitmap

; ◄■■► Description: Sets screen to graphic mode ◄■■►
proc  SetGraphic
	; http://stanislavs.org/helppc/int_10-0.html

	mov ax,13h   							; ◄■■ 320 X 200 
											; ◄■■ Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

END start