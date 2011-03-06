program qHelloPack2;

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


qstart('Hello pack 2', nil, nil);
qLabel('Default there is the same size of widgets in row,');
qNextRow;
qLabel('if window is resizable then widgets are resizable in width ');
qNextRow;
qLabel('Blank label'); qButton('can separate', nil); qLabel(''); qButton('buttons', nil);

qNextRowLeft;
qLabel(' qNextRowLeft'); qButton('x', nil);
 qLabel('minimal size of widgets, not resizable '); qButton('and QUIT', @qDestroy);

qNextRow;
qLabel('Try resize the window and look at the next row');
qNextRowResize; 
qLabel('qNextRowResize set window resizable'); qButton('and fully resizable qButton', nil);

qFrame;
qNextRowLeft;
qLabel(' qNextRowLeft in qFrame'); qButton('1', nil); qButton('- 2 -', nil);
qLabel('.                  .');
qFrame;
qNextRowLeft;
qButton('QUIT', @qDestroy);
qEndFrame;




qGo;


end.