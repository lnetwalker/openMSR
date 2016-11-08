package logicsim;

import java.awt.*;
import java.io.*;
import javax.swing.*;
import java.util.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */



public class CLK extends Gate {
  static final long serialVersionUID = 3971572931629721831L;

  transient long lastTime;
  long highTime=1000;
  long lowTime=1000;

  public CLK() {
    super();
    imagename="clock";
    //loadImage();
  }


  /**
   * Wenn der Konstruktor Wire-Parameter enthaelt, wird kein image geladen, weil
   * dieses Gatter dann innerhalb eines Moduls verwendet wird.
   */
  public CLK(Wire w1) {
    super(w1);
  }


  public int getNumInput() {
    return 0;
  }
  public int getNumOutput() {
    return 1;
  }

  public void simulate() {
    if (lastTime==0)
      lastTime=new Date().getTime();

    if (out[0]==false && new Date().getTime() - lastTime > lowTime) {
      out[0]=true;
      lastTime=new Date().getTime();
    }
    if (out[0]==true && new Date().getTime() - lastTime > highTime) {
      out[0]=false;
      lastTime=new Date().getTime();
    }
  }

  public boolean hasProperties() {
      return true;
  }
  
  public boolean showProperties(Component frame) {
    String h = (String)JOptionPane.showInputDialog(frame, I18N.getString("MESSAGE_ENTER_TIME_HIGH"), "LogicSim",
                                                   JOptionPane.QUESTION_MESSAGE, null,null, Integer.toString((int)highTime));
    if (h!=null && h.length()>0) highTime=new Integer(h).intValue();
    h = (String)JOptionPane.showInputDialog(frame, I18N.getString("MESSAGE_ENTER_TIME_LOW"), "LogicSim",
                                            JOptionPane.QUESTION_MESSAGE, null,null, Integer.toString((int)lowTime));
    if (h!=null && h.length()>0) lowTime=new Integer(h).intValue();
    return true;
  }

}