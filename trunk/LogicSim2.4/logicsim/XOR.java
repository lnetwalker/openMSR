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

public class XOR extends Gate{
  static final long serialVersionUID = -1264218321757869967L;

  public XOR() {
    super();
    imagename="XOR";
    //loadImage();
  }
  public XOR(Wire w1, Wire w2) {
    super(w1,w2);
  }

  public XOR(int n) {
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
    int n=0;
    for (int i=0; i<getNumInput() && getInput(i)!=null; i++)
      if (getInputState(i)) n++;
    out[0] = (n % 2 > 0);  //ungerade ??

  }
}