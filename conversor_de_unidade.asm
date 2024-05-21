;1 - Celsius para Fahrenheit
;2 - BAR para KPA
;3 - Metro para Decâmetro
;4 - Kg para Gramas

; Feito por Guilherme de Abreu
; 22.222.028-7

; --- Mapeamento de Hardware (8051) ---
    RS      equ     P1.3    ;Reg Select ligado em P1.3
    EN      equ     P1.2    ;Enable ligado em P1.2

org 0000h
    LJMP START

org 0030h
START:
    MOV 40H, #'#' 
    MOV 41H, #'0'
    MOV 42H, #'*'
    MOV 43H, #'9'
    MOV 44H, #'8'
    MOV 45H, #'7'
    MOV 46H, #'6'
    MOV 47H, #'5'
    MOV 48H, #'4'
    MOV 49H, #'3'
    MOV 4AH, #'2'
    MOV 4BH, #'1'
    ACALL lcd_init
    ACALL mainLoop

mainLoop:
    ACALL clearDisplay2
    ACALL showMenu
    ACALL waitForKeypress
    CJNE A, #'1', option2   ; Se a escolha não for '1', teste para outras opções
	CALL option1
    JMP mainLoop


option1:
	ACALL clearDisplay2
	ACALL receiveNumber
	ACALL celsiusToF ; Sub-rotina para converter Celsius para Fahrenheit
	RET


option2:
	CJNE A, #'2', option3 ; se o número inserido for diferente de 2, vá para a opção 3 etc...
	ACALL clearDisplay2
	ACALL receiveNumber
	ACALL BarToKPa
	RET


option3:
	CJNE A, #'3', option4
	ACALL clearDisplay2
	ACALL receiveNumber
	ACALL MToDec
	RET


option4:
	CJNE A, #'4', mainLoop ; Se o valor for diferente de 4, volta para o main loop
	ACALL clearDisplay2
	ACALL receiveNumber
	ACALL KgToGr
	RET



; Função para exibição do menu
showMenu:
    MOV A, #00h
    CALL posicionaCursor
    MOV A, #'1'
    CALL sendCharacter
    MOV A, #'-'
    CALL sendCharacter 
    MOV A, #'C'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter
    MOV A, #'F'
    CALL sendCharacter

    MOV A, #40h
    CALL posicionaCursor 
    MOV A, #'2'
    CALL sendCharacter
    MOV A, #'-'
    CALL sendCharacter 
    MOV A, #'B'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter
    MOV A, #'K'
    CALL sendCharacter 
	

	MOV A, #07h
    CALL posicionaCursor 
    MOV A, #'3'
    CALL sendCharacter
    MOV A, #'-'
    CALL sendCharacter 
    MOV A, #'M'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter
    MOV A, #'D'
    CALL sendCharacter


    MOV A, #47h
    CALL posicionaCursor
    MOV A, #'4'
    CALL sendCharacter
    MOV A, #'-'
    CALL sendCharacter 
    MOV A, #'K'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter
    MOV A, #'G'
    CALL sendCharacter 


    MOV A, #4Eh
    CALL posicionaCursor
    RET


waitForKeypress:
    ACALL leituraTeclado
    JNB F0, waitForKeypress   ; Se F0 estiver claro, aguarde até que uma tecla seja pressionada
	MOV A, #4Eh
	ACALL posicionaCursor	
	MOV A, #40h
	ADD A, R0
	MOV R0, A
	MOV A, @R0        
	ACALL sendCharacter
	CLR F0
    RET



receiveNumber:
	; Zera os registradores utilizados antes de receber qualquer outro
	; numero para a conversão, evitando conflito
	MOV R6, #00h
	MOV R2, #00h
	MOV R1, #00h

	MOV A, #00h
    ACALL posicionaCursor
    MOV A, #'E'
    CALL sendCharacter 
    MOV A, #'n'
    CALL sendCharacter 
    MOV A, #'t'
    CALL sendCharacter
    MOV A, #'e'
    CALL sendCharacter
    MOV A, #'r'
    CALL sendCharacter 

    ACALL waitForKeypress
	; Converte o valor para a leitura certa do teclado
	; pois o valor esta somado com 30, entao diminui 30
	CJNE A, #'1', check_2
	SUBB A, #30h  ; subtrair #30h para conversão de ASCIIh
	MOV R6, A  ; Copia o valor do teclado para R6
	RET


; método que encontrei para a leitura correta
check_2:
	CJNE A, #'2', check_3 ; Se o valor for diferente de 2, vá para check_3 etc...
	SUBB A, #30h  ; subtrair #30h para conversão de ASCII
	MOV R6, A  

	RET

check_3:
	CJNE A, #'3', check_4
	SUBB A, #30h 
	MOV R6, A  

	RET


check_4:
	CJNE A, #'4', check_5 
	SUBB A, #30h 
	MOV R6, A 

	RET

check_5:
	CJNE A, #'5', check_6
	SUBB A, #30h ;
	MOV R6, A  

	RET

check_6:
	CJNE A, #'6', check_7 
	SUBB A, #30h 
	MOV R6, A 

	RET

check_7:
	CJNE A, #'7', check_8
	SUBB A, #30h 
	MOV R6, A 

	RET

check_8:
	CJNE A, #'8', check_9 
	SUBB A, #30h
	MOV R6, A  

	RET


check_9:
	CJNE A, #'9', receiveNumber 
	SUBB A, #30h 
	MOV R6, A  

	RET



; Função para a conversão de Celsius para Ferenheit
celsiusToF:

    MOV A, R6   
	MOV R1, #18
    MOV B, R1   ; Carrega 18 em B
    MUL AB      ; Multiplica A e B (C * (9/5 = 2 ou 1.8 arredondado))
	MOV B, #10 ; divide por 10 para "arrumar" o 18 para 1.8
	DIV AB
    ADDC A, #32  ; Carrega 32 em A
	MOV R2, A



    MOV A, #40h
    ACALL posicionaCursor 
    MOV A, #'F'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter

    CALL divideAndDisplay

    RET

; Função para a conversão de Bar para Kpa
BarToKPa:

    MOV A, R6
    MOV B, #100
    MUL AB
	MOV R2, A


    MOV A, #40h
    ACALL posicionaCursor 
    MOV A, #'K'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter

    CALL divideAndDisplay

    RET 

; Função para a conversão de Metros para Decametro
MToDec:

    MOV A, R6
    MOV B, #10
    DIV AB
    MOV R2, A


    MOV A, #40h
    ACALL posicionaCursor 
    MOV A, #'D'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter


    CALL divideAndDisplay

    RET


; Função para a conversão de Kg para gramas
KgToGr:

    MOV A, R6
    MOV B, #1000
    MUL AB
    MOV R2, A


    MOV A, #40h
    ACALL posicionaCursor
    MOV A, #'G'
    CALL sendCharacter 
    MOV A, #'>'
    CALL sendCharacter

    CALL divideAndDisplay

    RET



divideAndDisplay:
	
    ; Obtém o dígito da milha
    MOV A, R2
    MOV B, #1000
    DIV AB

    ADD A, #48

    CALL sendCharacter

    ; Obtém o dígito da centena
    MOV A, R2
    MOV B, #100
    DIV AB

    ADD A, #48

    CALL sendCharacter


    ; Obtém o dígito da dezena
    MOV A, R2
    MOV B, #10
    DIV AB

    ; Converte o dígito da dezena para ASCII ('0' é 48 em ASCII)
    ADD A, #48

    ; Exibe o dígito da dezena no LCD
    CALL sendCharacter

    MOV A, B

    ADD A, #48

    CALL sendCharacter

 
    CALL longDelay

    RET ; Retorna da função





leituraTeclado:
	MOV R0, #0			; clear R0 - the first key is key0

	; scan row0
	MOV P0, #0FFh	
	CLR P0.0			; clear row0
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row1
	SETB P0.0			; set row0
	CLR P0.1			; clear row1
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row2
	SETB P0.1			; set row1
	CLR P0.2			; clear row2
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row3
	SETB P0.2			; set row2
	CLR P0.3			; clear row3
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
finish:
	RET

; column-scan subroutine
colScan:
	JNB P0.4, gotKey	; if col0 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.6, gotKey	; if col2 is cleared - key found
	INC R0				; otherwise move to next key
	RET					; return from subroutine - key not found
gotKey:
	SETB F0				; key found - set F0
	RET					; and return from subroutine




; initialise the display
; see instruction set for details
lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereço da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
	CLR RS	
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET


;Retorna o cursor para primeira posição sem limpar o display
retornaCursor:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET




;Limpa o display
clearDisplay:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET

clearSinglePosition:
    ACALL posicionaCursor
    MOV A, #' '
    CALL sendCharacter
    RET

clearDisplay2:
    ; Limpar linha 1
    MOV A, #00h
    ACALL clearSinglePosition
    MOV A, #01h
    ACALL clearSinglePosition
    MOV A, #02h
    ACALL clearSinglePosition
    MOV A, #03h
    ACALL clearSinglePosition
    MOV A, #04h
    ACALL clearSinglePosition
    MOV A, #05h
    ACALL clearSinglePosition
    MOV A, #06h
    ACALL clearSinglePosition
    MOV A, #07h
    ACALL clearSinglePosition
    MOV A, #08h
    ACALL clearSinglePosition
    MOV A, #09h
    ACALL clearSinglePosition
    MOV A, #0Ah
    ACALL clearSinglePosition
    MOV A, #0Bh
    ACALL clearSinglePosition
    MOV A, #0Ch
    ACALL clearSinglePosition
    MOV A, #0Dh
    ACALL clearSinglePosition
    MOV A, #0Eh
    ACALL clearSinglePosition
    MOV A, #0Fh
    ACALL clearSinglePosition

    ; Limpar linha 2
    MOV A, #40h
    ACALL clearSinglePosition
    MOV A, #41h
    ACALL clearSinglePosition
    MOV A, #42h
    ACALL clearSinglePosition
    MOV A, #43h
    ACALL clearSinglePosition
    MOV A, #44h
    ACALL clearSinglePosition
    MOV A, #45h
    ACALL clearSinglePosition
    MOV A, #46h
    ACALL clearSinglePosition
    MOV A, #47h
    ACALL clearSinglePosition
    MOV A, #48h
    ACALL clearSinglePosition
    MOV A, #49h
    ACALL clearSinglePosition
    MOV A, #4Ah
    ACALL clearSinglePosition
    MOV A, #4Bh
    ACALL clearSinglePosition
    MOV A, #4Ch
    ACALL clearSinglePosition
    MOV A, #4Dh
    ACALL clearSinglePosition
    MOV A, #4Eh
    ACALL clearSinglePosition
    MOV A, #4Fh
    ACALL clearSinglePosition

longDelay:
    MOV R7, #255  ; Configura um contador
delayLoop:
    DJNZ R7, delayLoop  ; Decrementa o contador e verifica se atingiu zero
    RET

delay:
	MOV R7, #50
	DJNZ R7, $
	RET
