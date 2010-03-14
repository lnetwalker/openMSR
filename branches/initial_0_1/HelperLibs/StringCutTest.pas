program StringCutTest;

{ Testprogram for the StringCut unit 	}
{ (c) 2010 by Hartmut Eilers		}
{ distributed under the terms of GPL	}

{ $ID:$ }

uses StringCut;

var
  T	 	: Array[1..3] of String255;
  Ergebnis	: StringArray;
  i,y		: integer;

begin
  T[1]:='Das ist ein Test für die StringCut Unit';
  T[2]:='    Ein Test mit Trennern zu Beginn';
  T[3]:='Ein anderer Test mit Trennern am Ende     ';
  for y:=1 to 3 do begin
    writeln('test ',y,':');
    writeln(T[y],'!');
    Ergebnis:=StringSplit(T[y],' ');
    for i:=1 to 10 do
      writeln(Ergebnis[i],'!');
    writeln;  
  end; 
  Writeln(T[1],' Anzahl=',GetNumberOfElements(T[1],' '),' Soll=8');
  Writeln(T[2],' Anzahl=',GetNumberOfElements(T[2],' '),' Soll=10');
  Writeln(T[3],' Anzahl=',GetNumberOfElements(T[3],' '),' Soll=12');
end.