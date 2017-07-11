<?php

// Devolo Homecontrol Query Tool
// (c) 2017 by Hartmut Eilers <hartmut@eilers.net>
// special thanks to github-user KiboOST for the PHP API

// configure here
$UUID="ABCE4FDF-0FDA-4F05-99E2-7BF9C784C7F2";
$GATEWAY="1407017270000351";
$LOCALPASSKEY="a5cec504a09baa890e48b48a9d014158";
$LOCALLOGIN = FALSE;

// fix me
$ROOT_DIR = "../../../divLibs/";

// user credentials as program parameters
$login = $argv[1];
$password = $argv[2];
// add possibility to provide hostinfo for stage selection
$DevoloStage = $argv[3];     // prod|beta

if ( count($argv) > 4 ) {
  $DEBUG = $argv[4];
} else {
  $DEBUG = 0;
}

// Load Devolo HC API
require($ROOT_DIR."/php-devoloDHC-master/class/phpDevoloAPI.php");
require($ROOT_DIR."/php-devoloDHC-master/localConnection/localphpdevoloAPI.php");

// append blanks to string to get defined length
function FixStr($short,$numchars)
{
  while ( strlen($short) < $numchars ) {
    $short = $short." ";
  }
  return $short;
}


// Login to Gateway or cloud
if ($LOCALLOGIN)
{
  // local login
  $DHC = new localDevoloDHC($login, $password, '10.63.9.236', $UUID, $GATEWAY, $LOCALPASSKEY, false);
  if (isset($DHC->_error)) echo "DHC error:".$DHC->_error;
  $auth = $DHC->getAuth();
  echo "<pre>".json_encode($auth, JSON_PRETTY_PRINT)."</pre><br>";
}
else {
  // login to cloud
  $DHC = new DevoloDHC($login, $password,true,0,$DevoloStage);
  if (isset($DHC->error)) echo $DHC->error;
}

//get all devices:
$devices[] = $DHC->getAllDevices();

if ($DEBUG == 1 ) { print_r($devices);}

//loop over the device and get their properties
foreach ( $devices[0]["result"] as $device )
{
  //print_r($device);
  $devicename=FixStr($device["name"],25);
  $deviceType=FixStr(str_replace("devolo.model.","",$device['model']),30);
  //echo $device['model'];
  // Fix Motionsensor unknown device
  if ( $device['model'] == 'devolo.model.Unknown:Device')
  {
      //echo "Icon=".$device['icon'];
    if ( $device['icon'] == 'icon_8' )
    {
      $deviceType=FixStr(str_replace("devolo.model.Unknown:Device","Motion:Sensor",$device['model']),30);
    }
    elseif ( $device['icon'] == 'wall-socket' )
    {
      $deviceType=FixStr(str_replace("devolo.model.Unknown:Device","Wall:Plug:Switch:and:Meter",$device['model']),30);
    }
  } // endFix

  print ($devicename.":\t(".$deviceType.")\t");


  foreach ($DHC->getDeviceStates($device["name"],FALSE)["result"] as $result) {

	  if ($DEBUG == 2 ) { print_r($result);}

      if ( $result["sensorType"] == "BinarySensor")
      {
        print(FixStr("BinarySensor: ",15).$result["state"]."\t");
      }
      elseif ($result["sensorType"] == "BinarySwitch")
      {
        print("BinarySwitch: ".$result["state"]."\t");
      }
	    elseif ( $result['sensorType'] == 'energy' )
      {
	      print("Power: ");
	      print("cur: ".$result['currentValue']."\t");
	      print("tot: ".$result['totalValue']."\t");
	    }
      elseif ($result["sensorType"] == "temperature")
      {
        print("Temp: ".$result["value"]."\t");
      }
      elseif ($result["sensorType"] == "light")
      {
        print("Light: ".$result["value"]);
      }
      elseif ($result['sensorType'] == "RemoteControl" )
      {
        print("Remote: "."Keys: ".$result['keyCount'].'  pressed: '.$result['keyPressed']);
      }
      elseif ($result['sensorType'] == "Power" )
      {
        print("Power: ".$result['value'].'   ');
      }
      elseif ($result['sensorType'] == "voltage" )
      {
        print("Spannung: ".$result['value'].'   ');
      }
      elseif ($result['sensorType'] == "warning" )
      {
        print("Warnung: ".$result['state'].'   ');
      }
      elseif ($result['sensorType'] == "door" )
      {
        print("Tür: ".$result['state'].'   ');
      }
      elseif ($result['sensorType'] == "MultiLevelSwitch" )
      {
        print("Type: : ".$result['switchType'].'  value: '.$result['value'].
        ' target: '.$result['targetValue'].' min/max: '.$result['min'].'/'.
        $result['max'].'   ');
      }
	    // ignore uninteresting values]
	    elseif (( $result["sensorType"] == "LastActivity" ) or ( $result["sensorType"] == "alarm" ))
      {
	      print("");
      }
	    // currently unknow devices properties -> dump them for investigation
	    else
      {
        print_r($result);
	    }
    }
    print("\n");
}
?>
