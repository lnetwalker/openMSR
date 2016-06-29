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
 added HTTP Stuff to connect to OpenMSR DeviceServer
 splitted in different files to better interface from 
 different programming languages
 by Hartmut Eilers. hartmut@eilers.net
*/

/*
 compile with: c++ main.cpp ObjRec.cpp webcam.cpp -Wno-deprecated -L/usr/lib/X11 -lX11  -o ObjectRecognition
 if you want to compile it for v4l1 then #define v4l1, for v4l2 #undef v4l1
 for v4l1  start with: LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so ./ObjectRecognition /dev/video0
 please check the path to the library v4l1compat.o
 for v4l2  start with: ./ObjectRecognition /dev/video0
*/

/*  $Id$ */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

// choose which version of v4l should be used v4l1/v4l2
//#define v4l1
#undef v4l1

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
// include the Object Recognition lib
#include "ObjRec.hpp"

// v4l header
#ifdef v4l1
#include <libv4l1-videodev.h>
#else
// v4l2 lib benutzen
#include <linux/videodev2.h>
#include "webcam.h"
#endif

using namespace std;

#define VIDEO_BUFFERS   2 // Es werden 2 Buffer verwendet
#define debug  0
// 0 = aus
// 1 = labels Tabelle überwachen
// 3 = Grenzen des geklickten Punkes in grafischen Ausgabefenster

#ifdef v4l1
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
#endif

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

#ifdef v4l1
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
    if (ioctl (video_fd, VIDIOCSYNC, buf + (!frame) ) == -1);
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
#endif

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
        cout << "von Thomas Maurer, Version 1.1" << endl;
	cout << "minor changes regarding OpenMSR Support by Hartmut Eilers, Version 1.2" << endl << endl;
	cout << "V4L2 support by Hartmut Eilers, Version 1.3" << endl << endl;
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
#ifdef v4l1
    video_in * in = new video_in();
   if (in->grab_open(device, WIDTH, HEIGHT, DEPTH) < 0){
        fprintf (stderr,"Device %s kann nicht geöffnet werden!\n", device);
        exit(0);
    }
#else
    Webcam webcam(device, WIDTH, HEIGHT);
#endif
    // Grabbe schon mal einen ungeraden Frame
#ifdef v4l1
    if (in->grab_frame(1) < 0) return 0;
#endif
    
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
#ifdef v4l1
	    org_frame = in->grab_pix();             
#else
	    RGBImage frame = webcam.frame();
	    org_frame = (unsigned char *) frame.data;
#endif
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
#ifdef v4l1
    in->grab_close();
#endif
    // Reservierten Speicher wieder freigeben.
    delete tv1;
    delete tv2;
    delete Objekt1;
    delete Objekt2;
    delete Objekt3;
#ifdef v4l1    
    delete in;
#endif    
    delete out;
    free((void *)translated_buffer);
}

