  1 U   E     1 Flankenerkennung E1
  2 UN  M    11 
  3 =   M    12 pos FLanke an E1
  4 U   E     1 
  5 =   M    11 /Flankenerkennung E1
  6 U   E     2 Flankenerkennung E2
  7 UN  M    13 
  8 =   M    14  pos Flanke an E2
  9 U   E     2 
 10 =   M    13 /Flankenerkennung E2
 11 UN  E     1 Phase 0 einschalten
 12 UN  E     2 
 13 S   M     1 Phase 0
 14 R   M     2 
 15 R   M     3 
 16 R   M     4 
 17 R   M     5 
 18 R   M     6 
 19 R   M     7 
 20 R   M     8 
 21 R   M     9 
 22 R   M    10 
 23 U   M    12 Phase 1 einschalten
 24 R   M     1 
 25 S   M     2 
 26 U   M    14 Phase 2 einschalten
 27 R   M     2 
 28 S   M     3 
 29 U   M     3 
 30 TE  T     8 
 31 K       100 
 32 U   T     8 Phase 3 einschalten
 33 R   M     3 
 34 S   M     4 
 35 U   M     4 
 36 TE  T     1 
 37 K        10 
 38 U   T     1 Phase 4 einschalten
 39 R   M     4 
 40 S   M     5 
 41 U   M     5 
 42 TE  T     2 
 43 K        10 
 44 U   T     2 Phase 5 einschalten
 45 R   M     5 
 46 S   M     6 
 47 U   M     6 
 48 TE  T     3 
 49 K        10 
 50 U   T     3 Phase 6 einschalten
 51 R   M     6 
 52 S   M     7 
 53 U   M     7 
 54 TE  T     4 
 55 K        10 
 56 U   T     4 Phase 7 einschalten
 57 R   M     7 
 58 S   M     8 
 59 U   M     8 
 60 TE  T     5 
 61 K       100 
 62 U   T     5 Phase 8 einschalten
 63 R   M     8 
 64 S   M     9 
 65 U   M     9 
 66 TE  T     6 
 67 K       100 
 68 U   T     6 Phase 9 einschalten
 69 R   M     9 
 70 S   M    10 
 71 U   M    10 
 72 TE  T     7 
 73 K       100 
 74 U   T     7  Phase 3 einschalten
 75 R   M    10 
 76 S   M     5 
 77 NOP      -1 Ausgabe der Signale der einzelnen Phasen
 78 U   M     1 Phase 0 alles aus
 79 R   A     1 
 80 R   A     2 
 81 R   A     3 
 82 R   A     4 
 83 R   A     5 
 84 R   A     6 
 85 U   M     2 Phase 1 gelb blinken
 86 U   M    62 
 87 =   A     2 
 88 =   A     5 
 89 U   M     3 Phase 2 beide Richtungen gelb
 90 S   A     2 
 91 S   A     5 
 92 R   A     1 
 93 R   A     3 
 94 R   A     4 
 95 R   A     6 
 96 U   M     4  Phase 3 beide Richtungen rot
 97 S   A     1 
 98 S   A     4 
 99 R   A     2 
100 R   A     3 
101 R   A     5 
102 R   A     6 
103 U   M     5 Phase 4 Richtung 1 rot,gelb; Richtung 2 rot
104 S   A     1 
105 S   A     2 
106 R   A     3 
107 S   A     4 
108 R   A     5 
109 R   A     6 
110 U   M     6 Phase 5  Richtung 1 gruen; Richtung 2 rot
111 R   A     1 
112 R   A     2 
113 S   A     3 
114 S   A     4 
115 R   A     5 
116 R   A     6 
117 U   M     7  Phase 6 Richtung 1 gelb; Richtung 2 rot
118 R   A     1 
119 S   A     2 
120 R   A     3 
121 S   A     4 
122 R   A     5 
123 R   A     6 
124 U   M     8 Phase 7 Richtung 1 rot; Richtung 2 rot, gelb
125 S   A     1 
126 R   A     2 
127 R   A     3 
128 S   A     4 
129 S   A     5 
130 R   A     6 
131 U   M     9 Phase 8 Richtung 1 rot; Richtung 2 gruen
132 S   A     1 
133 R   A     2 
134 R   A     3 
135 R   A     4 
136 R   A     5 
137 S   A     6 
138 U   M    10 Phase 9 Richtung 1 rot; Richtung 2 gelb
139 S   A     1 
140 R   A     2 
141 R   A     3 
142 R   A     4 
143 S   A     5 
144 R   A     6 
145 EN       -1 Zykluszeit Tz= 6.07 ms
