unit FieldDevice;

{ Access Layer for datastructures of configured MQTT Devices 	}
{ Every MQTT Device stores his relevant data in this structure	}
{ (c) 2017 by Hartmut Eilers									}
{ released as part of openMSR tools under the Terms 			}
{ GNU GPL V 2 or later											}


interface
  type
    TDevTyp = ( Input, Output, Analog );
    TMQTTAction = ( s, p );
  	// Define record for the field device
  	TFieldDevice = record
      typ         : TDevTyp;
      MQTTAction  : TMQTTAction;
      topic       : String;
      indexnum    : word;
      LastRun     : integer;
  	end;

    TFieldDeviceObject = object
      public
        function AddDevice(DeviceTyp : TDevTyp; Action : TMQTTAction;
                           workingTopic : String; DeviceNumber: word) : boolean;

        function GetDeviceCount():word;

        procedure GetDeviceInfo(IndexNumber: word; var DeviceTyp : TDevTyp; 
                                var Action : TMQTTAction; 
                                var workingTopic : String; 
                                var DeviceNumber: word);
                                
        procedure GetTopicInfo(topic: String; var DeviceTyp : TDevTyp; 
                               var Action : TMQTTAction; var DeviceNumber: word);
    end;

implementation

  const
    MaxIndex = 384;

  var
    FieldDeviceArray  : array [1..MaxIndex] of TFieldDevice;
    ElementCounter    : word;

  function TFieldDeviceObject.AddDevice(DeviceTyp : TDevTyp; Action : 
                                        TMQTTAction; workingTopic : String; 
                                        DeviceNumber: word) : boolean;

  var
    ThisIndex   : word;

  begin
    ThisIndex:=GetDeviceCount()+1;
    if ThisIndex>MaxIndex then begin
      AddDevice:=false;
    end
    else begin
      writeln('adding MQTT Data');
      ElementCounter:=ElementCounter + 1;
      FieldDeviceArray[ThisIndex].typ:=DeviceTyp;
      FieldDeviceArray[ThisIndex].MQTTAction:=Action;
      FieldDeviceArray[ThisIndex].topic:=workingTopic;
      FieldDeviceArray[ThisIndex].indexnum:=DeviceNumber;
      AddDevice:=true;
    end;
  end;

  function TFieldDeviceObject.GetDeviceCount():word;
  begin
    GetDeviceCount:=ElementCounter;
  end;

  procedure TFieldDeviceObject.GetDeviceInfo(IndexNumber: word; 
                                             var DeviceTyp : TDevTyp; 
                                             var Action : TMQTTAction; 
                                             var workingTopic : String; 
                                             var DeviceNumber: word);
                                             
  begin
    // check weather index is in range
    if ( IndexNumber > ElementCounter ) then begin
      // signal error
      DeviceNumber:=9999;
    end
    else begin
      DeviceTyp:=FieldDeviceArray[IndexNumber].typ;
      Action:=FieldDeviceArray[IndexNumber].MQTTAction;
      workingTopic:=FieldDeviceArray[IndexNumber].topic;
      DeviceNumber:=FieldDeviceArray[IndexNumber].indexnum;
    end;

  end;

  procedure TFieldDeviceObject.GetTopicInfo(topic: String; var DeviceTyp : TDevTyp; 
                                            var Action : TMQTTAction; 
                                            var DeviceNumber: word);
                                            
  var
    TopicCounter: word;
    found       : boolean;

  begin
    TopicCounter:=0;
    found:=false;
    repeat
      TopicCounter:=TopicCounter+1;
      if (topic = FieldDeviceArray[TopicCounter].topic) then
        found:=true;
    until (  found or (TopicCounter >= ElementCounter) );
    if found then begin
      DeviceTyp:=FieldDeviceArray[TopicCounter].typ;
      Action:=FieldDeviceArray[TopicCounter].MQTTAction;
      DeviceNumber:=FieldDeviceArray[TopicCounter].indexnum
    end
    else begin
      DeviceTyp:=input;
      Action:=p;
      DeviceNumber:=9999;
    end;
  end;


begin
  ElementCounter:=0;
end.
