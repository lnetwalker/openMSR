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

/*  Ausgangsgatter fuer Modul.
    Wird beim Erstellen eines Moduls angelegt.
    Ausgaenge des Moduls werden daran angeschlossen.

*/

public class MODOUT extends Gate {
  static final long serialVersionUID = 1824440628969344103L;

  public MODOUT() {
    super();
    imagename="output";
    //loadImage();
  }


  public int getNumInput() {
    return 16;
  }
  public int getNumOutput() {
    return 16;
  }


  public boolean getOutput(int n) {
    if (getInput(n)!=null)
      return getInputState(n);
    else
      return false;
  }

  

}
