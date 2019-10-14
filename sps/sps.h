{ global variables and constant definitions of the sps project 	}
{ all global values should be defined here, if you see any	}
{ ugly constant values in the code, please replace them with	}
{ symbolic names and define the names in this file		}
{ and please remember: the project is running since the early	}
{ 90's !It was first used in Dezember 1989			}
{ there is code of all my Pascal programming states		}
{ included beginner to "rebeginner" after years of no single	}
{ line written in pascal! thanks for not blaming me ;)		}

{ copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>	}
{ distributed under the GNU General Public License V2 or any later}


type  string3 =string[3];
      string12=string[12];
      string15 =string[15];
      string80=string[80];



const
      	awl_max     = 2000;
      	anweismax   = 37;
      	minScreenX  = 80;
      	minScreenY  = 25;
      	{ include the SPS Version and build date }
      	version     ={$I %VERSION% };
      	datum       ={$I %DATE%};
                   { attention, it is important to keep the order of	}
		   { the sps commands, because the bytecode interpreter }
		   { relies on the order! (the editor formatter too!)	}
		   { write new commands without blanks, they will be 	}
		   { added where needed	     							}
		   { only append new commands !!						}
		   { check procedure formatiere in edit.pas and the 	}
		   { interpreter in awl_interpreter.pas	and run_sps.pas	}
      	anweis      : array [1..anweismax] of string3 =(
                        'UN(','ON(','UN','ON','U(','O(','=N','JI','TE',
                        'ZR','EN','U','O',')','=','S','R','J','K','NOP',
			'EQ','LT','GT','$','PE','JP','SP','SPB','JC','EP',
			'AN(','AN','A(','A','DEC','INC','LDD');

	p_up = #72;
	p_dw = #80;
	p_le = #75;
	p_re = #77;
	esc  = #27;
	enter= #13;
	tab  = #9;



var
{$IFDEF SPS}
{ these variables are only used from sps.pas }
     programm,sicher   : boolean;
     taste             : char;
     i                 : Word;
     name              : string;
     zeilenvorschub,
     Grosschrift,
     seitenlaenge,
     formfeed          : byte;
     balken_pkte       : balken_choice;
     copy_right        : string15;
     start_pfad        : string80;
     doc_start         : doc_pointer;
     dummy_string      : string;
{$ENDIF}

{ these variables are used by sps.pas and run_sps.pas }
     operand            : array[1..awl_max] of char;
     par                : array[1..awl_max] of longint;
     operation          : array[1..awl_max] of string3;
     anweisung	        : array[1..anweismax] of string3;
     znr                : array[1..awl_max] of integer;
     comment            : array[1..awl_max] of string;
     ConfFile	          : string;
     debug              : boolean;
     DebugResult        : boolean;
     DebugMSG           : String;
