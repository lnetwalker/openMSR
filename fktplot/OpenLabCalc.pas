program OpenLabCalc;

uses PhysMach,FunctionSolver,crt;

{ $id:$ }

{ 24.06.2009	start of program }

{ this program can calculate any formular with the data from the DeviceServer }
const	debug		= false;

var	data		: string80;
	dest		: word;
	formel		: string80;
	funk		: token;
	zahlen		: array30;

function val2str(zahl:real):string;
{ wandelt eine Zahl in einen String um }

var 	tmp		: string;
begin
	str(zahl,tmp);
	val2str:=tmp;
end;


procedure ParseFormular( var formel:string; var destidx:word);
{ parse the formular for all DeviceServer Variables and replace }
{ the variables by their values; also determine in which var	}
{ the result must be stored					}

var 	i,p,idx,start	: word;

begin
	// get destination index to store result
	start:=pos('=',formel);
	i:=1;
	while i < start do begin
		if (formel[i] = 'A') or (formel[i] = 'a') then begin	// its a variable
			p:=i+1;		// save position of variable
			while ((ord(formel[p])>=48) and (ord(formel[p])<=57)  ) do inc(p);	// sammle alle Zahlen
			dec(p);
			val(copy(formel,i+1,p-i),destidx);
		end;
		inc(i);
	end;
	// replace all occurances of variables with their values
	formel:=copy(formel,start+1,length(formel));
	i:=1;
	while i <= length(formel) do begin
		if (formel[i] = 'A') or (formel[i] = 'a') then begin	// its a variable
			p:=i+1;		// save position of variable
			while ((ord(formel[p])>=48) and (ord(formel[p])<=57)  ) do inc(p);	// sammle alle Zahlen
			dec(p);
			val(copy(formel,i+1,p-i),idx);
			formel:=copy(formel,1,i-1)+val2str(analog_in[idx])+copy(formel,p+1,length(formel));
		end;
		inc(i);
	end;
end;

begin			// main program
	PhysMachInit;
	PhysMachloadCfg('OpenLabCalc.cfg');

	write('formel: ');readln(formel);
	
	repeat
		PhysMachReadAnalog;
		data:=formel;
		ParseFormular(data,dest);
		codier(data,funk,zahlen);
		analog_in[dest]:=trunc(fx(1,funk,zahlen));
		//PhysMachWriteAnalog;
	until keypressed;
end.