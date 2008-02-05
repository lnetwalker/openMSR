Qgtk2.pas - rychlé programování v Pascalu s knihovnami gtk2
-----------------------------------------------------------


Freepascal 2.0 umo¾òuje vyu¾ívat gtk2 knihovny pro X-windows, 
nebo i pro M$ windows.     
Pou¾ití gtk2 knihoven je v¹ak trochu komplikované a trvá asi
vìt¹inou mnoho týdnù, ne¾ se to nìkdo nauèí. 
Programová jednotka qgtk2.pas toto velmi zjednodu¹uje a urychluje,
neumo¾òuje sice plnì vyu¾ít v¹ech mo¾ností gtk2, ale pøesto pro
mnoho jednodu¹¹ích programù bude bohatì staèit. 

Qgtk2.pas vzniklo upravou qgtk.pas, ktere poziva gtk1.
Ve verzi 0.9 je jeste mnoho v gtk2 obsolentnich a deprecated funkci, 
ale funguje to.



Nutno mit nainstalovany Freepascal 2.0 (a vyssi)
 http://www.freepascal.org/

Pro M$ Windows jsou nutne gtk2 dll knihovny
Mozno stahnout z http://members.lycos.co.uk/alexv6/



Zmeny v qgtk2 oproti qgtk:

nepouziva se qgdkfont, font urcuje primo qfontname

Promene qfontname a podobne qfontname0 jsou ve tvaru "Sans Bold 12" (pouziva se pango)
(a ne jak to bylo v qgtk ve tvaru "-*-helvetica-medium-r-*-*-*-120-*-*-p-*-iso8859-2")



License: GNU GENERAL PUBLIC LICENSE                                                             
                                                                                                
(c) 2005 Jirka Bubenicek  - hebrak@yahoo.com
