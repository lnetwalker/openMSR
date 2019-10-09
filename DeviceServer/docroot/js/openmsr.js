/*
    this JavaScript library provides different GUI
    elements to use with OpenMSR
    Copyright (c) 2010 by Hartmut Eilers
    <hartmut@eilers.net>
    released under the GNU GPL V 2.0 or later

    Project start 17.08.2010

    { $Id: openmsr.js,v 1.7 2010-09-09 07:38:17 hartmut Exp $ }

*/

/* History:
	Sep 2010
		start
		DigitalDataReader
		DigitalDataSender
		AnalogDataReader
		Lamp
		Switch
		HorMeter
		Knob

	Oct 2016
		added LCDisplay
		fixed Bug in AnalogReader
		refactored code

  Nov 2016
    added datalogger
*/


/** this function initializes the JavaScript Tools */
function OpenMSRInit() {
  // init Event mechanics
  EventInit();
  // Clear Debugging Window if it exists
  if ( document.getElementById('debug')!= null ) {
    document.getElementById('debug').value = '';
    DbgMsgCnt = 0;
    // Max Number of Messages in the Message Box
    DbgMaxMsg = 250;
  }
  DebugLOG(' Page loaded OpenMSRInit done' );
}

/**
    custom events for communication between the different elements of this lib
*/
function Event(){
  this.eventHandlers = new Array();
}

Event.prototype.addHandler = function(eventHandler){
  this.eventHandlers.push(eventHandler);
  DebugLOG(' added Event Handler ' );
}

Event.prototype.execute = function(args){
  DebugLOG(' Event ' + args + ' occured' );
  for(var i = 0; i < this.eventHandlers.length; i++){
    this.eventHandlers[i](args);
  }
}

function EventInit() {
  OpenMSREvent = new Event();
}
// end of events


/** debug output
    spits out the Timestamp as ms since 1.1.1970 0:00 h
    and the message in a textarea named debug
*/
function DebugLOG(msg) {
  //return;
  if ( document.getElementById('debug')!= null ) {
    var TimeStamp = new Date;
    if ( DbgMsgCnt == DbgMaxMsg ) {
      // delete the Message Box to avoid too much data
      // which slows down everything
      DbgMsgCnt = 0;
      document.getElementById('debug').value = '';
    }
    DbgMsgCnt = DbgMsgCnt + 1;
    document.getElementById('debug').value += TimeStamp.getTime() + ' ' + msg + '\n';
  }
}


/** Initialize Plattformindependent the asynchronous access */
function getXMLHttpRequest() {
	var httpReq=null;
	if (window.XMLHttpRequest) {
		httpReq=new XMLHttpRequest();
	} else if (typeof ActiveXObject != "undefined") {
		httpReq=new ActiveXObject("Microsoft.XMLHTTP");
	}
	return httpReq;
}

/** the communication layer between the browser and the DeviceServer
   functions to query/set the DeviceServer and to use the events*/
var DigitalDataReader = function () {
  /*
  this function reads the digital data from the DeviceServer
  and distributes it over Events
  */

  this.Adresse = 'http://localhost:10080/digital/ReadInputValues.html';
  this.IOGroup = 0;
  this.EventMapping = new Array();
  //var this.ReaderTimer=null;
  this.req = null;
  this.OldVal = 0;

  var me = this;

  me.TimeIntervall = 400;

  // Start the asynchronous read request
  this.SendRequest = function () {
    //alert('SendRequest ' + me.IOGroup );
    me.req=getXMLHttpRequest();
    if (me.req) {
      //alert ('SendRequest send ' + me.Adresse + '?' + me.IOGroup );
      me.req.onreadystatechange = me.PrintState;
      me.req.open("get", me.Adresse + "?" + me.IOGroup, true);
      me.req.send(null);
    }
  }

  // this function reads the asynchronous response from the AJAX request
  // and sends the values as events
  this.PrintState = function () {
    //alert('PrintState');
    // readyState 4 gibt an dass der request beendet wurde
    if ( me.req.readyState ==4 ) {
      //
      // in resonseText ist die Antwort des Servers
      str=me.req.responseText;
      //alert(str);
      // remove html tags
      str = str.replace(/<[^<>]+>/g , "");
      // remove leading space
      str = str.replace(/^ /, "");
      inputs=str.split(" ");
      // now loop over the result and fire the events
      for (var i=0;i<8;i++) {
        // send out events if the signal has changed since last run
        DebugLOG('DigitalDataReader: i=' +i + 'inputs=' + inputs[i] + 'OldVal=' +me.OldVal[i] );
        if ( inputs[i] != me.OldVal[i] ) {
          EventArgs = 'digital' + ' ' + me.EventMapping[i+1] + ' ' + inputs[i];
          //DebugLOG('DigitalDataReader: send Event = ' + EventArgs );
          // fire event
          OpenMSREvent.execute(EventArgs);
        }
      }
      // save values for next run
      me.OldVal=inputs;
    }
  }

  // this function read the timer value
  this.TimerVal = function (xx) {
    me.TimeIntervall = xx;
  }

  // this function builds the list of event to input mapping
  this.AssignEvent = function (xx,yy) {
    me.EventMapping[xx] = yy;
    //alert(me.EventMapping[xx]);
  }

  // the URL to read the DeviceServer
  this.DeviceServerURL = function (xx) {
    me.Adresse = xx;
  }

  // the IOGroup to read
  this.IOGroup = function (xx) {
    me.IOGroup = xx;
    //alert(me + ' ' + me.IOGroup);

    // establish our own timer to periodically read the signals
    me.ReaderTimer = setInterval(me.SendRequest,me.TimeIntervall);

  }

}


var DigitalDataSender=function () {
  /*
  this function receives events and sends the data to
  the DeviceServer
  */
  this.Adresse = 'http://localhost:10080/digital/WriteOutputValues.html';
  this.IOGroup = 0;
  this.EventMapping = new Array();
  this.ValArray = new Array();
  this.req = null;
  this.value = 0;
  var me = this;

  me.TimeIntervall=400;

  // Start the asynchronous write request
  this.SendRequest = function () {
    //alert('SendRequest ' + me.IOGroup );
    me.req=getXMLHttpRequest();
    if (me.req) {
      // calculate the value from the ValArray
      me.value=0;
      for (var i=1;i<8;i++) {
        if (me.ValArray[i] == 1) {
          me.value=me.value+Math.pow(2,(i-1));
        }
      }
      //alert ('SendRequest send ' + me.Adresse + '?' + me.IOGroup + "," + me.value );
      me.req.onreadystatechange = me.PrintState;
      me.req.open("get", me.Adresse + "?" + me.IOGroup + "," + me.value, true);
      me.req.send(null);
    }
  }

  // this function reads the asynchronous response from the AJAX request
  // and sends the values as events
  this.PrintState = function () {
    //alert('PrintState');
    // readyState 4 gibt an dass der request beendet wurde
    if ( me.req.readyState ==4 ) {
      //
      // in resonseText ist die Antwort des Servers
      var str=me.req.responseText;
      // currently we just read the response, and ignore it
    }
  }

  // this function read the timer value
  this.TimerVal = function (xx) {
    me.TimeIntervall = xx;
  }

  // this function builds the list of event to input mapping
  this.AssignEvent = function (xx,yy) {
    this.EventMapping[xx] = yy;
    //alert(xx + ' ' + this.EventMapping[xx]);
  }

  // the URL to use with the DeviceServer
  this.DeviceServerURL = function (xx) {
    this.Adresse = xx;
  }

  // the IOGroup to use
  this.IOGroup = function (xx) {
    this.IOGroup = xx;
    //alert(me + ' ' + me.IOGroup);
    // establish our own timer to periodically read the signals
    me.SenderTimer = setInterval(me.SendRequest,me.TimeIntervall);
  }

  this.ReceiveEvent = function(EventArgs) {
    // split the event data in its elements
    var EventArray = EventArgs.split(' ');
    // check wether the current event is for me
    // loop over the mapping and store value if mapping matches
    if ( EventArray[0] == 'digital') {
      for (var i=1;i<8;i++) {
        if (me.EventMapping[i] == EventArray[1] ) {
          //alert(me + ' ' + EventArray[2]);
          me.ValArray[i]=EventArray[2];
        }
      }
    }
  }

  // install Event Handler
  OpenMSREvent.addHandler(me.ReceiveEvent);
}


var AnalogDataReader = function () {
  /*
  this function reads the analog data from the DeviceServer
  and distributes it over Events
  */

  this.Adresse = 'http://localhost:10080/analog/read.html';
  this.IOGroup = 0;
  this.EventMapping = new Array();
  this.req = null;
  this.inputs = new Array();
  var me = this;

  me.TimeIntervall=480;

  // Start the asynchronous read request
  this.SendRequest = function () {
    //alert('SendRequest ' + me.IOGroup );
    me.req=getXMLHttpRequest();
    if (me.req) {
      DebugLOG('AnalogReader.SendRequest send ' + me.Adresse + '?' + me.IOGroup );
      me.req.onreadystatechange = me.PrintState;
      me.req.open("get", me.Adresse + "?" + me.IOGroup, true);
      me.req.send(null);
    }
  }


  // fires one Event
  this.FireEvent = function (Item,Index) {
    EventData = 'analog' + ' ' + Item + ' ' + me.inputs[Index];
    // fire event
    DebugLOG(' AnalogReader.PrintState fired event ->' + EventData );
    OpenMSREvent.execute(EventData);
  }


  // this function reads the asynchronous response from the AJAX request
  // and sends the values as events
  this.PrintState = function () {
    // readyState 4 gibt an dass der request beendet wurde
    if ( me.req.readyState ==4 ) {
      // in resonseText ist die Antwort des Servers
      var str=me.req.responseText;
      // remove html tags
      str = str.replace(/<[^<>]+>/g , "");
      // remove leading space
      str = str.replace(/^ /, "");
      me.inputs=str.split(" ");
      DebugLOG('AnalogReader.PrintState: received ' + me.inputs );
      me.EventMapping.forEach(me.FireEvent);
    }
  }

  // this function read the timer value
  this.TimerVal = function (xx) {
    me.TimeIntervall = xx;
  }

  // this function builds the list of event to input mapping
  this.AssignEvent = function (xx,yy) {
    me.EventMapping[xx-1] = yy;
    //alert(xx + ' ' + me.EventMapping[xx]);
    DebugLOG(' AnalogReader EventMapping '+ me.EventMapping[xx]);
  }

  // the URL to read the DeviceServer
  this.DeviceServerURL = function (xx) {
    me.Adresse = xx;
  }

  // the IOGroup to read
  this.IOGroup = function (xx) {
    me.IOGroup = xx;
    //alert(me + ' ' + me.IOGroup);
    // establish our own timer to periodically read the signals
    me.ReaderTimer = setInterval(me.SendRequest,me.TimeIntervall);
  }

}

var AnalogDataWriter = function () {
  /*
  this function receives Events and writes the analog data to the DeviceServer
  */

  this.Adresse = 'http://localhost:10080/analog/write.html';
  this.IOGroup = 0;
  this.EventMapping = new Array();
  this.ValArray = new Array();
  this.req = null;
  this.inputs = new Array();
  var me = this;

  me.TimeIntervall=480;

  // Start the asynchronous write request
  this.SendRequest = function () {
    //alert('SendRequest ' + me.IOGroup );
    me.req=getXMLHttpRequest();
    if (me.req) {
      DebugLOG('AnalogWriter.SendRequest send ' + me.Adresse + '?' + me.IOGroup );
      var cnt=me.ValArray.length;
      me.req.onreadystatechange = me.PrintState;
      me.req.open("get", me.Adresse + "?" + ((me.IOGroup-1)*8+cnt-1) + "," + parseInt(me.ValArray[cnt-1],10).toString(), true);
      me.req.send(null);
    }
  }


  // this function reads the asynchronous response from the AJAX request
  // and sends the values as events
  this.PrintState = function () {
    // readyState 4 gibt an dass der request beendet wurde
    if ( me.req.readyState ==4 ) {
      // in resonseText ist die Antwort des Servers
      var str=me.req.responseText;
      DebugLOG('AnalogDataWriter.PrintState: received ' + me.req.responseText );
    }
  }


  this.ReceiveEvent = function(EventArgs) {
    // split the event data in its elements
    var EventArray = EventArgs.split(' ');
    // check wether the current event is for me
    // loop over the mapping and store value if mapping matches
    if ( EventArray[0] == 'analog') {
      for (var i=1;i<8;i++) {
        if (me.EventMapping[i] == EventArray[1] ) {
          //alert (EventArray[0] + ' ' + EventArray[1] + ' ' + EventArray[2]);
          //alert(me + ' ' + EventArray[2] + ' i=' + i);
          me.ValArray[i]=EventArray[2];
        }
      }
    }
  }


  // this function read the timer value
  this.TimerVal = function (xx) {
    me.TimeIntervall = xx;
  }

  // this function builds the list of event to input mapping
  this.AssignEvent = function (xx,yy) {
    me.EventMapping[xx] = yy;
    //alert(xx + ' ' + me.EventMapping[xx]);
    DebugLOG(' AnalogWriter EventMapping '+ me.EventMapping[xx]);
  }

  // the URL to read the DeviceServer
  this.DeviceServerURL = function (xx) {
    me.Adresse = xx;
  }

  // the IOGroup to read
  this.IOGroup = function (xx) {
    me.IOGroup = xx;
    //alert(me + ' ' + me.IOGroup);
    // establish our own timer to periodically read the signals
    me.WriterTimer = setInterval(me.SendRequest,me.TimeIntervall);
  }

  // install Event Handler
  OpenMSREvent.addHandler(me.ReceiveEvent);

}

// The different devices that are available

// the meter is an instrument to show analog values
var HorMeter = function(CanvasName,Cat,CatNo) {
  // get access to the given canvas
  this.canv = document.getElementById(CanvasName);
  // set width and height of the canvas

  // default background image
  ImgSrc = 'images/lampe.gif';

  // note who i am
  var me = this;

  // setup the background image
  this.HorMeterCanv = this.canv.getContext("2d");
  this.BackgroundImg = new Image();
  this.BackgroundImg.src = me.ImgSrc;
  this.BackgroundImg.onload = function() {
    me.HorMeterCanv.beginPath();
    me.HorMeterCanv.drawImage(me.BackgroundImg, 0, 0);
    me.HorMeterCanv.closePath();
  };

  this.Resltn=10;

  this.width = function (width) {
    this.canv.width = width;
  }

  this.height = function(height) {
    this.canv.height = height;
  }

  // print a custom background image
  this.canvbgimg = function(imagename) {
    this.BackgroundImg.src = imagename;
    // redraw the canvas
    me.height = this.canv.height;
  }

  // get the maximum Value for the meter
  this.maxVal = function(xx) {
    this.MaxHorMeterVal = xx;
  }

  // get the minimum Value for the meter
  this.minVal = function(xx) {
    this.MinHorMeterVal = xx;
  }

  // get the maximum Value Position for the meter
  this.maxPos = function(xx,yy) {
    this.MaxPosX = xx;
    this.MaxPosY = yy;
  }

  // get the minimum Value Position for the meter
  this.minPos = function(xx,yy) {
    this.MinPosX = xx;
    this.MinPosY = yy;
  }

  // get the color for the meter
  this.color = function(xx) {
    this.Color = xx;
  }

  // get the width for the meter gauge
  this.MeterWidth = function(xx) {
    this.LineWidth = xx;
  }

  // get the Resolution for the meter
  this.Resolution = function(xx) {
    this.Resltn = xx;
  }

  // use the Value for the meter
  // and display everything
  this.currentValue = function(EventArgs) {
    // split the event data in its elements
    var EventArray = EventArgs.split(' ');
    // check wether the current event is for me
    if ( EventArray[0] == Cat) {
      if ( EventArray[1] == CatNo ) {
        // the event is for me, so display data
        CurVal = EventArray[2];
        //alert (' Event received: ' + Cat + ' ' + CatNo + ' ' + CurVal);
        ValX = parseInt( me.Resltn * ( CurVal - me.MinHorMeterVal ) * ((me.MaxPosX-me.MinPosX) / ((me.MaxHorMeterVal - me.MinHorMeterVal) * me.Resltn)) +  me.MinPosX);
        //document.write(ValX ,' ', MinPosX ,' ', MaxPosX ,' ', xx,' ',MaxHorMeterVal,' ',MinHorMeterVal,' ',(MaxPosX-MinPosX) / ((MaxHorMeterVal - MinHorMeterVal)*10));
        // delete canvas
        me.canv.height = me.canv.height;
        me.HorMeterCanv.beginPath();
        me.HorMeterCanv.drawImage(me.BackgroundImg, 0, 0);
        me.HorMeterCanv.strokeStyle = me.Color;
        me.HorMeterCanv.lineWidth = me.LineWidth;
        // paint the meter
        me.HorMeterCanv.moveTo(me.MinPosX, me.MinPosY);
        me.HorMeterCanv.lineTo(ValX,me.MaxPosY);
        me.HorMeterCanv.stroke();
        me.HorMeterCanv.closePath();
      }
    }
  }

  // install Event Handler
  OpenMSREvent.addHandler(me.currentValue);
}


// digital switch
var Switch = function(CanvasName,Cat,CatNo) {
  // get access to the given canvas
  this.canv = document.getElementById(CanvasName);

  // set width and height of the canvas
  this.width = function (width) {
    this.canv.width = width;
  }

  this.height = function(height) {
    this.canv.height = height;
  }

  // default background image
  this.ImgSrcOff = 'images/switch-off.jpg';
  this.ImgSrcOn  = 'images/switch-on.jpg';

  // note who i am
  var me = this;

  // setup the background image
  this.SwitchCanv = this.canv.getContext("2d");
  this.BackgroundImg = new Image();
  this.BackgroundImg.src = me.ImgSrcOff;

  this.BackgroundImg.onload = function() {
    me.SwitchCanv.beginPath();
    me.SwitchCanv.drawImage(me.BackgroundImg, 0, 0);
    me.SwitchCanv.closePath();
  }

  this.state=0;

  // print a custom background image
  this.offimg = function(imagename) {
    this.ImgSrcOff = imagename;
    this.BackgroundImg.src = me.ImgSrcOff;
    me.state = 1;
    this.changeState();
  }


  // print a custom background image
  this.onimg = function(imagename) {
    this.ImgSrcOn = imagename;
    this.BackgroundImg.src = me.ImgSrcOn;
    me.state = 1;
    this.changeState();
  }


  // This is called when you release the mouse button.
  this. changeState = function() {
    //alert("State: "+ state );
    if ( me.state == 1 ) {
      me.state = 0
      me.BackgroundImg.src = me.ImgSrcOff;
    } else {
      me.state = 1
      me.BackgroundImg.src = me.ImgSrcOn;
    }
    // display actual state
    me.canv.width = me.canv.width;
    me.SwitchCanv.beginPath();
    me.SwitchCanv.drawImage(me.BackgroundImg, 0, 0);
    me.SwitchCanv.closePath();
    // pack the event arguments in one string
    EventArgs = Cat + ' ' + CatNo + ' ' + me.state;
    // fire event
    OpenMSREvent.execute(EventArgs);
  };


  // add eventhandler for mouse click
  this.canv.onclick = me.changeState;

}


// this function show the logic state with pictures
// can be LED like or any other pictures
function Lamp(CanvasName,Cat,CatNo) {
  // get access to the given canvas
  this.canv = document.getElementById(CanvasName);

  // set width and height of the canvas
  this.width = function (width) {
    this.canv.width = width;
  }

  this.height = function(height) {
    this.canv.height = height;
  }

  // default background image
  this.ImgSrcOff = 'images/led-green-off.jpg';
  this.ImgSrcOn  = 'images/led-green-on.jpg';

  var me = this;
  // setup the background image
  this.LampCanv = this.canv.getContext("2d");
  this.BackgroundImg = new Image();
  this.BackgroundImg.src = me.ImgSrcOff;
  this.BackgroundImg.onload = function() {
    //me.canv.width = me.canv.width;
    me.LampCanv.beginPath();
    me.LampCanv.drawImage(me.BackgroundImg, 0, 0);
    me.LampCanv.closePath();
  }

  // print a custom background image
  this.offimg = function(imagename) {
    this.ImgSrcOff = imagename;
    DebugLOG('Cust Img Lamp off =' + me.ImgSrcOff );
    InitialLampState();
  }

  // print a custom background image
  this.onimg = function(imagename) {
    this.ImgSrcOn = imagename;
    DebugLOG('Cust Img Lamp on =' + me.ImgSrcOn );
    InitialLampState();
  }

  function InitialLampState() {
    me.BackgroundImg.src = me.ImgSrcOff;
    //me.canv.width = me.canv.width;
    me.LampCanv.beginPath();
    me.LampCanv.drawImage(me.BackgroundImg, 0, 0);
    me.LampCanv.closePath();
  }

  function HandleLampState (EventArgs) {
    // split the event data in its elements
    EventArray = EventArgs.split(' ');
    // check wether the current event is for me
    if ( EventArray[0] == Cat) {
      if ( EventArray[1] == CatNo ) {
        // the event is for me, so display data
        if ( EventArray[2] == 1 ) {
          me.BackgroundImg.src = me.ImgSrcOn;
          DebugLOG('Lamp on ' + me.ImgSrcOn );
        } else {
          me.BackgroundImg.src = me.ImgSrcOff;
          DebugLOG('Lamp off ' + me.ImgSrcOff );
        }
        //canv.width = canv.width;
        me.LampCanv.beginPath();
        me.LampCanv.drawImage(me.BackgroundImg, 0, 0);
        me.LampCanv.closePath();
      }
    }
  }

  // install Event Handler
  OpenMSREvent.addHandler(HandleLampState);
}


// analog knob
function Knob(CanvasName,Cat,CatNo) {
  /*
  default-knob data
  default-knob.png
  75,87 center of knob
  75,30 upper knob marker
  75,50 inner knob marker
  marker length 20 px
  */

  // get access to the given canvas
  var canv = document.getElementById(CanvasName);

  // set width and height of the canvas
  this.width = function (width) {
    canv.width = width;
  }

  this.height = function(height) {
    canv.height = height;
  }

  // default background image
  var ImgSrc = 'images/default-knob.png';
  // setup the background image
  var KnobCanv = canv.getContext("2d");
  var BackgroundImg = new Image();
  BackgroundImg.src = ImgSrc;

  BackgroundImg.onload = function() {
    canv.width = canv.width;
    KnobCanv.beginPath();
    KnobCanv.drawImage(BackgroundImg, 0, 0);
    KnobCanv.closePath();
  }


  // print a custom background image
  this.bgimg = function(imagename) {
    ImgSrc = imagename;
  }


  var VAlpha = 218;
  var xc = 75;
  var yc = 87;
  var r = 60;
  var OldY = 0;
  var KnobButton = false;
  var LineWidth = 2;
  var Color = 'black';
  var KnobVal = 0;
  var Resolution = 1;
  // no floating updates as default
  var floatingUpdate = 0;
  var pointerlength = 0;
  var r1 = 0;

  // get the width for the meter gauge
  this.MeterWidth = function(xx) {
    LineWidth = xx;
  }

  // get theresolution for the meter gauge
  this.Resolution = function(xx) {
    Resolution = xx;
  }

  // get the color for the meter
  this.MeterColor = function(xx) {
    Color = xx;
  }

  // get the radius
  this.Radius = function(xx) {
    r = xx;
  }

  // get center of dial
  this.Center = function (xx,yy) {
    xc = xx;
    yc = yy;
  }

  // get the Minimum Value
  this.MinVal = function (xx) {
    KnobMin = xx;
  }

  // get the Maximum Value
  this.MaxVal = function (xx) {
    KnobMax = xx;
  }

  // Floating Update ?
  this.floatingUpdate = function (xx) {
    floatingUpdate = xx;
  }

  // pointer length if pointer not from center of knob
  this.pointerlength = function (xx) {
    pointerlength = xx;
    //alert ( pointerlength );
  }

  // This is called when you move the mouse over the button
  function changeState(e) {

    if ( KnobButton ) {
      /* for a 8 bit knob it means that it can have
      256 values. 0 degree is to the right ( east )
      with increasing values left turned,
      which means that -38 degree is max value and
      218 degree corresponds to min value
      */
      // cross browser mouse event detection
      if (!e) var e = window.event;

      // cross browser y koordinate
      if ( e.pageY ) 	{
        posy = e.pageY;
      }
      else if ( e.clientY ) 	{
        posy = e.clientY ;
      }

      // y coordinate changed in up or down direction so increase or decrease angle
      if ( OldY > posy ) {
        if ( ( VAlpha - Resolution ) > ( -39 ) ) {
          VAlpha = VAlpha - Resolution;
          KnobVal = KnobVal + Resolution;
        }
      } else  if ( OldY < posy ) {
        if ( ( VAlpha +Resolution ) < 219 ) {
          VAlpha = VAlpha + Resolution;
          KnobVal = KnobVal - Resolution;
        }
      }

      // record position to decide what to do
      OldY = posy;

      // [GRAD] -> [RAD]
      VAlphaRad = (VAlpha * 2.0*Math.PI/360.0);

      // radius of the part with no pointer
      if ( pointerlength > 0 ) {
        r1 = r - pointerlength;
      }

      // Calculate the positions xr,r the marker koordinates at
      // the inner knob position if not centered
      if ( r1 > 0 ) {
        xr = xc + (Math.round((r1-2)*Math.cos(VAlphaRad)));
        yr = yc - (Math.round((r1-2)*Math.sin(VAlphaRad)));
        //alert ( xr + ' ' + yr );
      }

      // Calculate the positions xm,ym the marker koordinates at
      // the outer knob positions
      xm = xc + (Math.round((r-2)*Math.cos(VAlphaRad)));
      ym = yc - (Math.round((r-2)*Math.sin(VAlphaRad)));
      //alert( xm + '/' + ym );
      // draw the line
      canv.width = canv.width;
      KnobCanv.beginPath();
      KnobCanv.drawImage(BackgroundImg, 0, 0);
      KnobCanv.strokeStyle = Color;
      KnobCanv.lineWidth = LineWidth;
      if ( r1 > 0 ) {
        KnobCanv.moveTo(xr,yr);
      } else {
        KnobCanv.moveTo(xc, yc);
      }
      KnobCanv.lineTo(xm,ym);
      KnobCanv.stroke();
      KnobCanv.closePath();
      /*
      floating update means, every change of the meter knob
      is instantly propagated. therefore a lot of events are generated
      and may lead to slow updates in sophisticated  szenarios
      */
      if ( floatingUpdate == 1 ) {
        EventArgs = Cat + ' ' + CatNo + ' ' + ( KnobMin + (( KnobMax - KnobMin ) / 256 * KnobVal));
        // fire event
        OpenMSREvent.execute(EventArgs);
      }
    }
  }


  function sendKnobValue () {
    // this function is executed whenever the mousebutton is released
    // the we need to send the value
    // pack the event arguments in one string
    EventArgs = Cat + ' ' + CatNo + ' ' + ( KnobMin + (( KnobMax - KnobMin ) / 256 * KnobVal));
    // fire event
    OpenMSREvent.execute(EventArgs);
    KnobButton = false;
  }

  function KnobMouseDown () {
    // this function is executed whenever the mousebutton is pressed
    KnobButton = true;
  }

  // add eventhandler for mouse move and mouse up/down
  canv.onmousemove = changeState;
  canv.onmouseup = sendKnobValue;
  canv.onmousedown = KnobMouseDown;
}


// an LCD Display
var LCDisplay = function (CanvasName,Cat,CatNo) {

  // variables and constants.default values
  this.file_extension = 'jpg';                     // File extension: all files must have the same extension.
  this.DigitsNumber = 6;
  this.Decimals = 2;
  this.display_name = 'HC1331C';
  this.Convert = 1;
  this.ImagePath = '/images/';

  // --------------------------------------------------------------------------

  // set the Display Type
  // may be one off ITT5870S,ST12C,LT303,HD1131R,TDSG5160,HC1331C
  this.Display_Type = function (Name) {
    //alert(Name);
    this.display_name = Name;
  }

  // How much Digits the Display should have
  this.No_of_Digits = function (xx,yy) {
    this.DigitsNumber = xx;
    this.Decimals = yy;
  }

  // which function should be called to Convert the raw data to the display datat
  this.Convert = function(xx) {
    this.ConvertFactor = xx;
  }

  // set the Image Path
  this.setImagePath = function(xx) {
    this.ImagePath = xx;
  }


  // The main program starts here.
  var me = this;
  me.CanvasName = CanvasName;

  // --------------------------------------------------------------------------


  // Function to convert digits into file names and extensions.
  this.digit_name = function(number) {
    // Each display set is composed by 12 jpg files with digits between 0 and 9
    // plus a "dot" or "colon" on and off. File names example for the default
    // ITT5870S nixie tube:
    // "ITT5870S.0.jpg", "ITT5870S.1.jpg", "ITT5870S.2.jpg", "ITT5870S.3.jpg",
    // "ITT5870S.4.jpg", "ITT5870S.5.jpg", "ITT5870S.6.jpg", "ITT5870S.7.jpg",
    // "ITT5870S.8.jpg", "ITT5870S.9.jpg", "ITT5870S.doton.jpg",
    // "ITT5870S.dotoff.jpg"
    var num = Math.floor(number);

    // it's a number so load digit
    return me.ImagePath + me.display_name + '.' + num + '.' + me.file_extension;
  }



  // --------------------------------------------------------------------------
  // Function to convert colons into file names and extensions.
  this.colon_name = function (on) {
    if (on == 0)
      return me.ImagePath + me.display_name + '.dotoff.' + me.file_extension;
    else
      return me.ImagePath + me.display_name + '.doton.' + me.file_extension;
  }


  // --------------------------------------------------------------------------
  // Function to show characters like blank, E, r ....
  this.character = function (Char) {
    // handle blank, -, E, r
    if (Char == ' ' ) {
      // treat blank as special
      Char = 'blank';
    }
    return this.ImagePath + this.display_name + '.' + Char + '.' + this.file_extension;
  }

  // --------------------------------------------------------------------------
  this.HandleDisplayData = function  (EventArgs) {
    // split the event data in its elements
    EventArray = EventArgs.split(' ');
    // check wether the current event is for me
    if ( EventArray[0] == Cat) {
      if ( EventArray[1] == CatNo ) {
        // the event is for me, so display data
        currentVal = EventArray[2];
        //console.log(currentVal);
        //me.showLCD(currentVal);
        DebugLOG('running Display function! currentVal=' + currentVal);
        var digit_string = '';
				var Wert = 0;
				var WertString = '';
				// get the number to display
				// and convert if needed
				//if ( me.ConvertFactor != 1 ) {
        Wert = currentVal * me.ConvertFactor;
        //Wert = currentVal * 0.01;
        //console.log(Wert);
        //}

        DebugLOG('Display -> ' + me + ' Wert=' + Wert + ' Factor=' + me.ConvertFactor );
        WertString = Wert.toString();
        DebugLOG('running Display function! num_as_str=' + WertString);
				// format the string to wanted standard

				// no comma in string
				if ( WertString.indexOf('.') == -1 ) {
					// append a dot as comma
					WertString = WertString + '.';
					// append the number of wanted decimals
					for ( i=1; i <= me.Decimals ; i++ ) {
						WertString = WertString + '0';
					}
				}

				// wrong number of decimals, correct by appending zeros or truncating
				// calculate the number of decimals
				var CurrentDecimals = WertString.length - ( WertString.indexOf('.') + 1 );
				DebugLOG('CurrentDecimals=' + CurrentDecimals );
				if ( CurrentDecimals < me.Decimals ) {
					// String has not enough decimals -> append zero(s)
					for ( i=CurrentDecimals; i<me.Decimals; i++ ) {
						WertString = WertString + '0';
					}
				} else {
					DebugLOG('WertString=' + WertString );
					// correct number of decimals or too much decimals
					if ( CurrentDecimals > me.Decimals ) {
						// too much decimals -> truncate number
						var too_much_decimals = CurrentDecimals - me.Decimals;
						WertString = WertString.substring(0,WertString.length - too_much_decimals  );
					}
				}
				DebugLOG('WertString=' + WertString + ' CurrentDecimals=' + CurrentDecimals + ' 2muchDec=' + too_much_decimals);

				// negative numbers !!
				// think about what needs to be done


				// if string is too long, show err!!
				if ( WertString.length > me.DigitsNumber ) {
					WertString = 'Err.';
				}


				// if the string is too short prepend with blanks
				if ( WertString.length < me.DigitsNumber ) {
					//alert ('string too short');
					for ( i = WertString.length; i < me.DigitsNumber; i++ ) {
						WertString = ' ' + WertString;
					}
				}

				for ( i=0; i < me.DigitsNumber ; i++ ) {
					//document.getElementById("Print").value = digit_number;
					me.digit_string = me.CanvasName + i.toString();
					document.getElementById(me.digit_string).style.visibility = "visible";
					if ( WertString[i] == '.' ) {
						document.getElementById(me.digit_string).src = me.colon_name(1);
					} else {
						digit_number = parseInt(WertString[i]);
						if ( isNaN(digit_number) ) {
							document.getElementById(me.digit_string).src = me.character(WertString[i]);
						} else {
							document.getElementById(me.digit_string).src = me.digit_name(digit_number);    // Yes, change the digits
						}
					}
				}
				DebugLOG('Display ' + Cat + ' ' + CatNo + ' ' + currentVal + ' finished' );
			}
		}
	}

  // Finally we can start the display.
  OpenMSREvent.addHandler(me.HandleDisplayData);                       // Start the display Event Handler
  // --------------------------------------------------------------------------
}


// Datalogger ( LogicAnalyzer ) Display
var DataLogger = function ( CanvasName,Cat,CatNo) {
  var req=null;
  var Eingang=new Array();
  var Ausgang=new Array();
  var SwitchState=new Array();
  var ReloadEingangTimer;
  var LED_on=new Image();
  var LED_off=new Image();
  var power=new Array();
  // get handle for the canvas element
  var canv = document.getElementsByTagName("canvas")[0];
  var width = canv.width = 400;
  var height = canv.height = 100;
  var OldValue = new Array();
  Xcor = 0;
  Ycor = 0;
  // how much pixels space between the signals
  Padding = 6;
  // the width of a signalstep
  SignalBreite = 5;
  // the height of a signal
  SignalHoehe = 5;
  // the gap from top canvas to first signal
  Rand = 8;
  // Access to canvas
  var Scope = canv.getContext("2d");


  //Diese Funktion zeichnet das High eines Signals
  // als Linie auf dem Canvas
  function PrintHi(SignalNr) {
    if ( SignalNr == 0 ) {
      // start with row = 0 and next column
      Xcor = Xcor+SignalBreite;
      if (Xcor > width) {
        // we reached the end of the canvas, so delete canvas and start from beginning
        canv.width = 400;
        Xcor = 0;
      }
    }
    // just the next row in this column
    Ycor = SignalNr*10+Padding + Rand;
    Scope.beginPath();
    Scope.strokeStyle = "lightgreen";
    Scope.lineWidth = 1;
    if ( OldValue[SignalNr] == false ) {
      // Last value was low so we need a vertical line
      Scope.moveTo(Xcor, Ycor);
      Scope.lineTo(Xcor,Ycor-SignalHoehe);
    }
    Scope.moveTo(Xcor,Ycor-SignalHoehe);
    Scope.lineTo(Xcor+SignalBreite,Ycor-SignalHoehe);
    Scope.stroke();
    Scope.closePath();
    // STore last value for next run
    OldValue[SignalNr] = true;
  }


  //Diese Funktion zeichnet das Low eines Signals
  // als Linie auf dem Canvas
  function PrintLo(SignalNr) {
    if ( SignalNr == 0 ) {
      // start with row = 0 and next column
      Xcor = Xcor+SignalBreite;
      if (Xcor > width) {
        // we reached the end of the canvas, so delete canvas and start from beginning
        canv.width = 400;
        Xcor = 0;
      }
    }
    // just the next row in this column
    Ycor = SignalNr*10+Padding + Rand;
    Scope.beginPath();
    Scope.strokeStyle = "green";
    Scope.lineWidth = 1;
    if ( OldValue[SignalNr] == true ) {
      // Last value was low so we need a vertical line
      Scope.moveTo(Xcor, Ycor);
      Scope.lineTo(Xcor,Ycor-SignalHoehe);
    }
    Scope.moveTo(Xcor,Ycor);
    Scope.lineTo(Xcor+SignalBreite,Ycor);
    Scope.stroke();
    Scope.closePath();
    // STore last value for next run
    OldValue[SignalNr] = false;
  }

}
