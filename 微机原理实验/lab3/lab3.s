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

    psect intentry
    W_TMP equ 0xf0
    S_TMP equ 0xf1
intentry:
    ; Interrupt service routine
    ; clear overflow flag
    ;banksel PIR0
    ;btfss   PIR0, 5 
    ;retfie
    banksel PIR0
    bcf     PIR0, 5
    ; set TIMER0 
    banksel TMR0H
    movlw   0xc3
    movwf   TMR0H
    banksel TMR0L
    movlw   0x74
    movwf   TMR0L    
    ; reverse output
    banksel PORTA
    MOVLW   01H
    XORWF   PORTA,f
    retfie

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

    ;TIMER0 config
    banksel T0CON0
    movlw   10010000B
    movwf   T0CON0
    banksel T0CON1
    movlw   10010000B
    movwf   T0CON1
    banksel PIR0
    bcf     PIR0, 5

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

    ; Main loop is not needed.
loop:   
    nop
    goto    loop

;END 
end reset_vec