/* -----------------------------------------
 * KOLTER ELECTRONIC (c) 1999
 * SuSE Linux DLD 6.0/6.1
 * -----------------------------------------
 * Programmversion 	: 1.2
 * Programmname		: pciad.c
 * Linux-Kernel 	: 2.2.2-pre6 mit SuSE
 * Compile with GNU    	: gcc -O2 -o pciad pciad.c
 * GCC Version		: 2.7.2.3
 * Autor		: Heinrich Kolter
 * Testrechner		: 586 AMD K6-200
 * 			: Pentium-II 450
 *			: Cerleron 333 MHz
 *
 * Fuer Kartentype	: PCI-DA
 *
 * Beispiel-Source ist in GNU-C geschrieben
 * datum 02.07.1999
 * -----------------------------------------
*/

#include <stdio.h>
#include <unistd.h>
#include <asm/io.h>

#define adr 0x6500 		// absolute I/O-Adresse

void DAC_test()			// D/A-Kanaele programmieren
{
int dummy;

// DATA :   D15................D0
// +10 Volt = xxxx 1111 1111 1111
//   0 Volt = xxxx 1000 0000 0000
// -10 Volt = xxxx 0000 0000 0000
//            high-byte  low-byte

// set DAC auf + 10.000 Volt
outb(255,adr+32);		// low-byte  DAC A
outb(15,adr+36);		// high-byte DAC A

// set DAC auf + 5.000 Volt
outb(0,adr+40);			// low-byte  DAC B
outb(12,adr+44);		// high-byte DAC B

// set DAC auf - 5.000 Volt
outb(0,adr+48);			// low-byte  DAC C
outb(4,adr+52);			// high-byte DAC C

// set DAC auf - 10.000 Volt
outb(0,adr+56);			// low-byte  DAC D
outb(0,adr+60);			// high-byte DAC D

dummy = inb(adr+29);		// read = uebergabe der DAC-Register
}

// ---------------------------------------------------------
int main()
{
// Testen der Karte
printf("\n\a\f");
printf("Teste PCI-Karte auf I/O-Adresse %4d dezimal \n", adr);

// oeffne alle PC-Hardware-Ports
iopl(3);					

// Test der D/A-Kanaele
DAC_test();
printf("Werte an DAC-Register uebergeben...\n\n ");
getchar();

exit(0);
}
