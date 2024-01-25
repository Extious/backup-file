/*
  ?????????pcnt?rcnt????
  ??????????????????????????????2??????????????3????????
*/
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
    
GLOBAL pcnt,rcnt,posCode,segCode,index,cur,count
 pcnt:ds 1h
 rcnt:ds 1h
 posCode:ds 1h
 segCode:ds 1h
 index:ds 1h
 cur:ds 1h
 count:ds 1h
 
    psect intentry
intentry:
    movlw 0
    movwf count
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

begin:   
    ;TODO?check if there is only one btn was pushed
check:
    ;if count==1,then STATUS[2]==1,go to Pbtn
    ;else go to Rbtn
    movlw 1
    xorwf count,w
    btfss STATUS,2
    goto Rbtn
    goto Pbtn
;release the btn
Rbtn:
    incf rcnt
    ;if rcnt>=250,then STATUS[0]==1,let rcnt = 250
    movlw 250
    subwf rcnt,w
    btfsc STATUS,0
    goto resetrcnt
    ;if rcnt>=2,then STATUS[2]==1,clrf pcnt
    movlw 2
    subwf rcnt,w
    btfsc STATUS,0
    clrf pcnt
    ;if rcnt==60,then STATUS[2]==1,go to singlepush
    movlw 60
    xorwf rcnt,w
    btfsc STATUS,2
    goto singlepush
;    movlw 63
;    xorwf rcnt,w
;    btfsc STATUS,2
;    clrf pcnt
    retfie
;push the btn
Pbtn:   
    ;if pcnt==1,then STATUS[2]==1,retfie
    incf pcnt
    movlw 1
    xorwf pcnt,w
    btfsc STATUS,2
    retfie
    ;if pcnt==2,then STATUS[0]==1,go to checkdoublepush
    movlw 2
    xorwf pcnt,w
    btfsc STATUS,2
    goto checkdoublepush
    
continue:
    ;if pcnt==200 ,then STATUS[2]==1,go to longpush
    ;else retfie
    movlw 200
    xorwf pcnt,w
    btfss STATUS,2
    retfie
    goto longpush
 
checkdoublepush:
    ;if rcnt<=59 ,then STATUS[0]==0,go to doublepush,
    ;else goto continue
    movlw 59
    subwf rcnt,w
    btfss STATUS,0
    goto doublepush
    clrf rcnt
    retfie
    
resetrcnt:
    movlw 250
    movwf rcnt
    retfie
    
singlepush:
    ; position
    banksel PORTC
    movlw  11110111B
    movwf   PORTC
    banksel PORTA
    movf    segCode, w
    movwf   PORTA
    retfie
        
doublepush:
    movlw 201
    movwf pcnt
    movlw 61
    movwf rcnt
    ; position
    banksel PORTC
    movlw  11111011B
    movwf   PORTC
    banksel PORTA
    movf    segCode, w
    movwf   PORTA
    retfie
      
longpush:
    movlw 61
    movwf rcnt
    decf pcnt
    ; position
    banksel PORTC
    movlw  11111101B
    movwf   PORTC
    banksel PORTA
    movf    segCode, w
    movwf   PORTA
    retfie
    
query_3:
    incf count
    movf    index, w
    call Table_3
    movwf   segCode
    goto begin
query_2:
    incf count
    movf    index, w
    call Table_2
    movwf   segCode 	 
    goto begin
query_1:
    incf count
    movf    index, w
    call Table_1
    movwf   segCode 	
    goto begin
query_0:
    incf count
    movf    index, w
    call Table_0
    movwf   segCode 
    goto begin

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
    movlw   10000000B
    movwf   T0CON0
    banksel T0CON1
    movlw   01010001B
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

    movlw   0
    movwf   pcnt
    movlw   250
    movwf   rcnt
    ; init LED
    ; test
loop:
    nop
    goto loop
;END 
end reset_vec