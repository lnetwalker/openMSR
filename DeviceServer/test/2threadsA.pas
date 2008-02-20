program simplethread;

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
	runningThread : char;


procedure TVerySimpleThread.execute;
begin
  while not self.terminated do begin
	delay(20);
	runningThread:='S';
  end;
end;

procedure TAnotherThread.execute;
begin
  while not self.terminated do begin
	delay(20);
	runningThread:='A';
	inc(MainCounter);
  end;
end;


begin
	clrscr;
	MainCounter:=0;
	myThread:=TVerySimpleThread.create(true);
	myThread.freeOnTerminate:=true;
	my2Thread:=TAnotherThread.create(true);
	my2Thread.freeOnTerminate:=true;
	while ( MainCounter<2000 ) do begin
		gotoxy(15,20);write(runningThread);
	end;
end.
