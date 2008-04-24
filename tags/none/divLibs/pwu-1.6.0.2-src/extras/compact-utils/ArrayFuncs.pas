{ Functions to assist array work.
  by Lars (L505) }
unit ArrayFuncs;

interface

function AssignArray(src: array of string): TStrArray;

implementation

{ assigns an array to a new location (like a copy) }
function AssignArray(src: array of string): TStrArray;
var
  i: integer;
begin
  SetLength (result, Length(src));
  for i:= Low(src) to High(src) do
    result[i]:= src[i];
end;

end.
 
