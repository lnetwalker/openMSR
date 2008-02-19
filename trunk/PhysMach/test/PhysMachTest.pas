program PhysMachTest;

uses PhysMach,strings;

{ compile with fpc -Fu.. -Fu../../gtk+/qgtk2.pas-0.9/  -gl PhysMachTest.pas }


const
	debug	= false;

var
	line			: string;
	cmd,hw			: char;
	pa,va			: LongInt;
	i			: byte;
	ConfFile		: string;

begin
	writeln('PhysMach Machine Monitor');
	writeln('(c) by Hartmut Eilers, 2008 - released under the GPL V2 or above');
	writeln;
	writeln('Enter H for Help');
	writeln;
	write('Config File: ');readln(ConfFile);
	if ( ConfFile='' ) then ConfFile:='PhysMachTest.cfg';
	// initialize Hardware
	PhysMachInit;
	PhysMachloadCfg(ConfFile);
	writeln('detected Hardware: ',HWPlatform);
	//PhysMachWriteDigital;

	repeat
		write('>');
		readln(line);
		line:=upcase(line);
		cmd:=line[1];
		hw:=line[3];
		val(copy(line,5,2),pa);
		if length(line)>=7 then
			val(copy(line,7,length(line)-6),va);
		if debug then writeln('pa=',pa,' va=',va);
		case cmd of
			'R' : 	begin
					case hw of
						'C' :	begin
								PhysMachCounter;
								writeln(zust[pa]);
							end;
						'I' :	begin
								PhysMachReadDigital;
								writeln(eingang[pa]);
							end;
						'A' :	begin
								PhysMachReadAnalog;
								writeln(analog_in[pa]);
							end;
					end;
				
				end;
			'W' :	begin
					case hw of
						'O' :	begin
								if debug then writeln (pa,' ',va);
								if va=0 then ausgang[pa]:=false
								else ausgang[pa]:=true;
								PhysMachWriteDigital;
							end;
						'A' :	begin
							end;
					end;
				end;
			'H' :	begin
					writeln('cmd lines are build like this');
					writeln('cmd hardware number [value]');
					writeln('cmd=[R|W|H|E|C] for read, write, help, end and config');
					writeln('hardware=[C|I|O|A] for counter, input, output, analog values');
					writeln('Number = Number of line');
					writeln('Value= value needed when writing lines');
				end;
			'C' :	begin
					// dump the configuration data
					for i:=1 to group_max do begin
						if (i_devicetype[i]<>'-') then
							writeln('InputGroup ',i,' Type ',i_devicetype[i],' Address ',i_address[i]);
						if (o_devicetype[i]<>'-') then
							writeln('OutputGroup ',i,' Type ',o_devicetype[i],' Address ',o_address[i]);
						if (c_devicetype[i]<>'-') then
							writeln('CounterGroup ',i,' Type ',c_devicetype[i],' Address ',c_address[i]);
						if (a_devicetype[i]<>'-') then
							writeln('AnalogGroup ',i,' Type ',a_devicetype[i],' Address ',a_address[i]);
					end;
				end;
		end;
	until cmd='E';
	writeln('bye');
end.

