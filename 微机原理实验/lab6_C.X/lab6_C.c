/*
 * File:   main.c
 * Author: zhaozhan
 *
 * Created on 2023?7?15?, ??7:03
 */

#include <xc.h>
#ifndef BOOTLOADER
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
#pragma config WDTE = OFF
//#pragma config WDTE = SWDTEN    // WDT operating mode (WDT enabled/disabled by SWDTEN bit in WDTCON0)
#pragma config WDTCWS = WDTCWS_7// WDT Window Select bits (window always open (100%); software control; keyed access not required)
#pragma config WDTCCS = SC      // WDT input clock selector (Software Control)
// CONFIG4
#pragma config WRT = WRT_upper  // UserNVM self-write protection bits (0x0000 to 0x01FF write protected)
#pragma config SCANE = not_available// Scanner Enable bit (Scanner module is not available for use)
#pragma config LVP = ON         // Low Voltage Programming Enable bit (Low Voltage programming enabled. MCLR/Vpp pin function is MCLR.)
// CONFIG5
#pragma config CP = OFF          // UserNVM Program memory code protection bit (Program Memory code protection enabled)
#pragma config CPD = OFF        // DataNVM code protection bit (Data EEPROM code protection disabled)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.
#endif

const unsigned char SEGMENT[11] = {
    0x7f,   //0
    0x06,   //1
    0xdb,   //2
    0xcf,   //3
    0xe6,   //4
    0xed,   //5
    0xfd,   //6
    0x07,   //7
    0xff,   //8
    0xef,   //9
    0xf7,   //a
};
unsigned char segBuf[4] = {0x7f, 0x7f, 0x7f, 0x7f};

void __interrupt() ISR(void);
void delay();
void scan_LED();
void div_num();

int ADCcount = 0;
int ADCres = 0;
int voltage = 0;

char idx = 0;
char posCode = 0xf7;//0b11110111

void scan_LED(void) {
    /*
     Only require to fill the segBuf to display.
     */
    PORTA = segBuf[idx];
    PORTC = posCode;
    posCode = posCode >> 1;
    idx++;
    if(idx == 4) {
        posCode = 0xf7;
        idx = 0;
    }
}

void div_num() {
    segBuf[3] = SEGMENT[(voltage)/1000];
    segBuf[2] = SEGMENT[(voltage/100)%10];
    segBuf[1] = SEGMENT[(voltage/10)%10];
    segBuf[0] = SEGMENT[(voltage)%10];
}


void __interrupt() ISR(void) {
    PIR0bits.TMR0IF = 0;     // Remember to clear it.
    scan_LED();
    return;
}

int main(void)
{
    //portA Config
    ANSELA = 0;
    TRISA = 0;
    LATA = 0;
    //portB config
    ANSELB = 0;
    TRISB = 0xff;
    WPUB = 0xff;
    TRISB = 0x0;
    //portC config
    ANSELC = 0;
    TRISC = 0;
    LATC = 0;
    //timer config
    T0CON0 = 0b10000000;
    T0CON1 = 0b01000010;
    //ADC config 
    ADCON0 = 0x84;//0b10000100  bit7 to enable,bit2 to right-justified
    ADPCH = 0xff; // FVR  ???????????????
    ADREF = 0x00;//Vref-??Vss?Vref+??Vdd
    FVRCON = 0x81;//0b10000001  bit7????????    bit0??FVR???1.024V
    //interrupt config
    INTPPS = 0x08;
    INTCON = 0x81;//0b10000001  bit7??GIE    bit6?????? bit0?????int????
    PIE0 = 0x20;//0b00100000    ??timer0??
    while(1) {
        int v_high = ADRESH;
        int v_low = ADRESL;
        ADCON0 |= 0x01;//ADC????
        ADCres = (v_high << 8) | v_low;
        voltage = 1024.0 * 1024 / ADCres; // add very long asm
        div_num();
        for(int i=0; i<10000; ++i);
    };
    return 0;
}

