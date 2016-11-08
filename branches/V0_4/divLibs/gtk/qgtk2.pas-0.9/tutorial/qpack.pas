program qHelloPack;

{ Demo program for  qgtk2.pas

  Quick programming with gtk in pascal,
  Freepascal, gtk+

  (c) 2002 Jirka Bubenicek  -  hebrak@yahoo.com


  License: GNU GENERAL PUBLIC LICENSE

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
}



uses qgtk2;


begin


qstart('Hello buttons!', nil, nil);

qLabel('Hello'); qButton('qButton', nil); qLabel('and qLabel');

qNextRow;
qLabel('1 qNextRow  qLabel'); qButton('and qButton', nil);

qFrame;
qButton('2 qFrame',nil); 
qNextRow;
qlabel('3 qNextRow in frame -'); qLabel('and qLabel');
qseparator;
qlabel('4 qseparator in frame'); qButton('and qButton', nil);

qFrame;
qLabel('5 qFrame'); qButton('and qButton', nil);
qNextRow;
qLabel('6 qLabel       ');

qEndFrame;

qLabel('7 qEndFrame'); qButton('and qButton', nil);
   qButton('...', nil); qButton('and QUIT', @qDestroy);


qGo;


end.