program spsdatalogger;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net					}
{ distributed  under the terms of the GNU GPL V 2					}
{ see http://www.gnu.org/licenses/gpl.html for details				}

{ this program may be used as an datalogger in connection with 		}
{ the SPS Software													}

uses qgtk2;

const	
	version='V 0.1';

var 
	maxx,maxy,
	TimeBase,
	Messung,
	xfakt,yfakt,
	xOffset,
	Timer,
	OldTimer		: word;

	eingang,
	ausgang,
	ein_alt,
	aus_alt			: array[1..16] of boolean;

	PauseButton,
	ExitButton,
	TimerValue		: qWidget;
	Pause			: boolean;

procedure oncreate;

var x,z,leftoffset,
	tx				: word;
	ch				: string;
	meldung			: string;


begin
	{ black Background }
	qsetClr( qBlack );
	qfillrect( 0, 0,maxx-1, maxy-1);
	qsetClr( qWhite );
	qfont(yfakt-8);
	(*writeln ('xfakt:=',xfakt,' yfakt=',yfakt);*)
    qrect(0,0,maxx,maxy);
    meldung:='SPS Datalogger '+version;
	leftoffset:=round(length(meldung)/2)+10;
	(*writeln('leftoffset=',leftoffset);*)
    qdrawtext(round(maxx/2-(leftoffset*xfakt)),1*yfakt,meldung);
    qrect(xOffset,3*yfakt,maxx,8*yfakt+10);
	qrect(xOffset+1,3*yfakt+1,maxx,8*yfakt+10);
	qrect(xOffset,16*yfakt,maxx,8*yfakt+10);
    qrect(xOffset+1,16*yfakt+1,maxx,8*yfakt+10);
    for x:=1 to 8 do begin
    	str(x,ch);
        z:=(x+3)*yfakt;
		writeln('x=',x,' z=',z);
		qdrawtext(xfakt,z,'E'+ch);
        qline(xOffset,z+1,maxx,z+1);

		z:=(x+16)*yfakt+1;
        qdrawtext(xfakt,z,'A'+ch);
        qline(xOffset,z,maxx,z);
        qline(xOffset,z+1,maxx,z+1);
    end;
	qdrawtext(1,14*yfakt,'Time');
    qline (xOffset,14*yfakt-4,maxx,14*yfakt-4);
    tx:=xOffset;
    while (tx<=maxx) do begin
		qline(tx,14*yfakt-8,tx,14*yfakt);
        inc(tx,8);
	end;
end;

function GetNewValue: integer;
var	k	: byte;
begin
	for k:=1 to 8 do begin
		if (Random<=0.5) then
			eingang[k]:=false
		else
			eingang[k]:=true;
		if (Random<=0.5) then
			ausgang[k]:=false
		else
			ausgang[k]:=true;
	end;
end;


procedure set_hi_low;              {zeichnet linie fuer hi/ bzw. low }
var x			: byte;
    z,y			: word;

begin
	y:=Messung*8+xOffset;
	qsetClr( qGreen );
	for x:=1 to 8 do begin
		z:=(x+3) * yfakt-8*ord(eingang[x]);
		qline(y-8,z,y,z);
		if ein_alt[x]<>eingang[x] then begin
			qline(y-8,(x+3)*yfakt,y-8,(x+3)*yfakt-8);
			{setlinestyle(dashedln,0,normwidth);}
			{qline(y-8,(x+3)*yfakt,y-8,(8+15)*yfakt)};
		end;
		z:=(x+16)*yfakt-8*ord(ausgang[x]);
		qline(y-8,z,y,z);
		if aus_alt[x]<>ausgang[x] then
			qline(y-8,(x+16)*yfakt,y-8,(x+16)*yfakt-8);
		ein_alt[x]:=eingang[x];
		aus_alt[x]:=ausgang[x];
     end;
end;                               { **** ENDE SET_HI_LOW ****}



procedure ontimer;
begin
	if (not(Pause)) then begin
		GetNewValue;
		set_hi_low;
		inc(Messung);
		if (Messung>TimeBase) then begin
			Messung:=1;
			oncreate;
		end;
	end;
end;


procedure onclose;
begin
if qdialog('Quit?','Yes', 'No','') =1 then
      qdestroy;
end;


procedure onPause;
begin
	if qToggleGetA(PauseButton) then Pause:=true
	else Pause:=false;
end;

procedure onTimebase;
begin
	val(qinput('Timervalue in ms:', '20'),Timer );
	if Timer <> 0 then
		if Timer <> OldTimer then begin
			writeln('Timebase changed try to stop timer ',OldTimer,'  ms');
			qtimerstop(OldTimer);
			OldTimer:=Timer;
			writeln ( ' restarting new timer with ',Timer,' ms');
			qtimerstart(Timer, @ontimer);
		end
end;


begin
    maxx:=640;maxy:=480;
    xfakt:=round(maxx/80);yfakt:=round(maxy/25);
	xOffset:=5*xfakt;
	{ TimeBase gibt an wieviel Messpunkte in x-Richtung platz haben  }
	TimeBase:=round((maxx-xOffset)/8);
	Timer:=20;
	OldTimer:=Timer;
	Messung:=1;
	randomize;
	qstart('Datalogger', nil, nil);
	TimerValue:=qbutton('Timebase',  @onTimebase);
	PauseButton:=qbuttonToggle('||', @onPause);
	ExitButton:=qbutton('Exit',@onClose);
	qNextRow;
	qdrawstart(maxx,maxy, @oncreate,nil, nil);
	qtimerstart(Timer, @ontimer);

	qGo;
end.

