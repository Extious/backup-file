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
intentry:
    retfie
    
psect   main,class=CODE,delta=2 ; PIC10/12/16
    
 global _main
_main:
/*  
    //enable all interrupts,interrupting on rising edge
    banksel INTCON;
    movlw 0x81;1000 0001
    movwf INTCON;
    //enable TMR0 interrupt
    banksel PIE0;
    movlw 0x20;0010 0000
    movwf PIE0; 

    movlw 0xff;
    movwf TMR0H;

    movlw 0xd0;
    movwf TMR0L;//set duration   0bdb
  */  


    banksel TRISB;
    movlw 0x00;
    movwf TRISB;set PORTB output 

    movlw 0x00;
    movwf TRISC;set PORTC 0~7 output

    //init TMR0,begin counting
    movlw 0x90;8b'1001 0000'
    movwf T0CON0;
    movlw 0x40;8b'0100 0000'
    movwf T0CON1;

    //begin with a magic
year:
    movlw 0x02;
    call TABLE;
    movwf PORTB;set output number 

    movlw 0xe0;
    movwf PORTC;set segment 0 light

    call delay5ms;

    movlw 0x00;
    call TABLE;
    movwf PORTB;set output number 

    movlw 0xd0;
    movwf PORTC;set segment 1 light

    call delay5ms;

    movlw 0x02;
    call TABLE;
    movwf PORTB;set output number 

    movlw 0xb0;
    movwf PORTC;set segment 2 light

    call delay5ms;

    movlw 0x03;
    call TABLE;
    movwf PORTB;set output number 

    movlw 0x70;
    movwf PORTC;set segment 3 light

    call delay5ms;

    //goto year;

    L1:

    movlw 0x01;
    call TABLE;
    movwf PORTB;set output number 1

    movlw 0xe0;
    movwf PORTC;set segment 0 light

    call delay5ms;

    movlw 0x02;
    call TABLE;
    movwf PORTB;set output number 2

    movlw 0xd0;
    movwf PORTC;set segment 1 light

    call delay5ms;

    movlw 0x03;
    call TABLE;
    movwf PORTB;set output number 3

    movlw 0xb0;
    movwf PORTC;setsegment 2 light

    call delay5ms;

    movlw 0x04;
    call TABLE;
    movwf PORTB;set output number 4

    movlw 0x70;
    movwf PORTC;set segment 3 light

    call delay5ms;

    goto L1;


delay250ms:
Loop1:
    btfss T0CON0,5;
    goto Loop1;
Loop2:
    btfsc T0CON0,5;
    goto Loop2;
    return


delay5ms:
    movlw 0xfd;
    movwf TMR0H;

    movlw 0x99;
    movwf TMR0L;

Loop3:
    btfss T0CON0,5;
    goto Loop3;

    movlw 0xfd;
    movwf TMR0H;

    movlw 0x99;
    movwf TMR0L;

Loop4:
    btfsc T0CON0,5;
    goto Loop4;
    return
TABLE:
    addwf PCL,F ;add offset to pc to generate a computed goto
    retlw 0x3f ;0
    retlw 0x06 ;1
    retlw 0x5b ;2
    retlw 0x4f ;3
    retlw 0x66 ;4
    retlw 0x6b ;5
    retlw 0x7b ;6
    retlw 0x07 ;7
    retlw 0x7f ;8
    retlw 0x6f ;9
    retlw 0x3f ;0
    retlw 0x06 ;1
    retlw 0x5b ;2
end reset_vec