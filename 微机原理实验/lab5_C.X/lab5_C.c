/*
 * File:   main.c
 * Author: zhaozhan
 *
 * Created on 2023?7?15?, ??7:03
 */

#pragma config WDTE = OFF
#include <xc.h>

unsigned char pcnt=0;
unsigned char rcnt=250;
unsigned char count;
unsigned char index;
unsigned char segCode;
const unsigned char table_3[]={0b11110111};//10
const unsigned char table_2[]={0xef,0xfd};//9,6
const unsigned char table_1[]={0xff,0b11101101,0b11001111};//8,5,3
const unsigned char table_0[]={0x27,0b11100110,0b11011011,0b00000110};//7,4,2,1

void longpush(){
    rcnt=61;
    pcnt--;
    PORTC=0b11111101;
    PORTA=segCode;
    return;
}
void doublepush(){
    pcnt=201;
    rcnt=61;
    PORTC=0b11111011;
    PORTA=segCode;
    return;
}
void singlepush(){
    PORTC=0b11110111;
    PORTA=segCode;
    return;
}


void __interrupt() ISR(void){
    //PORTAbits.RA7=1;
    PIR0bits.TMR0IF=0;
    count=0;
    TRISB=0xff;
    WPUB=0xff;
    index=0x0;
    /*PORTB:1111*/
    if(PORTBbits.RB3==0){
        count++;
        segCode=table_3[index];
        goto begin;
    }else if(PORTBbits.RB2==0){
        count++;
        segCode=table_2[index];
        goto begin;
    }else if(PORTBbits.RB1==0){
        count++;
        segCode=table_1[index];
        goto begin;
    }else if(PORTBbits.RB0==0){
        count++;
        segCode=table_0[index];
        goto begin;
    }
    /*PORTB:0111*/
    TRISBbits.TRISB3=0;
    PORTBbits.RB3=0;
    index++;
    if(PORTBbits.RB2==0){
        count++;
        segCode=table_2[index];
        goto begin;
    }else if(PORTBbits.RB1==0){
        count++;
        segCode=table_1[index];
        goto begin;
    }else if(PORTBbits.RB0==0){
        count++;
        segCode=table_0[index];
        goto begin;
    }
    /*PORTB:0011*/
    TRISBbits.TRISB2=0;
    PORTBbits.RB2=0;
    index++;
    if(PORTBbits.RB1==0){
        count++;
        segCode=table_1[index];
        goto begin;
    }else if(PORTBbits.RB0==0){
        count++;
        segCode=table_0[index];
        goto begin;
    }
    /*PORTB:0001*/
    TRISBbits.TRISB1=0;
    PORTBbits.RB1=0;
    index++;
    if(PORTBbits.RB0==0){
        count++;
        segCode=table_0[index];
        goto begin;
    }
begin:
    if(count==1){
        pcnt++;
        if(pcnt==1){
            return;
        }else if(pcnt==2){
            if(rcnt<=59){
                doublepush();
                return;
            }else{
                rcnt=0;
                return;
            }
        }else if(pcnt==200){
            longpush();
            return;
        }else
            return;
    }else{
        rcnt++;
        if(rcnt>=250){
            rcnt=250;
            return;
        }else if(rcnt>=2){
            pcnt=0;
            if(rcnt==60){
                singlepush();
                return;
            }else
                return;
        }else
            return;
    }
}


void main(void) {
    ANSELA=0x0;
    TRISA=0x0;
    PORTA=0x0;
    LATA=0x0;
    
    ANSELC=0x0;
    TRISC=0x0;
    PORTC=0x0;
    LATC=0x0;
    
    ANSELB=0x0;
    TRISB=0xff;
    PORTB=0x0;
    WPUB=0xff;
    
    T0CON0=0b10000000;
    T0CON1=0b01010011;
    TMR0H=0xfa;
    PIR0bits.TMR0IF=0;
    INTCONbits.GIE=1;
    INTCONbits.PEIE=1;
    PIE0bits.TMR0IE=1;
    while(1){
    }
    return;
}
