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



public class OnDelay extends Gate {
  static final long serialVersionUID = -2350098633141393951L;

  transient long startTime;
  transient boolean lastInputState;
  long delayTime=1000;

  public OnDelay() {
    super();
    imagename="ondelay";
  }


  public int getNumInput() {
    return 1;
  }
  public int getNumOutput() {
    return 1;
  }

  public void simulate() {
    if (lastInputState==false && getInput(0)!=null && getInputState(0)) { // positive flanke
      startTime=new Date().getTime();
    }

    if (new Date().getTime() - startTime > delayTime && getInput(0)!=null && getInputState(0))
      out[0]=true;

    if (getInput(0)==null || getInputState(0)==false)
      out[0]=false;

    if (getInput(0)!=null) lastInputState=getInputState(0);
  }

  public boolean hasProperties() {
      return true;
  }
  
  public boolean showProperties(Component frame) {
    String h = (String)JOptionPane.showInputDialog(frame, I18N.getString("GATE_TURNONDELAY_TIME"), I18N.getString("GATE_TURNONDELAY"),
                                                    JOptionPane.QUESTION_MESSAGE, null,null, Integer.toString((int)delayTime));
    if (h!=null && h.length()>0) delayTime=new Integer(h).intValue();
    return true;
  }

}