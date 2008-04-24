program simpletest;

uses inifiles;
var
  IniFile : TIniFile;
  
begin
  IniFile:=TIniFile.Create( 'test.ini' );
  WriteLn( 'Adding some sections ...' );
  IniFile.NewSection( 'Section1' );
  IniFile.NewSection( 'Section2' );
  IniFile.NewSection( 'Section3' );

  WriteLn( 'Adding data to the sections ...' );
  IniFile.WriteString( 'Section1', 'Key1', 'Value1' );
  IniFile.WriteString( 'Section1', 'Key2', 'Value2' );
  IniFile.WriteInteger( 'Section2', 'Key', 23 );
  IniFile.WriteBool( 'Section3', 'BoolKey', true );

  WriteLn( 'Writing all data to "test.ini" ...' );
  IniFile.WriteIniFile;

  WriteLn( 'Destroying the class ...' );
  IniFile.Destroy;
end.