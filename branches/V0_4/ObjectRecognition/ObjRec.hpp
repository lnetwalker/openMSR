#ifndef ObjRec_HPP
#define ObjRec_HPP

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
#include <stdlib.h> 
// HTTP access
#include <stdexcept> // runtime_error
#include <sstream>
#include <sys/socket.h> // socket(), connect()
#include <arpa/inet.h> // sockaddr_in
#include <netdb.h> // gethostbyname(), hostent
#include <errno.h> // errno
// end HTTP access


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

using namespace std;

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
#endif
