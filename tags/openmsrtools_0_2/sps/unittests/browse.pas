unit browse;
{ browse.pas : unit which shows a text window with any ascii text 	}
{ where you can browse and search									} 
interface

type	
		string76 = string[76];
		doc_pointer = ^doc_record;
      	doc_record = record
                     zeil : string[76];
                     nach,
                     vor  : doc_pointer;
                   end;

procedure browsetext (start :doc_pointer;x1,y1,x2,y2:word);
procedure ReadListFromFile(fqfn:string;var start:doc_pointer);
procedure AppendStringToList(line:string;var start:doc_pointer);

implementation
uses crt,popmenu;

procedure AppendStringToList(line:string;var start:doc_pointer);
var
	z1,z2             : doc_pointer;
	
begin
	new(z1);
	z1:=start;
	while ( z1^.nach <> nil) do z1:=z1^.nach;
	new (z2);
	z1^.nach:=z2;
	z2^.vor:=z1;
	z2^.nach:=nil;
	z2^.zeil:=line;
end;


procedure ReadListFromFile(fqfn:string;var start:doc_pointer);
var
     z1,z2             : doc_pointer;
	 f                 : text;

begin
     assign(f,fqfn);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'Error reading  DOCfiles');
        writeln ('DOCfile not found ',fqfn);
        halt(1);
     end
     else begin
        new(z1);
        start:=z1;
        readln(f,z1^.zeil);
        z1^.vor:=nil;
        while not eof(f) do begin
           new(z2);
           z1^.nach:=z2;
           readln(f,z2^.zeil);
           z2^.vor:=z1;
           z1:=z2;
        end;
        z1^.nach:=nil;
        close(f);
     end;

end;


procedure browsetext (start :doc_pointer;x1,y1,x2,y2:word);


const p_up = #73;
      p_dw = #81;
      esc  = #27;

var   akt_zeig,list_end : doc_pointer;
      tasten            : char;
      cnt               : byte;

procedure list_doc(list_start : doc_pointer;var end_z:doc_pointer);

var counter : byte;
    z       : doc_pointer;

begin
     clrscr;
     z:=list_start;
     counter:=1;
     while (counter < y2-8) and (z^.nach <> nil) do begin
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
     gotoxy(1,y2-9);clreol;
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
           gotoxy(1,y2-9);
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
        gotoxy(1,y2-9);
        write   (SuchWort,'  not found, press any key to continue ');
        write   ('               ');
        repeat
        until keypressed;
     end;
     textcolor(lightgray);
     gotoxy(1,y2-9);
     clreol;
end;



begin
     save_screen;
     cursor_off;
     textbackground(green);textcolor(black);
     my_wwindow(x1,y2-3,x2,y2,'[HELP]','',false);
     write('Browse with PAGE UP / PAGE DOWN , leave with ESC');
     write(', search with s / S');
     textbackground(lightgray);textcolor(Black);
     my_wwindow(x1,y1,x2-1,y2-5,'[INFO]','<ESC>',true);
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
                 until (cnt>y2-1) or (akt_zeig^.vor=nil);
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
 {    restore_screen;}
     textbackground(black);textcolor(black);
     window(x1,y1,x2,y2);
     clrscr;
end;

begin

end.
