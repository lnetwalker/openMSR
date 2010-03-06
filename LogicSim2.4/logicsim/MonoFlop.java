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



public class MonoFlop extends Gate {
  static final long serialVersionUID = -6063406618533983926L;

  transient long startTime;
  transient boolean lastInputState;
  long highTime=1000;

  public MonoFlop() {
    super();
    imagename="monoflop";
  }


  public int getNumInput() {
    return 1;
  }
  public int getNumOutput() {
    return 1;
  }

  public void simulate() {
    if (lastInputState==false && getInput(0)!=null && getInputState(0)) { // positive flanke
      out[0]=true;
      startTime=new Date().getTime();
    }

    if (new Date().getTime() - startTime > highTime)
      out[0]=false;

    if (getInput(0)!=null) lastInputState=getInputState(0);
  }
  
  public boolean hasProperties() {
      return true;
  }  

  public boolean showProperties(Component frame) {
    String h = (String)JOptionPane.showInputDialog(frame, I18N.getString("MESSAGE_ENTER_TIME_HIGH"), I18N.getString("GATE_MONOFLOP_PROPERTIES"),
                                                    JOptionPane.QUESTION_MESSAGE, null,null, Integer.toString((int)highTime));
    if (h!=null && h.length()>0) highTime=new Integer(h).intValue();
    return true;
  }

}