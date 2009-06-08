{ On windows, this program compiled in only 31 Kilobytes, yet still uses a
  stringlist with equivilent features of the one in Classes.pp }

program project1;

{$mode delphi}{$H+}

uses
 CompactUtils, CompactSysUtils;


var
  SmallList: PStrList;
  s: string;
  i: integer;
  
const
 {$ifdef win32}
  TEST_PATH = 'c:\test\test.txt';
 {$endif}
 {$ifdef unix}
  TEST_PATH = '/var/test.txt';
 {$endif}
begin

  SmallList:= NewStrList;
  SmallList.add('test0');
  SmallList.add('test1');
  SmallList.add('test2');
  writeln(SmallList.text);
  SmallList.free; SmallList:= nil;

  writeln('Extracted file path: ', ExtractFilePath(TEST_PATH));
  writeln('Extracted file name: ', ExtractFileName(TEST_PATH));
  writeln('Extracted file drive: ', ExtractFileDrive(TEST_PATH));
  
  s:= inttostr(649);
  writeln(s);

  // does the same thing, but compatible with KOL naming scheme
  s:= int2str(649);
  writeln(s);


  i:= strtoint('64366');
  writeln(i);
  
  writeln(uppercase('somE UPpErCasE tExt FoR the pC to spit'));
  writeln(lowercase('somE lowerCaSe tExt FoR the pC to spit'));

  s:= BoolToStr(true);
  writeln(s);
  
  s:= BoolToStr(false);
  writeln(s);

  s:= FloatToStr(1.342);
  writeln(s);

  
  readln;
end.

