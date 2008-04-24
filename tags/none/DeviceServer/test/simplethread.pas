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
	fCounter : integer;
  public
    procedure execute; override;
  end;


var myThread : TVerySimpleThread ;
	MainCounter : word;


procedure TVerySimpleThread.execute;
begin
  while not self.terminated do begin
	delay(20);
	write(fCounter,' ');
	inc(MainCounter);
  end;
end;


begin
	MainCounter:=0;
	myThread:=TVerySimpleThread.create(false);
	myThread.freeOnTerminate:=true;
	while ( MainCounter<2000 ) do begin
		inc(myThread.fCounter);
		{inc(MainCounter);}
		delay(10);
	end;
end.
