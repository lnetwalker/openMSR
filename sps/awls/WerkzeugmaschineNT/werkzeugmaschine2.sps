  1 U   E     4 Flankenerkennung Start Taste
  2 UN  M     4 
  3 =   M     4 
  4 S   M    10 steuerung laeuft
  5 S   M     5 phase 1 ein
  6 R   M     6 phase 2 aus
  7 R   M     7 phase 3 aus
  8 R   M     8 phase 4 aus
  9 R   M     9 phase 5 aus
 10 U   E     4 
 11 =   M     4 
 12 U   E     3 werkstueck in position
 13 UN  M     3 
 14 =   M     3 
 15 R   M     5 phase 1 aus
 16 S   M     6 phase 2 ein
 17 R   M     7 phase 3 aus
 18 R   M     8 phase 4 aus
 19 R   M     9 phase 5 aus
 20 U   E     3 
 21 =   M     3 
 22 U   E     1 
 23 UN  M     1 motor 1 unten
 24 =   M     1 
 25 R   M     5 phase 1 aus
 26 R   M     6 phase 2 aus
 27 S   M     7 phase 3 ein
 28 R   M     8 phase 4 aus
 29 R   M     9 phase 5 aus
 30 U   M    11 bearbeitung beendet
 31 R   M     5 phase 1 aus
 32 R   M     6 phase 2 aus
 33 R   M     7 phase 3 aus
 34 S   M     8 phase 4 ein
 35 R   M     9 phase 5 aus
 36 U   E     2 motor 1 oben
 37 UN  M     2 
 38 =   M     2 
 39 R   M     5 phase 1 aus
 40 R   M     6 phase 2 aus
 41 R   M     7 phase 3 aus
 42 R   M     8 phase 4 aus
 43 S   M     9 phase 5 ein
 44 U   E     2 
 45 =   M     2 
 46 U   M     5 phase 1
 47 =   A     3 motor 2 laeuft
 48 U   M     6 phase 2
 49 S   A     1 motor 1 ab
 50 R   A     2 
 51 U   M     7 phase 3
 52 R   A     1 motor 1 aus
 53 R   A     2 
 54 R   A     4 bearbeiten ein
 55 TE  T     1 timer 1 starten
 56 K        30  30 sekunden
 57 U   T     1 zeit T1 abgelaufen
 58 S   M    11 
 59 U   M     8 phase 4
 60 R   A     4 bearbeitung aus
 61 R   A     1 motor 1 auf
 62 S   A     2 
 63 U   M     9 phase 5
 64 R   M    11 
 65 R   A     1 motor 1 aus
 66 R   A     2 
 67 R   M    10 steuerung aus
 68 EN       -1 Zykluszeit Tz= 0.05 ms
