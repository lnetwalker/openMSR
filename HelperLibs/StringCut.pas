unit StringCut;

{ this unit provides the function StringSplit which allows you 	}
{ to split a string in words with the possibility to use any	}
{ character as delimiter. The result is an array with the words }
{ in addition there is the function GetNumberOfElements which	}
{ counts the elements in the given string.			}
{ this unit is published under the terms of the GPL V 2 or any	}
{ later version. (c) by Hartmut Eilers <hartmut@eilers.net>	}

{ $Id$ }

interface

type
  String255	= String [255];
  StringArray 	= array [1..255] of String255;

function StringSplit(Line : String255; Trenner : Char):StringArray;
function GetNumberOfElements( Line : String255; Trenner : Char):Integer;

implementation

function StringSplit(Line : String255; Trenner : Char):StringArray;
var 
  i,y		: integer;
  TrennPos	: array [1..255] of integer;
  Result	: StringArray;
  
begin
  { check for all Trenner chars in Line and save the positions }
  y:=1;
  for i:=1 to length(Line) do
    if line[i] = Trenner then begin
      TrennPos[y]:=i;
      inc(y);
    end;
  { now all Trenner positions are known }
  { loop over the array of positions and split the string }
  for i:=1 to y do
    if i=1 then
      { start splitting at position 1 }
      Result[i]:=copy(Line,1,TrennPos[i]-1)
    else if i<y then
	{ start splitting at last position+1 }
	Result[i]:=copy(Line,TrennPos[i-1]+1,TrennPos[i]-TrennPos[i-1]-1)
      else
	{ the last element split to end of string }
	Result[i]:=copy(Line,TrennPos[i-1]+1,Length(Line)-TrennPos[i]-1);
  { splitting is done return result }
  StringSplit:=Result;
end;


function GetNumberOfElements( Line : String255; Trenner : Char):Integer;
var
  Anzahl,i	: Integer;
  
begin
  Anzahl := 0;
  for i:=1 to length(Line) do
    if line[i] = Trenner then inc(Anzahl);
  GetNumberOfElements:=Anzahl+1;
end;


begin
end.