{ this unit provides the function StringSplit which allows you 	}
{ to split a string in words with the possibility to use any	}
{ character as delimiter. The result is an array with the words }
{ in addition there is the function GetNumberOfElements which	}
{ counts the elements in the given string.			}
{ this unit is published under the terms of the GPL V 2 or any	}
{ later version. (c) by Hartmut Eilers <hartmut@eilers.net>	}
unit StringCut;

{ $Id$ }

interface

{ used Type definitions }
type
  { the string to split }
  String255	= String [255];

  { the resulting array of the splitted string }
  StringArray 	= array [1..255] of String255;


function StringSplit(Line : String255; Trenner : Char):StringArray;
function GetNumberOfElements( Line : String255; Trenner : Char):Integer;
function RemoveDoubleChars(Line : String255; DoubleChar : Char):String255;
function IntegerInString(s: string) : integer;

implementation

uses sysutils;

function RemoveDoubleChars(Line : String255; DoubleChar : Char):String255;
var
	x	: byte;
begin
	x:=1;
	repeat
		if (Line[x]=DoubleChar) then begin
			if ( x+1 <= length(Line) ) then
				if (Line[x+1]=DoubleChar) then
				// remove the actual char from Line
					Line:=copy(Line,1,x-1) +copy(Line,x+1,length(Line))
				else
					inc(x);
		end
		else
			inc(x);
	until ( x >= length(Line));
	RemoveDoubleChars:=Line;
end;


function StringSplit(Line : String255; Trenner : Char):StringArray;
var
  i,y		: integer;
  TrennPos	: array [1..255] of integer;
  Result	: StringArray;

begin
  // remove double Trenner chars from Line
  Line:=RemoveDoubleChars(Line,Trenner);
  { check for all Trenner chars in Line and save the positions }
  y:=1;
  for i:=1 to length(Line) do
    if line[i] = Trenner then begin
      TrennPos[y]:=i;
      inc(y);
    end;
  if (pos(Trenner,Line) > 0 ) then begin
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
	     Result[i]:=copy(Line,TrennPos[i-1]+1,Length(Line));
  end
  else Result[1]:=Line;

  { splitting is done return result }
  StringSplit:=Result;
end;


function GetNumberOfElements( Line : String255; Trenner : Char):Integer;
var
  Anzahl,i	: Integer;

begin
  // remove double Trenner chars from Line
  Line:=RemoveDoubleChars(Line,Trenner);

  // check if at least one elemnt
  if ( length(Line) = 0 ) then Anzahl := 0
  else Anzahl := 1;

  for i:=1 to length(Line) do
    if line[i] = Trenner then inc(Anzahl);

  // return the number of elements
  GetNumberOfElements:=Anzahl;
end;


function IntegerInString(s: string) : integer;
var i, state, startPos, endPos : integer;
begin
  state := 0;
  startPos := -1;
  endPos := Length(s);
  for i := 1 to Length(s) do begin
    if ((s[i] >= '0') and (s[i] <= '9')) then begin
      if state = 0 then startPos := i;
      state := 1;
    end
    else
      if state = 1 then begin
        endPos := i-1;
        break;
      end;

  end;
  if startPos > -1 then
    IntegerInString := StrToInt(Copy(s, startPos, endPos))
  else
    IntegerInString := -2147483648;
end;

begin
end.
