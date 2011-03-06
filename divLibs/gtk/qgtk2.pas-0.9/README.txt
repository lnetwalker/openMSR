Qgtk2.pas - quick programming in Pascal with gtk2 libraries
-----------------------------------------------------------


Freepascal 2.0 allows you to use gtk2 libraries for X-windows 
or even for M$ windows.
The usage of gtk2 libraries is rather complicated and it usually takes 
many weeks to learn it.
The unit qgtk2.pas makes the usage of gtk2 simpler and quicker. Although it
doesn't give you the possibility of using all the features of gtk2 it will be
sufficient enough for many easier programs.

Qgtk2 is a modification of qgtk.pas which uses gtk1.
There are still many deprecated and obsolete functions in version 0.8, but it does work.


You need to have installed Freepascal 2.0 (or higher)
 http://www.freepascal.org/  

For M$ Windows you need gtk2 runtime dll library
You can download it from http://members.lycos.co.uk/alexv6/



Changes in qgtk2

There isn't used qgtkfont (like in qgtk), but the font is set directly by the variable
qfontname.

The variable qfontname and similarly qfontname0 are for instance "Sans Bold 12" (pango is used)
and not like in qgtk where it was "-*-helvetica-medium-r-*-*-*-120-*-*-p-*-iso8859-2"




License: GNU GENERAL PUBLIC LICENSE

(c) 2002-2005 Jirka Bubenicek  - hebrak@yahoo.com  
