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

public class NOT extends Gate{
  static final long serialVersionUID = 3351085067064933298L;

  public NOT() {
    super();
    imagename="NOT";
    //loadImage();
  }
  public NOT(Wire w1) {
    super(w1);
  }

  public int getNumInput() {
    return 1;
  }
  public int getNumOutput() {
    return 1;
  }


  public boolean getOutput(int n) {
    if (n>=0 && n<getNumOutput() && getInput(0)!=null)
      return !getInputState(0);
    else
      return false;
  }

  public boolean isOutputPositive(int n) {
    return false;
  }
  
  public void reset() {
      out[0]=true;
  }
}