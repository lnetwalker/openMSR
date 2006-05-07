program kop;


{ this program generates a ladder logic diagram ( Kontaktplan ( KOP ))	}
{ from an Instruction list (IL) ( Anweisungsliste (AWL)) program		}

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}


{$include ./sps.h}


var i				: integer;
	token			: byte;
	Zeile,
	Beschriftung,
	dummy,
	KVal			: string;



function mehrfach (z:word):boolean;

begin
     mehrfach:=true;
     if (operation[z+1]=anweisung[1]) or				{ UN(	}
        (operation[z+1]=anweisung[3]) or				{ UN	}
        (operation[z+1]=anweisung[5]) or				{ U(	}
		(operation[z+1]=anweisung[20]) or				{ NOP	}
		(operation[z+1]=anweisung[11]) or				{ EN	}
		(operation[z+1]=anweisung[25]) or				{ PE	}
		(operation[z+1]=anweisung[30]) or				{ EP	}
		(operation[z+1]=anweisung[31]) or				{ AN(	}
		(operation[z+1]=anweisung[32]) or				{ AN	}
		(operation[z+1]=anweisung[33]) or				{ A(	}
		(operation[z+1]=anweisung[34]) or				{ A		}
        (operation[z+1]=anweisung[12]) 					{ U		}
	 then mehrfach:=false
end;


function add2string(Zeichenkette:string;Zeichen:char;laenge:byte):string;
{ fügt Zeichen an Zeichenkette bis die Länge = laenge ist }
begin
	if (length(Zeichenkette)<laenge) then
		repeat
			Zeichenkette:=Zeichenkette+Zeichen;
		until ( length(Zeichenkette)>=laenge );
	add2string:=Zeichenkette;
end;

procedure sps_laden;

var	f              		:text;
	zeile		   		:string[48];
	i,code  	   		:integer;   { code is currently a dummy, may be used for error detection }
	name		   		:string;

procedure get_file_name;           { namen des awl-files einlesen   }

begin
	write (' Filename : ');
	readln (name);
	if pos('.',name)=0 then name:=name+'.sps';
end;                               { **** ENDE GET_FILE_NAME **** }



begin
	i:=0;
	if paramcount=0 then get_file_name  { keine Aufrufparameter }
	else begin
		name:=paramstr(1);
		if pos('.',name)=0 then name:=name+'.sps';
	end;
	assign (f,name);
	{$I-} reset (f); {$I+}
	if ioresult <> 0 then
	begin
		writeln (' SPS-File nicht gefunden');
		halt(1);
	end;
	writeln(' Lade Programm ',name);
	while not(eof(f)) do
	begin
		inc(i);
		readln (f,zeile);
		val (copy(zeile,1,3),znr[i],code);
		operation[i] := copy(zeile,5,3);
		operand[i] := zeile[9];
		val (copy(zeile,11,5),par[i],code);
		comment[i] := copy (zeile,17,22);
	end;
	for i := 1 to anweismax do begin
		anweisung[i]:=anweis[i];
		if (length(anweis[i]) < 3) then begin
			repeat
				anweisung[i]:=concat(anweisung[i],' ');
		 	until (length(anweisung[i]) = 3);
		end;
	end;

	close (F);
end;                               {**** ENDE SPS_LADEN **** }


begin
	writeln('kop export V ',version,' (c) 2006 by Hartmut Eilers <hartmut@eilers.net>');
	writeln('for OpenSPS. ');
	writeln;
	sps_laden;
	i:=1;
	Zeile:='|-';
	Beschriftung:='  ';
	repeat
		token:=0;
		repeat
			inc(token);
		until (operation[i]=anweisung[token]) or (token>anweismax);
		str(par[i],dummy);

		case token of
			3,12,32,34 : begin	{ UN oder U oder AN oder A }
					if ((token = 3 ) or (token = 32)) then
						Zeile:=Zeile+'-[/]-'
					else
						Zeile:=Zeile+'-[ ]-';
					Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' ';
				 end;
			7,15 : begin	{ = oder =N }
						Zeile:=add2string(Zeile,'-',50);
						Beschriftung:=add2string(Beschriftung,' ',50);
						if (mehrfach(i)) then begin
							Zeile:=Zeile+'+';
							if ( operation[i+1]<>'EN ' ) then
								Beschriftung:=Beschriftung+'|';
						end;
						if (token = 7) then
							Zeile:=Zeile+'-|NOT|-';
						Zeile:=add2string(Zeile,'-',60);
						Beschriftung:=add2string(Beschriftung,' ',60);
						Zeile:=Zeile+'-( )-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' ';
						writeln(Zeile);
						writeln(Beschriftung);
						if (mehrfach(i)) then begin
							Zeile:='';
							Beschriftung:='';
							Zeile:=add2string(Zeile,' ',50);
							Beschriftung:=add2string(Beschriftung,' ',50);
						end 
						else begin
							Zeile:='|-';
							Beschriftung:='  ';
						end;
				 end;
			4,13 : begin	{ ON oder O }
						Zeile:=Zeile+'----+';
						Beschriftung:=Beschriftung+'    |';
						writeln(Zeile);
						writeln(Beschriftung);
						if ( token = 4 ) then
							Zeile:='|--[/]-'
						else
							Zeile:='|--[ ]-';
						Beschriftung:='    '+operand[i]+dummy+' ';
				 end;
			11,25,30 : begin	{ EN PE EP }
						Zeile:='|--END--|';
						writeln(Zeile);
				 end;
			24 : begin	{ $ = execute }
						Zeile:=add2string(Zeile,'-',54);
						Beschriftung:=add2string(Beschriftung,' ',54);
						Zeile:=Zeile+'-(execute)-|';
						Beschriftung:=Beschriftung+comment[i];
						writeln(Zeile);
						writeln(Beschriftung);
						Zeile:='|-';
						Beschriftung:='  ';
				 end;
			9  : begin { TE }
						Zeile:=add2string(Zeile,'-',59);
						Beschriftung:=add2string(Beschriftung,' ',59);
						str(par[i+1],KVal);
						Zeile:=Zeile+'-(SE)-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' k='+KVal;
						writeln(Zeile);
						writeln(Beschriftung);
						Zeile:='|-';
						Beschriftung:='  ';
				 end;
			10 : begin { ZR }
						Zeile:=add2string(Zeile,'-',59);
						Beschriftung:=add2string(Beschriftung,' ',59);
						str(par[i+1],KVal);
						Zeile:=Zeile+'-(ZR)-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' k='+KVal;
						writeln(Zeile);
						writeln(Beschriftung);
						Zeile:='|-';
						Beschriftung:='  ';
				 end;
			16,17 : begin { S oder R }
						Zeile:=add2string(Zeile,'-',50);
						Beschriftung:=add2string(Beschriftung,' ',50);
						if (mehrfach(i)) then begin
							Zeile:=Zeile+'+';
							Beschriftung:=Beschriftung+'|';
						end;
						Zeile:=add2string(Zeile,'-',60);
						Beschriftung:=add2string(Beschriftung,' ',60);
						if ( token = 16 ) then
							Zeile:=Zeile+'-(S)-|'
						else
							Zeile:=Zeile+'-(R)-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy;
						writeln(Zeile);
						writeln(Beschriftung);
						if (mehrfach(i)) then begin
							Zeile:='';
							Beschriftung:='';
							Zeile:=add2string(Zeile,' ',50);
							Beschriftung:=add2string(Beschriftung,' ',50);
						end 
						else begin
							Zeile:='|-';
							Beschriftung:='  ';
						end;
				 end;
			20 : begin { NOP }
					writeln;
					Zeile:='|-';
					Beschriftung:='  ';
				 end;
			else begin
					writeln;
					writeln('Unimplemented AWL Command found, KOP is not correct,');
					writeln('quitting unexpected!');
					token:=11;
				 end;
		end;
		inc(i);
	until ((token = 11) or (token = 25) or (token = 30));  { EN PE EP }
	
end.