package logicsim;

import java.awt.*;
import java.io.*;
import javax.swing.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class AND extends Gate {
  static final long serialVersionUID = 4521959944440523564L;

  public AND() {
    super();
    imagename="AND";
    //loadImage();
  }

  public AND(int n) {
    this();
    numInput=n;
  }

  /**
   * Wenn der Konstruktor Wire-Parameter enthaelt, wird kein image geladen, weil
   * dieses Gatter dann innerhalb eines Moduls verwendet wird.
   */
  public AND(Wire w1, Wire w2) {
    super(w1,w2);
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
    //if (n==0) b=true;  // nothing connected
    out[0]=b;
  }
}