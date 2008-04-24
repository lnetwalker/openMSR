program twothreads;

{ thread examples and tests to better understand thread programming in pascal 	}
{ copyright (c) by Hartmut Eilers  <hartmut@eilers.net>							}
{ licensed under the GNU GPL V2 or any later revision							}
{ under Linux use "ps -eLf|grep <programname>" to see the threads				}


uses
  cthreads,classes,crt;

type
  TVerySimpleThread = class(TThread)
  protected
	fCounter : LongInt;
  public
    procedure execute; override;
  end;

type
  TAnotherThread = class(TThread)
  protected
	
  public
    procedure execute; override;
  end;


var myThread : TVerySimpleThread ;
	my2Thread : TAnotherThread;
	MainCounter : LongInt;


procedure TVerySimpleThread.execute;
begin
  while not self.terminated do begin
	delay(20);
	inc(MainCounter);
	{gotoxy(10,21);clreol;
	write ('ST',MainCounter,' ');}
  end;
end;

procedure TAnotherThread.execute;
begin
  while not self.terminated do begin
		delay(10);
		//gotoxy(10,20);clreol;
		//write('M',MainCounter,' ');
		//write('T',myThread.fCounter,' ');
  end;
end;


begin
	clrscr;
	MainCounter:=0;
	myThread:=TVerySimpleThread.create(false);
	myThread.freeOnTerminate:=true;
	my2Thread:=TAnotherThread.create(false);
	my2Thread.freeOnTerminate:=true;
	while ( MainCounter<2000 ) do begin
		inc(myThread.fCounter);
		gotoxy(10,22);clreol;
		write('TC',myThread.fCounter,' MC ',MainCounter);
		delay(15);
	end;
end.
