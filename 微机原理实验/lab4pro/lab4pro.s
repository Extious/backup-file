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
    dw        0xDFEC
    dw        0xF7FF
    dw        0xFFBF
    dw        0xEFFE
    dw        0xFFFF

    psect        reset_vec
reset_vec:
    ljmp        _main

    psect cinit
start_initialization:

    psect        CommonVar, class=COMMON, space=1, delta=1
charcase: ds 1h

    psect intentry
    pCode   equ        0xf0
    segOffset equ 0xf1
    segCode equ 0xf2
intentry:
    ; Interrupt service routine
    ; clear overflow flag
    banksel PIR0
    bcf     PIR0, 5
    ; output:
    call    func_output
    ;right shift position code
    rrf            pCode, f   ;??
    ;use offset to search in table
    ;incf    segOffset, f
    movf    segOffset, w

    btfsc   Flag, 0
    call    Table_1
    btfsc   Flag, 1
    call    Table_2
    btfsc   Flag, 2
    call    Table_3
    btfsc   Flag, 3
    call    Table_4

    incf    segOffset, f
    movwf   segCode
    btfss   segOffset, 2
    retfie
_reset:
    call    func_delay_op
    call    func_output
    ; reset vars
    movlw   11110111B
    movwf   pCode
    movlw   0
    movwf   segOffset
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

    ;PORTB config 
    banksel PORTC
    clrf    PORTC
    banksel LATC
    clrf    LATC
    banksel ANSELC  
    clrf    ANSELC  
    banksel TRISC  
    movlw   00000000B
    movwf   TRISC

    ;TIMER0 config
    banksel T0CON0
    movlw   10000000B
    movwf   T0CON0
    banksel T0CON1
    movlw   01010000B
    movwf   T0CON1
    banksel PIR0
    bcf     PIR0, 5
    banksel TMR0H
    movlw   0x7f
    movwf   TMR0H

    ; INTERRUPT config
    banksel PIR0
    bcf     PIR0, 5
    ; GIE, PIE enable
    banksel INTCON
    bsf            INTCON, 7
    bsf            INTCON, 6
    ; TMR0IE enable
    banksel PIE0
    bsf            PIE0,   5

    ; go!
    call    set_pcode
    Flag    equ 0xf7
    movlw   0x01
    movwf   Flag
loop:
    btfsc   Flag, 4 ;????1???????
    call    _reset_flag
    call    func_delay
    rlf            Flag ;????
    goto loop

_reset_flag:
    movlw   0x01
    movwf   Flag
    return

set_pcode:
    movlw   11110111B
    movwf   pCode
    movlw   1
    movwf   segOffset
    movlw   00000110B
    movwf   segCode
    return

Table_1:; Attention: RA7 == RA6 
    addwf   PCL, f
    retlw   00000110B ;1
    retlw   11011011B ;2
    retlw   11001111B ;3
    retlw   11100110B ;4
Table_2:; Attention: RA7 == RA6 
    addwf   PCL, f
    retlw   11100110B ;4
    retlw   00000110B ;1
    retlw   11011011B ;2
    retlw   11001111B ;3
Table_3:; Attention: RA7 == RA6 
    addwf   PCL, f
    retlw   11001111B ;3
    retlw   11100110B ;4
    retlw   00000110B ;1
    retlw   11011011B ;2
Table_4:; Attention: RA7 == RA6 
    addwf   PCL, f
    retlw   11011011B ;2
    retlw   11001111B ;3
    retlw   11100110B ;4
    retlw   00000110B ;1

func_delay_op:
    count1_op  equ 0x22
    banksel 0
    movlw   10
    movwf   count1_op
    delay_1:
    decfsz  count1_op, 1
    goto    delay_1
    return

func_delay:
    count1  equ 0x20
    count2  equ 0x21
    banksel 0
    movlw   200
    movwf   count1
    delay_1_op:
    movlw   200
    movwf   count2
    delay_2_op:
    decfsz  count2, 1 ;count2???
    goto    delay_2_op
    decfsz  count1, 1
    goto    delay_1_op
    return    

func_output:
; TODO
    ; segment
    banksel PORTA
    movf    segCode, w
    movwf   PORTA
    ; position
    banksel PORTC
    movf    pCode, w
    movwf   PORTC
    return
    ; END
exit:
    nop
;END 
end reset_vec