program simpletest;

uses inifiles, classes;
var
  IniFile 	: TIniFile;
  Dummy 	: TStringList;
  i			: integer;
  
begin
  IniFile:=TIniFile.Create( 'test.ini' );
  Dummy:=TStringList.Create;

  WriteLn( 'Readind data from "test.ini" ...' );
  IniFile.ReadIniFile;
  
  WriteLn( 'Number of sections : ', IniFile.SectionCount );
  WriteLn( 'Number of key-value-pairs in "Section 1" : ',
	IniFile.ValueCount( 'Section1' ) );
  WriteLn( 'Number of key-value-pairs in "Section 2" : ',
	IniFile.ValueCount( 'Section2' ) );
  WriteLn( 'Number of key-value-pairs in "Section 3" : ',
	IniFile.ValueCount( 'Section3' ) );
	
  IniFile.SectionList( Dummy );
  WriteLn( 'Section names :' );
  for i:=1 to Dummy.count do
	WriteLn( #9, Dummy.Strings[i-1] );
  Dummy.Clear;

  WriteLn( 'list of keys in "Section1" :' );
  IniFile.keyList( Dummy, 'Section1' );
  for i:=1 to Dummy.count do
	WriteLn( #9, Dummy.Strings[i-1] );
  Dummy.Clear;
  
  WriteLn( 'list of values in "Section1" :' );
  IniFile.ValueList( Dummy, 'Section1' );
  for i:=1 to Dummy.count do
	WriteLn( #9, Dummy.Strings[i-1] );
	
  WriteLn( 'Value of Key "Key1" in Section "Section1" : ',
	IniFile.ReadString( 'Section1', 'Key1', '' ) );
  WriteLn( 'Value of Key "Key" in Section "Section2" : ',
	IniFile.ReadInteger( 'Section2', 'Key', 0 ) );
  WriteLn( 'Value of Key "BoolKey" in Section "Section3" : ',
	IniFile.ReadBool( 'Section3', 'BoolKey', false ) );

  WriteLn( 'Destroying the class ...' );
  IniFile.Destroy;
  Dummy.Destroy;
end.