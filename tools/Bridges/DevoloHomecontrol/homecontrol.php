<?php

// Devolo Homecontrol Bridge for OpenMSR
// (c) 2017 by Hartmut Eilers <hartmut@eilers.net>
// special thanks to github user KiboOST for the PHP API

// configure here

// fix me
$ROOT_DIR = $_SERVER['DOCUMENT_ROOT'] || "../../../divLibs/";
$ROOT_DIR = "../../../divLibs/";

// user credentials as program parameters
$login = $argv[1];
$password = $argv[2];
// add possibility to provide hostinfo for stage selection
$DevoloStage = $argv[3];     // prod|beta
//beta: $_authUrl = 'https://dc-beta.devolo.net';
//      $_dhcUrl =  'https://hc-beta.devolo.net';

// end of configure

require($ROOT_DIR."/php-devoloDHC-master/class/phpDevoloAPI.php");
require('../../../DeviceServer/Lib/DeviceServer.php');

// add the possibility to add Devolo Cloud URL ( = $DevoloHost ) to DevoloDHC
$DHC = new DevoloDHC($login, $password,true,0,$DevoloStage);
if (isset($DHC->error)) echo $DHC->error;

//get some infos on your Devolo Home Control box:
echo "__infos__<br>";
$infos = $DHC->getInfos();
echo "<pre>".json_encode($infos['result'], JSON_PRETTY_PRINT)."</pre><br>";

//get all batteries level under 20% (ommit argument to have all batteries levels):
$BatLevels = $DHC->getAllBatteries();
echo "<pre>Batteries Levels:<br>".json_encode($BatLevels['result'], JSON_PRETTY_PRINT)."</pre><br>";

//You can first ask without data, it will return all available sensors datas for this device:
$data = $DHC->getDeviceStates('Bewegung Ess-/Wohnzimmer');
echo "<pre>sensordata Bewegung Ess-/Wohnzimmer:<br>".json_encode($data, JSON_PRETTY_PRINT)."</pre><br>";

//get all devices:
$zone = $DHC->getAllDevices();
echo "<pre>Devices:<br>".json_encode($zone, JSON_PRETTY_PRINT)."</pre><br>";

// get device data from Motion2
$data = $DHC->getDeviceData('Motion2','temperature');
echo "<pre>devicedata Motion2:<br>".json_encode($data, JSON_PRETTY_PRINT)."</pre><br>";

echo "\nTemperatue Motion2: ".json_encode($data["result"]["value"]).'\n';

//get daily diary, last number of events:
$diary = $DHC->getDailyDiary();
echo "<pre>diary:<br>".json_encode($diary['result'], JSON_PRETTY_PRINT)."</pre><br>";

$stats = $DHC->getDailyStat('Bewegung Ess-/Wohnzimmer', 0);
echo "<pre>statistics Bewegung Ess-/Wohnzimmer:<br>".json_encode($stats['result'], JSON_PRETTY_PRINT)."</pre><br>";

echo "\n";
// end of homecontrol.php
?>
