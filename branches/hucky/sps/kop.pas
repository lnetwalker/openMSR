procedure kop;


{ this procedure generates a ladder logic diagram ( Kontaktplan ( KOP ))}
{ from an Instruction list (IL) ( Anweisungsliste (AWL)) program		}

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}

var i				: integer;
	token			: byte;
	Zeile,
	Beschriftung,
	dummy,
	KVal			: string;
	KOP_pointer		: doc_pointer;

function add2string(Zeichenkette:string;Zeichen:char;laenge:byte):string;
{ fügt Zeichen an Zeichenkette bis die Länge = laenge ist }
begin
	if (length(Zeichenkette)<laenge) then
		repeat
			Zeichenkette:=Zeichenkette+Zeichen;
		until ( length(Zeichenkette)>=laenge );
	add2string:=Zeichenkette;
end;


begin
	if not(programm) then exit;
	i:=1;
	Zeile:='|-';
	Beschriftung:='  ';
	new(kop_pointer);
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
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
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
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
						if ( token = 4 ) then
							Zeile:='|--[/]-'
						else
							Zeile:='|--[ ]-';
						Beschriftung:='    '+operand[i]+dummy+' ';
				 end;
			11,25,30 : begin	{ EN PE EP }
						Zeile:='|--END--|';
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
				 end;
			24 : begin	{ $ = execute }
						Zeile:=add2string(Zeile,'-',54);
						Beschriftung:=add2string(Beschriftung,' ',54);
						Zeile:=Zeile+'-(execute)-|';
						Beschriftung:=Beschriftung+comment[i];
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
						Zeile:='|-';
						Beschriftung:='  ';
				 end;
			9  : begin { TE }
						Zeile:=add2string(Zeile,'-',59);
						Beschriftung:=add2string(Beschriftung,' ',59);
						str(par[i+1],KVal);
						Zeile:=Zeile+'-(SE)-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' k='+KVal;
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
						Zeile:='|-';
						Beschriftung:='  ';
						inc(i);
				 end;
			10 : begin { ZR }
						Zeile:=add2string(Zeile,'-',59);
						Beschriftung:=add2string(Beschriftung,' ',59);
						str(par[i+1],KVal);
						Zeile:=Zeile+'-(ZR)-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' k='+KVal;
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
						Zeile:='|-';
						Beschriftung:='  ';
						inc(i);
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
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
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
					AppendStringToList('',KOP_pointer);
					Zeile:='|-';
					Beschriftung:='  ';
				 end;
			else begin
					AppendStringToList('',KOP_pointer);
					AppendStringToList('Unimplemented AWL Command found, KOP is not correct,',KOP_pointer);
					AppendStringToList('quitting unexpected!',KOP_pointer);
					token:=11;
				 end;
		end;
		inc(i);
	until ((token = 11) or (token = 25) or (token = 30));  { EN PE EP }
	browsetext(KOP_pointer,1,2,screenx,screeny);
	//release(KOP_pointer);
end;