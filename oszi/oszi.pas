program oszi;

{ (c) 2006 by Hartmut Eilers < hartmut@eilers.net					}
{ distributed  under the terms of the GNU GPL V 2					}
{ see http://www.gnu.org/licenses/gpl.html for details				}

{ this program may be used as an osziloscope in connection with 	}
{ a supported A/D IO Card								}

{ $Id$ }

uses qgtk2,PhysMach;

const
	debug=false;
	NoOfUsedSignals=8;


var 
	i,
	xmitte,ymitte,
	timebase,
	Raster,
	maxx,
	maxy,
	PixelPerTimeBase : Integer;

	PauseButton,
	ExitButton,
	TimerValue,
	MaxButton,
	GetMaxValuesWindow	: qWidget;

	values			: Array [1..NoOfUsedSignals] of qWidget;
	
	Timer,
	OldTimer		: word;

	Pause			: boolean;

	Background		: qpic;

	ox,oy			: Array [1..NoOfUsedSignals] of Integer;

	NoOfInputs,k		: byte;

	Farbe			: Array [1..NoOfUsedSignals] of LongInt = (qRed,qAqua,qBlue,qYellow,qPurple,qWhite,qBrown,qGray);

	YcMax			: LongInt;

	Yrmax			: Array [1..NoOfUsedSignals] of Cardinal;
	
	InputLabel		: String;


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



function GetNewValue(value:integer): Integer;
var
	Yc	: real;
	Yc2	: integer;

begin
	{ read a new value and normalize it to this coordinate system }
	PhysMachReadAnalog;
	if debug then writeln('analog_in[',value,']=',analog_in[value]);
	// see CoordinateTransformation.txt
	//       Yr + Yrmax
	//yc = -------------- *  Ycmax 
	//         2*Yrmax
	//Yc:=((analog_in[value]+Yrmax[value])/(2*Yrmax))*maxy;
	//writeln('Yc[',value,']=',Yc);
	//     (Yc-Ycmax)*-1
	//Yc'=---------------*Yc'max
	//     	Ycmax
	Yc:=analog_in[value];
	Yc2:=round((Yc-Yrmax[value])*-1/(Yrmax[value])*maxy);
	if debug then writeln('Yc2[',value,']=',Yc2);
	GetNewValue:=Yc2;
	//GetNewValue:=round(sin(value)*(maxy/4))+ymitte;
end;


procedure ontimer;
var 	x,y,i		: integer;
	ColLabel	: String;
begin
	if not(Pause) then begin

		x:=timebase;
		inc(timebase,PixelPerTimeBase);

		// delete the old signal where we currently draW
		qdrawpic(x, 0,Background);
		qsetClr( qGreen );
		// readraw the vertical line if needed
		if ((x mod Raster) = 0 ) then qline(x,0,x,maxy);

		for i:=1 to NoOfInputs do begin
			{ get next value from A/D device }
			{ and draw a line from current coordinates to new ones }
			y:=GetNewValue(i);

			qsetClr(Farbe[i]);
			str (i,ColLabel);
			ColLabel:='ch#'+ColLabel;
			qdrawtext(60*i,15,ColLabel);
			qline(ox[i],oy[i],x,y);
			ox[i]:=x;
			oy[i]:=y;

			if x >= maxx then begin
				timebase:=0;
				ox[i]:=0;oy[i]:=ymitte;
			end
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
			if debug then writeln('Timebase changed try to stop timer ',OldTimer,'  ms');
			qtimerstop(OldTimer);
			OldTimer:=Timer;
			if debug then writeln ( ' restarting new timer with ',Timer,' ms');
			qtimerstart(Timer, @ontimer);
		end
	end
end;


procedure onMax;
begin
	qshowsec(GetMaxValuesWindow);
end;


procedure AbortSetup;
begin 
	qhidesec(GetMaxValuesWindow); 
end;


procedure SaveMaxValues;
var loop	: byte;
begin 
	for loop:=1 to NoOfInputs do begin 
		val(qtextstring(values[loop],0,-1),Yrmax[loop]);
		//if Yrmax[loop]=1 then Yrmax[loop]:=1;
		writeln('Max for channel ',loop,' changed to ',Yrmax[loop]);
	end;
	qhidesec(GetMaxValuesWindow); 
end;

procedure dummy;
begin
end;


begin
	NoOfInputs:=NoOfUsedSignals;
	Raster:= 40;
	maxx:=480;
	maxy:=480;
	PixelPerTimeBase:=20;
	Timer:=250;

	for k:=1 to NoOfInputs do 
	    Yrmax[k]:=500; //4294967294;

	xmitte:=round(int(maxx/2));
	ymitte:=round(int(maxy/2));
	timebase:=0;

	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg('.oszi.cfg');
	writeln('detected Hardware: ',HWPlatform);
	
	qstart('Oszi', nil, nil);
	TimerValue:=qbutton('Timebase',  @onTimebase);
	PauseButton:=qbuttonToggle('||', @onPause);
	MaxButton:=qbutton('Max',@onMax);
	ExitButton:=qbutton('Exit',@onClose);
	qNextRow;

	qdrawstart(maxx,maxy, @oncreate,nil, nil);
	qtimerstart(Timer, @ontimer);

	// window to read Max Values for the 8 channels
	GetMaxValuesWindow:=qsecwindow('Maximum Values Setup');
	qFrame;
	qlabel('Enter the Maximum Values for the channels'  );
	qNextRow;
	for k:=1 to NoOfInputs do begin
		str(k,InputLabel);
		InputLabel:='Channel #' + InputLabel+'  ';
		qlabel(InputLabel);
		values[k]:=qtext(5,1, @dummy);
		qNextRow;
	end;
	qEndFrame;
	qseparator;
	qbutton('exit', @AbortSetup);
	qbutton('save', @SaveMaxValues);
	
	qGo;
end.