<?php

// PHP Lib for easy openMSR DeviceServer access
// (c) 2017 by Hartmut Eilers <hartmut@eilers.net>
// released under the terms of the GNU GPL V2 or later

class DeviceServer{

  // private things...

  protected $_curlHdl = null;

  protected function _request( $host, $path)  //standard function handling all get/post request with curl | return string
  {
      if (!isset($this->_curlHdl))
      {
          $this->_curlHdl = curl_init();
          curl_setopt($this->_curlHdl, CURLOPT_SSL_VERIFYHOST, false);
          curl_setopt($this->_curlHdl, CURLOPT_SSL_VERIFYPEER, false);

          curl_setopt($this->_curlHdl, CURLOPT_RETURNTRANSFER, true);
          curl_setopt($this->_curlHdl, CURLOPT_FOLLOWLOCATION, true);

          curl_setopt($this->_curlHdl, CURLOPT_REFERER, 'http://www.openmsr.org/');
          curl_setopt($this->_curlHdl, CURLOPT_USERAGENT, 'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:51.0) Gecko/20100101 Firefox/51.0 openMSR_phpAPI');

          curl_setopt($this->_curlHdl, CURLOPT_ENCODING , "gzip");
      }

      $url = filter_var($host.$path, FILTER_SANITIZE_URL);

      curl_setopt($this->_curlHdl, CURLOPT_URL, $url);
      // GET request
      curl_setopt($this->_curlHdl, CURLOPT_POST, false);

      $response = curl_exec($this->_curlHdl);

      //$info   = curl_getinfo($this->_curlHdl);
      //echo "<pre>cURL info".json_encode($info, JSON_PRETTY_PRINT)."</pre><br>";

      $this->error = null;
      if($response === false) $this->error = curl_error($this->_curlHdl);
      return $response;
  }

// public stuff
public $ServerURL = 'http://localhost:10080/';

public function SetServerURL($URL)
{
  if ( isset($URL))
  {
    $this->ServerURL = $URL;
  }
}

public function ReadInputValues($iogroup)
{
    $path = '/digital/ReadInputValues.html?'.$iogroup;
    $response = $this->_request($ServerURL,$path);
    return $response;
}

public function ReadOuputValues($iogroup)
{
    $path = '/digital/ReadOuputValues.html?'.$iogroup;
    $response = $this->_request($ServerURL,$path);
    return $response;
}

}
?>
