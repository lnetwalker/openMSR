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
 * Fuer Kartentypen PCI-ADDA, PCI-AD, PCI-DA
 *
 * Beispiel-Source ist in GNU-C geschrieben
 * erstellt am 02.07.1999
 * geprueft am 19.07.1999 / ko
 * -----------------------------------------
*/

#include <stdio.h>
#include <unistd.h>
#include <asm/io.h>

#define adr 0x6500 	// physikalische I/O-Adresse der A/D-Karte

// Globale Vars
int		kanal, digit,dummy;
int		LB, HB;
double		volt;
char		stat;

// Konstante fuer 1 digit (LSB) in Volt
double mvd = 0.0003051804379;
			
// ---------------------------------------------------------
void ad_status()				// lese A/D status-bit EOC ein
{
if ((inb(adr+1) & 1) == 0) stat = 1;
	else stat = 0;
}

// ---------------------------------------------------------
void ADC_wandel()				
{
// Wandlungsroutine CONVERT einleiten
	outb(1,adr);				// ADC RC=high =  read
        outb(1,adr);				// 2 X
	outb(0,adr);				// ADC RC=low  =  convert

// Status-Bit abfragen ob EOC=TRUE, sonst EOC wieder neu holen
// EOC = End Of Conversion = Wandlungsende abwarten bis Wert gebildet
do
ad_status();
while (stat != 0);

// ADC-Daten bilden und in digit ablegen
	outb(1,adr);				// ADC umschalten auf read mit higher-byte	
	HB = inb(adr);				// lese high-byte von A/D Wandler
	outb(3,adr);				// ADC umschalten auf lower-byte	
	LB = inb(adr);				// lese low-byte von A/D-Wandler
	digit=(HB*256) + LB;			// digit bilden. Werte zwischen 0...65535
}

// ---------------------------------------------------------
void ADC_test()					// A/D-Kanaele messen
{
for (kanal=0; kanal<16; kanal++)
{ 
	outb(kanal,adr+4);			// Multiplexer-Kanal einstellen
	usleep(20);				// warten fuer MUX, min. 4 us.
						// je laenger = umso genauer
	ADC_wandel();
	volt = (digit * mvd) - 10;		// berechne hier nach +-10 Volt

	printf("  Kanal %2d = digit = %5d    = %3.3f Volt \n", kanal,digit,volt);
}
}

// ---------------------------------------------------------
int main()
{
// Testen der AD-Karte
printf("\n\a\f");
printf("Teste PCI-Karte auf I/O-Adresse %4d dezimal \n", adr);

// oeffne alle ports
iopl(3);					

// Test der A/D-Kanäle 1..16
ADC_test();

printf("Taste druecken fuer Ende... ");
getchar();
exit(0);
}
