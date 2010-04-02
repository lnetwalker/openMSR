library PhysMachCLib;

// export the Unit PhysMach to C programs
// see PhysMachCLib.h for more information

// (c) 2009 by Hartmut Eilers
// Released under the GNU GPL V2 or later
 
// { $Id$ }

// import the PhysMach Unit
uses PhysMach;

Var
	// in PhysMach these are constants, they must be exported as variables
	// they are exported with the same names than in PhysMach
	Cio_max		: integer ; public name 'io_max';
	Cgroup_max	: integer ; public name 'group_max';
	Cmarker_max	: integer ; public name 'marker_max';
	Cakku_max	: integer ; public name 'akku_max';
	Ccnt_max	: integer ; public name 'cnt_max';
	Ctim_max	: integer ; public name 'tim_max';
	Canalog_max	: integer ; public name 'analog_max';
	CDeviceTypeMax	: integer ; public name 'DeviceTypeMax';


// exported functions and procedures
exports PhysMachInit name 'PhysMachInit';
exports PhysMachReadDigital name 'PhysMachReadDigital';
exports PhysMachWriteDigital name 'PhysMachWriteDigital';
exports PhysMachCounter name 'PhysMachCounter';
exports PhysMachloadCfg name 'PhysMachLoadCfg';
exports PhysMachReadAnalog name 'PhysMachReadAnalog';
exports PhysMachTimer name 'PhysMachTimer';
exports PhysMachGetDevices name 'PhysMachGetDevices';
exports PhysMachIOByDevice name 'PhysMachIOByDevice';


// main of lib
begin
	// get the values from the constants in PhysMach 
	Cio_max:=io_max;
	Cgroup_max:=group_max;
	Cmarker_max:=marker_max;
	Cakku_max:=akku_max;
	Ccnt_max:=cnt_max;
	Ctim_max:=tim_max;
	Canalog_max:=analog_max;
	CDeviceTypeMax:=DeviceTypeMax;
	// done with the constants


end.

// finished

{
interface

type
	DeviceTypeArray		= array[1..DeviceTypeMax] of char;

var
	marker 			: array[1..marker_max]   of boolean;
	eingang,ausgang		: array[1..io_max]	 of boolean;
	zust			: array[1..io_max]	 of boolean;
	lastakku		: array[1..akku_max]     of boolean;
	zahler			: array[1..cnt_max]	 of boolean;
	timer			: array[1..tim_max]	 of boolean;
	t			: array[1..tim_max]	 of word;	 
	z			: array[1..cnt_max]	 of word;
	analog_in		: array[1..analog_max]   of integer;

	HWPlatform		: string;

	durchlaufeProSec,
	durchlauf,
	durchlauf100		: word;

	i_address,
	o_address,
	c_address,
	a_address		: array [1..group_max] of LongInt; 
	i_devicetype,
	o_devicetype,
	c_devicetype,
	a_devicetype 		: array [1..group_max] of char;
	DeviceList		: DeviceTypeArray;


}