unit porting;

{ enthaelt alles was portiert werden muss  }
{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}

interface
{$ifdef LINUX}
uses linux;
{$endif}

{$ifdef WIN32}
uses dos;
{$endif}


function sound(note:byte):byte;
{ mittels write(#7)=beep gefakt }

function nosound:byte;


implementation

{ difficulties with port !!! run_awl.pp }
{                   read(z) !! in run_awl.pp }
{                   gettime resolution !!! run_awl }
{                   str !!! run_awl     }
{                   getdir !!!!! sps }
{                   zykluszeit wird nicht in awl eingetragen bei en Befehl}
{                                !!!! run_awl }

{ see also sps.his and sps.doc for additional informations }
      

   


function sound(note:byte):byte;
begin
  write(#7);
end;

function nosound:byte;
begin

end;



begin
 
end.













