program datalogger;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net					}
{ distributed  under the terms of the GNU GPL V 2					}
{ see http://www.gnu.org/licenses/gpl.html for details				}

{ this program may be used as an datalogger in connection with 		}
{ the SPS Software													}

{ $Id$ }

uses qgtk2,PhysMach;

const	
	version='V 0.1';
	TimeLengthPixel=8;	// gibt an wieviel pixel eine Zeiteinheit lang ist

var 
	maxx,maxy,
	TimeBase,
	Messung,
	xfakt,yfakt,
	xOffset,
	Timer,
	leftoffset,
	OldTimer		: word;

	input_group1,
	input_group2,
	ig1_alt,
	ig2_alt			: array[1..8] of boolean;

	PauseButton,
	ExitButton,
	TimerValue,
	SaveButton,
	StartButton		: qWidget;
	Pause,
	SaveData		: boolean;
	
	Background		: qpic;

	meldung			: string;

	f				: text;


procedure printMeldung;
begin
	qsetClr( qBlack );
	qfillrect( 0, 0,maxx-1, yfakt);
	qsetClr( qWhite );
	qdrawtext(xfakt,1*yfakt,meldung);
end;

procedure onCreate;

var x,z,tx			: word;
	ch				: string;


begin
	{ black Background }
	qsetClr( qBlack );
	qfillrect( 0, 0,maxx-1, maxy-1);
	qsetClr( qWhite );
	qfont(yfakt-8);
	(*writeln ('xfakt:=',xfakt,' yfakt=',yfakt);*)
    qrect(0,0,maxx,maxy);

	str(Timer,meldung);
	meldung:='Timebase: '+meldung+' ms';
    qdrawtext(xfakt,1*yfakt,meldung);

    qrect(xOffset-2,3*yfakt,maxx,8*yfakt+10);
	qrect(xOffset-2+1,3*yfakt+1,maxx,8*yfakt+10);
	qrect(xOffset-2,16*yfakt,maxx,8*yfakt+10);
    qrect(xOffset-2+1,16*yfakt+1,maxx,8*yfakt+10);
    for x:=1 to 8 do begin
    	str(x,ch);
        z:=(x+3)*yfakt;
		writeln('x=',x,' z=',z);
		qdrawtext(xfakt,z,'S'+ch);
        qline(xOffset,z+1,maxx,z+1);

		str(x+8,ch);
		z:=(x+16)*yfakt+1;
        qdrawtext(xfakt,z,'S'+ch);
        qline(xOffset,z,maxx,z);
        qline(xOffset,z+1,maxx,z+1);
    end;
	qdrawtext(1,14*yfakt,'Time');
    qline (xOffset,14*yfakt-4,maxx,14*yfakt-4);
    tx:=xOffset;
    while (tx<=maxx) do begin
		qline(tx,14*yfakt-8,tx,14*yfakt);
        inc(tx,TimeLengthPixel);
	end;
	// save the Background
	qgetpic(xOffset+TimeLengthPixel,3*yfakt,TimeLengthPixel,24*yfakt,Background);
end;

function GetNewValue: integer;
var	k	: byte;
begin
	for k:=1 to 8 do begin
		if (Random<=0.5) then
			input_group1[k]:=false
		else
			input_group1[k]:=true;
		if (Random<=0.5) then
			input_group2[k]:=false
		else
			input_group2[k]:=true;

		if SaveData then begin
			write(f,input_group1[k]:6);
			write(f,input_group2[k]:6);
		end;

	end;

	if SaveData then writeln(f);

end;


procedure set_hi_low;              {zeichnet linie fuer hi/ bzw. low }
var x			: byte;
    z,y			: word;

begin
	y:=Messung*TimeLengthPixel+xOffset;
	qdrawpic(y-TimeLengthPixel, 3*yfakt,Background);
	qsetClr( qGreen );
	for x:=1 to 8 do begin
		z:=(x+3) * yfakt-8*ord(input_group1[x]);
		qline(y-8,z,y,z);
		if ig1_alt[x]<>input_group1[x] then begin
			qline(y-8,(x+3)*yfakt,y-8,(x+3)*yfakt-8);
			{setlinestyle(dashedln,0,normwidth);}
			{qline(y-8,(x+3)*yfakt,y-8,(8+15)*yfakt)};
		end;
		z:=(x+16)*yfakt-8*ord(input_group2[x]);
		qline(y-8,z,y,z);
		if ig2_alt[x]<>input_group2[x] then
			qline(y-8,(x+16)*yfakt,y-8,(x+16)*yfakt-8);
		ig1_alt[x]:=input_group1[x];
		ig2_alt[x]:=input_group2[x];
     end;
	// roter Cursor
	qsetClr( qRed );
	qline (y,3*yfakt,y,24*yfakt);
end;                               { **** ENDE SET_HI_LOW ****}


procedure onStart;
begin
	// start mit der Möglichkeit trigger einzustellen
end;



procedure onSettings;
begin
	// Dialog zur Auswahl der setup datei mit den Einstellungen
end;


procedure onTimer;
begin
	if (not(Pause)) then begin
		GetNewValue;
		set_hi_low;
		inc(Messung);
		if (Messung>TimeBase) then Messung:=1;
	end;
end;


procedure onClose;
begin
	if qdialog('Quit?','Yes', 'No','') =1 then begin
		qdestroy;
		close(f);
	end;
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
			qtimerstart(Timer, @onTimer);

			str(Timer,meldung);
			meldung:='Timebase: '+meldung+' ms';
			printMeldung();
			if SaveData then writeln(f,meldung);

		end
end;

procedure onSave;
var
	Picture		: qpic;
	filename	: String;

begin
	filename:=qFileselect('Save Data', '*.dlog');
	writeln('selected filename: ',filename);
	if (filename<>'') then begin
		assign(f,filename);
		rewrite(f);
		SaveData:=true;

		str(Timer,meldung);
		meldung:='Timebase: '+meldung+' ms';
		writeln(f,meldung);

	end;
end;


begin
    maxx:=800;maxy:=600;
    xfakt:=round(maxx/80);yfakt:=round(maxy/25);
	xOffset:=7*xfakt;
	{ TimeBase gibt an wieviel Messpunkte in x-Richtung platz haben  }
	TimeBase:=round((maxx-xOffset)/TimeLengthPixel);
	Timer:=20;
	OldTimer:=Timer;
	Messung:=1;
	randomize;

	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg('.datalogger.cfg');
	qstart('Datalogger  '+version, nil, nil);
	StartButton:=qbutton('|>', @onStart);
	PauseButton:=qbuttonToggle('||', @onPause);
	TimerValue:=qbutton('Timebase',  @onTimebase);
	SaveButton:=qbutton('Save',@onSave);
	ExitButton:=qbutton('Exit',@onClose);
	qNextRow;
	qdrawstart(maxx,maxy, @onCreate,nil, nil);

	qtimerstart(Timer, @onTimer);

	qGo;
end.

