
unit comedilib_scxi;
interface
type
  TArray0to11OfChar = array[0..11] of char;

{
  Automatically converted by H2Pas 1.0.0 from /home/hartmut/src/OpenMSR/divLibs/comedi/comedilib_scxi.tmp.h
  The following command line parameters were used:
    -e
    -p
    -D
    -w
    -o
    /home/hartmut/src/OpenMSR/divLibs/comedi/comedilib_scxi.pas
    /home/hartmut/src/OpenMSR/divLibs/comedi/comedilib_scxi.tmp.h
}

  const
    External_library='kernel32'; {Setup as you need}

  { Pointers to basic pascal types, inserted by h2pas conversion program.}
  






  Type
  Pcomedi_t  = ^comedi_t;
  scxi_board_struct = record
          device_id : dword;
          name : TArray0to11OfChar;
          modclass : longint;
          clock_interval : dword;
          dio_type : longint;
          aio_type : longint;
          channels : longint;
          status_reg : longint;
          data_reg : longint;
          config_reg : longint;
          eeprom_reg : longint;
          gain_reg : longint;
       end;
  Pscxi_board_struct  = ^scxi_board_struct;
  Pscxi_mod_t  = ^scxi_mod_t;
  scxi_module_struct = record
          dev : Pcomedi_t;
          board : dword;
          dio_subdev : dword;
          ser_subdev : dword;
          chassis : dword;
          slot : dword;
       end;
  Pscxi_module_struct  = ^scxi_module_struct;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  {
      include/comedilib_scxi.h
      header file for the comedi scxi library routines
  
      Copyright (C) 2004 Caleb Tennis
  
      This program is free software; you can redistribute it and/or modify
      it under the terms of the GNU Lesser General Public License as published by
      the Free Software Foundation; either version 2 of the License, or
      (at your option) any later version.
  
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.
  
      You should have received a copy of the GNU General Public License
      along with this program; if not, write to the Free Software
      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  
   }
{$ifndef _COMEDILIB_SCXI_H}
{$DEFINE H2PAS_FUNCTION_1}


  const
     SLOT0_INTERVAL = 1200;     
     FAST_INTERVAL = 1200;     
     MEDIUM_INTERVAL = 10000;     
     SLOW_INTERVAL = 30000;     
     SCXI_LINE_MOSI = 0;     
     SCXI_LINE_DA = 1;     
     SCXI_LINE_SS = 2;     
     SCXI_LINE_MISO = 4;     
     SCXI_DIO_NONE = 0;     
     SCXI_DIO_DO = 1;     
     SCXI_DIO_DI = 2;     
     SCXI_AIO_NONE = 0;     
     SCXI_AIO_AO = 1;     
     SCXI_AIO_AI = 2;     
     REG_PARK = $0FFFF;     

  { was #define dname def_expr }
  function n_scxi_boards : longint;
      { return type might be wrong }


  procedure comedi_scxi_close(var comedi_mod:scxi_mod_t);cdecl;external External_library name 'comedi_scxi_close';

  function comedi_scxi_open(var dev:comedi_t; chassis_address:word; mod_slot:word):Pscxi_mod_t;cdecl;external External_library name 'comedi_scxi_open';

  function comedi_scxi_register_readwrite(var comedi_mod:scxi_mod_t; reg_address:word; num_bytes:dword; var data_out:byte; var data_in:byte):longint;cdecl;external External_library name 'comedi_scxi_register_readwrite';

{$endif}
  { _COMEDILIB_SCXI_H }

implementation

{$IFDEF H2PAS_FUNCTION_1}
  { was #define dname def_expr }
  function n_scxi_boards : longint;
      { return type might be wrong }
      begin
         n_scxi_boards:=(sizeof(scxi_boards))/(sizeof(scxi_boards[0]));
      end;
{$ENDIF H2PAS_FUNCTION_1}


end.
