/*
 * File:   main.c
 * Author: zhaozhan
 *
 * Created on 2023?7?15?, ??5:29
 */

#include <xc.h>

void __interrupt() ISR(void){
    PIR0bits.TMR0IF=0;
    TMR0H=0xc3;
    TMR0L=0x74;
    PORTBbits.RB7=PORTBbits.RB7==1?0:1;
}
void main(void) {
    ANSELB=0x0;
    TRISB=0x0;
    T0CON0=0b10010000;
    T0CON1=0b10010000;
    PIR0bits.TMR0IF=0;
    INTCONbits.GIE=1;
    INTCONbits.PEIE=1;
    PIE0bits.TMR0IE=1;
    while(1){
    }
    return;
}
