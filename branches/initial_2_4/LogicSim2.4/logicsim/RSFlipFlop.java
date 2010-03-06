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

public class RSFlipFlop extends ModularGate{
  static final long serialVersionUID = 1049162074522360589L;

  public RSFlipFlop() {
    super();
    imagename="RSFF";
    //loadImage();
    out[1]=true;
  }


  public void createModule() {
    Gate not1 = new NOT(getInput(0));
    Gate not2 = new NOT(getInput(1));
    Gate n1 = new NAND();
    Gate n2 = new NAND();

    n1.setInput(0, new Wire(not1,0));
    n2.setInput(0, new Wire(not2,0));
    n1.setInput(1, new Wire(n2, 0));
    n2.setInput(1, new Wire(n1, 0));

    gates.addGate(not1);
    gates.addGate(not2);
    gates.addGate(n2);
    gates.addGate(n1);

    // Eingang 0 dieses Moduls auf Eingang 0 des Gatters not1 setzen
    inputGates.setElementAt(not1, 0);
    inputNums.setElementAt(new Integer(0), 0);
    // Eingang 1 dieses Moduls auf Eingang 0 des Gatters not2 setzen
    inputGates.setElementAt(not2, 1);
    inputNums.setElementAt(new Integer(0), 1);


    // Ausgang 0 dieses Moduls auf Ausgang 0 des Gatters n1 setzen
    outputGates.setElementAt(n1, 0);
    outputNums.setElementAt(new Integer(0), 0);
    // Ausgang 1 dieses Moduls auf Ausgang 0 des Gatters n2 setzen
    outputGates.setElementAt(n2, 1);
    outputNums.setElementAt(new Integer(0), 1);
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
}