program test_usb8_io;

uses usb8_io_access,SysUtils;

var i: byte;
begin
  usb8_hwinit('/dev/ttyACM0',1);
  writeln('Test der digitalen Ausgabe: Count from 0 to 255');
  for i:=0 to 255 do begin
    write(i,' ');
    usb8_write_ports(1,i);
    //sleep(500);
  end;
  usb8_close;
end.