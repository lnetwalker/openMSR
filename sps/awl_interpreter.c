/* Output from p2c 2.00.Oct.15, the Pascal-to-C translator */
/* From input file "/home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas" */


/* this is the interpreter for sps files */
/* interpreter version 1.2*/

/* copyright (C) 2017 by Hartmut Eilers <hartmut@eilers.net>*/
/* distributed under the GNU General Public License V2 or any later*/


#include <p2c/p2c.h>


Static double timeNow()
{
  long usec = 0;

  gettime(std, 0);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 9:
 * Warning: Symbol 'STD' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 9:
 * Warning: Expected a '(', found a comma [227] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 9:
 * Warning: Symbol 'GETTIME' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 10:
 * Warning: Symbol 'USEC' is not defined [221] */
  return (((std * 3600.0 + sec) * 1000 + ms) * 1000 + usec);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 11:
 * Warning: Symbol 'STD' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 11:
 * Warning: Expected a '(', found a ')' [227] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 11:
 * Warning: Symbol 'SEC' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 11:
 * Warning: Symbol 'MS' is not defined [221] */
}


Static Void RPMs()
{
  double time1, time2;
  long durchlaufeProSec;

  if (runs == 0) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 17:
 * Warning: Symbol 'RUNS' is not defined [221] */
    time1 = timeNow();
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 18:
 * Warning: Symbol 'TIME1' is not defined [221] */
  }
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 20:
 * Warning: Symbol 'RUNS' is not defined [221] */
  runs++;
  if (runs != TimeRuns)
    return;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 21:
 * Warning: Symbol 'RUNS' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 21:
 * Warning: Symbol 'TIMERUNS' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 22:
 * Warning: Symbol 'RUNS' is not defined [221] */
  time2 = (timeNow() - time1) / TimeRuns;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 23:
 * Warning: Symbol 'TIMERUNS' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 23:
 * Warning: Symbol 'TIME2' is not defined [221] */
  if (time2 == 0)   /* 1 �second */
    time2 = 0.0000001;
  durchlaufeProSec = (long)(1000000L / time2);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 25:
 * Warning: Symbol 'DURCHLAUFEPROSEC' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 26:
 * Note: Turbo Pascal conditional compilation directive was ignored [218] */
  /*$ifdef SPS*/
  gotoxy(35, 16);
  clreol();
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 28:
 * Warning: Symbol 'CLREOL' is not defined [221] */
  printf("Cycletime Tz=%5.2f ms =%5ld CPS ", time2 / 1000, durchlaufeProSec);
  /*$endif*/
}


Static Void toggle_internal_clock(m1, m2, m3)
boolean *m1, *m2, *m3;
{
  /* toggelt die internen clock-marker */
  *m3 = !*m3;
  if (*m3)
    *m2 = !*m2;
  if (*m2 && *m3)
    *m1 = !*m1;
}  /* **** ENDE TOGGLE_INTERNAL_CLOCK **** */


Static boolean mehrfach(z)
unsigned short z;
{
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas:
 * Note: Eliminated unused assignment statement [338] */
  if (operation[z+1] == anweisung[1] || operation[z+1] == anweisung[3] ||
      operation[z+1] == anweisung[5] || operation[z+1] == anweisung[20] ||
      operation[z+1] == anweisung[11] || operation[z+1] == anweisung[25] ||
      operation[z+1] == anweisung[30] || operation[z+1] == anweisung[31] ||
      operation[z+1] == anweisung[32] || operation[z+1] == anweisung[33] ||
      operation[z+1] == anweisung[34] || operation[z+1] == anweisung[12])
	/* UN(*/
	  return false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 47:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 47:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 48:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 48:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* UN*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 49:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 49:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* U(*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 50:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 50:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* NOP*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 51:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 51:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* EN*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 52:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 52:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* PE*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 53:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 53:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* EP*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 54:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 54:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* AN(*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 55:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 55:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* AN*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 56:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 56:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* A(*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 57:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 57:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* A*/
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 58:
 * Warning: Symbol 'OPERATION' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 58:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
  /* U*/
  return true;
}


/* Local variables for interpret: */
struct LOC_interpret {
  boolean akku, help;
  unsigned short k;
  uchar klammer, token;
  boolean klammerakku[255];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 71:
 * Warning: Symbol 'STRING3' is not defined [221] */
  long klammeroper[255];
  long aktuell, analog_akku;
} ;

/* Local variables for verkn: */
struct LOC_verkn {
  struct LOC_interpret *LINK;
} ;

Local Void zerleg(LINK)
struct LOC_verkn *LINK;
{
  /*negiert ggf den zustand eines operanden*/
  boolean inv = false;   /*und weist ihn dem Hilfsregister zu */

  if (LINK->LINK->aktuell == "ON " || LINK->LINK->aktuell == "UN " ||
      LINK->LINK->aktuell == "AN ")
    inv = true;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 87:
 * Warning: Symbol 'OPERAND' is not defined [221] */
  switch (operand[LINK->LINK->k]) {

  case "I":
    if (inv) {
      LINK->LINK->help = ~eingang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 89:
 * Warning: Symbol 'EINGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 89:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = eingang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 91:
 * Warning: Symbol 'EINGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 91:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "E":
    if (inv) {
      LINK->LINK->help = ~eingang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 93:
 * Warning: Symbol 'EINGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 93:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = eingang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 95:
 * Warning: Symbol 'EINGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 95:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "O":
    if (inv) {
      LINK->LINK->help = ~ausgang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 97:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 97:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = ausgang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 99:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 99:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "A":
    if (inv) {
      LINK->LINK->help = ~ausgang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 101:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 101:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = ausgang[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 103:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 103:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "M":
    if (inv) {
      LINK->LINK->help = ~marker[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 105:
 * Warning: Symbol 'MARKER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 105:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = marker[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 107:
 * Warning: Symbol 'MARKER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 107:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "T":
    if (inv) {
      LINK->LINK->help = ~timer[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 109:
 * Warning: Symbol 'TIMER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 109:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = timer[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 111:
 * Warning: Symbol 'TIMER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 111:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "C":
    if (inv) {
      LINK->LINK->help = ~zahler[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 113:
 * Warning: Symbol 'ZAHLER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 113:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = zahler[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 115:
 * Warning: Symbol 'ZAHLER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 115:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "Z":
    if (inv) {
      LINK->LINK->help = ~zahler[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 117:
 * Warning: Symbol 'ZAHLER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 117:
 * Warning: Symbol 'PAR' is not defined [221] */
    } else {
      LINK->LINK->help = zahler[par[LINK->LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 119:
 * Warning: Symbol 'ZAHLER' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 119:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
    break;

  case "J":
    if (debug)
      printf("analog input\n");
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 120:
 * Warning: Symbol 'DEBUG' is not defined [221] */
    break;
    /* errorabfrage */

  default:
    printf(" unknown operand line: %12u\n", LINK->LINK->k);
    _Escape(1);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas:
 * Note: Eliminated unused assignment statement [338] */
    break;
  }
}  /* **** ENDE ZERLEG *****       */


Local Void verkn(LINK)
struct LOC_interpret *LINK;
{
  /* verkn�pft akku mit hilfsregister */
  struct LOC_verkn V;

  V.LINK = LINK;
  switch (LINK->token) {

  case 1:
  case 2:
  case 5:
  case 6:
  case 31:
  case 33:  /* UN(,ON(,U(,O(,AN(,A( */
    LINK->klammer++;
    LINK->klammerakku[LINK->klammer-1] = LINK->akku;
    LINK->akku = true;
    LINK->klammeroper[LINK->klammer-1] = LINK->aktuell;
    break;

  default:
    zerleg(&V);
    break;
  }
  switch (LINK->token) {

  case 3:   /* UN*/
    LINK->akku = (LINK->akku && LINK->help);
    break;

  case 4:   /* ON*/
    LINK->akku = (LINK->akku || LINK->help);
    break;

  case 12:
    if (operand[LINK->k] == "J") {   /* U*/
      LINK->analog_akku = analog_in[par[LINK->k]];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 146:
 * Warning: Symbol 'ANALOG_IN' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 146:
 * Warning: Symbol 'PAR' is not defined [221] */
    }
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 145:
 * Warning: Symbol 'OPERAND' is not defined [221] */
    else
      LINK->akku = (LINK->akku && LINK->help);
    break;

  case 13:   /* O*/
    LINK->akku = (LINK->akku || LINK->help);
    break;

  case 32:   /* AN*/
    LINK->akku = (LINK->akku && LINK->help);
    break;

  case 34:   /* A*/
    LINK->akku = (LINK->akku && LINK->help);
    break;
  }
}  /* **** ENDE VERKN *****/


Local Void zuweisen(LINK)
struct LOC_interpret *LINK;
{
  /* weist den akkuinhalt einem ausg. od merker*/
  if (LINK->token == 7)
    LINK->akku = !LINK->akku;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 159:
 * Warning: Symbol 'OPERAND' is not defined [221] */
  switch (operand[LINK->k]) {

  case "O":
    ausgang[par[LINK->k]] = LINK->akku;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 160:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 160:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
    break;

  case "A":
    ausgang[par[LINK->k]] = LINK->akku;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 161:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 161:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
    break;

  case "M":
    marker[par[LINK->k]] = LINK->akku;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 162:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 162:
 * Warning: Symbol 'MARKER' is not defined [221] */
    break;

  case "J":
    analog_in[par[LINK->k]] = LINK->analog_akku;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 163:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 163:
 * Warning: Symbol 'ANALOG_IN' is not defined [221] */
    break;
    /*else*/
    /*f�r sp�tere errorabfrage */
  }
  if (!mehrfach(LINK->k))
    LINK->akku = true;
}  /* **** ENDE ZUWEISEN **** */

Local Void setzen(LINK)
struct LOC_interpret *LINK;
{
  /* setzt einen ausg. od. merker auf log 1*/
  if (LINK->akku) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 173:
 * Warning: Symbol 'OPERAND' is not defined [221] */
    switch (operand[LINK->k]) {

    case "O":
      ausgang[par[LINK->k]] = true;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 174:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 174:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
      break;

    case "A":
      ausgang[par[LINK->k]] = true;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 175:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 175:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
      break;

    case "M":
      marker[par[LINK->k]] = true;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 176:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 176:
 * Warning: Symbol 'MARKER' is not defined [221] */
      break;
      /*else*/
      /* f�r sp�tere Fehlermeldung */
    }
  }
  if (!mehrfach(LINK->k))
    LINK->akku = true;
}  /* **** ENDE SETZEN **** */

Local Void rucksetzen(LINK)
struct LOC_interpret *LINK;
{
  /* setzt einen ausg. od. merker auf log 0 */
  if (LINK->akku) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 187:
 * Warning: Symbol 'OPERAND' is not defined [221] */
    switch (operand[LINK->k]) {

    case "O":
      ausgang[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 188:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 188:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
      break;

    case "A":
      ausgang[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 189:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 189:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
      break;

    case "M":
      marker[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 190:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 190:
 * Warning: Symbol 'MARKER' is not defined [221] */
      break;
      /*else*/
      /* f�r sp�tere Fehlermeldung */
    }
  }
  if (!mehrfach(LINK->k))
    LINK->akku = true;
}  /* **** ENDE RUCKSETZEN **** */

Local Void klammer_zu(LINK)
struct LOC_interpret *LINK;
{
  /* beendet letzte klammer und verkn�pft */
  boolean helper;

  /* ON( bzw UN(  bzw AN(*/
  if (LINK->klammeroper[LINK->klammer-1] == "ON(" ||
      LINK->klammeroper[LINK->klammer-1] == "UN(" ||
      LINK->klammeroper[LINK->klammer-1] == "AN(") {
    helper = !LINK->akku;
    LINK->akku = helper;
  }
  if (LINK->klammeroper[LINK->klammer-1] == "O( " ||
      LINK->klammeroper[LINK->klammer-1] == "ON(")
    LINK->akku = (LINK->akku || LINK->klammerakku[LINK->klammer-1]);
  if (LINK->klammeroper[LINK->klammer-1] == "U( " ||
      LINK->klammeroper[LINK->klammer-1] == "UN(" ||
      LINK->klammeroper[LINK->klammer-1] == "AN(" ||
      LINK->klammeroper[LINK->klammer-1] == "A( ")
    LINK->akku = (LINK->akku && LINK->klammerakku[LINK->klammer-1]);
  LINK->klammer--;
}  /* **** ENDE KLAMMER_ZU **** */

Local Void set_timer(LINK)
struct LOC_interpret *LINK;
{
  /*timer auf startwert setzen*/
  long dummy;

  if (LINK->akku && ~lastakku[par[LINK->k]]) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 218:
 * Warning: Symbol 'LASTAKKU' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 218:
 * Warning: Symbol 'PAR' is not defined [221] */
    /* negative parameter means that a analog input value should be used as parameter */
    if (par[LINK->k+1] > 0) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 220:
 * Warning: Symbol 'PAR' is not defined [221] */
      t[par[LINK->k]] = par[LINK->k+1];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 221:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 221:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 222:
 * Warning: Symbol 'T' is not defined [221] */
    } else {
      putchar('\007');
      dummy = -par[LINK->k+1];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 224:
 * Warning: Symbol 'PAR' is not defined [221] */
      t[par[LINK->k]] = analog_in[dummy];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 225:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 225:
 * Warning: Symbol 'ANALOG_IN' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 225:
 * Warning: Symbol 'T' is not defined [221] */
    }
    timer[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 227:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 227:
 * Warning: Symbol 'TIMER' is not defined [221] */
    lastakku[par[LINK->k]] = true;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 228:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 228:
 * Warning: Symbol 'LASTAKKU' is not defined [221] */
  } else if (!LINK->akku) {
    t[par[LINK->k]] = 65535L;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 231:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 231:
 * Warning: Symbol 'T' is not defined [221] */
    timer[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 232:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 232:
 * Warning: Symbol 'TIMER' is not defined [221] */
    lastakku[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 233:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 234:
 * Warning: Symbol 'LASTAKKU' is not defined [221] */
  }
  LINK->akku = true;
}  /* **** ENDE SET_TIMER *****/

Local Void set_counter(LINK)
struct LOC_interpret *LINK;
{
  /* counter auf startwert setzen */
  if (LINK->akku && ~lastakku[par[LINK->k] + 8]) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 241:
 * Warning: Symbol 'LASTAKKU' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 241:
 * Warning: Symbol 'PAR' is not defined [221] */
    z[par[LINK->k]] = par[LINK->k+1];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 242:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 242:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 242:
 * Warning: Symbol 'Z' is not defined [221] */
    zahler[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 243:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 243:
 * Warning: Symbol 'ZAHLER' is not defined [221] */
    lastakku[par[LINK->k] + 8] = true;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 244:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 245:
 * Warning: Symbol 'LASTAKKU' is not defined [221] */
  } else if (!LINK->akku) {
    z[par[LINK->k]] = 65535L;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 247:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 247:
 * Warning: Symbol 'Z' is not defined [221] */
    zahler[par[LINK->k]] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 248:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 248:
 * Warning: Symbol 'ZAHLER' is not defined [221] */
    lastakku[par[LINK->k] + 8] = false;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 249:
 * Warning: Symbol 'PAR' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 250:
 * Warning: Symbol 'LASTAKKU' is not defined [221] */
  }
  LINK->akku = true;
}  /* **** ENDE SET_COUNTER *****/


Local Void analog_equal(LINK)
struct LOC_interpret *LINK;
{
  /* check for anaologig equal  */
  LINK->akku = false;
  if (par[LINK->k] == LINK->analog_akku) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 259:
 * Warning: Symbol 'PAR' is not defined [221] */
    LINK->akku = true;
  }
}  /* **** ENDE ANALOG_EQUAL*/

Local Void analog_less(LINK)
struct LOC_interpret *LINK;
{
  /* check for anaologig less than */
  LINK->akku = false;
  if (LINK->analog_akku < par[LINK->k]) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 266:
 * Warning: Symbol 'PAR' is not defined [221] */
    LINK->akku = true;
  }
}  /* **** ENDE ANALOG_less*/

Local Void analog_great(LINK)
struct LOC_interpret *LINK;
{
  /* check for anaologig greater than */
  LINK->akku = false;
  if (LINK->analog_akku > par[LINK->k]) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 273:
 * Warning: Symbol 'PAR' is not defined [221] */
    LINK->akku = true;
  }
}  /* **** ENDE ANALOG_great*/

Local Void jump(LINK)
struct LOC_interpret *LINK;
{
  LINK->k = par[LINK->k] - 1;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 278:
 * Warning: Symbol 'PAR' is not defined [221] */
  LINK->akku = true;
}

Local Void execute(LINK)
struct LOC_interpret *LINK;
{
  /* executes an external program */
  /* an external program should be launched if the akku is true*/
  /* the returncode of that programm is stored in the ANALOG_AKKU*/
  /* because it could be a 8 Bit value. the best effort is, that*/
  /* one can act on different return values with EQ,GT and LT*/
  /* you have to ensure, that output of the program is redirected*/
  if (!LINK->akku)
    return;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 291:
 * Note: Turbo Pascal conditional compilation directive was ignored [218] */
  /*$ifdef LINUX*/
  LINK->analog_akku = fpsystem(comment[LINK->k]);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 292:
 * Warning: Symbol 'COMMENT' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 292:
 * Warning: Symbol 'FPSYSTEM' is not defined [221] */
  /*$else*/
  exec(GetEnv("COMSPEC"), comment[LINK->k]);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 294:
 * Warning: Symbol 'GETENV' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 294:
 * Warning: Symbol 'COMMENT' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 294:
 * Warning: Symbol 'EXEC' is not defined [221] */
  LINK->analog_akku = DosExitCode;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 295:
 * Warning: Symbol 'DOSEXITCODE' is not defined [221] */
  /*$endif*/
}

Local Void cond_jump(LINK)
struct LOC_interpret *LINK;
{
  if (LINK->akku) {
    LINK->k = par[LINK->k] - 1;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 303:
 * Warning: Symbol 'PAR' is not defined [221] */
    LINK->akku = true;
  } else
    LINK->akku = true;
}


Local Void decrement(LINK)
struct LOC_interpret *LINK;
{
}


Local Void increment(LINK)
struct LOC_interpret *LINK;
{
}


Local Void loadconst(LINK)
struct LOC_interpret *LINK;
{
}



Static Void interpret()
{
  /* interpretiert einen durchlauf der awl */
  struct LOC_interpret V;
  long anweis;
  Char timestring[256];
  long watchdog = 0;
  Char STR2[256];


  V.k = 0;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 328:
 * Warning: Symbol 'WATCHDOG' is not defined [221] */
  V.akku = true;
  V.analog_akku = 0;
  V.help = false;
  V.klammer = 0;
  do {
    V.k++;
    watchdog++;
    V.aktuell = operation[V.k];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 336:
 * Warning: Symbol 'OPERATION' is not defined [221] */
    if (watchdog > awl_max) {
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 337:
 * Warning: Symbol 'AWL_MAX' is not defined [221] */
      V.aktuell = "EN ";
    }
    V.token = 0;
    do {   /* UN( .. O(*/
      V.token++;
      anweis = anweisung[V.token];
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 341:
 * Warning: Symbol 'ANWEISUNG' is not defined [221] */
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 342:
 * Warning: Symbol 'ANWEISMAX' is not defined [221] */
    } while (V.aktuell != anweis && V.token <= anweismax);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 343:
 * Warning: Expected UNTIL, found a '/' [227] */
    /* =      */
    /* JI */
    /* TE */
    /* ZR */
    /* EN   */
    /* U O*/
    /* ) */
    /* =N */
    /* S */
    /* R */
    /* J */
    /* K */
    /* NOP */
    /* EQ */
    /* LT */
    /* GT */
    /* $    */
    /* PE*/
    /* JP,SP*/
    /* JC,SPB*/
    /* EP*/
    /* AN(*/
    /* AN*/
    /* A(*/
    /* A    */
    /* DEC       */
    /* INC       */
    /* LDD       */
    /*else*/
    /* f�r sp�tere Fehlerabfrage */
  } while (V.aktuell != "EN " && V.aktuell != "PE " && V.aktuell != "EP ");
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 378:
 * Warning: Symbol 'TIME2' is not defined [221] */
  sprintf(timestring, "%5.2f", time2 / 1000.0);
  if (V.aktuell == "EN " || V.aktuell == "PE " || V.aktuell == "EP ") {
    sprintf(STR2, "Zykluszeit Tz=%s ms", timestring);
    comment[V.k] = STR2;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 379:
 * Warning: Symbol 'COMMENT' is not defined [221] */
  }
  if (!debug)
    return;
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 380:
 * Warning: Symbol 'DEBUG' is not defined [221] */
  for (V.k = 8; V.k >= 1; V.k--) {
    if (V.k == 8)
      printf("interpreter: E 8-1 %12ld ", eingang[V.k]);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 383:
 * Warning: Symbol 'EINGANG' is not defined [221] */
    else
      printf("%12ld ", eingang[V.k]);
  }
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 385:
 * Warning: Symbol 'EINGANG' is not defined [221] */
  putchar('\n');
  for (V.k = 8; V.k >= 1; V.k--) {
    if (V.k == 8)
      printf("interpreter: A 8-1 %12ld ", ausgang[V.k]);
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 389:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
    else
      printf("%12ld ", ausgang[V.k]);
  }
/* p2c: /home/DEVOLO/hartmut.eilers/massdata/Privat/openMSR/sps/awl_interpreter.pas, line 391:
 * Warning: Symbol 'AUSGANG' is not defined [221] */
  putchar('\n');
}  /* **** ENDE INTERPRET **** */



/* End. */
