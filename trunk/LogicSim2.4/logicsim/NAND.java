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

public class NAND extends Gate{
  static final long serialVersionUID = -8148143070926953439L;

  public NAND() {
    super();
    imagename="AND";
   // loadImage();
  }
  public NAND(Wire w1, Wire w2) {
    super(w1,w2);
  }

  public NAND(int n) {
    this();
    numInput=n;
  }

  public int getNumInput() {
    if (numInput>0)
      return numInput;
    else
      return 2;
  }
  public int getNumOutput() {
    return 1;
  }

  public void simulate() {
    boolean b=true;
    int n=0;
    for (int i=0; i<getNumInput(); i++) {
      if (getInput(i)==null) continue;
      b=b && getInputState(i);
      n++;
    }
    //if (n==0) b=true;
    out[0]=!b;
  }

  public boolean isOutputPositive(int n) {
    return false;
  }
}