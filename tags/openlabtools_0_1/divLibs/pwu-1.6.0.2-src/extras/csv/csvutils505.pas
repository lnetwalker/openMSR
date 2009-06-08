{ Basic CSV functions for adding cells and new rows to a new CSV string
  which can then be save to a file 

  Note: relies on strwrap1, it is available in freepascal contributed units section 

  Excel seems to handle ,"", empty strings and "strings" fine, and it is safer to
  enclose everything in quotes instead of figuring out which fields need quotes and
  which don't - not worth the time or the bytes saved.

  Author,
  Lars (L505)
  http://z505.com  }

unit CsvUtils505; {$ifdef fpc}{$mode objfpc} {$H+}{$endif}

interface
uses
  capstr;

function CsvAddCell(s: string; var csvstr: string; delim: string; encloser: string): boolean; overload;
function CsvStartNewRow(var csvstr: string; delim: string): boolean; overload;
function CsvEnd(var csvstr: string; delim: string): boolean; overload;

function CsvAddCell(s: string; var csvstr: string): boolean; overload;
function CsvEnd(var csvstr: string): boolean; overload;
function CsvStartNewRow(var csvstr: string): boolean; overload;

function CsvAddCell(s: string; var csvstr: TCapStr; delim: string; encloser: string): boolean; overload;
function CsvEnd(var csvstr: TCapStr; delim: string): boolean; overload;
function CsvStartNewRow(var csvstr: TCapStr; delim: string): boolean; overload;

function CsvAddCell(s: string; var csvstr: Tcapstr): boolean; overload;
function CsvEnd(var csvstr: tcapstr): boolean; overload;
function CsvStartNewRow(var csvstr: tcapstr): boolean; overload;


procedure debugproc(s: string);
var debugln: procedure (s: string) = {$ifdef fpc}@{$endif}debugproc;



implementation

uses
  strutils,
  sysutils,
  strwrap1;

var
  CRLF: string = #13#10;

procedure debugproc(s: string);
begin
end;

{  s is the string to add, cvs string is the string to add too
   S consists of an unquoted (unenclosed) string, if quotes exist in S they will
   be replaced with doubled quote (encloser). }
function CsvAddCell(s: string; var csvstr: string; delim: string; encloser: string): boolean;
begin
   // if '' then add "",
  result:= false;
  if s = '' then 
  begin
    s:= encloser + encloser + delim; // "",
    csvstr:= csvstr + s;
    exit;
  end;
  // excel may do weird things with HTML, replace quotes first  
  s:= stringreplace(s, '&quot;', '"', [rfReplaceAll]);
  // replaces " with ""
  s:= stringreplace(s, encloser, encloser + encloser, [rfReplaceAll]);


  // enclose string in Quotes (enclosers)
  s:= encloser + s + encloser;
  //Replace CrLf, i.e. Excel prefers #10 
  s:= stringreplace(s, #13#10, #10, [rfReplaceAll]);
  csvstr:= csvstr + s + ',';  //"test",
end;

{ UNTESTED }
function CsvAddCell(s: string; var f: text; delim: string; encloser: string): boolean; overload;
begin
   // if '' then add "",
  result:= false;
  if s = '' then 
  begin
    s:= encloser + encloser + delim; // "",
    append(f);
    write(f, s);
    exit;
  end;
  // excel may do weird things with HTML, replace quotes first  
  s:= stringreplace(s, '&quot;', '"', [rfReplaceAll]);
  // replaces " with ""
  s:= stringreplace(s, encloser, encloser + encloser, [rfReplaceAll]);


  // enclose string in Quotes (enclosers)
  s:= encloser + s + encloser;
  //Replace CrLf, i.e. Excel prefers #10 
  s:= stringreplace(s, #13#10, #10, [rfReplaceAll]);
  append(f);
  write(f, s);
  write(f, ',');
end;


function CsvAddCell(s: string; var csvstr: TCapStr; delim: string; encloser: string): boolean;
begin
   // if '' then add "",
  result:= false;
  if s = '' then 
  begin
    s:= encloser + encloser + delim; // "",
    // csvstr:= csvstr + s;
    capstr.addstr(s, @csvstr);
    exit;
  end;
  // excel may do weird things with HTML, replace quotes first  
  s:= stringreplace(s, '&quot;', '"', [rfReplaceAll]);
  // replaces " with ""
  s:= stringreplace(s, encloser, encloser + encloser, [rfReplaceAll]);


  // enclose string in Quotes (enclosers)
  s:= encloser + s + encloser;
  //Replace CrLf, i.e. Excel prefers #10 
  s:= stringreplace(s, #13#10, #10, [rfReplaceAll]);
//  csvstr:= csvstr + s + ',';  //"test",
  capstr.addstr(s , @csvstr);
  capstr.addstr(',', @csvstr);
end;


{ adds new row to existing csv string returns false if problem }
function CsvStartNewRow(var csvstr: string; delim: string): boolean;
var
  endpos: integer;
begin
  result:= false;
  if delim = '' then exit;
  endpos:= (length(csvstr) - length(delim)) + 1;
  // decide whether to replace trailing comma with carriage return
  if AnsiEndsStr(delim, csvstr) then  
    system.delete(csvstr, endpos, length(delim));
  csvstr:= csvstr + CRLF;  // add carriage return to end, starting new row
  result:= true;
end;

function CsvStartNewRow(var f: text; delim: string): boolean;
begin

end;


function CsvStartNewRow(var csvstr: TCapStr; delim: string): boolean;
var
  endpos: integer;
begin
  result:= false;
  if delim = '' then exit;
  endpos:= (csvstr.strlen - length(delim)) + 1;
  // decide whether to replace trailing comma with carriage return
  capstr.endupdate(@csvstr); // must make this call before using string data in functions
  if AnsiEndsStr(delim, csvstr.data) then  
    capstr.delete(@csvstr, endpos, length(delim));
//  csvstr:= csvstr + CRLF;  // add carriage return to end, starting new row
  capstr.addstr(CRLF, @csvstr);
  result:= true;  

end;

{ this must be called after adding is complete, deletes trailing comma (delim) }
function CsvEnd(var csvstr: string; delim: string): boolean;
var
  b: boolean;
  endpos: integer;
begin
  result:= false;
  if delim = '' then exit;
  if csvstr = '' then exit;
  // find location of potential trailing delimiter
  endpos:= (length(csvstr) - length(delim)) + 1;
  // delete trailing comma (delimiter) 
  b:= AnsiEndsStr(delim, csvstr);
  if b = true then // delete trailing delim
    system.delete(csvstr, endpos, length(delim));
  result:= true;
end;

function CsvEnd(var f: text; delim: string): boolean;
begin
end;

function CsvEnd(var csvstr: TCapStr; delim: string): boolean;
var
  b: boolean;
  endpos: integer;
begin
  result:= false;
  if delim = '' then exit;
  if csvstr.data = '' then exit;
  // find location of potential trailing delimiter
  endpos:= (csvstr.strlen - length(delim)) + 1;
  // delete trailing comma (delimiter) 
  capstr.endupdate(@csvstr); // must make this call before using string data in functions
  b:= AnsiEndsStr(delim, csvstr.data);
  if b = true then // delete trailing delim
    capstr.delete(@csvstr, endpos, length(delim));
  capstr.endupdate(@csvstr);
  result:= true;
end;


// overloaded, with default encloser and delimiter
function CsvAddCell(s: string; var csvstr: string): boolean; 
begin
  result:= CsvAddCell(s, csvstr, ',', '"');
end;

// overloaded, with default delimiter
function CsvEnd(var csvstr: string): boolean;
begin
  result:= CsvEnd(csvstr, ',');
end;

// overloaded, with default delimiter
function CsvStartNewRow(var csvstr: string): boolean;
begin
  result:= CsvStartNewRow(csvstr, ',');
end;



// overloaded, with default encloser and delimiter
function CsvAddCell(s: string; var csvstr: Tcapstr): boolean; 
begin
  result:= CsvAddCell(s, csvstr, ',', '"');
end;

// overloaded, with default delimiter
function CsvEnd(var csvstr: tcapstr): boolean;
begin
  result:= CsvEnd(csvstr, ',');
end;

// overloaded, with default delimiter
function CsvStartNewRow(var csvstr: tcapstr): boolean;
begin
  result:= CsvStartNewRow(csvstr, ',');
end;

end.