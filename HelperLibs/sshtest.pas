program sshtest;
 
{Test program for telnetsshclient
 
Written by Reinier Olislagers 2011.
Modified for libssh2 by Alexey Suhinin 2012.
 
License of code:
* MIT
* LGPLv2 or later (with FreePascal static linking exception)
* GPLv2 or later
according to your choice.
Free use allowed but please don't sue or blame me.
 
Uses other libraries/components; different licenses may apply that also can influence the combined/compiled work.
 
Run: sshtest <serverIPorhostname> [PrivateKeyFile]
}
{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}
 
uses
  telnetsshclient;
var
  comm: TTelnetSSHClient;
  Command: string;
begin
  writeln('Starting.');
  comm:=TTelnetSSHClient.Create;
  comm.HostName:= ParamStr(1); //First argument on command line
  if comm.HostName='' then
  begin
    writeln('Please specify hostname on command line.');
    halt(1);
  end;
 
  comm.PrivateKeyFile := ParamStr(2);
 
  comm.TargetPort:='0'; //auto determine based on protocoltype
  comm.UserName:='root'; //change to your situation
  comm.Password:='password'; //change to your situation
  comm.ProtocolType:=SSH; //Telnet or SSH
  writeln(comm.Connect); //Show result of connection
  if comm.Connected then
  begin
    writeln('Server: ' + comm.HostName + ':'+comm.TargetPort+', user: '+comm.UserName);
    writeln('Welcome message:');
    writeln(comm.WelcomeMessage);
    Command:='ls -al';
    writeln('*** Sending ' + Command);
    writeln('*** Begin result****');
    writeln(comm.CommandResult(Command));
    writeln('*** End result****');
    writeln('');
    writeln('');
    Command:='df -h';
    writeln('*** Sending ' + Command);
    writeln('*** Begin result****');
    writeln(comm.CommandResult(Command));
    writeln('*** End result****');
    writeln('');
    writeln('');
    writeln('All output:');
    writeln('*** Begin result****');
    writeln(comm.AllOutput);
    writeln('*** End result****');
    comm.Disconnect;
  end
  else
  begin
    writeln('Connection to ' +
      comm.HostName + ':' +
      comm.TargetPort + ' failed.');
  end;
  comm.Free;
end.