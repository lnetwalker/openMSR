#include "ObjRec.hpp"

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

