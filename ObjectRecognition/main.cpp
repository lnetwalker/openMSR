/***************************************************************************
   main.cpp  -  Beispielapplikation zur Diplomarbeit
        Kameragestützte Echtzeit Objektverfolgung unter Linux.
                
                             -------------------
    copyright            : (C) 2002 by Thomas Maurer
    email                : thomas@maurer-tech.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************/

/*
 some minor mods in 16 bit resolution for usb webcams
 by Hartmut Eilers
 hartmut@eilers.net
*/

/*
 compile with: c++ main.cpp -Wno-deprecated -L/usr/lib/X11 -lX11  -o ObjRec
 start with: LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so ./ObjRec /dev/video0
 please check the path to the library v4l1compat.o
 if normal start does not work
*/

/*  $Id$ */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

// für Xlib
#include <X11/Xlib.h>
#include <stdlib.h>

//#include <curses.h>
#include <iostream>
#include <string.h>
#include <stdio.h>
#include <sys/time.h>
#include <fcntl.h>
#include <limits.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
//#include <linux/videodev2.h>
#include <libv4l1-videodev.h>
// HTTP access
#include <stdexcept> // runtime_error
#include <sstream>
#include <sys/socket.h> // socket(), connect()
#include <arpa/inet.h> // sockaddr_in
#include <netdb.h> // gethostbyname(), hostent
#include <errno.h> // errno
// end HTTP access

using namespace std;

#define VIDEO_BUFFERS   2 // Es werden 2 Buffer verwendet
#define debug  0
// 0 = aus
// 1 = labels Tabelle überwachen
// 3 = Grenzen des geklickten Punkes in grafischen Ausgabefenster

// Bild Eigenschaften festlegen
#define WIDTH  320 // 640 // 320 // 924 // 320 // 80
#define HEIGHT 240 // 480 // 240 // 576 // 240 // 60
#define DEPTH   3// 3 = 3 byte = VIDEO_PALETTE_RGB24 = RGB888 in 24bit Worten.
#define IMGSIZE (WIDTH * HEIGHT * DEPTH)
#define GRAY_STEP 1 // Gibt an, wie groß der Hellichkeitsunterschied
                    // zwichen 2 Flächen sein soll. Nur für Testzwecke! Sonst 1
//#define ARRAY_ZEILEN (WIDTH*HEIGHT/4)
#define ARRAY_ZEILEN (WIDTH*HEIGHT*GRAY_STEP/4+1)
#define ARRAY_SPALTEN 9 // 0-8 = 9
#define NEXT_INDEX 0
#define MENGE  1
#define X_MAX  2
#define X_MIN  3
#define Y_MAX  4
#define Y_MIN  5
#define MENGENDICHTE 6
#define CONNECTIONS 7
#define ROOT   8

/**
 * HTTP Request Functions
 */

char Domain[]="localhost";
int  Port=10080;
const string URL = "GET /analog/write.html?";
const string HeaderData = " HTTP/1.1\r\nHost: localhost\r\nConnection: Keep-alive\r\nUser-Agent: OpenLab Tools ObjRec 0.2\r\n\r\n";
 
std::runtime_error CreateSocketError()
{
    std::ostringstream temp;
    temp << "Socket-Fehler #" << errno << ": " << endl;
    return std::runtime_error(temp.str());
}

void SendAll(int socket, const char* const buf, const int size) {
    int bytesSent = 0; // Anzahl Bytes die wir bereits vom Buffer gesendet haben
    do {
	#if debug
	cout << "Sending Data -> done " << bytesSent << " of " << size << " Bytes" << endl;
	#endif
        int result = send(socket, buf + bytesSent, size - bytesSent, 0);
        if(result < 0) { 
	// Wenn send einen Wert < 0 zurück gibt deutet dies auf einen Fehler hin.
	    cout << "CreateSocketError" << endl;
            throw CreateSocketError();
        }
        bytesSent += result;
    } while(bytesSent < size);
    #if debug
    cout << "Request finished" << endl;
    #endif
}


// Liest eine Zeile des Sockets in einen stringstream
void GetLine(int socket, std::stringstream& line) {
    for(char c; recv(socket, &c, 1, 0) > 0; line << c) {
        if(c == '\n') {
            return;
        }
    }
    throw CreateSocketError();
}

// URL aufrufen und Antwort verwerfen
int MakeRequest( int idx, int x, int y ) {
    // idx ist der Index des analogen Ausganges in den
    // x gespeichert wird, in idx+1 wird y gespeichert
    std::ostringstream tempString;
    tempString << URL << idx << "," << x << "," << y << HeaderData;
    string request = tempString.str();
    
    
    hostent* phe = gethostbyname(Domain);

    if(phe == NULL) {
        cout << "Host konnte nicht aufgeloest werden!" << endl;
        return 1;
    }

    if(phe->h_addrtype != AF_INET) {
        cout << "Ungueltiger Adresstyp!" << endl;
        return 1;
    }

    if(phe->h_length != 4) {
        cout << "Ungueltiger IP-Typ!" << endl;
        return 1;
    }

    int Socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(Socket == -1) {
        cout << "Socket konnte nicht erstellt werden!" << endl;
        return 1;
    }

    sockaddr_in service;
    service.sin_family = AF_INET;
    service.sin_port = htons(Port); // Das HTTP-Protokoll benutzt Port 80

    char** p = phe->h_addr_list; // p mit erstem Listenelement initialisieren
    int result; // Ergebnis von connect
    do {
        if(*p == NULL) { // Ende der Liste
            cout << "Verbindung fehlgschlagen!" << endl;
            return 1;
        }

        service.sin_addr.s_addr = *reinterpret_cast<unsigned long*>(*p);
        ++p;
        result = connect(Socket, reinterpret_cast<sockaddr*>(&service), sizeof(service));
    } while(result == -1);

    #if debug
    cout << "Verbindung erfolgreich!" << endl;
    #endif
    
    SendAll(Socket, request.c_str(), request.size());

    // empfange und verwerfe antwort
    while(true) {
        stringstream line;
        try
        {
            GetLine(Socket, line);
	    #if debug
	    cout << "Reading Answer: "<< line << endl;
	    #endif
        }
        catch(exception& e) // Ein Fehler oder Verbindungsabbruch
        {
            break; // Schleife verlassen
        }
    }
    close(Socket);
    return 0;
}
// end HTTP access

/**
 * Diese Klasse enthällt Methoden für die Findung und Verfolgung von Objekten.
 */
class o_tracing
{
public:
    o_tracing();
    ~o_tracing();
    unsigned int * areas_buffer;
    void start_tracing(unsigned char * in_org_frame);
    void set_rgb_threshold(unsigned char red_min, unsigned char red_max,
    unsigned char green_min, unsigned char green_max,
    unsigned char blue_min, unsigned char blue_max);
    void set_total_threshold(unsigned int distance);

    //void draw_tracing_frame();
    void draw_tracing_frame(unsigned char * org_frame);
    unsigned int create_roots(unsigned int index, unsigned int root);
    void get_center();
    void set_object_idx(int idx);

private:
    unsigned int id;    
    unsigned char * org_frame;
    // Tabelle die für das eindeutige Labeling verwendet wird.
    unsigned int labels[ARRAY_ZEILEN][ARRAY_SPALTEN];
    //unsigned int akt_label;
    unsigned int x0;
    unsigned int y0;
    unsigned int width;
    unsigned int height;
    unsigned int akt_label;// Maximale Anzahl der labels    
    unsigned int objekt_index;// Index des gefundenen Objektes
    bool rgb_tracing;
    unsigned int distance;
    unsigned char red_min;
    unsigned char red_max;
    unsigned char green_min;
    unsigned char green_max;
    unsigned char blue_min;
    unsigned char blue_max;
    unsigned int old_x_max, old_x_min, old_y_max, old_y_min, old_xcenter, old_ycenter;
    unsigned int DeviceServerIndex;
    
    void threshold();
    void tracing();
    void labeling (unsigned int area_index);
    void just_count(unsigned int index1, unsigned int modulo, unsigned int quotient, unsigned int connections);
    void join_labels();
    void in_label(unsigned int index1, unsigned int index2,
    unsigned int modulo, unsigned int quotient);
    /*unsigned int get_mengendichte(unsigned int index);*/
};

/**
 * Diese Klasse enthält Methoden, die für das Einfangen von Bildern
 * von einem Video Device zuständig sind.
 */
class video_in{

public:
    video_in();
    int grab_open (char *device, int width, int height, int depth);
    void grab_close (void);
    int grab_frame (int frame);         
    unsigned char * grab_pix (void);
private:
    unsigned char *buffer;
    int video_fd;       // Video filedescriptor
    int frame;

    struct video_mbuf mbuf;
    struct video_picture pic;
    struct video_channel chn;
    struct video_mmap buf[VIDEO_BUFFERS]; // 2 Buffer, die das gegrabbte Bild enthalten.
    struct video_capability cap;
    int grab_frame ();      
    int grab_sync ();
};

/**
 * Diese Klasse enthält Methoden, die für das ausgeben von Bildern
 * auf einem X-Window-System und zur Verarbeitung von Ereignissen verwendet werden.
 */
class video_out{

public:
    video_out();
    int get_depth();
    bool get_event(unsigned char *buffer,unsigned char *type,
    unsigned char *red, unsigned char *green, unsigned char *blue, KeySym *key);
    void display_frame (unsigned char * translated_buffer, int depth, int bpl,
    unsigned int *buffer);
    void display_frame (unsigned char * translated_buffer,int depth, int bpl,
    unsigned char *buffer);
private:
    Window create_simple_window(Display* display, int width, int height, int x, int y);
    Display* display;// Zeiger auf X Display Struktur
    int screen_num;// Nummer des Screens
    Window win;// Zeiger zum Fenster der Applikation
    char *display_name;
    GC gc;// GC (graphics context) wird zum zeichnen benötigt
    XGCValues gcv;// Enthällt Einstellungen für den GC
    XEvent an_event;// Variable für ein Ereignis
    XImage *ximage;// XImage das im Fenster angezeigt werden soll
    void handle_button_down(XButtonEvent* button_event, unsigned char *buffer,
    unsigned char *type, unsigned char *red, unsigned char *green, unsigned char *blue);

};

/**
 * Der Konstruktor der Klasse o_tracing initalisiert einige Variablen
 */
o_tracing::o_tracing(){

    static int id_count=0;
    id_count++;
    id=id_count;
    x0=0;
    y0=0;
    width=WIDTH;
    height=HEIGHT;
    akt_label=(WIDTH*HEIGHT/4); 
    objekt_index=0; // Index des gefundenen Objektes
    // Anlegen eines Speicherbereichs, in dem die gefundenen Flächen abgelegt werden
    areas_buffer=(unsigned int *)malloc(WIDTH*HEIGHT*4);//mal 4 wegen 4 byte integer Werten);
    rgb_tracing=false;
    distance=400;

    red_min=0;
    red_max=0;
    green_min=0;
    green_max=0;
    blue_min=0;
    blue_max=0;
}   

/**
 * Der Destruktor der Klasse o_tracing gibt einen
 * Speicherbereich wieder frei.
 */
o_tracing::~o_tracing(){
    free((void *)areas_buffer);
}   

/**
 * Diese Funktion durchläuft beginnend bei ihrem Einstiegspunkt
 * recursiv den labels Teilbaum und erzeugt
 * für jeden Index einen Root Eintrag.
 * Dabei ist zu beachten, dass ab dem Einstiegspunkt nur die
 * weiteren Elemente bearbeitet werden, die eine Verbindung zu dem
 * Einstiegspunkt haben. Dadurch muss dieser Alg. auf allen Indizes
 * gestartet werden.
 */
unsigned int o_tracing::create_roots(unsigned int index, unsigned int root){
    // Gibt es schon einen Root?
    if(labels[index][ROOT]==0){
        // Es gibt keinen root
        if(labels[index][NEXT_INDEX]!=0){// Gibt es einen NEXT_INDEX
            // JA Dann überprüfe diesen.
            root = create_roots(labels[index][NEXT_INDEX], root);
        }
        labels[index][ROOT]=root;
        // Werte auf Root übertragen und beim nichtroot nullen.
        if(index!=root){
            labels[root][MENGE] += labels[index][MENGE];
            labels[index][MENGE]=0;     
            labels[root][CONNECTIONS] += labels[index][CONNECTIONS];
            labels[index][CONNECTIONS]=0;       
            if(labels[root][X_MAX] < labels[index][X_MAX]){
                labels[root][X_MAX]=labels[index][X_MAX];
            }
            labels[index][X_MAX]=0;
            if(labels[root][X_MIN] > labels[index][X_MIN]){
                labels[root][X_MIN]=labels[index][X_MIN];
            }
            labels[index][X_MIN]=0;
            if(labels[root][Y_MAX] < labels[index][Y_MAX]){
                labels[root][Y_MAX]=labels[index][Y_MAX];
            }
            labels[index][Y_MAX]=0;
            if(labels[root][Y_MIN] > labels[index][Y_MIN]){
                labels[root][Y_MIN]=labels[index][Y_MIN];
            }
            labels[index][Y_MIN]=0;
        }
    }
    // Es gibt einen Root
    else root = labels[index][ROOT];    
return(root);
};

/**
 * Diese Funktion duchläuft das gesamte aktive Bild und überprüft
 * das Punkte, die in einer Gruppe sind, das Lable des 1. Gruppenmitglieds
 * bekommen. Weiter werden die min und max Werte sowie der Mengen
 * Zähler auf das 1. Gruppenelement übertragen.
 * Zuvor werden die roots gebildet.
 * Der Eintrag mit dem grössten connections Wert wird in objekt_index
 * abgelegt und repäsentiert das zu verfolgende Objekt.
 */
void o_tracing::join_labels(){
    unsigned int area_index;
    unsigned int i=0;
    unsigned int tmp=GRAY_STEP;// Compilerbug überlisten.
    unsigned int connections=0;
    unsigned int tmp2=0;
    unsigned int md_index=0;// Index mit der höchsten Mengendichte   

    //Duchlaufe die Lables Tabelle, um alle ROOTs zu bilden und die Mengendichten
    //zu bilden und die größte Mengendichte zu ermitteln.
    for(unsigned int i2=tmp;i2<=akt_label;i2=i2+tmp){
        create_roots(i2,i2);
        if (labels[i2][MENGE]!=0){
            tmp2 = labels[i2][CONNECTIONS];
            if (tmp2 > connections){
                connections = tmp2;
                md_index = i2;
            }
        }
    }

    if (md_index!=0){
        area_index = labels[md_index][X_MIN] + (labels[md_index][Y_MIN]*(WIDTH));// Index im Flächenberich.
        // Durchlaufe den SubFrame im Fenster
        do{
            if((areas_buffer[area_index])!=0){
                if (labels[areas_buffer[area_index]][ROOT]==md_index){
                    areas_buffer[area_index] = 255;
                }
                else areas_buffer[area_index] = 0;
            }
            if(i < width-1){                                                         // Naechstes Pixel Betrachten
                i = i++;
                area_index = area_index + 1;
            } else{
                i = 0;
                // Bereich der nicht zum Subframe gehört überspringen     
                area_index = area_index + (WIDTH-width+1);      
            }   
        }while(area_index <= labels[md_index][X_MAX] +  WIDTH*(labels[md_index][Y_MAX]));
    }
    objekt_index=md_index;
#if debug==1
    cout << ''2. Durchlauf\n'';
    for(unsigned int i=0;i<=akt_label;i++){
        cout << i << ''\t'';
        cout << labels[i][0] << ''\t'';
        cout << labels[i][1] << ''\t'';
        cout << labels[i][2] << ''\t'';
        cout << labels[i][3] << ''\t'';
        cout << labels[i][4] << ''\t'';
        cout << labels[i][5] << ''\t'';
        cout << labels[i][6] << ''\t'';
        cout << labels[i][7] << ''\t'';
        cout << labels[i][8] << ''\n'';
    }
    cout << ''----\n'';
#endif
}

/**
 * Für den angegebenen index werden die Zählerstände erhöht
 * und die min max Werte aktualisiert.
 */
void o_tracing::just_count(unsigned int index1, unsigned int modulo, unsigned int quotient, unsigned int connetions){
    if(labels[index1][X_MAX]< modulo){
        labels[index1][X_MAX]=modulo;
    }
    if( (labels[index1][X_MIN]> modulo) || (labels[index1][MENGE] == 0) ){
        labels[index1][X_MIN]=modulo;
    }
    if(labels[index1][Y_MAX]< quotient){
        labels[index1][Y_MAX]=quotient;
    }
    if( (labels[index1][Y_MIN]> quotient) || (labels[index1][MENGE] == 0) ){
        labels[index1][Y_MIN]=quotient;
    }
    labels[index1][MENGE]=labels[index1][MENGE]+1;
    labels[index1][CONNECTIONS]=labels[index1][CONNECTIONS]+connetions;
}

/**
 * Diese Funktion erstellt eine Tabelle die für jedes Lables die Anzahl
 * der Pixel und deren äusterten Positionen in den X-Y System umfasst.
 * In der Spalte ''index'' wird eine Verbindung zu ''wert'' geschaffen.
 * Dadurch wird gezeigt, dass index und wert zu einer Gruppe gehören.
 */
void o_tracing::in_label(unsigned int index1, unsigned int index2, unsigned int modulo, unsigned int quotient){
    if(index1>index2){
        unsigned int tmp;
        tmp=index1;
        index1=index2;
        index2=tmp;
        /*DEBUG01*///   cout << ''x'';
    }
    if(labels[index1][NEXT_INDEX]==0){
        // Diesem index ist noch keine weitere Gruppe zugeordnet.
        labels[index1][NEXT_INDEX]=index2;
    } else{
        // Es sind schon mehr als 2 Gruppen verbunden.
        if(labels[index1][NEXT_INDEX]==index2);// just_count(labels, index1, modulo, quotient);
        else in_label(labels[index1][NEXT_INDEX], index2, modulo, quotient);
    }
}

/**
 * Diese Methode implementiert die Flächenerkennung nach dem
 * ''Connected Components Labeling Algorithmus'' Verfahren.
 * Vordergrundpixel die aneinander angrenzen werden zu einer
 * Fläche verbunden.
 */
void o_tracing::labeling (unsigned int area_index){

    unsigned int tmp=0;  // Hilfsvariable
    unsigned int pos1=0; // Pixel linkes        
    unsigned int pos2=0; // Pixel oben
    unsigned int pos3=0; // Pixel rechts oben
    unsigned int pos4=0; // Pixel links oben
    bool left=true;
    bool up=true;
    bool right=true;
    unsigned int  modulo=0;
    unsigned int  quotient =0;

    modulo = area_index%WIDTH; // Modulo berechnen um die X-Positon zu ermitteln.
    quotient = area_index/WIDTH; // Division um die Y-Positon zu ermitteln
    
    // Es muß auf 3 Sonderfälle überprüft werden, damit nicht Information außerhalb
    // des Frames gelesen werden.
    // 1. Der Punkt befindet sich NICHT am linken Rand des Frame
    if(modulo != x0) left=false;
    // 2. Der Punkt befindet sich NICHT am oberen Rand des Frame
    if(area_index >= WIDTH) up=false; // >= da ab Null gezählt wird
    // 3. Der Punkt befindet sich NICHT am rechten Rand des Frame
    if(modulo != x0+width-1) right=false;
    
    // linkes Pixel lesen
    if(left == false){
        pos1 = areas_buffer[area_index-1];
        // Pixel links oben lesen
        if(up == false){
            pos4 = areas_buffer[area_index-(WIDTH+1)];
        }
    }
    // Pixel oben lesen
    if(up == false){
        pos2 = areas_buffer[area_index-(WIDTH)];
        // Pixel rechts oben lesen
        if(right == false){ 
            pos3 = areas_buffer[area_index-(WIDTH-1)];
        }
    }
    // pos1 + pos2 + pos3 + pos4 = 0 Das Pixel bekommt ein neues Label
    if (pos1 + pos2 + pos3 + pos4 == 0){
        (akt_label)=(akt_label)+GRAY_STEP;
        // die Anzahl und die min+max Positionen werden abgelegt
        just_count(akt_label, modulo, quotient, 0);
        areas_buffer[area_index]=akt_label;
        return;
    }
    // 1 xor 2 xor 3 xor 4 == true (es gibt genau einen Nachbarn)
    if( (pos1?1:0) + (pos2?1:0) + (pos3?1:0) + (pos4?1:0) == 1){
        // die Anzahl und die min+max Positionen werden abgelegt
        just_count(akt_label, modulo, quotient, 1);
        // Es ist nur 1 vor den 4 != 0. Dieses wird als Lable verwendet.
        areas_buffer[area_index]=pos1 + pos2 + pos3 + pos4;
        return; 
    }
    // Wenn der Programmfluss bis hierher kommt, gibt es min. 2 Labels die das Pixel
    // beinflussen.
    // Für das weitere Vorgehen müssen pos1-4 sortiert werden (pos1=min. pos4=max.)
    // Dafür wird ein statischer bubble-sort Alg. verwendet.
    if(pos1>pos2){
        tmp=pos2;
        pos2=pos1;
        pos1=tmp;
    }
    if(pos2>pos3){
        tmp=pos3;
        pos3=pos2;
        pos2=tmp;
    }
    if(pos3>pos4){
        tmp=pos4;
        pos4=pos3;
        pos3=tmp;
    }
    if(pos1>pos2){
        tmp=pos2;
        pos2=pos1;
        pos1=tmp;
    }
    if(pos2>pos3){
        tmp=pos3;
        pos3=pos2;
        pos2=tmp;
    }
    if(pos1>pos2){
        tmp=pos2;
        pos2=pos1;
        pos1=tmp;
    }
    // Sind Elemente von pos1-pos4 gleich, werden sie in die labels_tabelle
    // eingetragen.
    if(pos1){
        areas_buffer[area_index]=pos1;
        if(pos1!=pos2){
            in_label(pos1, pos2, modulo, quotient);
            }
        if(pos2!=pos3){
            in_label(pos2, pos3, modulo, quotient);
        }   
        if(pos3!=pos4){
            in_label(pos3, pos4, modulo, quotient);
        }
        just_count(pos1, modulo, quotient, 4);
    } else if(pos2){
        areas_buffer[area_index]=pos2;
        if(pos2!=pos3){
            in_label(pos2, pos3, modulo, quotient);
        }
        if(pos3!=pos4){
            in_label(pos3, pos4, modulo, quotient);
        }
        just_count(pos2, modulo, quotient, 3);
    } else if (pos3){
        areas_buffer[area_index]=pos3;
        if(pos3!=pos4){
            in_label(pos3, pos4, modulo, quotient);
        }
        just_count(pos3, modulo, quotient, 2);
    }
    // pos4 gibt es nicht da 1 von 4 schon in einer früheren
    // Regel abgefangen wurde
    return;
}

/**
 * Diese Methode führt die Aufgabe des Thresholding durch.
 * In ihr wird also entscheiden, ob ein Pixel Vodergrund oder
 * Hintergrundpixel wird.
 * Für ein Vordergrundpixel wird sofort das Labeling iniziert.
 */
void o_tracing::threshold(){
    //Löschen der labels Tabelle;
    for(unsigned int i=0;i<=akt_label;i++){
        labels[i][NEXT_INDEX]=0;
        labels[i][MENGE]=0;
        labels[i][X_MIN]=WIDTH;
        labels[i][X_MAX]=0;
        labels[i][Y_MIN]=HEIGHT;
        labels[i][Y_MAX]=0;
        labels[i][MENGENDICHTE]=0;
        labels[i][CONNECTIONS]=0;
        labels[i][ROOT]=0;
    }
    // Thresholding
    akt_label=0;    // Aktuelle Label-Nummer
    // Index des Orginals und des Area auf linke obere Ecke des SubFrame stellen.
    unsigned int org_index = (x0 + (y0*(WIDTH)))*3; // Index im gegrabte Frameberich.
    unsigned int area_index = x0 + (y0*(WIDTH));    // Index im Flächenberich.
    unsigned int i=0;
    unsigned int tmp;
    // Durchlaufe den SubFrame im Fenster
    do{
        // Test ob es sich um ein Vordergrund-Pixel handelt.
        if (rgb_tracing==true){ // Thresholding mittels drei Wertebereiche
                    // für RGB bzw. wirklich B G R
            if ( (red_min <= org_frame[org_index+2] && org_frame[org_index+2] <= red_max)
                && (green_min <= org_frame[org_index+1] && org_frame[org_index+1] <= green_max)
                && (blue_min <= org_frame[org_index] && org_frame[org_index]<= blue_max) )
            {
                // Es ist ein Vordergrund-Pixel
                // ''Connected Components Labeling Algorithmus'' durchführen
                labeling(area_index);
            } else{
                // Es ist ein Hintergrund-Pixel
                areas_buffer[area_index]=0;                 
            }
        }else { // Thresholding mittels einer Distanz
            tmp = org_frame[org_index+0];
            tmp = tmp + org_frame[org_index+1];
            tmp = tmp + org_frame[org_index+2];
        
            if(tmp <= this->distance){
                // Es ist ein Hintergrund Pixel
                areas_buffer[area_index]=0;                 
            } else{
                // Es ist ein Vordergrund-Pixel
                // ''Connected Components Labeling Algorithmus'' durchführen
                labeling(area_index);
            }
        }
        if(i < width-1){  // Nächstes Pixel Betrachten
            i = i++;
            org_index = org_index + 3; // + 3 da ein Pixel durch 3 byte dargestellt wird         
            area_index = area_index + 1;
        } else{
            i = 0; // Bereich, der nicht zum Subframe gehört, überspringen    
            org_index = org_index + (WIDTH-width+1)*3;      
            area_index = area_index + (WIDTH-width+1);      
        }
    }while(area_index <= x0 + width + WIDTH*(height+y0-1));
        // Solange nicht das letzte Subframe Pixel erreicht ist.
        // x1 + width bewegt uns auf der x-Achse bis auf den rechten                                
        // Rand des SubFrame. Durch height+y1-1 ermitteln wir die Anzahl der Schritte,
        // die auf der y-Achse nach unten zu gehen sind und durch die Multiplikation
        // Mit WIDTH erhalten wie die letzte Positon (rechts unten) des SubFrame.
        // -1 verhindert, dass wir eine Zeile zu tief rauskommen.
    
#if debug==1
    cout << ''1. Durchlauf\n'';
    for(unsigned int i=0;i<= akt_label;i++){
    cout << i << ''\t'';
    cout << labels[i][0] << ''\t'';
    cout << labels[i][1] << ''\t'';
    cout << labels[i][2] << ''\t'';
    cout << labels[i][3] << ''\t'';
    cout << labels[i][4] << ''\t'';
    cout << labels[i][5] << ''\t'';
    cout << labels[i][6] << ''\t'';
    cout << labels[i][7] << ''\t'';
    cout << labels[i][8] << ''\n'';
    }
    cout << akt_label << ''----\n'';
#endif
    }

/**
 * Diese Methode stellt das Thresholding so ein,
 * dass für die drei Farben Rot, Grün, Blau je ein Bereich
 * bestimmt werden kann in dem sich diese Farbe befinden muss.
 * Trifft diese Bedingung für alle drei Farben zu, so
 * wird das gerade betrachtete Pixel als Vordergrundpixel eingestuft.
 */
void o_tracing::set_rgb_threshold(unsigned char red_min, unsigned char red_max,
				  unsigned char green_min, unsigned char green_max,
				  unsigned char blue_min, unsigned char blue_max){
    this->rgb_tracing=true;
    this->red_min=red_min;
    this->red_max=red_max;
    this->green_min=green_min;
    this->green_max=green_max;;
    this->blue_min=blue_min;
    this->blue_max=blue_max;
}

/**
 * Diese Methode stellt das Thresholding so ein, dass die drei
 * Farbanteile Rot, Grün, Blau eines Pixel zusammenaddiert werden.
 * Ist dieser Wert größer als der als Parameter übergebene
 * Wert, so wird das gerade betrachtete Pixel als Vordergrundpixel eingestuft.
 */
void o_tracing::set_total_threshold(unsigned int distance){
    rgb_tracing=false;
    this->distance=distance;
}

/**
 * Diese Methode startet den Vorgang der Objekterkennung / Objektverfolgung
 * durch das Aufrufen der entsprechenden Methoden.
 */
void o_tracing::start_tracing(unsigned char * in_org_frame){
    org_frame=in_org_frame;
    // Hintergrund ausfiltern und Flächen erkennen.
    threshold();
    join_labels();
    tracing();
    //draw_tracing_frame();
}
    
/**
 * Diese Funktion errechnet für den angegebenen Index eine
 * Mengendichte.
 * Mengendichte = MENGE²*100/((X_MAX-X_MIN+1)*(Y_MAX-Y_MIN+1)
 *
unsigned int o_tracing::get_mengendichte(unsigned int index){
    unsigned int tmp1 = (labels[index][MENGE]);
    unsigned int tmp2 = (labels[index][X_MAX]-labels[index][X_MIN]+1)
            * (labels[index][Y_MAX]-labels[index][Y_MIN]+1);
    unsigned int tmp3 = tmp1*100 / tmp2;
    unsigned int tmp4 = tmp3 * tmp1;
    return (tmp4);
}*/

/**
 * Diese Methode errechnet zusammen mit der Information aus ihrem
 * vorhergehenden Aufruf die Geschwindigkeit und Richtung des zu
 * verfolgenden Objektes.
 * Weiter wird ein Scanfenster errechnet/ausgegeben, in dem das Objekt
 * erwartet wird.
 */
void o_tracing::tracing(){

    static bool first = 1;
    unsigned int xcenter;
    unsigned int ycenter;
    int delta_x;
    int delta_y;
    int tmp_x0, tmp_y0, tmp_x1, tmp_y1;
    unsigned int object_width;
    unsigned int objekt_height;
    // Aussenmaße des Objekts    
    object_width=labels[objekt_index][X_MAX]-labels[objekt_index][X_MIN];
    objekt_height=labels[objekt_index][Y_MAX]-labels[objekt_index][Y_MIN];
    if (objekt_index==0){  // Es gibt kein Objekt
        x0=0;
        y0=0;
        width=WIDTH-1;
        height=HEIGHT-1;
    }
    else{
        if ( ( object_width<2) || (objekt_height<2) ){
            x0=0;
            y0=0;
            width=WIDTH-1;
            height=HEIGHT-1;
        }
        else{
            // Mittelung der Objekte
            xcenter = labels[objekt_index][X_MIN] + (object_width/2);
            ycenter = labels[objekt_index][Y_MIN] + (objekt_height/2);
            if (first){
                first = false;
                delta_x = 10;
                delta_y = 10;       
            } else {
                // delta auf beiden Achsen
                delta_x = xcenter-old_xcenter;
                delta_y = ycenter-old_ycenter;
            }
                // Errechnung des neuen Scanfenster + Bereichssicherung
                tmp_x0=xcenter - 1 - (object_width);
            if (delta_x<0) tmp_x0 = tmp_x0 + delta_x;
            if (tmp_x0<0) x0=0;
            else x0=tmp_x0;

                tmp_y0=ycenter - 1 - (objekt_height);
            if (delta_y<0) tmp_y0 = tmp_y0 + delta_y;
                if (tmp_y0<0) y0=0;
            else y0=tmp_y0;
        
                tmp_x1=xcenter + 1 + (object_width);
            if (delta_x>0) tmp_x1 = tmp_x1 + delta_x;
            if (tmp_x1>WIDTH) width=WIDTH-x0-1;
            else width=tmp_x1-x0-1;
        
                tmp_y1=ycenter + 1 + (objekt_height);
            if (delta_y>0) tmp_y1 = tmp_y1 + delta_y;
            if (tmp_y1>HEIGHT) height=HEIGHT-y0-1;
            else height=tmp_y1-y0-1;
            
            // Es werden Informationen über das bald alte Objekt abgelegt!
            old_x_max = labels[objekt_index][X_MAX];
            old_x_min = labels[objekt_index][X_MIN];
            old_y_max = labels[objekt_index][Y_MAX];
            old_y_min = labels[objekt_index][Y_MIN];
            old_xcenter= xcenter;
            old_ycenter= ycenter;
	    //if (objekt_index<4) cout << "Objekt (" << objekt_index << ") -> (x,y)=(" << xcenter << "," << ycenter << ")" << endl;
	    
        }   
    }   
    #if debug
    if (height >= HEIGHT)
    {
    cout << "! heigth hat die Auflösung überschritten - in Methode tracing \n";
    }
    if (width >= WIDTH)
    {
    cout << "! width hat die Auflösung überschritten - in Methode tracing \n";
    }
    #endif
}


/**
 * Diese Funktion zeichnet kleine Makierungen in die Ecken des
 * Scanfensters.
 */
void o_tracing::draw_tracing_frame(unsigned char * my_frame){
    
    for(int i=0;i<2;i++)
    {   
        unsigned int my_x0=(3*x0)+((id+i)%3);
    	if (id>3) cout << '!' << endl;
        unsigned int my_width=3*WIDTH;

	
    	// Ecke links oben.
    	my_frame[my_x0+(my_width*y0)]=255;
    	my_frame[my_x0+(my_width*y0)+3]=255;
    	my_frame[my_x0+(my_width*y0)+6]=255;
    	my_frame[my_x0+(my_width*(y0+1))]=255;
    	my_frame[my_x0+(my_width*(y0+2))]=255;
    	//Ecke rechts oben.
    	my_frame[my_x0+(my_width*y0)+width*3]=255;
    	my_frame[my_x0+(my_width*y0)+width*3-3]=255;
    	my_frame[my_x0+(my_width*y0)+width*3-6]=255;
    	my_frame[my_x0+(my_width*(y0+1))+width*3]=255;
    	my_frame[my_x0+(my_width*(y0+2))+width*3]=255;
    	//Ecke links unten.
    	my_frame[my_x0+(my_width*(y0+height))]=255;
    	my_frame[my_x0+(my_width*(y0+height))+3]=255;
    	my_frame[my_x0+(my_width*(y0+height))+6]=255;
    	my_frame[my_x0+(my_width*(y0+height-1))]=255;
    	my_frame[my_x0+(my_width*(y0+height-2))]=255;
    	//Ecke recht unten.
    	my_frame[my_x0+(my_width*(y0+height))+width*3]=255;
    	my_frame[my_x0+(my_width*(y0+height))+width*3-3]=255;
    	my_frame[my_x0+(my_width*(y0+height))+width*3-6]=255;
    	my_frame[my_x0+(my_width*(y0+height-1))+width*3]=255;
    	my_frame[my_x0+(my_width*(y0+height-2))+width*3]=255;
    }
}


void o_tracing::get_center() {

  if (id>3) cout << "!" << endl;
  #if debug
  cout << old_xcenter << "," << old_ycenter ;
  #endif
  // Store position in DeviceServer
  MakeRequest(DeviceServerIndex,old_xcenter,old_ycenter);
}


void o_tracing::set_object_idx(int idx) {
    DeviceServerIndex = idx ;
}


/**
 * In diesem Konstruktor werden Vorbereitungen getroffen, die
 * für die Darstellung eines grafischen Fenster nötig sind.
 */
video_out::video_out(){
    // Vorbereitungen für das X-Fenter
    display_name = getenv("DISPLAY"); // Einholen der Displayadresse
    // Verbindungsaufbau zum X Server
    display = XOpenDisplay(display_name);
    if (display == NULL){
        fprintf(stderr, "Zum Display %s konnte keine Verbindung aufgebaut werden.", display_name);
        exit(1);
    }
    // Ermittele die Abmessungen des (Standard) Desktop
    screen_num = DefaultScreen(display);
    printf("window Breite= %d; Höhe= %d\n", WIDTH, HEIGHT);
    // Erzeuge ein einfaches Fenster das ''child'' des root Fensters ist.
    // Das Weiß des root wird Hintergrund der child.
    // Das Fenster wird in der linken oberen Ecke plaziert.
    win = create_simple_window(display, WIDTH, HEIGHT, 0, 0);
    //Events aktivieren
    XSelectInput(display,win,ExposureMask | ButtonPressMask |
        KeyPressMask);
    // Erzeugen eines graphical context
    gc = XCreateGC (display, win, 0, &gcv);
    // Windows wird dargestellt auch wenn es noch keinen Inhalt hat.
    XMapWindow(display, win);
}
    
/**
 * Diese Methode überprüft, ob eine Taste betätigt wurde.
 * Wurde eine Taste betätigt, gibt sie true zurück
 * ansonsten false
 */
bool video_out::get_event(unsigned char *buffer, unsigned char *type,
			  unsigned char *red, unsigned char *green, unsigned char *blue, KeySym *key){

    if (XCheckMaskEvent(display,ButtonPressMask | KeyPressMask, &an_event)){
        switch (an_event.type) {
	    case ButtonPress:
		  handle_button_down((XButtonEvent*)&an_event.xbutton, buffer, type, red, green, blue);
		  break;
	    case KeyPress:
		  *key = XLookupKeysym(&an_event.xkey, 0);
                        
		  //return(true);
		  break;
            default: /* Ignoriere andere Ereignisse */
		  break;
        }
	return (true);
    } else{
	return (false);
    }
}

/**
 * Diese Methode gibt die Anzahl von bit zurück, die für die
 * Farbdarstellung eines Bildpunktes verwendet wird.
 */
int video_out::get_depth(){
    return(DefaultDepth(display, screen_num));
}

/**
 * Diese Methode füllt ein Fenster mit dem Inhalt der Integer Werte
 * im Parameter buffer.
 * So kann ein Bild aus dem Speicher auf dem Monitor ausgegeben werden.
 * Bei dem Bild sollte es sich um ein 32 bit Grauwert codiertes Bild handeln.
 * Beachtet werdem muss, dass Helligkeitswerte größer 255 (Dezimal)
 * unbestimmt bzw. als Modulo von 255 ausgegeben werden.
 */
void video_out::display_frame (unsigned char * translated_buffer,
			       int depth, int bpl, unsigned int *buffer){
        
    struct imagem{
	unsigned int *buffer;
	unsigned int width;
        unsigned int height;
    };
    imagem my_imagem;
    my_imagem.width=WIDTH;
    my_imagem.height=HEIGHT;
    my_imagem.buffer = buffer;
    switch(depth) {

        case 8:{
            unsigned x,y,z,k;
            //unsigned buffer;
            for(z=k=y=0;y!=my_imagem.height;y++)
            for(x=0;x!=my_imagem.width;x++){
                if (z == (my_imagem.width*my_imagem.height)) break;                                 
                // alt for 24 bit depth, organization BGRX
                // 24 bit RGBX -> RGB   
                translated_buffer[k+0]=my_imagem.buffer[z+0];    // red
                translated_buffer[k+1]=my_imagem.buffer[z+0];    // green
                translated_buffer[k+2]=my_imagem.buffer[z+0];    // blue
                translated_buffer[k+3]=0;
                k+=4; z+=1;
            }           
        }
        break;      
        case 16:
            {
            unsigned int x,y,z,k/*,pixel*/,r,g,b;
            unsigned short *word;
            word=(unsigned short *) translated_buffer;
            for(z=k=y=0;y!=my_imagem.height;y++)
            for(x=0;x!=my_imagem.width;x++){
            if (z == (my_imagem.width*my_imagem.height)) break;             
                r=my_imagem.buffer[z++] <<8;
                g=my_imagem.buffer[z++] <<8;                      
                b=my_imagem.buffer[z++] <<8;
                r &= 0xf800;
                g &= 0xfc00;                        
                b &= 0xf800;
                word[k++]=r|g>>5|b>>11;
            }           
        }
        break;      
        case 32:
        case 24:{
            unsigned x,y,z,k;
            for(z=k=y=0;y!=my_imagem.height;y++)
            for(x=0;x!=my_imagem.width;x++)
                {
                if (z == (my_imagem.width*my_imagem.height*3)) break;               
                // alt for 24 bit depth, organization BGRX
                // 24 bit RGBX -> RGB   
                translated_buffer[k+2]=my_imagem.buffer[z+2];    // red
                translated_buffer[k+1]=my_imagem.buffer[z+1];    // green
                translated_buffer[k+0]=my_imagem.buffer[z+0];    // blue
                k+=4; z+=3;
                }           
            }
        break;      
        default:
            cout << "Diese Farbtiefe wird nicht unterstützt !" << endl;
            break;  
    }

    //cout << "video_out::display_frame" << endl;
    static int first = 1;
    if (first == 1){
	ximage = XCreateImage (display, CopyFromParent, 24 /*zuvor depth*/,
	    ZPixmap, 0, (char *)translated_buffer, my_imagem.width,
	    my_imagem.height, bpl*8, bpl * my_imagem.width);
	first = 0;
    }
    //Windows wird dargestellt
    XPutImage(display, win, gc, ximage, 0,0,0,0, my_imagem.width, my_imagem.height);
    //Windows wird dargestellt
    XFlush(display);
    //XDestroyImage(ximage);
}

/**
 * Diese Methode füllt ein Fenster mit dem Inhalt der char Werte
 * im Parameter buffer.
 * So kann ein Bild aus dem Speicher auf dem Monitor ausgegeben werden.
 * Bei dem Bild sollte es sich um ein 24 bit RGB Farbcodiertes Bild handeln.
 */
void video_out::display_frame (unsigned char * translated_buffer,
			       int depth, int bpl, unsigned char *buffer){
    struct imagem{
        unsigned char *buffer;
        unsigned int width;
        unsigned int height;
    };
    imagem my_imagem;
    my_imagem.width=WIDTH;
    my_imagem.height=HEIGHT;
    my_imagem.buffer = buffer;
    //cout << " in display_frame " << endl;
    switch(depth) {
        case 8:{
            unsigned x,y,z,k;
            //unsigned buffer;
            for(z=k=y=0;y!=my_imagem.height;y++)
            for(x=0;x!=my_imagem.width;x++){
                if (z == (my_imagem.width*my_imagem.height)) break;                                 
                // alt for 24 bit depth, organization BGRX
                // 24 bit RGBX -> RGB   
                translated_buffer[k+0]=my_imagem.buffer[z+0];    // red
                translated_buffer[k+1]=my_imagem.buffer[z+0];    // green
                translated_buffer[k+2]=my_imagem.buffer[z+0];    // blue
                translated_buffer[k+3]=0;
                k+=4; z+=1;
            }           
        }
        break;      
        case 16:
            {
            unsigned int x,y,z,k/*,pixel*/,r,g,b;
            unsigned short *word;
            word=(unsigned short *) translated_buffer;
            for(z=k=y=0;y!=my_imagem.height;y++)
            for(x=0;x!=my_imagem.width*3;x++){
                if (z == (my_imagem.width*my_imagem.height*3)) break;             
                // for 16 bit depth, organization 565
                //          fprintf (stdout, ''%d - %d\n'', (imagem_t.x*imagem_t.y*imagem_t.w), z); 
                
                b=my_imagem.buffer[z++] <<8;
		g=my_imagem.buffer[z++] <<8;                      
                r=my_imagem.buffer[z++] <<8;
                r &= 0xf800;
                g &= 0xfc00;                        
                b &= 0xf800;
                word[k++]=r|g>>5|b>>11;
            }           
        }
        break;      
        case 32:
        case 24:{
        //Windows wird dargestellt
        //XMapWindow(display, win);
        unsigned x,y,z,k;
            for(z=k=y=0;y!=my_imagem.height;y++)
            for(x=0;x!=my_imagem.width;x++)
                {
                if (z == (my_imagem.width*my_imagem.height*3)) break;               
                // alt for 24 bit depth, organization BGRX
                // 24 bit RGBX -> RGB   
                translated_buffer[k+2]=my_imagem.buffer[z+2];    // red
                translated_buffer[k+1]=my_imagem.buffer[z+1];    // green
                translated_buffer[k+0]=my_imagem.buffer[z+0];    // blue
                k+=4; z+=3;
                }           
            }
        break;      
        default:
            cout << "Diese Farbtiefe wird nicht unterstützt !" << endl;
            break;  
    }
    //cout << " after case display depth" << endl;
    static int first = 1;
        if (first == 1){
        ximage = XCreateImage (display, CopyFromParent, depth /*24*/ /*zuvor depth*/,
            ZPixmap, 0, (char *)translated_buffer, my_imagem.width,
                my_imagem.height, bpl*8, bpl * my_imagem.width);
        first = 0;
    }
    //cout << "XPutImgae" << endl;
    //cout << " image width " << my_imagem.width << " height " << my_imagem.height << endl;
    XPutImage (display, win, gc, ximage, 0,0,0,0, my_imagem.width, my_imagem.height);
    //cout << "XFlush" << endl;
    XFlush(display);
    //XDestroyImage(ximage);
}

/**
 * Erzeugt ein X-Windows-Fenster
 */
Window video_out::create_simple_window(Display* display, int width, int height, int x, int y)
{
    int win_border_width = 2;
    Window win;
    // Erzeuge ein Fenster als Child des root Fenster.
    // Das Schwarz und Weiß des root Fenster werden für den
    // Vorder- und Hintergrund des neuen Fenster verwendet.
    // Das Fenster wird links oben an den Koordinaten 0,0
    // plaziert und hat die Ausdehnung WIDTH, HEIGHT
    win = XCreateSimpleWindow(display, RootWindow(display, screen_num),
                            0, 0, WIDTH, HEIGHT, win_border_width,
                            BlackPixel(display, screen_num),
                            WhitePixel(display, screen_num));
    Window root = RootWindow(display, screen_num);
    cout << "Root=" << root << endl;
    // Sende alle Nachrichten und sorge so dafür, dass das
    // Fenster aktualisiert wird.
    XFlush(display);
    return win;
}

/**
 * Diese Methode behandelt die Mouse-Events.
 * Wird eine Mousetaste im grafischen Fenster gedrückt,
 * werden die Koordinaten und die entsprechenden RGB
 * Farbanteile des Pixels über dem sich die Mouse befindet
 * im Textfenster ausgegeben.
 */
void video_out::handle_button_down(XButtonEvent* button_event, unsigned char *buffer,
                                   unsigned char *type, unsigned char *red, 
				   unsigned char *green, unsigned char *blue){

    int x, y;   /* invert the pixel under the mouse. */
    //unsigned char red, green, blue;
    x = button_event->x;
    y = button_event->y;
    switch (button_event->button) {
        case Button1:
            *type = 1;
            *blue = buffer[x*3+(y*WIDTH)*3];
            *green = buffer[x*3+(y*WIDTH)*3+1];
            *red = buffer[x*3+(y*WIDTH)*3+2];
        break;
        case Button2:
            *type = 2;
            *blue = buffer[x*3+(y*WIDTH)*3];
            *green = buffer[x*3+(y*WIDTH)*3+1];
            *red = buffer[x*3+(y*WIDTH)*3+2];
        break;
        case Button3:
            *type = 3;
            *blue = buffer[x*3+(y*WIDTH)*3];
            *green = buffer[x*3+(y*WIDTH)*3+1];
            *red = buffer[x*3+(y*WIDTH)*3+2];
        break;
    }
}

/**
 * Der Konstruktor der Klasse video_in initalisiert einige Variablen
 */
video_in::video_in(){
    frame=0;
}

/**
 * Einen Frame vom Device lesen und in frame 1 oder frame 2 ablegen.
 */
int video_in::grab_frame (/*int frame*/){       
    if (ioctl(video_fd,  VIDIOCMCAPTURE, buf + frame) == -1);
    return 0;
}
/**
 * Einen Frame vom Device lesen und in den Parameter frame ablegen.
 */
int video_in::grab_frame (int selected_frame){      
    if (ioctl(video_fd,  VIDIOCMCAPTURE, buf + selected_frame) == -1);
    return 0;
}

/**
 * Warten bis der Grabvorgang abgeschlossen ist.
 */ 
int video_in::grab_sync () {
    if (ioctl (video_fd, VIDIOCSYNC, buf+ (!frame) ) == -1);
    return 0;
    return frame;
}

/**
 * Initalisierung des Grabben von einen Videodevice in eine nmap
 */
int video_in::grab_open (char *device, int width, int height, int depth){
    unsigned int size=0;
    // Öffnen des Video Devices  
    if ((video_fd=open(device, O_RDWR)) < 0 ) return -1;
    // Ermittelung der Videoeinstellungen
    if (ioctl (video_fd, VIDIOCGCAP, &cap) < 0) return -1;
    // Typ der Karte ausgeben
    cout << "Kartentyp: " << cap.name << endl;
    cout << "Maximale Auflösung: " << cap.maxwidth << " x " << cap.maxheight << endl;
    // Test ob die Video-Auflösung vom Gerät erreicht werden kann
    if (width > cap.maxwidth || height > cap.maxheight ||
          width < cap.minwidth || height < cap.minheight)
                       return -1;
    // Einstellung der Bildeigenschaften
    // if (ioctl (video_fd, VIDIOCGPICT, &pic) < 0) return -1;
    // chn.type = VIDEO_TYPE_CAMERA;
    // chn.norm = norm;
    // chn.channel = 0;
    // if (ioctl (video_fd, VIDIOCSCHAN, &chn) < 0) return -1;
    // mmap

    // Jeder Buffer bekommt seinen eigenen Speicherbereich zugewiesen.
    // und die Auflösung wird festgelegt.
    buf[0].frame = 0;
    buf[1].frame = 1;
    buf[0].width = buf[1].width = width;
    buf[0].height = buf[1].height = height;
    
    // Abhängig von depth wird das Farbformat eingestellt.
    // depth, entspricht der Anzahl der benötigten Bytes.
    switch (depth)
        {
        case 1:
            buf[0].format = buf[1].format = VIDEO_PALETTE_GREY;
            break;
        case 2:
            buf[0].format = buf[1].format = VIDEO_PALETTE_RGB565;
            break;
        case 3:
        default:
            buf[0].format = buf[1].format = VIDEO_PALETTE_RGB24;
            break;
        }
            
    // Ermitteln des Speicherbedarfs für einen Frame.
    size = width * height * depth;
    // Ermitteln des Speicherbedarfs für alle Frames des Buffers.
    mbuf.size = size * VIDEO_BUFFERS;
    mbuf.frames = 2;
    mbuf.offsets[0] = 0;    // 1. Offset für 1. Frame
    mbuf.offsets[1] = size; // 2. Offset für 2. Frame
    // Teile dem mmap-Interface die mbuf-Informationen mit.
    if (ioctl (video_fd, VIDIOCGMBUF, &mbuf) < 0) return -1;
    buffer = (unsigned char *)mmap (0, mbuf.size, PROT_READ | PROT_WRITE, MAP_SHARED, video_fd, 0);
    if (buffer == (unsigned char *) -1) return -1;
    //cout <<  "finished video_in::grab_open"  << endl;
    return 0;
}

/**
 * Diese Methode sorgt dafür, dass ein Frame eingefangen
 * und der Frame im anderen Buffer syncronisiert wird.
 */
unsigned char * video_in::grab_pix (void) {

    //cout << "starting video_in::grab_pix " << endl;
    if (grab_frame() < 0) return 0;
    if(grab_sync() < 0) return 0;
    frame=!frame;
    return buffer + mbuf.offsets[frame];// gibt einen Frame zurück
}

/**
 * Der Speicher, der für das Grabben verwendet wurde, wird wieder freigegeben
 * und der File Descriptor des Video Device wird wieder freigegeben.
 */
void video_in::grab_close (void) {
    munmap (buffer, mbuf.size);
    close(video_fd);
}

/**
 * Diese Methode stellt mit die rot grün und blau min. max. Werte mit Hilfe
 * der Toleranz ein.
 */
void settoleranz(unsigned char red, unsigned char green, unsigned char blue,
                 unsigned char *red_min, unsigned char *red_max, unsigned char *green_min,
                 unsigned char *green_max, unsigned char *blue_min, unsigned char *blue_max, unsigned char toleranz){
    if (red<=255-toleranz) *red_max = red + toleranz;
    else *red_max = 255;
    if (red>=toleranz) *red_min = red - toleranz;
    else *red_min = 0;
    if (green<=255-toleranz) *green_max = green + toleranz;
    else *green_max = 255;
    if (green>=toleranz) *green_min = green - toleranz;
    else *green_min = 0;
    if (blue<=255-toleranz) *blue_max = blue + toleranz;
    else *blue_max = 255;
    if (blue>=toleranz) *blue_min = blue - toleranz;
    else *blue_min = 0;
}

/**
 * Diese Methode erzeugt auf der Console ein Menu und übernimmt das Auswerten
 * von Tastatur und Mouseeingaben vom grafischen Fenster.
 */
bool Menue(video_out *out, o_tracing *Objekt1, o_tracing *Objekt2, o_tracing *Objekt3, unsigned char * org_frame,
           bool &grab1, bool &grab2, bool &grab3, bool &timeing){
    static bool first=true;
    static unsigned char toleranz1 = 8;
    static unsigned char toleranz2 = 8;
    static unsigned char toleranz3 = 8;
    unsigned char  type, red, green, blue, red_min, red_max;
    unsigned char  green_min, green_max, blue_min, blue_max;
    KeySym key;
    bool break_loop = false;
    type = 0;
    if ( out->get_event(org_frame, &type, &red, &green, &blue, &key) || first ){
        if (type==0){// Tastatur
                    //cout << key << endl;
            switch (key){
                case 'b':
                case 'B':
                break_loop = true;
                break;
                case '1':
                grab1 = ! grab1;
                break;
                case '2':
                grab2 = ! grab2;
                break;
                case '3':
                grab3 = ! grab3;
                break;
                case 't':
                case 'T':
                timeing = ! timeing;
                break;
                case 'q':
                case 'Q':
                if (toleranz1<(255/2)) toleranz1++;
                break;
                case 'a':
                case 'A':
                if (toleranz1>0) toleranz1--;
                break;
                case 'w':
                case 'W':
                if (toleranz2<(255/2)) toleranz2++;
                break;
                case 's':
                case 'S':
                if (toleranz2>0) toleranz2--;
                break;
                case 'e':
                case 'E':
                if (toleranz3<(255/2)) toleranz3++;
                break;
                case 'd':
                case 'D':
                if (toleranz3>0) toleranz3--;
                break;

            default:
            break;
            }
        } else {// Mousetaste
            // min. max. Werte bestimmen
            switch (type){
                case 1:
                    settoleranz(red, green, blue, &red_min, &red_max, &green_min, &green_max, &blue_min, &blue_max, toleranz1);
                    Objekt1->set_rgb_threshold(red_min, red_max, green_min, green_max, blue_min, blue_max);
                break;
                case 2:
                    settoleranz(red, green, blue, &red_min, &red_max, &green_min, &green_max, &blue_min, &blue_max, toleranz2);
                    Objekt2->set_rgb_threshold(red_min, red_max, green_min, green_max, blue_min, blue_max);
                break;
                case 3:
                    settoleranz(red, green, blue, &red_min, &red_max, &green_min, &green_max, &blue_min, &blue_max, toleranz3);
                    Objekt3->set_rgb_threshold(red_min, red_max, green_min, green_max, blue_min, blue_max);
                break;
                default:
                break;
            }
        }// end else
        //clear();
        cout << endl << "Diplomarbeit - Kameragestützte Echtzeit Objekterkennung unter Linux" << endl;
        cout << "von Thomas Maurer Version 1.1" << endl;
	cout << "minor changes by Hartmut Eilers Version 1.2" << endl << endl;
        cout << "Für Eingaben muss der Fokus auf dem Grafischen-Fenster liegen!" << endl;
        cout << "1 = Captureframe 1 ein/aus ";
        if (grab1) cout << "[EIN] ";
        else cout << "[AUS] ";
        cout << "Toleranz 1 = [" << (toleranz1*2) << "] q=+2 / a=-2 und Mousebutton1" << endl;
        cout << "2 = Captureframe 2 ein/aus ";
        if (grab2) cout << "[EIN] ";
        else cout << "[AUS] ";
        cout << "Toleranz 2 = [" << (toleranz2*2) << "] w=+2 / s=-2 und Mousebutton2" << endl;
        cout << "3 = Captureframe 3 ein/aus ";
        if (grab3) cout << "[EIN] ";
        else cout << "[AUS] ";
        cout << "Toleranz 3 = [" << (toleranz3*2) << "] e=+2 / d=-2 und Mousebutton3" << endl;
        cout << "t = Timing ein/aus         ";
        if (timeing) cout << "[EIN] " << endl;
        else cout << "[AUS] " << endl;
        cout << "b = Programm beenden." << endl << endl;
        cout << "Mit Mausknopf 1-3 kann je für Frame 1-3 die Threshold-Farbe gewählt werden." << endl;
        if (!first && (type==1 || type==2 || type==3)) {
            cout << "Button ";
            printf("%i: RGB=[%i][%i][%i]\n", type ,red, green, blue);
        }
        #if debug==3
            printf("%iR%i %iG%i %iB%i\n",red_min, red_max, green_min, green_max, blue_min, blue_max);
        #endif

        first = false;
        }//end if
    return (break_loop);
}

/**
 * Programmeinstieg
 */
int main (int argc, char* argv[]) {

    bool break_loop = false;
    unsigned char * translated_buffer;
    unsigned char * org_frame;// Zeiger auf den eingefangenen Frame

    bool grab1 = false;
    bool grab2 = false;
    bool grab3 = false;
    bool timeing = true; // wenn false muss die Destruktion
                         // angepasst werden -> sonst Segmentation fault
    bool retime = false; // Wird das Timing neu gestartet, wird der
                         // erste verfälschte Wert verworfen.
    int depth;           // Farbtiefe des Bildes
    int bpl;             // Anzahl von Bytes, die für die Farbtiefe benötigt werden
    timeval *tv1, *tv2;  // Variablen zur Zeiterfassung
    int a;               // Laufvariable
    char device[200];

    switch (argc){
        case 1:
	    strcpy(device, "/dev/video");
	    cout << "Keine Parameterangabe es wird /dev/video verwendet." << endl;
	    break;
        case 2:
	    strcpy(device, argv[1]);
	    break;
	default:
	    cout << "Als Parameter ist nur das Video device erlaubt z.B: /dev/video1" << endl;
	    exit(0);
	    break;      
    }

    video_out * out = new video_out();
    depth = out->get_depth();
    // Farbtiefe ermitteln
    cout << "Farbtiefe= " << depth << " Bit" << endl;
    // Abhängig von der Farbtiefe müssen später 1 bis 4 Byte pro Bildpunkt
    // allokiert werden.
    switch(depth){  
        case 24:    
            bpl=4;
            break;
        case 16:
        case 15:    
            bpl=2;
            break;
        default:
            bpl=1; break;
    }
    // Speicher für zu wandelndes Bild reservieren
    translated_buffer=(unsigned char *)malloc(bpl*WIDTH*HEIGHT);
    // Vorbereitung zum Einfangen von Frames
    video_in * in = new video_in();
    if (in->grab_open(device, WIDTH, HEIGHT, DEPTH) < 0){
        fprintf (stderr,"Device %s kann nicht geöffnet werden!\n", device);
        exit(0);
    }
    // Grabbe schon mal einen ungeraden Frame
    if (in->grab_frame(1) < 0) return 0;

    o_tracing *Objekt1 = new o_tracing();
    o_tracing *Objekt2 = new o_tracing();
    o_tracing *Objekt3 = new o_tracing();
    // Einstellung des Thresholding Verfahren.
    Objekt1->set_total_threshold(255*3-100);
    Objekt2->set_total_threshold(255*3-100);
    Objekt3->set_total_threshold(255*3-100);
    //Objekt1->set_rgb_threshold(150, 255, 0, 25, 0, 25);

    // Einstellung der DeviceServer Index Variablen
    Objekt1->set_object_idx(11);
    Objekt2->set_object_idx(13);    
    Objekt3->set_object_idx(15);
    
    // Schleife in der ein Bild gegrabbt und danach abgelegt wird.
    while (!break_loop){
	//cout << "running loop" << endl;
        if (timeing) gettimeofday(tv1 = new timeval,NULL);
        for (a=0; a< 100 && break_loop==false; a++)
            {
            // Abwechselnd in die beiden Frame Buffer grabben.
            // und je den anderen eingefangenen Frame freigeben.
            org_frame = in->grab_pix();             
            if (grab1){
                Objekt1->start_tracing(org_frame);
                Objekt1->draw_tracing_frame(org_frame);
		#if debug
		  cout << "Objekt1 (x,y)=(";
		#endif		  
		Objekt1->get_center();
		#if debug
		  cout << ")" << endl;
		#endif
	    }
            if (grab2){
                Objekt2->start_tracing(org_frame);
                Objekt2->draw_tracing_frame(org_frame);
		#if debug
		  cout << "Objekt2 (x,y)=(";
		#endif
		Objekt2->get_center();
  		#if debug
		  cout << ")" << endl;
		#endif
	    }
            if (grab3){
            	Objekt3->start_tracing(org_frame);
            	Objekt3->draw_tracing_frame(org_frame);
		#if debug
		  cout << "Objekt3 (x,y)=(";
		#endif
		Objekt3->get_center();
		#if debug
		  cout << ")" << endl;
		#endif
            }
	    //cout << "running loop -- before Menue" << endl;
            break_loop = Menue(out, Objekt1, Objekt2, Objekt3, org_frame, grab1, grab2, grab3, timeing);

            // den  Frame in X-Windows darstellen.
	    //out << "running loop -- display a frame" << endl;
            out->display_frame(translated_buffer, depth, bpl, org_frame);
            //out->display_frame(translated_buffer, 8, bpl, Objekt1->areas_buffer);
            
            //for (unsigned int i=0;i<WIDTH*HEIGHT;i++){
            //  Objekt1->areas_buffer[i]=0;
            //}
	    //cout << "running loop -- display a frame finished..." << endl;
        }
        gettimeofday(tv2 = new timeval,NULL);
	//cout << "running loop --  before timing" << endl;
        if (timeing) {
            //cout << ''sec: '' << tv2->tv_sec - tv1->tv_sec << '' '';
            //cout << ''usec: '' << tv2->tv_usec - tv1->tv_usec << endl;
            if (!retime) cout << "Sekunden für 100 Bilder: " << (float)(tv2->tv_sec - tv1->tv_sec) + (float)(((float)tv2->tv_usec - (float)tv1->tv_usec)/1000000) << endl;           
            retime = false;
        }
        else{
            retime = true;
        }
    }
    //Aufräumarbeit
    in->grab_close();
    // Reservierten Speicher wieder freigeben.
    delete tv1;
    delete tv2;
    delete Objekt1;
    delete Objekt2;
    delete Objekt3;
    delete in;
    delete out;
    free((void *)translated_buffer);
}

