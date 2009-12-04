program http_test;

uses crt,http_io_access;

var 
  InitString	: string;

begin
  //init the driver
  InitString:='http://canis:10080/digital/ReadInputValues.html?§http://canis:10080/digital/WriteOutputValues.html?§';
  http_hwinit(InitString,1);

  while not keypressed do begin
    writeln(http_read_ports(11));
    delay(20);
  end;

end.