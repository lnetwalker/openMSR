package logicsim;

import java.awt.*;
import javax.swing.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class DLatch extends Gate {
  static final long serialVersionUID = -3038268922756642547L;

  transient boolean lastStateOfC;  
  
  public DLatch() {
    super();
    imagename="DLatch";
    out[0]=false;
    out[1]=true;
  }

  public void simulate() {
    if (getInput(0)!=null && getInput(1)!=null) {
        if ( getInputState(1)) {
            out[0]=getInputState(0);
            out[1]=!out[0];
        }
        lastStateOfC=getInputState(1);
    }
  }

  public int getNumInput() {
    return 2;
  }
  
  public int getNumOutput() {
    return 2;
  }

  public boolean isOutputPositive(int n) {
    return (n==0);
  }
  
  public void reset() {
      out[0]=false;
      out[1]=true;
      lastStateOfC=false;      
  }
}