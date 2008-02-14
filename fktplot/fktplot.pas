program fktplot;

uses qgtk2,FunctionSolver;

{$Id$}


const 
	version = '0.1';
	datum   = '12/02/2008';
	anzahl  = 240;
	debug = false;
	GetScreenMaxX=800;
	GetSCreenMaxY=480;
	XFontCorr=15;		{ verschiebe Beschriftung um n pixxel nach links }

var 
	formel       : string80;
	xmin,xmax,dx,
	yfact,ymin,
	ymax,maxy    : real;
	y,x          : array[1..240] of real;
	zahlen       : array30;
	funk         : token;
	i,j,k,xfact,
	y_axis,
	zero_line,
	x_rand,y_rand,
	y_ver        : integer;
	x_wert,y_wert: string[6];
	ende         : boolean;



procedure holparm;
begin
	writeln('Programmende durch Formel=ende');
	write('Formel : Y=');
	readln(formel);
	for i:= 1 to length(formel) do formel[i]:=upcase(formel[i]);
	if formel='ENDE' then begin
		halt(0);
	end;
	write('XMIN   : ');
	readln(xmin);
	repeat
		write('XMAX   : ');
		readln(xmax);
	until xmax > xmin;
end;

procedure funktionswerte_berechnen;

begin
	dx:=(xmax-xmin)/(anzahl-2);
	ymax:=0;
	ymin:=0;
	x[1]:=xmin;
	i:=1;
	repeat			{ until all values are computed or an error occurs }
		y[i]:=fx(x[i],funk,zahlen);
		if FSfm<>0 then begin
			write(#7);
			writeln('ERROR : ',FSerr_msg[FSfm]);
		end;
		if debug then writeln(i,' ',x[i],' ',y[i]);
		if y[i]>ymax then ymax:=y[i];
		if y[i]<ymin then ymin:=y[i];
		x[i+1]:=x[i]+dx;
		inc(i);
	until (i>anzahl) or (FSfm<>0);
	if ymax>abs(ymin) then maxy:=2*ymax
	else maxy:=2* abs(ymin);
	if debug then writeln('maxy=',maxy);
end;


procedure funktion_zeichnen;

	var
		oldx,oldy,maxx,maxy		:word;


begin
       oldy:=GetScreenMaxY-y_rand-trunc(y[1]*yfact+zero_line)+y_ver;
       oldx:=x_rand;
	j:=oldx;
       for i:=2 to anzahl do begin
		k:=GetScreenMaxY-y_rand-trunc(y[i]*yfact+zero_line)+y_ver;
		inc(j,xfact);
		qline(oldx,oldy,j,k);
		oldx:=j;
		oldy:=k;
       end;
end;


procedure onCreate;

	procedure  beschriftung;
	begin
		formel:='Y='+formel;
		j:=10;
		k:=20;
		qdrawtext(j,k,formel);
		(* Y-Achse *)
		for i:=3 downto -3 do begin { jeweils 3 Werte im positiven und negativen Bereich }
			k:=GetScreenMaxY-Y_rand-trunc((i*maxy/6)*yfact+zero_line)+y_ver;
			qline(x_rand-4,k,x_rand+4,k); { Wertelinie }
			if i<>0 then str(i*maxy/6:6:3,y_wert) { Y Wert in String wandeln }
			else Y_wert:=' 0.00';
			qdrawtext(0,k,y_wert);		{ Y Wert ausgeben }
		end;
		(* X-Achse *)
		i:=0;
		{ koordinaten des 1. Wertes ermitteln }
		j:=x_rand;
		k:=GetScreenMaxY-y_rand+y_ver+14;
		{ umwandeln und ausgeben }
		str(x[1]:4:2,x_wert);
		qdrawtext(j-XFontCorr,k,x_wert);
		repeat
			inc(i,40);	{ um 40 Werte weiter rechts nächste Beschriftung }
			j:=i*xfact+x_rand;
			k:=GetScreenMaxY-y_rand+y_ver-10;
			qline (j,k+8,j,k+12); { Beschriftungslinie }
			str(x[i]:6:3,x_wert);
			qdrawtext(j-XFontCorr,k+24,x_wert);
		until i=240;
         end;


begin
	x_rand:=60;
	y_rand:=80;
	y_ver:=55;
	xfact:=trunc((GetScreenMaxX-80)/anzahl);
	yfact:=(GetScreenMaxY-y_rand-20)/maxy;
	y_axis:=GetScreenMaxY-y_rand-10;

	{ white Background }
	qsetClr( qWhite );
	qfillrect( 0, 0,GetScreenMaxX-1, GetScreenMaxY-1);
	qsetClr( qBlack );
	qrect(0,0,GetScreenMaxX-1,GetScreenMaxY-1);

	{ Nulllinie berechnen }
	zero_line:=trunc((GetScreenMaxY-y_rand)/2);

	{ Y-Achse zeichnen }
	qline(x_rand,0+y_ver,x_rand,GetScreenMaxY-y_rand+y_ver);

	{ X Achse zeichnen }
	qline(x_rand,y_axis+y_ver+10,xfact*anzahl+x_rand+10,y_axis+y_ver+10);
	qline(x_rand,zero_line+y_ver,xfact*anzahl+x_rand+10,zero_line+y_ver);
	beschriftung;
	funktion_zeichnen;
end;





begin
	qstart('Fktplot  '+version+' '+datum, nil, nil);
	holparm;
	codier(formel,funk,zahlen);
	if FSfm=0 then funktionswerte_berechnen;
	if FSfm=0 then begin
		qdrawstart(800,480, @onCreate,nil, nil);

		qgo;
	end;
end.