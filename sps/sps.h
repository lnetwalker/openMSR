{ global variables and constant definitions of the sps project 	}
{ all global values should be defined here, if you see any	}
{ ugly constant values in the code, please replace them with	}
{ symbolic names and define the names in this file		}
{ and please remember: the project is running since the early	}
{ 90's ! there is code of all my Pascal programming states	}
{ included beginner to "rebeginner" after years of no single	}
{ line written in pascal! thanks for not blaming me ;)		}



type  string3 =string[3];
      string12=string[12];
      string15 =string[15];
      string80=string[80];
      doc_pointer = ^doc_record;
      doc_record = record
                     zeil : string[76];
                     nach,
                     vor  : doc_pointer;
                   end;

   

const awl_max     =500;
      anweismax	  = 24;
      minScreenX  = 80;
      minScreenY  = 25;
      { include the SPS Version and build date }
      version     ={$I %SPSVERSION% };
      datum       ={$I %DATE%};
                   { attention, it is important to keep the order of	}
		   { the sps commands, because the bytecode interpreter }	
		   { relies on the order! (the editor formatter too!)	}
		   { write new commands without blanks, they will be 	}
		   { added where needed	     				}
		   { only append new commands !!			}
		   { check procedure formatiere in edit.pas and the 	}
		   { interpreter in awl_interpreter.pas			}
      anweis      : array [1..anweismax] of string3 =(
                          'UN(','ON(','UN','ON','U(','O(','=N','JI','TE',
                          'ZR','EN','U','O',')','=','S','R','J','K','NOP',
			  'EQ','LT','GT','$');
      	     

var  znr               : array[1..awl_max] of integer;
     operation         : array[1..awl_max] of string3;
     operand           : array[1..awl_max] of char;
     par               : array[1..awl_max] of longint;
     comment           : array[1..awl_max] of string[22];
     token	       : array[1..awl_max] of byte;
     anweisung	       : array[1..anweismax] of string3;
     programm,sicher   : boolean;
     graphdriver,
     graphmode,
     grapherror        : integer;
     taste             : char;
     i                 : Word;
     name              : string;
     pio_use,pio       : boolean;
     zeilenvorschub,
     Grosschrift,
     seitenlaenge,
     formfeed          : byte;
     balken_pkte       : balken_choice;
     copy_right        : string15;
     start_pfad        : string80;
     doc_start         : doc_pointer;
     erfolg            : byte;
     dummy_string      : string;
     screenx,screeny   : word;
