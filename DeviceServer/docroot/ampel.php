<html>
  <head>
    <title>Ampel Simulation</title>
    <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">

    <META HTTP-EQUIV="Pragma" CONTENT="no-cache">
    <META HTTP-EQUIV="Expires" CONTENT="-1">
    <link rel="shortcut icon" type="image/x-icon" href="images/ampel.ico">

    <style type="text/css">
      #ObGr {
      	position: absolute;
      	left: 135px;
      	top: 140px;
      	width: 10px;
      	height: 10px;
      }
      #ObGe {
      	position: absolute;
      	left: 135px;
      	top: 152px;
      	width: 10px;
      	height: 10px;
      }
      #ObRt {
      	position: absolute;
      	left: 135px;
      	top: 165px;
      	width: 10px;
      	height: 10px;
      }
      #UnGr {
      	position: absolute;
      	left: 310px;
      	top: 335px;
      	width: 10px;
      	height: 10px;
      }
      #UnGe {
      	position: absolute;
      	left: 310px;
      	top: 322px;
      	width: 10px;
      	height: 10px;
      }
      #UnRt {
      	position: absolute;
      	left: 310px;
      	top: 310px;
      	width: 10px;
      	height: 10px;
      }
      #LiGr {
      	position: absolute;
      	left: 110px;
      	top: 310px;
      	width: 10px;
      	height: 10px;
      }
      #LiGe {
      	position: absolute;
      	left: 123px;
      	top: 310px;
      	width: 10px;
      	height: 10px;
      }
      #LiRt {
      	position: absolute;
      	left: 136px;
      	top: 310px;
      	width: 10px;
      	height: 10px;
      }
      #ReGr {
      	position: absolute;
      	left: 335px;
      	top: 162px;
      	width: 10px;
      	height: 10px;
      }
      #ReGe {
      	position: absolute;
      	left: 322px;
      	top: 162px;
      	width: 10px;
      	height: 10px;
      }
      #ReRt {
      	position: absolute;
      	left: 310px;
      	top: 162px;
      	width: 10px;
      	height: 10px;
      }
      #Switch1 {
      	background-color: white;
      	position: absolute;
      	left: 300px;
      	top: 360px;
      }
      #Switch2 {
      	background-color: white;
      	position: absolute;
      	left: 340px;
      	top: 360px;
      }
      #Ampel {
	       background:url(images/ampel-neu.png);
	       position: absolute;
	       left: 50px;
	       top: 50px;
	       width: 370;
	       height: 358;
      }
      #debug {
	       position: absolute;
	       top: 30px;
	       left: 0px;
      }
      #label1 {
        position: absolute;
        top:370px;
        left:-140px;
      }
      #label2 {
        position: absolute;
        top:370px;
        left:-100px;
      }
      #label3 {
        position: absolute;
        top:45px;
        left:450px;
      }
      #Hostname{
        position: absolute;
        top:45px;
        left:450px;
      }
      #debugging{
        position: absolute;
        top:440px;
        left:50px;
      }
      #AutoBlau {
      	position: absolute;
      	left: -400px;
      	top: 200px;
      	width: 360px;
      	height: 50px;
      }
      #AutoBlauDrives {
      	position: absolute;
      	left: -390px;
      	top: 200px;
      	width: 360px;
      	height: 50px;
      }
      #AutoRed {
      	position: absolute;
      	left: -400px;
      	top: 200px;
      	width: 360px;
      	height: 50px;
      }
      #AutoRedDrives {
      	position: absolute;
      	left: -390px;
      	top: 200px;
      	width: 360px;
      	height: 50px;
      }

    </style>

    <script type="text/javascript" src="js/openmsr.js"></script>
   <script>
      function init() {


	OpenMSRInit();

  var ObRt = new Lamp('ObRt','digital',21);
	ObRt.offimg('images/AmpelRotAus.png');
	ObRt.onimg('images/AmpelRotAn.jpg');
	ObRt.width(11);
	ObRt.height(9);

	var ObGe = new Lamp('ObGe','digital',22);
	ObGe.offimg('images/AmpelGelbAus.png');
	ObGe.onimg('images/AmpelGelbAn.jpg');
	ObGe.width(11);
	ObGe.height(9);

	var ObGr = new Lamp('ObGr','digital',23);
	ObGr.offimg('images/AmpelGruenAus.png');
	ObGr.onimg('images/AmpelGruenAn.jpg');
	ObGr.width(11);
	ObGr.height(9);

	var UnRt = new Lamp('UnRt','digital',21);
	UnRt.offimg('images/AmpelRotAus.png');
	UnRt.onimg('images/AmpelRotAn.jpg');
	UnRt.width(11);
	UnRt.height(9);

	var UnGe = new Lamp('UnGe','digital',22);
	UnGe.offimg('images/AmpelGelbAus.png');
	UnGe.onimg('images/AmpelGelbAn.jpg');
	UnGe.width(11);
	UnGe.height(9);

	var UnGr = new Lamp('UnGr','digital',23);
	UnGr.offimg('images/AmpelGruenAus.png');
	UnGr.onimg('images/AmpelGruenAn.jpg');
	UnGr.width(11);
	UnGr.height(9);

	var LiRt = new Lamp('LiRt','digital',24);
	LiRt.offimg('images/AmpelRotAus.png');
	LiRt.onimg('images/AmpelRotAn.jpg');
	LiRt.width(11);
	LiRt.height(9);

	var LiGe = new Lamp('LiGe','digital',25);
	LiGe.offimg('images/AmpelGelbAus.png');
	LiGe.onimg('images/AmpelGelbAn.jpg');
	LiGe.width(11);
	LiGe.height(9);

	var LiGr = new Lamp('LiGr','digital',26);
	LiGr.offimg('images/AmpelGruenAus.png');
	LiGr.onimg('images/AmpelGruenAn.jpg');
	LiGr.width(11);
	LiGr.height(9);

	var ReRt = new Lamp('ReRt','digital',24);
	ReRt.offimg('images/AmpelRotAus.png');
	ReRt.onimg('images/AmpelRotAn.jpg');
	ReRt.width(11);
	ReRt.height(9);

	var ReGe = new Lamp('ReGe','digital',25);
	ReGe.offimg('images/AmpelGelbAus.png');
	ReGe.onimg('images/AmpelGelbAn.jpg');
	ReGe.width(11);
	ReGe.height(9);

	var ReGr = new Lamp('ReGr','digital',26);
	ReGr.offimg('images/AmpelGruenAus.png');
	ReGr.onimg('images/AmpelGruenAn.jpg');
	ReGr.width(11);
	ReGr.height(9);

	// some switches
	var MySwitch1 = new Switch('Switch1','digital',1);
	//MySwitch1.offimg('images/button_off.jpg');
	//MySwitch1.onimg('images/button_on.jpg');
	MySwitch1.width(40);
	MySwitch1.height(40);

	var MySwitch2 = new Switch('Switch2','digital',2);
	MySwitch2.width(40);
	MySwitch2.height(40);

	// second reader for iogroup 4
	var MyIOReader = new DigitalDataReader();
	MyIOReader.TimerVal(200);
	MyIOReader.AssignEvent(1,21);
	MyIOReader.AssignEvent(2,22);
	MyIOReader.AssignEvent(3,23);
	MyIOReader.AssignEvent(4,24);
	MyIOReader.AssignEvent(5,25);
	MyIOReader.AssignEvent(6,26);
	MyIOReader.AssignEvent(7,27);
	MyIOReader.AssignEvent(8,28);
	MyIOReader.DeviceServerURL('http://localhost:10080/digital/ReadOutputValues.html');
	MyIOReader.IOGroup(4);

	// the digital data feeder to send the switches to app iogroup
	var SwitchIOSender = new DigitalDataSender();
	SwitchIOSender.TimerVal(200);
	SwitchIOSender.AssignEvent(1,1);
	SwitchIOSender.AssignEvent(2,2);
	SwitchIOSender.DeviceServerURL('http://localhost:10080/digital/WriteInputValues.html');
	SwitchIOSender.IOGroup(4);

  var stateGreenBlue=function(){
    if ( LiGr.BackgroundImg.src == 'http://localhost:10080/images/AmpelGruenAn.jpg' ) {
      document.getElementById('AutoBlauDrives').style.display = "block"
      document.getElementById('AutoBlau').style.display = "none"
    }
    else {
      document.getElementById('AutoBlauDrives').style.display = "none"
      document.getElementById('AutoBlau').style.display = "block"
    }
  }

  stateGreenInterval=setInterval(stateGreenBlue,150);

  var stateGreenRed=function(){
    if ( UnGr.BackgroundImg.src == 'http://localhost:10080/images/AmpelGruenAn.jpg' ) {
      document.getElementById('AutoRedDrives').style.display = "block"
      document.getElementById('AutoRed').style.display = "none"
    }
    else {
      document.getElementById('AutoRedDrives').style.display = "none"
      document.getElementById('AutoRed').style.display = "block"
    }
  }

  stateGreenInterval=setInterval(stateGreenRed,150);
}
</script>

  </head>


  <body bgcolor=white >
	<?php
		//exec("ps ax|grep strampel.sps|grep run_sps|wc -l",$output,$return_value);
    //print_r($return_value);
		if ($output[0] == "2") {
      //print_r ($output);
			echo "run_sps l&auml;uft<br>";
    }
		else
			echo "starten Sie: run_sps -d -f awls/strampel.sps -c strampel.cfg im Verzeichnis sps<br>";

	?>
	<script type="text/javascript">
    var ProcessOutput = " <?php echo str_replace("\"","",json_encode($output)) ?> ";
    //alert(ProcessOutput);
    DebugLOG(ProcessOutput);
 </script>

	Eine einfache Ampelanlage:<br>
	<canvas id="Ampel"></canvas>
	<canvas id="Switch1"></canvas>
	<canvas id="Switch2"></canvas>
	<canvas id="ObGr"></canvas>
	<canvas id="ObGe"></canvas>
	<canvas id="ObRt"></canvas>
	<canvas id="UnGr"></canvas>
	<canvas id="UnGe"></canvas>
	<canvas id="UnRt"></canvas>
	<canvas id="LiGr"></canvas>
	<canvas id="LiGe"></canvas>
	<canvas id="LiRt"></canvas>
	<canvas id="ReGr"></canvas>
	<canvas id="ReGe"></canvas>
	<canvas id="ReRt"></canvas>

  <script type="text/javascript">
    function DebugWindowToggle() {
      var x = document.getElementById("debug");
      if (x.style.display === "none") {
        x.style.display = "block";
      } else {
        x.style.display = "none";
      }
    }
  </script>

	<div id="debugging">
	Debug Window:<button onclick="DebugWindowToggle()">On/Off</button><br>
	<textarea id=debug cols=120 rows=10></textarea>
	</div>

	<script type="text/javascript">
	  init();
	</script>
  <form>
	  <div id="label3">
		<font color=black>Server:Port=<input type=text value='http://localhost:10080' size=25><br>
		<br>
		S1 schaltet die Ampelanlage in Achtung d.h. alle Richtungen blinken Gelb<br>
		S2 schaltet den regul&auml;ren Ampelbetrieb ein
  </form>
  <div id="label1">S1</div>
  <div id="label2">S2</div>

  <!-- show the blue car -->
  <img id="AutoBlau" src="images/Blau01.png">
  <img id="AutoBlauDrives" src="images/Blau-drives.png" style=”display:none” >
  <!-- show the red car -->
  <img id="AutoRed" src="images/Rot01.png">
  <img id="AutoRedDrives" src="images/Rot-drives.png" style=”display:none” >
  </body>
</html>
