unit io_access;

{ $Id$ }

{ the functions in this file decide depending on the config switches		}
{ which hardware must be accessed. herein are all the funcs neccessary		}	
{ to access the hardware including init ,writing/reading values, distri-	}
{ bution of the state of the hardware ( input output counter marker 		}
{ timer vars ),mapping variables to portlines ( eg E1 to PIO 1, Port A 		}
{ bit 0. final config file will be rcspsio ( XML like format ) ) 		}
{ the code herein describes the physical and the virtualized hardware		}
{ (c) 2001 by Hartmut Eilers <hartmut@eilers.net>, released under the GPL 	}
{ see LICENSE file 								}

interface;
const  	max_marker := 512;
	max_ioline := 128;
	max_timer  := 16;
	max_counter:= 16;
	max_analog := 64;

	max_input_loop  := max_ioline/8;
	max_output_loop	:= max_ioline/8;
	max_cnt_loop	:= max_counter/8;
	
type 	ioline_type		: array [1..max_ioline]   of boolean;
	counter_type		: array [1..max_counter]  of longint;
	timer_type		: array [1..max_timer]    of longint;
	logic_counter_type 	: array [1..max_counter]  of boolean;
	logic_timer_type   	: array [1..max_timer]    of boolean;
	analog_type		: array [1..max_analog]   of longint;
	marker_type		: array [1..max_marker]   of boolean;


procedure get_digital_values 	(var inputs   : ioline_type;outputs:ioline_type;marker:ioline_type;counters:logic_counter_type;timers:logic_timer_type); 
procedure set_output   		(var outputs  : ioline_type);
procedure set_marker   		(var marker   : marker_type);
procedure set_counter  		(cnt_idx: LongInt ; var counter_value:LongInt);
procedure set_timer    		(tmr_idx: LongInt ; var timer_value:LongInt);
procedure get_analog_values 	(var analog_in : analog_type );

implementation;

uses linux,ports;

const   power       		: array [0..7] 	of byte =(1,2,4,8,16,32,64,128);
	npower			: array [0..7] 	of byte =(128,64,32,16,8,4,2,1);
type 	byte_array		: array [1..8]	of boolean;

var	{ all values from the config file are stored in these variables				}
	{ currently 128 Inputs and 128 Outputs are supported - they are byte aligned 		}
	{ so we have 128 / 8 = 16 possible ports which have to read/written 			}
	input_port 		: array [1..max_input_loop] of longint;	{ portadresses of the inputs 	}
	input_mask		: array [1..max_input_loop] of byte;	{ masks to mask out unused bits }
	input_devicetype	: array [1..max_input_loop] of string;	{ depending on this value the app. procedure is called }
	output_port		: array [1..max_output_loop] of longint;	{ portadresses of the outputs 	}
	output_mask		: array [1..max_output_loop] of byte;	{ masks to mask out unused bits }
	output_var		: array [1..max_output_loop] of LongInt;
	output_devicetype	: array [1..max_output_loop] of string;	{ depending on this string the app procedure is called }
	
	{ currently 16 counters are supported - with byte alignment we need to 			}
	{ read or write 2 ports 								}
	{ currently only softcounters are supported 						}
	counter_ports		: array [1..max_counter_loop]  of longint;	{ portadresses of the counters 	}
	counter_masks		: array [1..max_counter_loop]  of byte;	{ masks to mask out unused bits }
	counter_devicetype	: array [1..max_counter_loop]  of string;
	
	{ the marker of the sps }
	marker			: marker_type;
	eingang, ausgang	: ioline_type;
	counter			: logic_counter_type;
	timer			: logic_timer_type;
	
	{ the counter (z)  and timer (t) values are stored in this vars }
	t			: array [1..maxtimer] of LongInt;
	z			: array [1..maxcounters] of LongInt;

	{ this var stores the value of the softcounter in order to allow recognition of low high changes at the app. input line }	
	old_cnt			: array [1..maxcounters] of boolean; 	{ hier wird jeweils der alte eingangswert gespeichert  um positive }
									{ flanken erkennen zu können ( softcounter, positiv flankengetriggert }
	
	
procedure get_digital_values 	(var inputs   : ioline_type;outputs:ioline_type;markers:marker_type;counters:logic_counter_type;timers:logic_timer_type); 
var i, j	: longint;

begin
	{ get all input lines and compose the byte array }
	for i:=1 to max_input_loop do begin 	{ da jeweils 8 werte gelesen werden muss ich 16 mal lesen ( 8 * 16 = 128 ) }
		case input_devicetype[i] of { je nach hardware die entsprechende routine zum einlesen des ports aufrufen }
			"lp" 		:	IO_val:= inputmask[i] and read_lp_port(input_port[i]); { mit der inputmask }
			"DILPC"		:	IO_val:= inputmask[i] and read_DIL_ports(input_port[i]); {"verundet"werden }
			"pio8255"	:	IO_val:= inputmask[i] and read_8255_ports(input_port[i]); {unerwünschte bits ausgeblendet }
			"joystick"	:	IO_val:= inputmask[i] and read_joystick_buttons(input_port[i]);
		end;
		for j:=7 downto 0 do begin	{ den int wert mit der tabelle schnell in ein array of boolean wandeln }
         		if IO_val>=power[j] then begin
            			eingang[i*8-j]:=true;
				IO_val:=IO_val-power[j]
			end
			else eingang[i*8-j]:=false;
		end;
	end;
	{ now handle the counters and timers }
	count_down;
	
	{ and now prepare all values to be returned }
	markers :=marker;
	inputs  :=eingang;
	outputs :=ausgang;
	counters:=counter;
	timers  :=timer;
end;


procedure set_output   		(var outputs  : ioline_type);
{ takes the boolean array of outputs as parameter }
{ is used to write the calculated output values to the real devices }
{ depending on the type of hardware which is assigned to the logic output }
{ a special function is called to access the real hardware }
{ see the hardware section below for the possible devices }
var i,j		: LongInt;
 	wert	: byte;
	
begin
for i:= 1 to max_output_loop do begin
	wert:=0;
	for j:= 7 downto 0 do 
		if outputs[output_var[i]*8-j] then wert:=wert+npower[j];
	case output_device[i] of 
		"lp"		:	write_lp_port(output_port[i],wert);
		"DILPC"		:	write_DIL_port(output_port[i],wert);
		"pio8255"	:	write_8255_port(output_port[i],wert);
	end;			
end;


procedure set_marker   		(var marker   : marker_type);
begin
	{ needs to be evaluated what has to be done here }
end;


procedure set_counter  		(cnt_idx: LongInt ; var counter_value:LongInt);
begin
	z[cnt_idx]:=counter_value;
end;


procedure set_timer    		(tmr_idx: LongInt ; var timer_value:LongInt);
begin
	t[tmr_idx]:=timer_value;
end;
n
procedure get_analog_values 	(var analog_in : analog_type );
begin
	{ this is a dummy for the routines to read analog values from the Game Port }
end;


{ init everything needed }
begin
	{ read the config file rcspsio in order to learn about the hardware }
	{ if an inputmask is not set it must be set to $ff ! }
	
	{ here every hardware initializing must be done }

	{ reset all markers }
	for i:=1 to max_marker do 
		marker[i]:=false;
		
end.

{****************************************************************************}
{ non puplic functions and stuff }

procedure count_down;                    	{ zählt timer und counter herunter }

{ hier werden die timer und counter "heruntergezaehlt" }
{ alle zähler und timer in einer sps sind rückwärtslaufende Zähler, die mit einem wert vorgeladen werden, }
{ ist dieser wert durch ein externen Takt oder zeitimpulse auf null heruntergezaehlt wird ein eintsprechendes }
{ Flag innerhalb der SPS auf high gesetzt. dieses flag wird in einem sps programm ausgwertet. }
{ die timer werden dabei nicht wirklich von der zeit beeinflusst, sondern bei jedem durchlauf des programmes einfach }
{ decrementiert. alle zeiten innerhalb eines sps programmes sind also von der ablaufgeschwindigkeit des sps interpreters }
{ also direkt von der prozessorgeschwindigkeit abhängig. }
{ die counter sind als sog. softcounter ausgelegt. d. h. es gibt keine hardwarezaehler, sondern der eingangswert eines }
{ ganz normalen io eingangs wird per software abgefragt und bei positiver flanke wird ein softwarezaehler heruntergezaehlt }
{ daraus folgt auch, das die zaehler ebenfalls von der ablaufgeschwindigkeit abhaengig sind. wenn ich aus dem physikuntericht }
{ das noch richtig in erinnerung habe, heisst das, das der zaehler nur richtig zaehlt wenn sein takt kleiner als die halbe }
{ ablaufgeschwindigkeit ist . }
{ echte timer sind angedacht, werden irgendwann folgen, die vorhandenen Timer sollten jedoch erhalten bleiben, da sie }
{ kürzeste verzögerungen für die sps bedeuten }

var 	c,wert          : byte;
	i		: LongInt;

begin
     	for c:=1 to max_timer do begin
	        if t[c] > 0 then t[c]:=t[c]-1; 	{ Zeitzähler decrementieren  }
        	if t[c]=0 then timer[c]:=true  	{ zeitzähler = 0? ja ==> TIMER auf 1}
     	end;
	
	for i:=1 to max_cnt_loop do begin
		case counter_devicetype[i] of { je nach hardware die entsprechende routine zum einlesen des ports aufrufen }
			"lp" 		:	wert:= inputmask[i] and read_lp_port(input_port[i]); { mit der inputmask }
			"DILPC"		:	wert:= inputmask[i] and read_DIL_ports(input_port[i]); {"verundet"werden }
			"pio8255"	:	wert:= inputmask[i] and read_8255_ports(input_port[i]); {unerwünschte bits ausgeblendet }
			"joystick"	:	wert:= inputmask[i] and read_joystick_buttons(input_port[i]);
		end;

		for c:=1 to 8 do begin
        		if wert mod 2 = 0 then old_cnt[c*i]:=false 	{ wenn low am eingang dann 0 speichern   }
        		else						{ wenn 1 am eingang => positive flanke testen }
        			if not(old_cnt[c*i]) then begin          	{ der wert vom letzten programmdurchlauf ist 0, => pos. Flanke am Eingang }
        				old_cnt[c*i]:=true;                    	{ dann 1 speichern            }
            				if z[c*i]>0 then z[c*i]:=z[c*i]-1;      { und ISTwert herunterzälen   } 
            				if z[c*i]=0 then counter[c*i]:=true;   	{ wenn ISTwert 0 dann ZAHLER  auf 1 setzen }
          			end;
        		wert := wert div 2
     		end
	end	
end;                               		{ **** ENDE COUNT_DOWN ****       }



{****************************************************************************}
{ hardware specific stuff }
{ for every  supported hardware device the following routines have to be implemented }
{ a read function to read the data, a write function to write out data and a init }
{ mechanism ( depending on the type of device one or more of the above mentioned	}
{ functions may not be neccessary) }

{******************************************************************************}
{ normal read of ports as with a 8255 io controller }
			
{ read a port, returns an array of booleans}
function read_8255_port(io_port:longint):byte;       { ließt eingangswerte von IO Port ein }

var	return_value	:byte;

begin
     return_value:=port[io_port];
end;                               {****  ENDE READ_PORT ****}


{ write an array of booleans to a port }
procedure write_8255_port(io_port:longint;out_value:byte_array);              { gibt Ausg.werte an I/O Port aus }
var       k,wert      : byte;
begin
     wert:=0;
     for  k:=7 downto 0 do wert:=wert+power[k]*ord(out_value[k+1]);
     port[io_port]:=wert;
end;                               { **** ENDE SET_OUTPUT **** }

procedure init_8255_hardware;
begin
	{ configuration of the hardware }
	{ including iopermissions ! }
end;

{******************************************************************************}
{ joystick port }
function read_joystick_buttons(io_port:longint):byte; { reads the state of the joystick buttons }
begin
end;

procedure read_joystick_analog(io_port:longint; var analog1 : longint; analog2: longint; analog3 : longint; analog4: longint );
begin
end;

procedure init_joystick;
begin
end;


{******************************************************************************}
{ printer port }
function read_lp_port(io_port:longint):byte;
var byte_value : byte;

begin
	{ read the port }
	byte_value:= port[io_port];
	{ invert the MSB }
	if byte_value >= 128 then
		byte_value:=byte_value - 128
	else
		byte_value:=byte_value + 128;
	{ return the result }
	read_lp_port := byte_value;
end;
	
function write_lp_port(io_port:longint;byte_value:byte_array):byte;	
var       k,wert      : byte;

begin
     wert:=0;
     for  k:=7 downto 0 do wert:=wert+power[k]*ord(out_value[k+1]);
     port[io_port]:=wert;
end;

procedure init_lp_port(io_port:longint)
begin
	ioperm(io_port,$02,$FF);
end;

{**************************************************************************}
{ DIL/NetPC }
function read_DIL_ports(io_port:byte):byte;

begin
	{ read Data from IN port }
	port[CSCIR]:=io_port;
	read_ports:=port[CSCDR];
end;

function write_DIL_ports(io_port:byte;byte_value:byte):byte;	

begin
	{ write data to out port }
	port[CSCIR]:=io_port;
	port[CSCDR]:=byte_value;
	write_ports:=byte_value;
end;

procedure init_DIL_hardware;
begin
	read_config;
	{ init of DIL/NetP }
	{ set the permission to access the ports }
	{ sets the iopermission starting from Adress $22 for the next $aa bytes to true }
	{ this must be double checked, because it is a really large area }
	error:=IOperm($22,$aa,$ff);
	{ set port a of dil pc to output }
	port[CSCIR]:=PAMR;
	port[CSCDR]:=$ff;
	{ set port b of dil pc to input }
	port[CSCIR]:=PBMR;
	port[CSCDR]:=$00;

end;
