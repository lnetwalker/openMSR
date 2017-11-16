procedure kop;


{ this procedure generates a ladder logic diagram ( Kontaktplan ( KOP ))}
{ from an Instruction list (IL) ( Anweisungsliste (AWL)) program		}

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}

var i				: integer;
	token			: byte;
	Zeile,
	Beschriftung,
	dummy,
	KVal			: string;
	KOP_pointer		: doc_pointer;
	MaxLineLength	: word;

function add2string(Zeichenkette:string;Zeichen:char;laenge:byte):string;
{ fuegt Zeichen an Zeichenkette bis die Laenge = laenge ist }
begin
	if (length(Zeichenkette)<laenge) then
		repeat
			Zeichenkette:=Zeichenkette+Zeichen;
		until ( length(Zeichenkette)>=laenge );
	add2string:=Zeichenkette;
end;


begin
	if not(programm) then exit;
	MaxLineLength:=50;
	i:=1;
	Zeile:='|-';
	Beschriftung:='  ';
	new(kop_pointer);
	kop_pointer^.zeil:='';
	kop_pointer^.vor:=nil;
	kop_pointer^.nach:=nil;

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
						Zeile:=add2string(Zeile,'-',MaxLineLength-10);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-10);
						if (mehrfach(i)) then begin
							Zeile:=Zeile+'+';
							if ( operation[i+1]<>'EN ' ) then
								Beschriftung:=Beschriftung+'|';
						end;
						if (token = 7) then
							Zeile:=Zeile+'-|NOT|-';
						Zeile:=add2string(Zeile,'-',MaxLineLength);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength);
						Zeile:=Zeile+'-( )-|';
						Beschriftung:=Beschriftung+'  '+operand[i]+dummy+' ';
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
						if (mehrfach(i)) then begin
							Zeile:='';
							Beschriftung:='';
							Zeile:=add2string(Zeile,' ',MaxLineLength-10);
							Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-10);
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
						Zeile:=add2string(Zeile,'-',MaxLineLength-6);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-6);
						Zeile:=Zeile+'-(execute)-|';
						Beschriftung:=Beschriftung+comment[i];
						AppendStringToList(Zeile,KOP_pointer);
						AppendStringToList(Beschriftung,KOP_pointer);
						Zeile:='|-';
						Beschriftung:='  ';
				 end;
			9  : begin { TE }
						Zeile:=add2string(Zeile,'-',MaxLineLength-1);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-1);
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
						Zeile:=add2string(Zeile,'-',MaxLineLength-1);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-1);
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
						Zeile:=add2string(Zeile,'-',MaxLineLength-10);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-10);
						if (mehrfach(i)) then begin
							Zeile:=Zeile+'+';
							Beschriftung:=Beschriftung+'|';
						end;
						Zeile:=add2string(Zeile,'-',MaxLineLength);
						Beschriftung:=add2string(Beschriftung,' ',MaxLineLength);
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
							Zeile:=add2string(Zeile,' ',MaxLineLength-10);
							Beschriftung:=add2string(Beschriftung,' ',MaxLineLength-10);
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
	browsetext('[KOP]',KOP_pointer,1,2,screenx,screeny);
	dispose(KOP_pointer);
end;
