; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB
x equ 0
y equ 4

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	PUSH{R4,R5,R6,LR}
	MOV R3, #0
	CMP R0, #0
	BNE LOOP
	ADD SP, #-8
	STR R0, [SP, #x]
	STR R1, [SP, #y]
	ADD R3, #1
	B PRINT
LOOP
	CMP R0, #0
	BEQ PRINT
	MOV R2, #10
	UDIV R1, R0, R2
	MUL R4, R1, R2
	SUB R5, R0, R4
	MOV R0, R5
	ADD SP, #-8
	STR R0, [SP, #x]
	STR R1, [SP, #y]
	MOV R0, R1
	ADD R3, #1
	B LOOP
	
PRINT
	CMP R3, #0
	BEQ DONE
	LDR R0, [SP, #x]
	LDR R1, [SP, #y]
	ADD SP, #8
	ADD R0, #0x30
	PUSH{R3,R4}
	BL ST7735_OutChar
	POP{R3,R4}
	ADD R3, #-1
	B PRINT
	
DONE
	POP{R4,R5,R6,LR}
	BX LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
	PUSH{R4,R5,R6,LR}
	MOV R6, #0x7FFFFFFF
	AND R0, R6
	MOV R1, #9999
	CMP R0, R1
	BGT STARS
loop
	CMP R3, #3
	BEQ STAR
NEXT
	CMP R3, #5
	BEQ print
	MOV R2, #10
	UDIV R1, R0, R2
	MUL R4, R1, R2
	SUB R5, R0, R4
	MOV R0, R5
	PUSH {R0,R1}
	MOV R0, R1
	ADD R3, #1
	B loop


STAR
	MOV R6, #0x2E
	PUSH{R6,R7}
	ADD R3, #1
	
	B NEXT

STARS
	MOV R0, #0x2A
	PUSH {R0,R1}
	PUSH {R0,R1}
	PUSH {R0,R1}
	MOV R0, #0x2E
	PUSH {R0,R1}
	MOV R0, #0x2A
	PUSH {R0,R1}
	MOV R3, #5
	
print
	CMP R3, #0
	BEQ done
	POP{R0,R1}
	CMP R0, #9
	BGT GO
	ADD R0, #0x30
GO
	PUSH{R3,R4}
	BL ST7735_OutChar
	POP{R3,R4}
	ADD R3, #-1
	B print
	
done
	POP{R4,R5,R6,LR}
	BX LR
 
     
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
