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

public class OR extends Gate{
  static final long serialVersionUID = 9924257307317498L;

  public OR() {
    super();
    imagename="OR";
    //loadImage();
  }
  public OR(Wire w1, Wire w2) {
    super(w1,w2);
  }

  public OR(int n) {
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
    boolean b=false;
    for (int i=0; i<getNumInput(); i++) {
      if (getInput(i)==null) {
          out[0]=true;  // HIGH wenn ein Eingang nicht angeschlossen ist
          return;
      }
      b=b || getInputState(i);
    }
    out[0]=b;
  }
}