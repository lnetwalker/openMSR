program syslogtest;

uses BaseUnix,sysutils,systemlog;

var 	i	: longint;
	prefix	: ansistring;
	cnt	: byte;

begin
	i:=fpgetpid();
	cnt:=1;
	prefix:=format('syslogtest[%d] ',[i]);
	// prefix will be prepended to every message now.
	openlog(pchar(prefix),LOG_NOWAIT,LOG_DEBUG);
	syslog(log_info,'This is an info message number %d'#10,[cnt]);
	syslog(log_debug,'This is a debug message'#10);
	syslog(log_err,'This is an error'#10);

end.
