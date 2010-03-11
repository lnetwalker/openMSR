/* -----------------------------------------------------------
 * KOLTER ELECTRONIC (c) 1999
 * SuSE Linux DLD 6.0/6.1
 * -----------------------------------------------------------
 * Programmversion 	: 1.0
 * Programmname		: IOTEST.C
 * Linux-Kernel 	: 2.2.2-pre6 mit SuSE 6.1
 * Compile with     	: gcc -O2 -o IOTEST IOTest.c
 * GCC Version		: 2.7.2.3
 * Stand		: 1.06.1999
 * Autor		: Heinrich Kolter
 * Testrechner		: 586 AMD K6-200
 * 			: Pentium-II 450
 *			: Cerleron 333 MHz
 * Kartentypen   	: PCI1616
 *                	: OPTO-PCI /N
 *                	: OPTO-PCI /P
 *                	: PCI-Relais
 *                	: PCI-OptoRel
 *
 * Dieser Beispiel-Source in GNU-C ist dermassen einfach,
 * dass DLLs oder andere Treiber voellig ueberzogen waeren
 * und somit hinfaellig werden.
 * Sie koennen die I/O-Ports jederzeit unter Linux ansteuern.
 * -----------------------------------------------------------
*/

#include <stdio.h>
#include <unistd.h>
#include <asm/io.h>

#define BASEPORT 0x6500		// absolute PCI-Kartenadresse

int main()
{
unsigned char port_a;
unsigned char port_b;

printf("Test fuer I/O-PC-Karten  \n ");

  iopl(3);           		// oeffne alle I/O-Ports
                                // die auch ueber 03ff liegen

// teste Port write mit: output(byte,adresse);

  outb(255,BASEPORT+0);		// schreibe FF auf 1. Port 8-bit 	
  outb(255,BASEPORT+1);         // schreibe FF auf 2. Port 8-bit 	
    usleep(2000000);   		// Beispiel 2 Sekunden warten     	

  outb(85,BASEPORT+0);          // 01010101
  outb(170,BASEPORT+1);         // 10101010
    usleep(1000000);   		// 1 Sekunde warten 		

  outb(170,BASEPORT+0);         // 10101010
  outb(85,BASEPORT+1);          // 01010101
    usleep(1000000);   		// 1 Sekunde warten 	

  outb(0,BASEPORT+0);           // 00000000
  outb(0,BASEPORT+1);           // 00000000
    usleep(1000000);   		// 1 Sekunde warten 	

// jetzt die beiden I/O-Ports auslesen

  port_a = inb(BASEPORT+4);
  port_b = inb(BASEPORT+5);
  printf("Port A = %3d \n ",port_a);
  printf("Port B = %3d \n ",port_b);

// Ende
 exit(0);
}
