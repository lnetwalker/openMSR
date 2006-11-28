program oszi;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net					}
{ distributed  under the terms of the GNU GPL V 2					}
{ see http://www.gnu.org/licenses/gpl.html for details				}

{ this program may be used as an osziloscope in connection with 	}
{ a supported A/D IO Card											}

{ $Id$ }

uses qgtk2;


var i,ox,oy,
	xmitte,ymitte,
	timebase,
	Raster,
	maxx,
	maxy,
	PixelPerTimeBase : Integer;

	PauseButton,
	ExitButton,
	TimerValue		: qWidget;

	Timer,
	OldTimer		: word;

	Pause			: boolean;

	Background		: qpic;

procedure oncreate;

begin
	{ black Background }
	qsetClr( qBlack );
	qfillrect( 0, 0, maxx, maxy);
	{ Green Grid }
	qsetClr( qGreen );
	for i:=1 to round(int(maxx/Raster)) do begin
		qline(0,i*Raster,maxx,i*Raster);
		qline(i*Raster,0,i*Raster,maxy);
	end;
	qline(0,ymitte,maxx,ymitte);
	qline(xmitte,0,xmitte,maxy);
	// save the Background
	qgetpic(0,0,PixelPerTimeBase,maxy,Background);

end;

function GetNewValue(value:integer): integer;
begin
	GetNewValue:=random(maxx-10)+1+5;
	GetNewValue:=round(sin(value)*(maxy/4))+ymitte;
end;


procedure ontimer;
var 	x,y		: integer;
begin
	if not(Pause) then begin
		{ get next value from A/D device }
		{ and draw a line from current coordinates to new ones }
		y:=GetNewValue(x);
		x:=timebase;
		inc(timebase,PixelPerTimeBase);

		// delete the old signal where we currently draW
		qdrawpic(x, 0,Background);
		qsetClr( qGreen );
		// readraw the vertical line if needed
		if ((x mod Raster) = 0 ) then qline(x,0,x,maxy);

		qsetClr( qYellow );
		if x >= maxx then begin
			timebase:=0;
			ox:=0;oy:=ymitte;
		end
		else begin
			qline(ox,oy,x,y);
			ox:=x;
			oy:=y;
		end;
	end;
end;

procedure onClose;
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
	val(qinput('Timervalue in ms:', '100'),Timer );
	if Timer > 0 then begin
		if Timer < 2 then Timer:=2;
		if Timer <> OldTimer then begin
			writeln('Timebase changed try to stop timer ',OldTimer,'  ms');
			qtimerstop(OldTimer);
			OldTimer:=Timer;
			writeln ( ' restarting new timer with ',Timer,' ms');
			qtimerstart(Timer, @ontimer);
		end
	end
end;


begin
	Raster:= 40;
	maxx:=480;
	maxy:=480;
	PixelPerTimeBase:=8;
	Timer:=100;

	xmitte:=round(int(maxx/2));
	ymitte:=round(int(maxy/2));
	timebase:=0;
	randomize;
	
	qstart('Oszi', nil, nil);
	TimerValue:=qbutton('Timebase',  @onTimebase);
	PauseButton:=qbuttonToggle('||', @onPause);
	ExitButton:=qbutton('Exit',@onClose);
	qNextRow;

	qdrawstart(maxx,maxy, @oncreate,nil, nil);
	qtimerstart(Timer, @ontimer);

	qGo;
end.