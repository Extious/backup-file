#include <xc.inc>

    psect   init, class=CODE, delta=2
    psect   end_init, class=CODE, delta=2
    psect   powerup, class=CODE, delta=2
    psect   cinit,class=CODE,delta=2
    psect   functab,class=ENTRY,delta=2
    psect   idloc,class=IDLOC,delta=2,noexec
    psect   eeprom_data,class=EEDATA,delta=2,space=3,noexec
    psect   intentry, class=CODE, delta=2
    psect   reset_vec, class=CODE, delta=2

    global _main, reset_vec, start_initialization

psect config, class=CONFIG, delta=2
    dw	0xDFEC
    dw	0xF7FF
    dw	0xFFBF
    dw	0xEFFE
    dw	0xFFFF

    psect	reset_vec
reset_vec:
    ljmp	_main

    psect cinit
start_initialization:

    psect	CommonVar, class=COMMON, space=1, delta=1
charcase: ds 1h
posCode   equ	0xf0
segCode equ 0xf1
index	equ 0xf2
cur	equ 0xf3
last	equ 0xf4
; long press var
long	equ 0xf5
pcnt	equ 0xf6

    psect intentry
intentry:
    ; Interrupt service routine
    ; clear overflow flag
    banksel PIR0
    bcf     PIR0, 5
    ; reset 
    banksel TRISB 
    movlw   11111111B
    movwf   TRISB
    banksel WPUB
    movlw   0xff
    movwf   WPUB
    movlw   0x0
    movwf   index
/************************** PORTB: 1111 ****************************/
    banksel PORTB
    movf    PORTB, w
    movwf   cur
    ; query table
    btfss   cur, 3
    goto    query_3
    btfss   cur, 2
    goto    query_2
    btfss   cur, 1
    goto    query_1
    btfss   cur, 0
    goto    query_0
/************************* PORTB: 0111 ****************************/
    banksel TRISB
    bcf	    TRISB, 3
    banksel PORTB
    bcf	    PORTB, 3
    ; PORTB to cur,  index += 1
    movf    PORTB, w
    movwf   cur
    incf    index
    ; query table
    btfss   cur, 2
    goto    query_2
    btfss   cur, 1
    goto    query_1
    btfss   cur, 0
    goto    query_0
/************************* PORTB: 0011 ****************************/
    banksel TRISB
    bcf	    TRISB, 2
    banksel PORTB
    bcf	    PORTB, 2
    ; PORTB to cur,  index += 1
    movf    PORTB, w
    movwf   cur
    incf    index
    ; query table
    btfss   cur, 1
    goto    query_1
    btfss   cur, 0
    goto    query_0
/************************* PORTB: 0001 ****************************/
    banksel TRISB
    bcf	    TRISB, 1
    banksel PORTB
    bcf	    PORTB, 1
    ; PORTB to cur, index += 1
    movf    PORTB, w
    movwf   cur
    incf    index
    ; query table
    btfss   cur, 0
    goto    query_0

    ; if not found, wreg = index, so here, we are required to reset w
    ; to avoid set segCode = wreg
    no_btn:
    clrf    WREG
    clrf    pcnt
    clrf    long
export:
    movwf   segCode 	    
    clrf    posCode
    call    func_output

    ; long press count:
    incf    pcnt, f
    btfsc   pcnt, 7
    bsf	    long, 0
exit:
    retfie


query_3:
    movf    index, w
    call Table_3
    goto export
query_2:
    movf    index, w
    call Table_2
    goto export
query_1:
    movf    index, w
    call Table_1
    goto export
query_0:
    movf    index, w
    call Table_0
    goto export

Table_3:
    addwf   PCL, f
    retlw   11110111B ;10
Table_2:
    addwf   PCL, f
    retlw   0xef ;9
    retlw   0xfd ;6
Table_1:
    addwf   PCL, f
    retlw   0xff ;8
    retlw   11101101B ;5
    retlw   11001111B ;3
Table_0:
    addwf   PCL, f
    retlw   0x27 ;7
    retlw   11100110B ;4
    retlw   11011011B ;2
    retlw   00000110B ;1

psect   main,class=CODE,delta=2 ; PIC10/12/16
 global _main
_main:
;TODO
    ;PORTA config 
    banksel PORTA
    clrf    PORTA
    banksel LATA
    clrf    LATA
    banksel ANSELA  
    clrf    ANSELA  
    banksel TRISA   
    movlw   00000000B
    movwf   TRISA

    ;PORTC config 
    banksel PORTC
    clrf    PORTC
    banksel LATC
    clrf    LATC
    banksel ANSELC  
    clrf    ANSELC  
    banksel TRISC  
    movlw   00000000B
    movwf   TRISC

    ;PORTB config 
    banksel PORTB
    clrf    PORTB
    banksel LATB
    clrf    LATB
    banksel ANSELB  
    clrf    ANSELB  
    banksel TRISB 
    movlw   11111111B
    movwf   TRISB
    banksel WPUB
    movlw   0xff
    movwf   WPUB

    ;TIMER0 config
    banksel T0CON0
    movlw   10001001B
    movwf   T0CON0
    banksel T0CON1
    movlw   01010000B
    movwf   T0CON1
    banksel PIR0
    bcf     PIR0, 5
    banksel TMR0H
    movlw   0xfa
    movwf   TMR0H

    ; INTERRUPT config
    banksel PIR0
    bcf     PIR0, 5
    ; GIE, PIE enable
    banksel INTCON
    bsf	    INTCON, 7
    bsf	    INTCON, 6
    ; TMR0IE enable
    banksel PIE0
    bsf	    PIE0,   5

    ; init LED
    ; test
loop:
    nop
    goto loop

func_output:
    ; TODO
    ; segment
    banksel PORTA
    movf    segCode, w
    movwf   PORTA
    ; position
    banksel PORTC
    movf    posCode, w
    movwf   PORTC
    ; long press
    btfsc   long,  0
    bsf	    PORTC, 4
    return
    ; END

;END 
end reset_vec