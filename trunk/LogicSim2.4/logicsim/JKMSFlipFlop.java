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

public class JKMSFlipFlop extends ModularGate{
  static final long serialVersionUID = 6562388223937836948L;

  public JKMSFlipFlop() {
    super();
    imagename="JKMSFF";
    //loadImage();
    out[1]=true;
  }


  public void createModule() {
    Gate clk = new Dummy(getInput(1));
    Gate jk1 = new JKCFlipFlop(getInput(0), new Wire(clk, 0), getInput(2));
    Gate not = new NOT(new Wire(clk,0 ));
    Gate jk2 = new JKCFlipFlop(new Wire(jk1,0), new Wire(not, 0), new Wire(jk1, 1));

    gates.addGate(clk);
    gates.addGate(jk1);
    gates.addGate(not);
    gates.addGate(jk2);


    // Eingang 0 dieses Moduls auf Eingang 0 des Gatters jk1 setzen
    inputGates.setElementAt(jk1, 0);
    inputNums.setElementAt(new Integer(0), 0);
    // Eingang 1 dieses Moduls auf Eingang 0 des Gatters clk setzen
    inputGates.setElementAt(clk, 1);
    inputNums.setElementAt(new Integer(0), 1);
    // Eingang 2 dieses Moduls auf Eingang 2 des Gatters jk1 setzen
    inputGates.setElementAt(jk1, 2);
    inputNums.setElementAt(new Integer(2), 2);


    // Ausgang 0 dieses Moduls auf Ausgang 0 des Gatters jk2 setzen
    outputGates.setElementAt(jk2, 0);
    outputNums.setElementAt(new Integer(0), 0);
    // Ausgang 1 dieses Moduls auf Ausgang 1 des Gatters jk2 setzen
    outputGates.setElementAt(jk2, 1);
    outputNums.setElementAt(new Integer(1), 1);
  }

  public int getNumInput() {
    return 3;
  }
  public int getNumOutput() {
    return 2;
  }

  public boolean isOutputPositive(int n) {
    return (n==0);
  }
  
}