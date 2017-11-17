{ copyright (C) 2007 by Hartmut Eilers <hartmut@eilers.net>			}
{ distributed under the GNU General Public License V2 or any later	}


{ info.pas  includefile, zur anzeige der doc-datei }

procedure info(start :doc_pointer);

type string76 = string[76];

const p_up = #73;
      p_dw = #81;
      esc  = #27;

procedure list_doc(list_start : doc_pointer;var end_z:doc_pointer);

var counter : byte;
    z       : doc_pointer;

begin
     clrscr;
     z:=list_start;
     counter:=1;
     while (counter < screeny-8) and (z^.nach <> nil) do begin
        gotoxy(1,counter);
        write(z^.zeil);
        z:=z^.nach;
        inc(counter);
     end;
     end_z:=z;
end;



procedure suchen(such_start : doc_pointer; var such_end : doc_pointer);

var counter,i,found_pos     : byte;
    z,found                 : doc_pointer;
    SuchWort                : string20;
    tasten                  : char;



procedure search(var search_z : doc_pointer );

var temp : string80;
    k    : byte;
    h_pointer : doc_pointer;

begin
     found_pos:=0;
     while (found_pos=0) and (search_z<>nil) do begin;
       h_pointer:=search_z;
       temp:=search_z^.zeil;
       for k:=1 to length(temp) do temp[k]:=upcase(temp[k]);
       found_pos:=pos(Suchwort,temp);
       if search_z<> nil then search_z:=search_z^.nach;
     end;
     search_z:=h_pointer;
end;



begin
     textcolor(red);
     cursor_on;
     gotoxy(1,screeny-9);clreol;
     write('Search: ');readln(SuchWort);
     cursor_off;
     for i:=1 to length(SuchWort) do SuchWort[i]:=upcase(SuchWort[i]);
     textcolor(white);
     found:=such_start;
     
     if length(SuchWort)>0 then repeat
        search(found);
        if found <> nil then begin
           z:=found;
           found:=found^.nach;
           counter:=1;
           while (z^.nach<>nil) and (counter <>3) do begin
              inc(counter);
              z:=z^.vor;
           end;
           list_doc(z,such_end);
           gotoxy(found_pos,3);
           textbackground(white);textcolor(red);
           write(SuchWort);
           textbackground(blue);textcolor(green);
           gotoxy(1,screeny-9);
           write(SuchWort,'  found, to continue search press any key');
           write(', STOP <ESC>');
           textcolor(white);
           tasten:=readkey;
        end;
     until (found=nil) or (tasten=esc);
     if found=nil then begin
        textbackground(lightgray);textcolor(Black);
        list_doc(such_start,such_end);
        textcolor(red);
        gotoxy(1,screeny-9);
        write   (SuchWort,'  not found, press any key to continue ');
        write   ('               ');
        repeat
        until keypressed;
     end;
     textcolor(lightgray);
     gotoxy(1,screeny-9);
     clreol;
end;





var   akt_zeig,list_end : doc_pointer;
      tasten            : char;
      cnt               : byte;

begin
     save_screen;
     cursor_off;
     textbackground(green);textcolor(black);
     my_wwindow(2,screeny-3,screenx,screeny,'[HELP]','',false);
     write('Browse with PAGE UP / PAGE DOWN , leave with ESC');
     write(', search with s / S');
     textbackground(lightgray);textcolor(Black);
     my_wwindow(1,2,screenx-1,screeny-5,'[INFO]','<ESC>',true);
     list_doc(start,list_end);
     repeat
		tasten:=readkey;
        case tasten of
        p_up : begin
                 akt_zeig:=list_end;
                 cnt:=1;
                 repeat
                   akt_zeig:=akt_zeig^.vor;
                   inc(cnt);
                 until (cnt>screeny-1) or (akt_zeig^.vor=nil);
                 list_doc(akt_zeig,list_end);
               end;

        p_dw : begin
                 akt_zeig:=list_end;
                 cnt:=1;
                 repeat
                   akt_zeig:=akt_zeig^.vor;
                   inc(cnt);
                 until (cnt>8) or (akt_zeig^.nach=nil);
                 list_doc(akt_zeig,list_end);
               end;

        's','S' : suchen(start,list_end);

        end;

     until tasten=esc;
     restore_screen(1,2,screenx,screeny-1);
     textbackground(black);textcolor(black);
     window(1,2,screenx,screeny-1);
     clrscr;
end;





