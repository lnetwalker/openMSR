/* 
    this JavaScript library provides different
    elements to use with OpenMSR
    Copyright (c) 2010 by Hartmut Eilers
    <hartmut@eilers.net>
    released under the GNU GPL V 2.0 or later
    
    Project start 17.08.2010
    
    { $Id$ }
    
*/    


/*  
    custom events for communication between
    the different elements of this lib
*/    
function Event(){
    this.eventHandlers = new Array();
}

Event.prototype.addHandler = function(eventHandler){
    this.eventHandlers.push(eventHandler);
}

Event.prototype.execute = function(args){
    for(var i = 0; i < this.eventHandlers.length; i++){
	this.eventHandlers[i](args);
	//alert('Event triggered' + args);
    }
}

function EventInit() {
    OpenMSREvent = new Event();
}
// end of events

// the meter is an instrument to show analog values
function HorMeter (CanvasName) {
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
    var ImgSrc = 'images/lampe.gif';
    // setup the background image
    var HorMeterCanv = canv.getContext("2d");
    var BackgroundImg = new Image();
    BackgroundImg.src = ImgSrc;
    BackgroundImg.onload = function() {
    	HorMeterCanv.beginPath();
	HorMeterCanv.drawImage(BackgroundImg, 0, 0);
	HorMeterCanv.closePath();
    };

    var Resltn=10;
    
    // print a custom background image
    this.canvbgimg = function(imagename) {
	BackgroundImg.src = imagename;
	// redraw the canvas
	canv.height = canv.height;
    }
        
    // get the maximum Value for the meter
    this.maxVal = function(xx) {
	MaxHorMeterVal = xx;
    }

    // get the minimum Value for the meter
    this.minVal = function(xx) {
	MinHorMeterVal = xx;
    }

    // get the maximum Value Position for the meter
    this.maxPos = function(xx,yy) {
	MaxPosX = xx;
	MaxPosY = yy;
    }

    // get the minimum Value Position for the meter
    this.minPos = function(xx,yy) {
	MinPosX = xx;
	MinPosY = yy;
    }

    // get the color for the meter
    this.color = function(xx) {
	Color = xx;
    }

    // get the minimum Value Position for the meter
    this.MeterWidth = function(xx) {
	LineWidth = xx;
    }

    // get the Resolution for the meter
    this.Resolution = function(xx) {
	Resltn = xx;
    }

    // use the Value for the meter
    // and display everything
    this.currentValue = function(xx) {
	ValX = parseInt( Resltn * ( xx - MinHorMeterVal ) * ((MaxPosX-MinPosX) / ((MaxHorMeterVal - MinHorMeterVal) * Resltn)) +  MinPosX);
	//document.write(ValX ,' ', MinPosX ,' ', MaxPosX ,' ', xx,' ',MaxHorMeterVal,' ',MinHorMeterVal,' ',(MaxPosX-MinPosX) / ((MaxHorMeterVal - MinHorMeterVal)*10));
	HorMeterCanv.beginPath();
	HorMeterCanv.strokeStyle = Color;
	// delete canvas
	HorMeterCanv.lineWidth = LineWidth;
	// paint the meter
	HorMeterCanv.moveTo(MinPosX, MinPosY);
	HorMeterCanv.lineTo(ValX,MaxPosY);
	HorMeterCanv.stroke();
	HorMeterCanv.closePath();
    }

}


// digital switch
function Switch(CanvasName,Cat,CatNo) {
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
    var ImgSrcOff = 'images/switch-off.png';
    var ImgSrcOn  = 'images/switch-on.png';
    // setup the background image
    var SwitchCanv = canv.getContext("2d");
    var BackgroundImg = new Image();
    BackgroundImg.src = ImgSrcOff;
    BackgroundImg.onload = function() {
	canv.width = canv.width;
	SwitchCanv.beginPath();
	SwitchCanv.drawImage(BackgroundImg, 0, 0);
	SwitchCanv.closePath();   
    }


// print a custom background image
    this.offimg = function(imagename) {
	ImgSrcOff = imagename;
    }


// print a custom background image
    this.onimg = function(imagename) {
	ImgSrcOn = imagename;
    }
    
    var state = 0;    
    var Resltn=10;
    var state=1;


    // This is called when you release the mouse button.
    function changeState() {
      //alert("State: "+ state ); 
      if ( state == 1 ) {
	state = 0
	BackgroundImg.src = ImgSrcOff;
      } else {
	state = 1
	BackgroundImg.src = ImgSrcOn;
      }
      // display actual state
      canv.width = canv.width;
      SwitchCanv.beginPath();
      SwitchCanv.drawImage(BackgroundImg, 0, 0);
      SwitchCanv.closePath();
      // pack the event arguments in one string
      EventArgs = Cat + ' ' + CatNo + ' ' + state;
      // fire event
      OpenMSREvent.execute(EventArgs);
    };


    // add eventhandler for mouse click
    canv.onclick = changeState;

}


// this function show the logic state with pictures
// can be LED like or any other pictures
function Lamp(CanvasName,Cat,CatNo) {
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
    var ImgSrcOff = 'images/led-green-off.jpg';
    var ImgSrcOn  = 'images/led-green-on.jpg';
    // setup the background image
    var LampCanv = canv.getContext("2d");
    var BackgroundImg = new Image();
    BackgroundImg.src = ImgSrcOff;
    BackgroundImg.onload = function() {
	canv.width = canv.width;
	LampCanv.beginPath();
	LampCanv.drawImage(BackgroundImg, 0, 0);
	LampCanv.closePath();   
    }
    
    var state = 0;    
    var Resltn=10;
    var state=0;

// print a custom background image
    this.offimg = function(imagename) {
	ImgSrcOff = imagename;
    }


// print a custom background image
    this.onimg = function(imagename) {
	ImgSrcOn = imagename;
    }
   
    function HandleLampState (EventArgs) {
	// split the event data in its elements
	EventArray = EventArgs.split(' ');
	// check wether the current event is for me
	if ( EventArray[0] == Cat) {
	    if ( EventArray[1] == CatNo ) {
		// the event is for me, so display data
		if ( EventArray[2] == 1 ) {
		    BackgroundImg.src = ImgSrcOn;
		} else {
		    BackgroundImg.src = ImgSrcOff;
		}
		canv.width = canv.width;
		LampCanv.beginPath();
		LampCanv.drawImage(BackgroundImg, 0, 0);
		LampCanv.closePath();
	    }
	}
    }

    // install Event Handler
    OpenMSREvent.addHandler(HandleLampState);
}