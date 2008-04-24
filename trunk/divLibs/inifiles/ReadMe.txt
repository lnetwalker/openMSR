Unit "inifiles"
같같같같같같같�
  Author       : Raik Niemann ( mailto:raik.niemann@fh-stralsund.de )
  Date         : 17.06.2003 or 2003/06/17
  Homepage     : http://www.user.fh-stralsund.de/~seraniem
  Requirements : FreePascal ( www.freepascal.org ), units "classes" and
                 "sysutils"
  
Intention of this unit
======================  
  
  This unit is intended to read and store data in plain text files in the
  .ini-format, e.g. configuration files.
  An .ini file contains of one or more sections amd key-value-pairs in the
  sections. The section names are enclosed in brackets "[","]" and the keys
  are seperated from the values by a "=". The section names are case-
  insensitive, e.g. "Section1" and "SECtION1" are the same. The keys and
  values are case-sensitive.
  
  [Section1]
	Key1=Value1
	Key2=Value2

  # A comment
  ; Another comment
  
  [Section2]
	Key1=Value1
  ...

