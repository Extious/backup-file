/*
 * File:   main.c
 * Author: 22578
 *
 * Created on 2023?7?17?, ??4:43
 */


#include <xc.h>
#include <stdint.h>
#include "stdio.h"

#define _XTAL_FREQ 1000000  

// CONFIG1
#pragma config FEXTOSC = OFF    // External Oscillator mode selection bits (Oscillator not enabled)
#pragma config RSTOSC = HFINT1  // Power-up default value for COSC bits (HFINTOSC (1MHz))
#pragma config CLKOUTEN = OFF   // Clock Out Enable bit (CLKOUT function is disabled; i/o or oscillator function on OSC2)
#pragma config CSWEN = ON       // Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable bit (FSCM timer disabled)

// CONFIG2
#pragma config MCLRE = ON       // Master Clear Enable bit (MCLR pin is Master Clear function)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config LPBOREN = OFF    // Low-Power BOR enable bit (ULPBOR disabled)
#pragma config BOREN = ON       // Brown-out reset enable bits (Brown-out Reset Enabled, SBOREN bit is ignored)
#pragma config BORV = LO        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (VBOR) set to 1.9V on LF, and 2.45V on F Devices)
#pragma config ZCD = OFF        // Zero-cross detect disable (Zero-cross detect circuit is disabled at POR.)
#pragma config PPS1WAY = OFF    // Peripheral Pin Select one-way control (The PPSLOCK bit can be set and cleared repeatedly by software)
#pragma config STVREN = ON      // Stack Overflow/Underflow Reset Enable bit (Stack Overflow or Underflow will cause a reset)

// CONFIG3
#pragma config WDTCPS = WDTCPS_31// WDT Period Select bits (Divider ratio 1:65536; software control of WDTPS)
#pragma config WDTE = SWDTEN    // WDT operating mode (WDT enabled/disabled by SWDTEN bit in WDTCON0)
#pragma config WDTCWS = WDTCWS_7// WDT Window Select bits (window always open (100%); software control; keyed access not required)
#pragma config WDTCCS = SC      // WDT input clock selector (Software Control)

// CONFIG4
#pragma config WRT = WRT_upper  // UserNVM self-write protection bits (0x0000 to 0x01FF write protected)
#pragma config SCANE = not_available// Scanner Enable bit (Scanner module is not available for use)
#pragma config LVP = ON         // Low Voltage Programming Enable bit (Low Voltage programming enabled. MCLR/Vpp pin function is MCLR.)

// CONFIG5
#pragma config CP = OFF         // UserNVM Program memory code protection bit (Program Memory code protection disabled)
#pragma config CPD = OFF        // DataNVM code protection bit (Data EEPROM code protection disabled)
unsigned char rtemp,sflag;

unsigned char buff;
unsigned char pcnt=0;
unsigned char rcnt=250;
unsigned char count;
unsigned char index;
unsigned char segCode;

const unsigned char table_3[]={'a'};//10
const unsigned char table_2[]={'9','6'};//9,6
const unsigned char table_1[]={'8','5','3'};//8,5,3
const unsigned char table_0[]={'7','4','2','1'};//7,4,2,1

void initSerial();
void initTMR0();
void initInterrupt();

void longpush(){
    rcnt=61;
    pcnt--;
    TXREG=segCode;
    return;
}

void doublepush(){
    pcnt=201;
    rcnt=61;
    TXREG=segCode;
    return;
}

void singlepush(){
    TXREG=segCode;
    return;
}

void check_btn(){
    count=0;
    TRISB=0x0f;
    WPUB=0x0f;
    index=0;
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
void __interrupt() ISR(void){
    if(TMR0IF){
        TMR0IF=0;
        check_btn();
    }
    if(RCIE&&RCIF)
        {
                RCIF=0;
                rtemp=RC1REG;
                sflag=1;
        }
}

void main(){

    ANSELB=0x0;
    TRISB=0x0f;
    PORTB=0x0;
    WPUB=0x0f;


    ADCAP =0x05;
    ADPRE =0x10;
    ADACQ =0x10;
    initSerial();
    initTMR0();
    initInterrupt();
    while(1){
        if(sflag==1)
                {
                        RCIE=0;
                        sflag=0;
                        TX1REG=rtemp;
                        while(!TXIF);
                        TXIF=0;        
                        RCIE=1;        
                }
    }
}

void initSerial(){
    
    SPBRGH=0x0;
    SPBRGL=0x19;
    
    ANSELBbits.ANSB7=0;
    
    RB6PPS=0x10;//output
    TRISBbits.TRISB6=0;

    RXPPS=0x0f;//input
    TRISBbits.TRISB7=1;

    BRG16=1;//
    BRGH=1;
    SPBRG=25;
    TX1STAbits.SYNC=0;
    SPEN=1;

    TXEN=1;
}

void initTMR0(){
    T0CON0=0b10000000;
    T0CON1=0b01010001;
    TMR0H=0xfa;
}
//init interrupt
void initInterrupt(){
    GIE=1;//enable global interrupt
    PEIE=1;//enable Peripheral Interrupt

    TMR0IE=1;
    TXIE=1;
    RCIE=1;
}