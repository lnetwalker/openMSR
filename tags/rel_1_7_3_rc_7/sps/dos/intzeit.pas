unit intzeit;


{ stellt eine interruptgesteuerte uhr zur verfuegung }
{ die an beliebiger stelle des textschirmes steht    }
{ (c) Nov/91 by HuSoft				     }

	
interface

{$F+}procedure ende_zeit;{$F-}
procedure zeit(x,y,f:byte);

implementation

uses dos,getgraph;

var aiv,exitsave:pointer;
    o,p,ids,ido:word;
    regs:registers;
    graphdriver:integer;

(* ErklÑrung der Variablen                                               *)
(* aiv = AltIntVec = Timerpointer vor verbiegen                          *)
(* O   = Offset    = Offset des Bildschirmspeichers                      *)
(* p   = Position  = Adresse der BildschirmpositionfÅr die Zeit          *)
(* ids = InDosSeg  = Segmentadresse des INDOSFLAG                        *)
(* ido = InDosOffs = Offsetadresse des INDOSFLAG                         *)


procedure ende_zeit;

(* alternative Endeprozedur in der der Timerinterrupt restauriert wird   *)

begin
     if mem[ids:ido]=0 then begin    (* MS DOS ist nicht aktiv *)
        SetIntVec(28,aiv);           (* Timervektor zurÅcksetzen *)
        exitproc:=exitsave;          (* Normales Pascalende      *)
     end
else exit;
end;

procedure anz;        (* Interruptprozedur zur Zeitanzeige *)
interrupt;
var s,m,d1,d2:word;
    asz,ase,amz,ame,c:byte;

(* s   = Stunde                                                          *)
(* m   = Minute                                                          *)
(* d1  = Dummy1                                                          *)
(* d2  = Dummy2                                                          *)
(* asz = AsciiStundeZehner = ASCII-Wert des Zehneranteils der Stunde     *)
(* ase = AsciiStundeEiner  = ASCII-Wert des Eineranteils  der Stunde     *)
(* amz = AsciiMinuteZehner = ASCII-Wert des Zhneranteils  der Minute     *)
(* ame = AsciiMinuteEiner  = ASCII-Wert des Eineranteils  der Minute     *)
(* c   = Counter = ZÑhler der angiebt nach wieviel Timerticks die Zeit   *)
(*                 aktualisiert wird                                     *)

begin
     if mem[ids:ido]=0 then    (* MSDOS nicht aktiv *)
        if c=0 then begin      (* Counter abgelaufen => Zeit aktualisieren *)
           c:=10;
           gettime (s,m,d1,d2);  (* MSDOS zeit lesen *)

(* Zeit in ASCII-Werte umrechnen *)

           asz:=48+trunc(s/10);
           ase:=48+s-trunc(s/10)*10;
           amz:=48+trunc(m/10);
           ame:=48+m-trunc(m/10)*10;

(* ASCII-Werte in Bildschirmspeicher schreiben *)

           mem[o:p]:=asz;
           mem[o:p+2]:=ase;
           mem[o:p+4]:=58;      (* Doppelpunkt *)
           mem[o:p+6]:=amz;
           mem[o:p+8]:=ame;
        end

        else dec(c) (* counter war noch nicht abgelaufen => herunterzÑhlen *)

     else exit;  (* MSDOS ist aktiv => nichts tun, sonst Chaos *)
end;

procedure zeit;
(* Initialisierungsroutine der Zeitanzeige *)

var ab:word;
    i:byte;

(* ab = Adresse des Attributbytes                                          *)
(* i  = ZÑhler  fÅr das Schreiben des Attributbytes                        *)

begin
(* Adresse der Bildschirmposition ermitteln                                *)
     p:=x*160+y*2;
(* Attribute in Bildschirmspeicher schreiben                               *)
     ab:=p+1;
     for i:=1 to 5 do begin
         mem[o:ab]:=f;
         inc(ab,2);
     end;
(* Adresse des INDOS Flags ermitteln                                       *)
     regs.ah:=$34;
     msdos(regs);
     ids:=regs.es;
     ido:=regs.bx;
(* Pascalende auf eigene Endeprocedur legen                                *)
     exitsave:=exitproc;
     exitproc:=@ende_zeit;
(* Timerinterrupt verbiegen                                                *)
     GetIntVec(28,aiv);
     SetIntVec(28,@anz);
end;

begin
(* Startadresse des Bildschirms festlegen                                  *)
    graphdriver:=ord(graph_mode);
    if graphdriver=ord(hga) then O:=$b000
    else o:=$b800;
end.