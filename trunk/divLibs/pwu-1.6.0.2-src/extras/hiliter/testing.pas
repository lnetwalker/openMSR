unit testing;

{$mode objfpc} {$h+}

interface

type 
  somebyte = byte;

const
  SOME_CONST = 'test';

var
  somevar: somebyte;

implementation

procedure testproc(var i: integer);
var
  s: string;
begin
  s:= 'hello'; //comment
  writeln(s);
  i:= 12345;
end;

(* Comment... *)
 
{ Comment.. }

end.
