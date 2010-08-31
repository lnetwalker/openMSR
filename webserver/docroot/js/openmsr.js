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
function HorMeter (CanvasName,Cat,CatNo) {
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

    // get the width for the meter gauge
    this.MeterWidth = function(xx) {
	LineWidth = xx;
    }

    // get the Resolution for the meter
    this.Resolution = function(xx) {
	Resltn = xx;
    }

    // use the Value for the meter
    // and display everything
    function currentValue (EventArgs) {
	// split the event data in its elements
	var EventArray = EventArgs.split(' ');
	// check wether the current event is for me
	if ( EventArray[0] == Cat) {
	    if ( EventArray[1] == CatNo ) {
		// the event is for me, so display data
		CurVal = EventArray[2];
		//alert (' Event received: ' + Cat + ' ' + CatNo + ' ' + CurVal);
		ValX = parseInt( Resltn * ( CurVal - MinHorMeterVal ) * ((MaxPosX-MinPosX) / ((MaxHorMeterVal - MinHorMeterVal) * Resltn)) +  MinPosX);
		//document.write(ValX ,' ', MinPosX ,' ', MaxPosX ,' ', xx,' ',MaxHorMeterVal,' ',MinHorMeterVal,' ',(MaxPosX-MinPosX) / ((MaxHorMeterVal - MinHorMeterVal)*10));
		// delete canvas
		canv.height = canv.height;
		HorMeterCanv.beginPath();
		HorMeterCanv.drawImage(BackgroundImg, 0, 0);
		HorMeterCanv.strokeStyle = Color;
		HorMeterCanv.lineWidth = LineWidth;
		// paint the meter
		HorMeterCanv.moveTo(MinPosX, MinPosY);
		HorMeterCanv.lineTo(ValX,MaxPosY);
		HorMeterCanv.stroke();
		HorMeterCanv.closePath();
	    }
	}
    }

    // install Event Handler
    OpenMSREvent.addHandler(currentValue);

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
	KnobCanv.moveTo(xc, yc);
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
