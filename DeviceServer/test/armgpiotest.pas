program armgpiotest;

var
gpiodevicenumber      : string;
f               : text;

begin
  gpiodevicenumber:='4';
  assign(f,'/sys/class/gpio/export');
  rewrite(f);
  write(f,gpiodevicenumber);
  close(f);
  assign(f,'/sys/class/gpio/gpio' + gpiodevicenumber + '/direction');
  rewrite(f);
  write(f,'in');
  close(f);
  assign(f,'/sys/class/gpio/gpio' + gpiodevicenumber + '/value');
  rewrite(f);
  write(f,'1');
  close(f);
end.
