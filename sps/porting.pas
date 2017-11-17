unit porting;

{ enthaelt alles was portiert werden muss  }
{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>				}
{ distributed under the GNU General Public License V2 or any later	}

interface
{$ifdef LINUX}
uses linux,keyboard;
{$endif}

{$ifdef WIN32}
uses dos,keyboard;
{$endif}


function sound(note:byte):byte;
{ mittels write(#7)=beep gefakt }

function nosound:byte;

function my_readkey:char;

function my_keypressed:boolean;

procedure reset_keyboard();

implementation

const
	p_up = #72;
	p_dw = #80;
	p_le = #75;
	p_re = #77;
	page_up = #73;
    page_dw = #81;
	esc  = #27;
	enter= #13;
	tab  = #9;
    BCKSPCE =#8;

Var
  K : TkeyEvent;

{ see also sps.his and sps.doc for additional informations }

function sound(note:byte):byte;
begin
  write(#7);
  sound:=0;
end;

function nosound:byte;
begin
  nosound:=0;
end;

{ on ARM64 Plattform (Pinebook Ubuntu Mate 16.04 ) I have }
{ the problem that readkey only works,if you check        }
{ keypressed before. (FPC3.0) when using arrow keys this  }
{ does not work because the keycode is send as 2 bytes    }
{ first one 0 then the scancode. when you read the first  }
{ byte you need the second readkey, but in that case      }
{ keypressed does not return true .....                   }
{ so i write my own readkey and keypressed to avoid lot   }
{ porting work.perhaps this affects other architectures   }
{ could be an FPC 3.0 related behaviour.                  }
{ use $IFDEF keyfix statement around the code to activate }
{ and -dkeyfix as FPC Flag  see make_macros !             }

function my_readkey:char;
begin
  K:=PollKeyEvent;
  if K<>0 then begin
    K:=GetKeyEvent;
    K:=TranslateKeyEvent(K);
    if IsFunctionKey(K) then 
      case(FunctionKeyName(TkeyRecord(K).KeyCode)) of 
        'Left' : my_readkey:=p_le;
        'Right': my_readkey:=p_re;
        'Up'   : my_readkey:=p_up;
        'Down' : my_readkey:=p_dw;
        'PgUp' : my_readkey:=page_up;
        'PgDn' : my_readkey:=page_dw;
      end
    else my_readkey:=GetKeyEventChar(K);
  end
end;

function my_keypressed:boolean;
begin
  K:=PollKeyEvent;
  If K<>0 then my_keypressed:=true
  else my_keypressed:=false;
end;

procedure reset_keyboard();
begin
  DoneKeyboard;
end; 

begin
  InitKeyboard;
end.
