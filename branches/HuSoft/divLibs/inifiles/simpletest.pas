program simpletest;

uses inifiles;
var
  IniFile : TIniFile;
  
begin
  IniFile:=TIniFile.Create( '' );
  WriteLn( 'Adding some sections ...' );
  IniFile.NewSection( 'Section1' );
  IniFile.NewSection( 'Section2' );
  IniFile.NewSection( 'Section3' );

  WriteLn( 'Adding data to the sections ...' );
  IniFile.WriteString( 'Section1', 'Key1', 'Value1' );
  IniFile.WriteString( 'Section1', 'Key2', 'Value2' );
  IniFile.WriteInteger( 'Section2', 'Key', 23 );
  IniFile.WriteBool( 'Section3', 'BoolKey', true );

  WriteLn( 'Number of sections : ', IniFile.SectionCount );
  WriteLn( 'Number of key-value-pairs in "Section 1" : ',
	IniFile.ValueCount( 'Section1' ) );
  WriteLn( 'Number of key-value-pairs in "Section 2" : ',
	IniFile.ValueCount( 'Section2' ) );
  WriteLn( 'Number of key-value-pairs in "Section 3" : ',
	IniFile.ValueCount( 'Section3' ) );
	
  WriteLn( 'Value of Key "Key1" in Section "Section1" : ',
	IniFile.ReadString( 'Section1', 'Key1', '' ) );
  WriteLn( 'Value of Key "Key" in Section "Section2" : ',
	IniFile.ReadInteger( 'Section2', 'Key', 0 ) );
  WriteLn( 'Value of Key "BoolKey" in Section "Section3" : ',
	IniFile.ReadBool( 'Section3', 'BoolKey', false ) );

  WriteLn( 'Destroying the class ...' );
  IniFile.Destroy;
end.