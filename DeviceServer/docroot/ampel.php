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
	background:url(images/ampel.png);
	position: absolute;
	left: 50px;
	top: 50px;
	width: 370;
	height: 358;
      }
      #debug {
	position: absolute;
	top: 420;
	left: 50px;
      }

    </style>

    <script type="text/javascript" src="js/openmsr.js"></script>
	<?php
		system("./run_sps ../sps/awls/strampel.sps",$return_value);
		if ($return_value == 0) 
			echo "run_sps startet<br>";
		else
			echo "check for running run_sps !!!";
	?>
    <script>
      function init() {
		  

	OpenMSRInit();

	var ObRt = new Lamp('ObRt','digital',21);
	ObRt.offimg('images/AmpelRotAus.jpg');
	ObRt.onimg('images/AmpelRotAn.jpg');
	ObRt.width(11);
	ObRt.height(9);

	var ObGe = new Lamp('ObGe','digital',22);
	ObGe.offimg('images/AmpelGelbAus.jpg');
	ObGe.onimg('images/AmpelGelbAn.jpg');
	ObGe.width(11);
	ObGe.height(9);

	var ObGr = new Lamp('ObGr','digital',23);
	ObGr.offimg('images/AmpelGruenAus.jpg');
	ObGr.onimg('images/AmpelGruenAn.jpg');
	ObGr.width(11);
	ObGr.height(9);

	var UnRt = new Lamp('UnRt','digital',21);
	UnRt.offimg('images/AmpelRotAus.jpg');
	UnRt.onimg('images/AmpelRotAn.jpg');
	UnRt.width(11);
	UnRt.height(9);

	var UnGe = new Lamp('UnGe','digital',22);
	UnGe.offimg('images/AmpelGelbAus.jpg');
	UnGe.onimg('images/AmpelGelbAn.jpg');
	UnGe.width(11);
	UnGe.height(9);

	var UnGr = new Lamp('UnGr','digital',23);
	UnGr.offimg('images/AmpelGruenAus.jpg');
	UnGr.onimg('images/AmpelGruenAn.jpg');
	UnGr.width(11);
	UnGr.height(9);

	var LiRt = new Lamp('LiRt','digital',24);
	LiRt.offimg('images/AmpelRotAus.jpg');
	LiRt.onimg('images/AmpelRotAn.jpg');
	LiRt.width(11);
	LiRt.height(9);

	var LiGe = new Lamp('LiGe','digital',25);
	LiGe.offimg('images/AmpelGelbAus.jpg');
	LiGe.onimg('images/AmpelGelbAn.jpg');
	LiGe.width(11);
	LiGe.height(9);

	var LiGr = new Lamp('LiGr','digital',26);
	LiGr.offimg('images/AmpelGruenAus.jpg');
	LiGr.onimg('images/AmpelGruenAn.jpg');
	LiGr.width(11);
	LiGr.height(9);

	var ReRt = new Lamp('ReRt','digital',24);
	ReRt.offimg('images/AmpelRotAus.jpg');
	ReRt.onimg('images/AmpelRotAn.jpg');
	ReRt.width(11);
	ReRt.height(9);

	var ReGe = new Lamp('ReGe','digital',25);
	ReGe.offimg('images/AmpelGelbAus.jpg');
	ReGe.onimg('images/AmpelGelbAn.jpg');
	ReGe.width(11);
	ReGe.height(9);

	var ReGr = new Lamp('ReGr','digital',26);
	ReGr.offimg('images/AmpelGruenAus.jpg');
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
	MyIOReader.TimerVal(720);
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
	SwitchIOSender.TimerVal(600);
	SwitchIOSender.AssignEvent(1,1);
	SwitchIOSender.AssignEvent(2,2);
	SwitchIOSender.DeviceServerURL('http://localhost:10080/digital/WriteInputValues.html');
	SwitchIOSender.IOGroup(4);
}
</script>

  </head>
  <body bgcolor=white >
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

	<!--<textarea id=debug cols=120 rows=10></textarea>-->
	<script type="text/javascript">
	  init();
	</script>
  </body>
</html>