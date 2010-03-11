Linux-"Treiber" (Source)
Von KOLTER ELECTRONIC (c) 1999

Kopieren Sie zuerst den gesamten Inhalt der Diskette
in das root-Verzeichnis: ../ kolter.

Das Beispiel IOTEST.C ist fuer folgende PC-Karten 
verwendbar: PCI1616, OPTO-PCI/N, OPTO-PCI/P, PCI-Relais
und PCI-OptoRel.

Das Beispiel PCIAD.C ist fuer folgende PC-Karten anwendbar:
PCIAD12, PCIAD16 und alle PCI-ADDA.

Diese Beispiel-Sourcen in GNU-C sind dermassen einfach,
dass DLLs oder andere Treiber voellig ueberzogen waeren
und somit hinfaellig werden. Sie koennen die I/O-Ports
jederzeit unter Linux direkt ansteuern. Dabei spielt es 
keine Rolle ob Sie unter bash oder einer KDE X-Oberflaeche 
arbeiten.

Die I/O-Programmierung wird durch den Befehl IOPL(3)
auch fuer den Adressbereich ueber 03ff HEX ermoeglicht. 
Die hierfuer verwendeten INCLUDES /asm und /unistd finden
Sie im Linux-Root-Verzeichnis ../usr/include/asm

Eine Kernel-Anpassung oder Kernel-Compilierung ist
nicht erforderlich. Das Programm wird mit dem GNU-C
Standard-Compiler uebersetzt. Dazu muessen Sie den 
Compiler wie folgt aufrufen:

gcc -O2 -o iotest iotest.C

Nach erfolgreicher Uebersetzung erhalten Sie die
ausfuehrbare Datei: iotest pciad u.s.w.

Um iotest auszufuehren, muessen Sie diese Datei
als AUSFUEHRBARE DATEI in Ihr Root-System kopieren.   

Denken Sie daran, dass PCI-Karten je nach BIOS und
je nach Rechnertype einer anderen I/O-Adresse zugewiesen
werden. Das hier verwendete I/O-Beispiel, mit der Adresse
6500 HEX ist nicht representativ fuer alle Rechnersysteme.
Um die zu verwendende I/O-Adresse ausfindig zu machen,
gilt das Programm PCI-INF.EXE unter DOS anzuwenden.

Unter Linux (S.u.S.E.) finden Sie auch brauchbare Utils,
die die PCI-I/O-Adresse ermitteln. Rufen Sie unter KDE
dazu bitte wie folgt auf:

KDE(unten links) 
Einstellungen / Information / PCI

Unter der Vendor-ID 0x1001 finden Sie die Produkt-ID der
Karte. Z.Bsp. hat die PCI-ADDA die Produkt-ID 0x0012 Hex.
Unter dieser Nummer finden Sie mit der PCI-Hilfsroutine
den entsprechenden I/O-Adressbereich bzw. die 
Startadresse dieser Karte. Tragen Sie diese I/O-Adresse
dann anschliessend in Ihren C-Source ein und compilieren
Sie das Projekt neu um die angepasste Adresse in der
AUSFUEHRBAREN DATEI zu uebernehmen.


H.Kolter 04/07/1999

