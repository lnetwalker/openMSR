  1 U   E     4 Start
  2 UN  M     4 und Steuerung ist aus
  3 S   M     4 starte Steuerung
  4 NOP       0                       
  5 NOP       0                       
  6 NOP       0                       
  7 NOP       0                       
  8 U   E     2 Oberer Kontakt
  9 U   M     1 Motor fährt rauf
 10 R   M     1 Motor aus
 11 S   M     7 Phase 1 einschalten
 12 NOP       0                       
 13 NOP       0                       
 14 U   E     1 Unterer Kontakt
 15 U   M     2 Motor fährt ab
 16 R   M     2 Motor aus
 17 NOP       0 
 18 NOP       0 
 19 U   M     1 Motor fährt auf
 20 R   A     4 
 21 S   A     5 
 22 NOP       0                       
 23 NOP       0 
 24 UN  M     1 motor aus
 25 UN  M     2 
 26 R   A     4 
 27 R   A     5 
 28 NOP       0 
 29 NOP       0 
 30 U   M     2 motor fährt ab
 31 S   A     4 
 32 R   A     5 
 33 NOP       0 
 34 NOP       0 
 35 U   M     2 Sicherheitsabschaltung
 36 U   M     1 Motor auf und ab
 37 R   A     4 alles aus
 38 R   A     5 
 39 S   A     6 störungssignal ein
 40 R   M     4 Steuerung aus
 41 NOP       0 
 42 NOP       0 
 43 U   E     3 Abschaltung Motor 2
 44 UN  M     5 Flanke erkennen
 45 R   A     2 Motor 2 aus
 46 U   E     3 
 47 =   M     5 
 48 S   M     8 Phase 2 einschalten
 49 R   M     7 Phase 1 ausschalten
 50 NOP       0 
 51 NOP       0 
 52 U   M     4 positive flanke start signal
 53 UN  M     6 setzt Phase 1
 54 S   M     7 
 55 U   M     4 
 56 =   M     6 
 57 NOP       0 
 58 NOP       0 
 59 U   M     7 Phase 1
 60 S   A     2 Motor 2 einschalten
 61 NOP      -1 
 62 NOP      -1 
 63 U   M     8 Phase 2 ein
 64 S   M     2 Motor 1 ab
 65 NOP      -1 
 66 NOP      -1 
 67 NOP      -1 
 68 EN       -1 Zykluszeit Tz= 1.18 ms
