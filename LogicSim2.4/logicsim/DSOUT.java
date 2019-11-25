package logicsim;

import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.*;
import java.net.*;
import java.io.*;

/**
 * Title:        LogicSim
 * Module:	 DSOUT.java ( based on LCD.java )
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2010
 * Company:
 * @author Hartmut Eilers
 * @version 0.1
 */

/* Binary output: wie BININ, aber mit Einstellungen */

public class DSOUT extends Gate{
  static final long serialVersionUID = -6532037559895208921L;
  String DSOUT_URL = "";

  transient Image digits;
  // here we need to set display to hex
  int displayType=0;  // 0=HEX  1=DEC

  public DSOUT() {
    super();
    imagename="DSOUT";
  }

  public int getNumInput() {
    return 8;
  }
  public int getNumOutput() {
    return 0;
  }

  public void simulate() {    
    // write to the DeviceServer here

    // get the output values and make a dezimal
    int value=0;

    for (int i=0; i<8; i++) {
      if (getInput(i)!=null && getInputState(i))
        value+=(1<<i);
    }

    String res="";

    try {
      URL u = new URL(DSOUT_URL + Integer.toString(value));
      URLConnection uc = u.openConnection();
      uc.setDoOutput(true);
      uc.setRequestProperty("Content-Type","application/x-www-form-urlencoded");
      uc.addRequestProperty("User-Agent", "Mozilla LogicSim");
      // add the query string
      // For example: String query = "username=joe&pw=secret";

      // append the value to the URL
      String query = "";
      PrintWriter pw = new PrintWriter(uc.getOutputStream());
      pw.println(query);
      pw.close();

      // get the input from the request
      BufferedReader in = new BufferedReader(
      new InputStreamReader(uc.getInputStream()));
      String line;
      while ( (line = in.readLine()) != null) {
        res = res + line;
      }
      in.close();
    } catch ( IOException uc ) {
      System.err.println("Error writing DeviceServer");
    }
  }

  public void draw(Graphics g) {
    if (onimage==null || gateimage==null) loadImage();
    if (digits==null)
      digits=new ImageIcon(logicsim.LSFrame.class.getResource("images/LCDdigits.gif")).getImage();

    super.draw(g);

    int value=0;

    for (int i=0; i<8; i++) {
      if (getInput(i)!=null && getInputState(i))
        value+=(1<<i);
    }

    int offset=0, offset1=0, offset2=0;
    String sval = "";
    if (displayType==1)
      sval=Integer.toString(value);
    else
      sval=Integer.toHexString(value);

    if (sval.length()==0)
      sval="00";
    if (sval.length()==1)
      sval="0" + sval;

    for (int i=0; i<=1; i++) {
      switch (sval.charAt(i)) {
        case '0' : offset=0; break;
        case '1' : offset=15; break;
        case '2' : offset=30; break;
        case '3' : offset=45; break;
        case '4' : offset=60; break;
        case '5' : offset=75; break;
        case '6' : offset=90; break;
        case '7' : offset=105; break;
        case '8' : offset=120; break;
        case '9' : offset=135; break;
        case 'a' : offset=150; break;
        case 'b' : offset=165; break;
        case 'c' : offset=180; break;
        case 'd' : offset=195; break;
        case 'e' : offset=210; break;
        case 'f' : offset=225; break;
      }
      if (i==0) offset1=offset;
      if (i==1) offset2=offset;
    }

    g.setClip(x+5+5,y+24,15,30);
    g.drawImage(digits, x+5+5-offset1, y+24, null);
    g.setClip(x+20+5,y+24,15,30);
    g.drawImage(digits, x+20+5-offset2, y+24, null);
    g.setClip(0,0,Integer.MAX_VALUE,Integer.MAX_VALUE);
  }

  public boolean hasProperties() {
      return true;
  }

  public boolean showProperties(Component frame) {
    // fetch the URL of the deviceserver
    if ( DSOUT_URL.length()==0 )
      DSOUT_URL="http://";

    DSOUT_URL = (String)JOptionPane.showInputDialog(frame, I18N.getString("MESSAGE_DSOUT_WRITEURL"), "Device Server URL",
                                                   JOptionPane.QUESTION_MESSAGE, null,null, DSOUT_URL );
    return true;
  }

}
