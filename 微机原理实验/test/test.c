/*
 * File:   main.c
 * Author: zhaozhan
 *
 * Created on 2023?7?15?, ??7:03
 */

#pragma config WDTE = OFF
#include <xc.h>



void __interrupt() ISR(void){
}


void main(void) {
    ANSELA=0x0;
    TRISA=0x0;
    PORTA=0x0;
    
    ANSELC=0x0;
    TRISC=0x0;
    PORTC=0x0;
    
    PORTAbits.RA7=1;
    PORTAbits.RA6=1;
    PORTAbits.RA5=1;
    PORTAbits.RA4=1;
    PORTAbits.RA3=1;
    PORTAbits.RA2=1;
    PORTAbits.RA1=1;
    PORTAbits.RA0=1;
    PORTC=0b11110111;
    
    while(1){
    }
    return;
}
