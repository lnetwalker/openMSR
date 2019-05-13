/* Output from p2c 2.00.Oct.15, the Pascal-to-C translator */
/* From input file "run_sps-combined.pas" */


#include <p2c/p2c.h>


/*$M 16000,0,0*/
/* 16000 Bytes STACK , kein HEAP */

/* porting to linux startet at 27.05.99 */
/* don't blame me for "bad" code*/
/* some of the code inside is from my earliest steps */
/* in pascal and some of my least steps after years*/
/* where I coded not one simple line in pascal :) */
/* If you have improvements please contact me at */
/* hartmut@eilers.net*/
/* all code is copyright by Hartmut Eilers*/
/* the code is distributed under the GNU */
/* general public license*/
/* history */
/*27.05.1999    start of Linux Port*/
/* 03.10.2000  start of Version 1.7.1*/
/*11.10.2000  installed fpc 1.0 */
/*11.10.2000  start analog processing */
/*EQ,LT,GT*/
/*10.09.2005  restructure code to support */
/*different hardware */
/*12.10.2005started code to read */
/*configuaration file*/
/*set TAB STops to 4 started to */
/*beauitify code*/
/*                                                   */
/*25.10.2005 run_sps is fully configurable,*/
/*hardware may be mixed*/
/*12.04.2006added driver for joystick */
/*analog processing works ! */
/*03.02.2008introduced PhysMach Unit for Hardware access */

/* virtual machine version 1.1*/
/* physical machine version PhysMach*/


/* global variables and constant definitions of the sps project */
/* all global values should be defined here, if you see any*/
/* ugly constant values in the code, please replace them with*/
/* symbolic names and define the names in this file*/
/* and please remember: the project is running since the early*/
/* 90's !It was first used in Dezember 1989*/
/* there is code of all my Pascal programming states*/
/* included beginner to "rebeginner" after years of no single*/
/* line written in pascal! thanks for not blaming me ;)*/

/* copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>*/
/* distributed under the GNU General Public License V2 or any later*/

typedef Char string3[4];

typedef Char string12[13];

typedef Char string15[16];

typedef Char string80[81];

typedef Char DeviceTypeArray[16];


#define debug           false

#define awl_max         2000
#define anweismax       37
#define minScreenX      80
#define minScreenY      25
/* include the SPS Version and build date */

#define version         "emb_SPS_0.1 "
#define datum           "30.04.2019"

#define p_up            'H'
#define p_dw            'P'
#define p_le            'K'
#define p_re            'M'
#define esc             '\033'
#define enter           '\015'
#define tab             '\t'

#define Platform        " embedded C "

#define ProgNamVer      sprintf(STR1, " RUN_SPS  for %s%s %s ", \
				Platform, version, datum)

#define Copyright       " (c)  1989 - 2017 by Hartmut Eilers "

#define io_max          128

#define group_max       ((long)floor(io_max / 8.0 + 0.5))

#define marker_max      255
#define akku_max        16
#define cnt_max         16
#define tim_max         16
#define analog_max      64
#define DeviceTypeMax   16


/* attention, it is important to keep the order of*/
/* the sps commands, because the bytecode interpreter */
/* relies on the order! (the editor formatter too!)*/
/* write new commands without blanks, they will be */
/* added where needed     */
/* only append new commands !!*/
/* check procedure formatiere in edit.pas and the */
/* interpreter in awl_interpreter.pasand run_sps.pas*/

Static string3 anweis[anweismax] = {
  "UN(", "ON(", "UN", "ON", "U(", "O(", "=N", "JI", "TE", "ZR", "EN", "U",
  "O", ")", "=", "S", "R", "J", "K", "NOP", "EQ", "LT", "GT", "$", "PE", "JP",
  "SP", "SPB", "JC", "EP", "AN(", "AN", "A(", "A", "DEC", "INC", "LDD"
};

Char STR1[54];



/* these variables are used by sps.pas and run_sps.pas */
Static Char operand[awl_max];
Static long par[awl_max];
Static string3 operation[awl_max];
Static string3 anweisung[anweismax];
Static long znr[awl_max];
Static Char comment[awl_max][256];
Static Char ConfFile[256];


/* these are the global vars and constants needed to run an awl */

/* copyright (c) 2006 by Hartmut Eilers <hartmut@eilers.net>*/
/* distributed under the GNU General Public License V2 or any later*/


Static boolean extern_, escape;
Static unsigned short watchdog;
Static double time1, time2;
Static unsigned short runs, TimeRuns, std, min, sec, ms, usec;

Static long i;

/* vars from PhysMach */
Static boolean marker[marker_max];
Static boolean eingang[io_max], ausgang[io_max];
Static boolean zust[io_max];
Static boolean lastakku[akku_max];
Static boolean zahler[cnt_max];
Static boolean timer[tim_max];
Static unsigned short t[tim_max];
Static unsigned short z[cnt_max];
Static long analog_in[analog_max];

Static Char HWPlatform[256];

Static unsigned short durchlaufeProSec, durchlauf, durchlauf100;

Static long i_address[group_max], o_address[group_max], c_address[group_max],
	    a_address[group_max];
Static Char i_devicetype[analog_max], o_devicetype[analog_max],
	    c_devicetype[analog_max], a_devicetype[analog_max],
	    u_devicetype[analog_max];
Static DeviceTypeArray DeviceList;
Static Char CfgLine[256];
Static Char initstring[256];


/* this is the interpreter for sps files */
/* interpreter version 1.2*/

/* copyright (C) 2017 by Hartmut Eilers <hartmut@eilers.net>*/
/* distributed under the GNU General Public License V2 or any later*/

Static double timeNow()
{
  GetTime(&std, &min, &sec, &ms);
  usec = 0;
  return ((((std * 60.0 + min) * 60 + sec) * 1000 + ms) * 1000 + usec);
}


Static Void RPMs()
{
  if (runs == 0)
    time1 = timeNow();
  runs++;
  if (runs != TimeRuns)
    return;
  runs = 0;
  time2 = (timeNow() - time1) / TimeRuns;
  if (time2 == 0)   /* 1 �second */
    time2 = 0.0000001;
  durchlaufeProSec = (long)(1000000L / time2);
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
/* p2c: run_sps-combined.pas:
 * Note: Eliminated unused assignment statement [338] */
  if (!strcmp(operation[z], anweisung[0]) ||
      !strcmp(operation[z], anweisung[2]) ||
      !strcmp(operation[z], anweisung[4]) ||
      !strcmp(operation[z], anweisung[19]) ||
      !strcmp(operation[z], anweisung[10]) ||
      !strcmp(operation[z], anweisung[24]) ||
      !strcmp(operation[z], anweisung[29]) ||
      !strcmp(operation[z], anweisung[30]) ||
      !strcmp(operation[z], anweisung[31]) ||
      !strcmp(operation[z], anweisung[32]) ||
      !strcmp(operation[z], anweisung[33]) ||
      !strcmp(operation[z], anweisung[11]))
	/* UN(*/
	  return false;
  /* UN*/
  /* U(*/
  /* NOP*/
  /* EN*/
  /* PE*/
  /* EP*/
  /* AN(*/
  /* AN*/
  /* A(*/
  /* A*/
  /* U*/
  return true;
}


/* Local variables for interpret: */
struct LOC_interpret {
  boolean akku, help;
  unsigned short k;
  uchar klammer, token;
  boolean klammerakku[255];
  string3 klammeroper[255];
  string3 aktuell;
  LONGINT analog_akku;
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

  if (!strcmp(LINK->LINK->aktuell, "ON ") ||
      !strcmp(LINK->LINK->aktuell, "UN ") ||
      !strcmp(LINK->LINK->aktuell, "AN "))
    inv = true;
  switch (operand[LINK->LINK->k-1]) {

  case 'I':
    if (inv)
      LINK->LINK->help = !eingang[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = eingang[par[LINK->LINK->k-1] - 1];
    break;

  case 'E':
    if (inv)
      LINK->LINK->help = !eingang[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = eingang[par[LINK->LINK->k-1] - 1];
    break;

  case 'O':
    if (inv)
      LINK->LINK->help = !ausgang[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = ausgang[par[LINK->LINK->k-1] - 1];
    break;

  case 'A':
    if (inv)
      LINK->LINK->help = !ausgang[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = ausgang[par[LINK->LINK->k-1] - 1];
    break;

  case 'M':
    if (inv)
      LINK->LINK->help = !marker[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = marker[par[LINK->LINK->k-1] - 1];
    break;

  case 'T':
    if (inv)
      LINK->LINK->help = !timer[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = timer[par[LINK->LINK->k-1] - 1];
    break;

  case 'C':
    if (inv)
      LINK->LINK->help = !zahler[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = zahler[par[LINK->LINK->k-1] - 1];
    break;

  case 'Z':
    if (inv)
      LINK->LINK->help = !zahler[par[LINK->LINK->k-1] - 1];
    else
      LINK->LINK->help = zahler[par[LINK->LINK->k-1] - 1];
    break;

  case 'J':
    if (debug)
      printf("analog input\n");
    break;
    /* errorabfrage */

  default:
    printf(" unknown operand line: %12u\n", LINK->LINK->k);
    _Escape(1);
/* p2c: run_sps-combined.pas:
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
    strcpy(LINK->klammeroper[LINK->klammer-1], LINK->aktuell);
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
    if (operand[LINK->k-1] == 'J')   /* U*/
      LINK->analog_akku = analog_in[par[LINK->k-1] - 1];
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
  switch (operand[LINK->k-1]) {

  case 'O':
    ausgang[par[LINK->k-1] - 1] = LINK->akku;
    break;

  case 'A':
    ausgang[par[LINK->k-1] - 1] = LINK->akku;
    break;

  case 'M':
    marker[par[LINK->k-1] - 1] = LINK->akku;
    break;

  case 'J':
    analog_in[par[LINK->k-1] - 1] = LINK->analog_akku;
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
    switch (operand[LINK->k-1]) {

    case 'O':
      ausgang[par[LINK->k-1] - 1] = true;
      break;

    case 'A':
      ausgang[par[LINK->k-1] - 1] = true;
      break;

    case 'M':
      marker[par[LINK->k-1] - 1] = true;
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
    switch (operand[LINK->k-1]) {

    case 'O':
      ausgang[par[LINK->k-1] - 1] = false;
      break;

    case 'A':
      ausgang[par[LINK->k-1] - 1] = false;
      break;

    case 'M':
      marker[par[LINK->k-1] - 1] = false;
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
  if (!strcmp(LINK->klammeroper[LINK->klammer-1], "ON(") ||
      !strcmp(LINK->klammeroper[LINK->klammer-1], "UN(") ||
      !strcmp(LINK->klammeroper[LINK->klammer-1], "AN(")) {
    helper = !LINK->akku;
    LINK->akku = helper;
  }
  if (!strcmp(LINK->klammeroper[LINK->klammer-1], "O( ") ||
      !strcmp(LINK->klammeroper[LINK->klammer-1], "ON("))
    LINK->akku = (LINK->akku || LINK->klammerakku[LINK->klammer-1]);
  if (!strcmp(LINK->klammeroper[LINK->klammer-1], "U( ") ||
      !strcmp(LINK->klammeroper[LINK->klammer-1], "UN(") ||
      !strcmp(LINK->klammeroper[LINK->klammer-1], "AN(") ||
      !strcmp(LINK->klammeroper[LINK->klammer-1], "A( "))
    LINK->akku = (LINK->akku && LINK->klammerakku[LINK->klammer-1]);
  LINK->klammer--;
}  /* **** ENDE KLAMMER_ZU **** */

Local Void set_timer(LINK)
struct LOC_interpret *LINK;
{
  /*timer auf startwert setzen*/
  long dummy;

  if (LINK->akku && !lastakku[par[LINK->k-1] - 1]) {
    /* negative parameter means that a analog input value should be used as parameter */
    if (par[LINK->k] > 0)
      t[par[LINK->k-1] - 1] = par[LINK->k];
    else {
      putchar('\007');
      dummy = -par[LINK->k];
      t[par[LINK->k-1] - 1] = analog_in[dummy-1];
    }
    timer[par[LINK->k-1] - 1] = false;
    lastakku[par[LINK->k-1] - 1] = true;
  } else if (!LINK->akku) {
    t[par[LINK->k-1] - 1] = 65535L;
    timer[par[LINK->k-1] - 1] = false;
    lastakku[par[LINK->k-1] - 1] = false;
  }
  LINK->akku = true;
}  /* **** ENDE SET_TIMER *****/

Local Void set_counter(LINK)
struct LOC_interpret *LINK;
{
  /* counter auf startwert setzen */
  if (LINK->akku && !lastakku[par[LINK->k-1] + 7]) {
    z[par[LINK->k-1] - 1] = par[LINK->k];
    zahler[par[LINK->k-1] - 1] = false;
    lastakku[par[LINK->k-1] + 7] = true;
  } else if (!LINK->akku) {
    z[par[LINK->k-1] - 1] = 65535L;
    zahler[par[LINK->k-1] - 1] = false;
    lastakku[par[LINK->k-1] + 7] = false;
  }
  LINK->akku = true;
}  /* **** ENDE SET_COUNTER *****/


Local Void analog_equal(LINK)
struct LOC_interpret *LINK;
{
  /* check for anaologig equal  */
  LINK->akku = false;
  if (par[LINK->k-1] == LINK->analog_akku)
    LINK->akku = true;
}  /* **** ENDE ANALOG_EQUAL*/

Local Void analog_less(LINK)
struct LOC_interpret *LINK;
{
  /* check for anaologig less than */
  LINK->akku = false;
  if (LINK->analog_akku < par[LINK->k-1])
    LINK->akku = true;
}  /* **** ENDE ANALOG_less*/

Local Void analog_great(LINK)
struct LOC_interpret *LINK;
{
  /* check for anaologig greater than */
  LINK->akku = false;
  if (LINK->analog_akku > par[LINK->k-1])
    LINK->akku = true;
}  /* **** ENDE ANALOG_great*/

Local Void jump(LINK)
struct LOC_interpret *LINK;
{
  LINK->k = par[LINK->k-1] - 1;
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
  if (LINK->akku)
    printf("exec not implemented on embedded Hardware! \n");
}

Local Void cond_jump(LINK)
struct LOC_interpret *LINK;
{
  if (LINK->akku) {
    LINK->k = par[LINK->k-1] - 1;
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
  string3 anweis;
  Char timestring[256];


  V.k = 0;
  watchdog = 0;
  V.akku = true;
  V.analog_akku = 0;
  V.help = false;
  V.klammer = 0;
  do {
    V.k++;
    watchdog++;
    strcpy(V.aktuell, operation[V.k-1]);
    if (watchdog > awl_max)
      strcpy(V.aktuell, "EN ");
    V.token = 0;
    do {
      V.token++;
      strcpy(anweis, anweisung[V.token-1]);
    } while (strcmp(V.aktuell, anweis) && V.token <= anweismax);
    switch (V.token) {

    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:   /* UN( .. O(*/
      verkn(&V);
      break;

    case 7:   /* =      */
      zuweisen(&V);
      break;

    case 8:   /* JI */
      cond_jump(&V);
      break;

    case 9:   /* TE */
      set_timer(&V);
      break;

    case 10:   /* ZR */
      set_counter(&V);
      break;

    case 11:   /* EN   */
      break;

    case 12:
    case 13:   /* U O*/
      verkn(&V);
      break;

    case 14:   /* ) */
      klammer_zu(&V);
      break;

    case 15:   /* =N */
      zuweisen(&V);
      break;

    case 16:   /* S */
      setzen(&V);
      break;

    case 17:   /* R */
      rucksetzen(&V);
      break;

    case 18:   /* J */
      jump(&V);
      break;

    case 19:   /* K */
      break;

    case 20:   /* NOP */
      break;

    case 21:   /* EQ */
      analog_equal(&V);
      break;

    case 22:   /* LT */
      analog_less(&V);
      break;

    case 23:   /* GT */
      analog_great(&V);
      break;

    case 24:   /* $    */
      execute(&V);
      break;

    case 25:   /* PE*/
      break;

    case 26:
    case 27:   /* JP,SP*/
      jump(&V);
      break;

    case 28:
    case 29:   /* JC,SPB*/
      cond_jump(&V);
      break;

    case 30:   /* EP*/
      break;

    case 31:   /* AN(*/
      verkn(&V);
      break;

    case 32:   /* AN*/
      verkn(&V);
      break;

    case 33:   /* A(*/
      verkn(&V);
      break;

    case 34:   /* A    */
      verkn(&V);
      break;

    case 35:   /* DEC       */
      decrement(&V);
      break;

    case 36:   /* INC       */
      increment(&V);
      break;

    case 37:   /* LDD       */
      loadconst(&V);
      break;
      /*else*/
      /* f�r sp�tere Fehlerabfrage */
    }
  } while (strcmp(V.aktuell, "EN ") && strcmp(V.aktuell, "PE ") &&
	   strcmp(V.aktuell, "EP "));
  sprintf(timestring, "%5.2f", time2 / 1000);
  if (!strcmp(V.aktuell, "EN ") || !strcmp(V.aktuell, "PE ") ||
      !strcmp(V.aktuell, "EP "))
    sprintf(comment[V.k-1], "Zykluszeit Tz=%s ms", timestring);
  if (!debug)
    return;
  for (V.k = 8; V.k >= 1; V.k--) {
    if (V.k == 8)
      printf("interpreter: E 8-1 %s ", eingang[V.k-1] ? " TRUE" : "FALSE");
    else
      printf("%s ", eingang[V.k-1] ? " TRUE" : "FALSE");
  }
  putchar('\n');
  for (V.k = 8; V.k >= 1; V.k--) {
    if (V.k == 8)
      printf("interpreter: A 8-1 %s ", ausgang[V.k-1] ? " TRUE" : "FALSE");
    else
      printf("%s ", ausgang[V.k-1] ? " TRUE" : "FALSE");
  }
  putchar('\n');
}  /* **** ENDE INTERPRET **** */


/* Local variables for sps_laden: */
struct LOC_sps_laden {
  /* code is currently a dummy, may be used for error detection */
  Char name[256];
} ;

Local Void get_file_name(LINK)
struct LOC_sps_laden *LINK;
{
  /* namen des awl-files einlesen   */
  printf(" Filename : ");
  gets(LINK->name);
  if (strpos2(LINK->name, ".", 1) == 0)
    strcat(LINK->name, ".sps");
}  /* **** ENDE GET_FILE_NAME **** */




Static Void sps_laden()
{
  struct LOC_sps_laden V;
  FILE *f = NULL;
  Char zeile[49];
  long i = 0;
  long code;
  Char STR3[256];
  Char *TEMP;



  if (P_argc == 1)   /* keine Aufrufparameter */
    get_file_name(&V);
  else {
    strcpy(V.name, P_argv[1]);
    if (strpos2(V.name, ".", 1) == 0)
      strcat(V.name, ".sps");
  }
/* p2c: run_sps-combined.pas, line 575: Warning:
 * Don't know how to ASSIGN to a non-explicit file variable [207] */
  assign(f, V.name);
  rewind(f);
  if (P_ioresult != 0) {
    printf(" SPS-File nicht gefunden\n");
    _Escape(1);
  }
  printf(" Lade Programm %s\n", V.name);
  while (!P_eof(f)) {
    i++;
    fgets(zeile, 49, f);
    TEMP = strchr(zeile, '\n');
    if (TEMP != NULL)
      *TEMP = 0;
    sprintf(STR3, "%.3s", zeile);
    code = (sscanf(STR3, "%ld", &znr[i-1]) == 0);
    strsub(operation[i-1], zeile, 5, 3);
    operand[i-1] = zeile[8];
    code = (sscanf(strsub(STR3, zeile, 11, 5), "%ld", &par[i-1]) == 0);
    strsub(comment[i-1], zeile, 17, 22);
  }
  for (i = 0; i < anweismax; i++) {
    strcpy(anweisung[i], anweis[i]);
    if (strlen(anweis[i]) < 3) {
      do {
	strcat(anweisung[i], " ");
      } while (strlen(anweisung[i]) != 3);
    }
  }

  if (f != NULL)
    fclose(f);
  f = NULL;
  DosError = 0;
}  /***** ENDE SPS_LADEN **** */


Static Void run_awl()
{  /* hp run_awl                      */
  /*interrupt; */
  PhysMachReadDigital();   /* INPUTS lesen                    */
/* p2c: run_sps-combined.pas, line 611:
 * Warning: Symbol 'PHYSMACHREADDIGITAL' is not defined [221] */
  PhysMachReadAnalog();   /* analoge inputs lesen  */
/* p2c: run_sps-combined.pas, line 612:
 * Warning: Symbol 'PHYSMACHREADANALOG' is not defined [221] */
  PhysMachCounter();   /* TIMER / ZAHLER aktualisieren    */
/* p2c: run_sps-combined.pas, line 613:
 * Warning: Symbol 'PHYSMACHCOUNTER' is not defined [221] */
  PhysMachTimer();
/* p2c: run_sps-combined.pas, line 614:
 * Warning: Symbol 'PHYSMACHTIMER' is not defined [221] */
  interpret();   /* einen AWLdurchlauf abarbeiten   */
  PhysMachWriteDigital();   /* OUTPUTS ausgeben                */
/* p2c: run_sps-combined.pas, line 616:
 * Warning: Symbol 'PHYSMACHWRITEDIGITAL' is not defined [221] */
  PhysMachWriteAnalog();
/* p2c: run_sps-combined.pas, line 617:
 * Warning: Symbol 'PHYSMACHWRITEANALOG' is not defined [221] */
  toggle_internal_clock(&marker[61], &marker[62], &marker[63]);
      /* interne TAKTE M62-M64 toggeln   */
  if (watchdog > awl_max)
    escape = true;
  RPMs();
  if (debug) {
    delay(1000);
    printf(
      "###########################################################################\n");
  }
}  /* **** ENDE RUN_AWL ****          */


main(argc, argv)
int argc;
Char *argv[];
{  /* SPS_SIMULATION           */
  PASCAL_MAIN(argc, argv);
  if (P_argc < 3)
    strcpy(ConfFile, ".run_sps.cfg");
  else
    strcpy(ConfFile, P_argv[2]);
  PhysMachInit();
/* p2c: run_sps-combined.pas, line 631:
 * Warning: Symbol 'PHYSMACHINIT' is not defined [221] */
  PhysMachloadCfg(ConfFile);
/* p2c: run_sps-combined.pas, line 632:
 * Warning: Symbol 'PHYSMACHLOADCFG' is not defined [221] */
  fputs(ProgNamVer, stdout);
  puts(Copyright);
  printf("detected Hardware: %s\n", HWPlatform);
  sps_laden();
  if (debug) {
    printf(" Configured input ports :\n");
    for (i = 1; i <= group_max; i++)
      printf("%3ld%6ld%6c\n", i, i_address[i-1], i_devicetype[i-1]);
    printf(" Configured output ports :\n");
    for (i = 1; i <= group_max; i++)
      printf("%3ld%6ld%6c\n", i, o_address[i-1], o_devicetype[i-1]);
    printf(" Configured counter ports :\n");
    for (i = 1; i <= group_max; i++)
      printf("%3ld%6ld%6c\n", i, c_address[i-1], c_devicetype[i-1]);
  }
  TimeRuns = 150;

  printf("AWL gestartet, press any key to stop\n");
  do {
    run_awl();
    delay(15);
  } while (!(kbhit() || escape));
  if (escape)
    printf("Error: Watchdog error...!\n");

  PhysMachEnd();
/* p2c: run_sps-combined.pas, line 654:
 * Warning: Symbol 'PHYSMACHEND' is not defined [221] */
  exit(EXIT_SUCCESS);
}  /* **** SPS_SIMULATION **** */



/* End. */
