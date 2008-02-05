unit autograf;

(* Diese Unit bindet die Grafiktreiber fÅr die HERCULES-,CGA-,   *)
(* EGA- und die VGA Karte fest in ein Programm ein, wodurch das  *)
(* langwierige laden von Diskette entfÑllt.                      *)




interface

uses graph;

var GrafikDummy  : integer;

procedure herc;
procedure cga;
procedure egavga;


implementation

procedure herc ; external;
{$L c:\bp\bgi\HERC }

procedure cga ; external;
{$L c:\bp\bgi\CGA }

procedure egavga ; external;
{$L c:\bp\bgi\EGAVGA }

begin
  grafikdummy:=RegisterBGIDriver(@HERC);
  grafikdummy:=RegisterBGIDriver(@CGA);
  grafikdummy:=RegisterBGIDriver(@EGAVGA);
end.