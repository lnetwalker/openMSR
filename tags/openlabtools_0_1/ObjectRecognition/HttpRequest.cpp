#include <iostream>
#include <stdexcept> // runtime_error
#include <sstream>
#include <sys/socket.h> // socket(), connect()
#include <arpa/inet.h> // sockaddr_in
#include <netdb.h> // gethostbyname(), hostent
#include <errno.h> // errno

using namespace std;

char Domain[]="www.kernel.org";
int  Port=80;
const string request = "GET /faq/index.html HTTP/1.1\r\nHost: www.kernel.org\r\nConnection: close\r\n\r\n";

std::runtime_error CreateSocketError()
{
    std::ostringstream temp;
    temp << "Socket-Fehler #" << errno << ": " << endl;
    return std::runtime_error(temp.str());
}

void SendAll(int socket, const char* const buf, const int size)
{
    int bytesSent = 0; // Anzahl Bytes die wir bereits vom Buffer gesendet haben
    do
    {
        int result = send(socket, buf + bytesSent, size - bytesSent, 0);
        if(result < 0) // Wenn send einen Wert < 0 zurück gibt deutet dies auf einen Fehler hin.
        {
            throw CreateSocketError();
        }
        bytesSent += result;
    } while(bytesSent < size);
}

// Liest eine Zeile des Sockets in einen stringstream
void GetLine(int socket, std::stringstream& line)
{
    for(char c; recv(socket, &c, 1, 0) > 0; line << c)
    {
        if(c == '\n') {
            return;
        }
    }
    throw CreateSocketError();
}

int main()
{

    hostent* phe = gethostbyname(Domain);

    if(phe == NULL)
    {
        cout << "Host konnte nicht aufgeloest werden!" << endl;
        return 1;
    }

    if(phe->h_addrtype != AF_INET)
    {
        cout << "Ungueltiger Adresstyp!" << endl;
        return 1;
    }

    if(phe->h_length != 4)
    {
        cout << "Ungueltiger IP-Typ!" << endl;
        return 1;
    }

    int Socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(Socket == -1)
    {
        cout << "Socket konnte nicht erstellt werden!" << endl;
        return 1;
    }

    sockaddr_in service;
    service.sin_family = AF_INET;
    service.sin_port = htons(Port); // Das HTTP-Protokoll benutzt Port 80

    char** p = phe->h_addr_list; // p mit erstem Listenelement initialisieren
    int result; // Ergebnis von connect
    do
    {
        if(*p == NULL) // Ende der Liste
        {
            cout << "Verbindung fehlgschlagen!" << endl;
            return 1;
        }

        service.sin_addr.s_addr = *reinterpret_cast<unsigned long*>(*p);
        ++p;
        result = connect(Socket, reinterpret_cast<sockaddr*>(&service), sizeof(service));
    }
    while(result == -1);

    cout << "Verbindung erfolgreich!" << endl;

    SendAll(Socket, request.c_str(), request.size());

    // empfange und verwerfe antwort
    while(true)
    {
        stringstream line;
        try
        {
            GetLine(Socket, line);
        }
        catch(exception& e) // Ein Fehler oder Verbindungsabbruch
        {
            break; // Schleife verlassen
        }
    }
    close(Socket);
}
