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

public class TFlipFlop extends ModularGate{
  static final long serialVersionUID = -9089850810127031969L;

  public TFlipFlop() {
    super();
    imagename="TFF";
    out[1]=true;
  }


  public void createModule() {
    Gate h  = new HIGH();
    Gate clk = new Dummy(getInput(0));
    Gate jk1 = new JKCFlipFlop(new Wire(h,0), new Wire(clk, 0), new Wire(h, 0));
    Gate not = new NOT(new Wire(clk,0 ));
    Gate jk2 = new JKCFlipFlop(new Wire(jk1,0), new Wire(not, 0), new Wire(jk1, 1));

    gates.addGate(h);
    gates.addGate(clk);
    gates.addGate(jk1);
    gates.addGate(not);
    gates.addGate(jk2);


    // Eingang 0 dieses Moduls auf Eingang 0 des Gatters clk setzen
    inputGates.setElementAt(clk, 0);
    inputNums.setElementAt(new Integer(0), 0);

    // Ausgang 0 dieses Moduls auf Ausgang 0 des Gatters jk2 setzen
    outputGates.setElementAt(jk2, 0);
    outputNums.setElementAt(new Integer(0), 0);
    // Ausgang 1 dieses Moduls auf Ausgang 1 des Gatters jk2 setzen
    outputGates.setElementAt(jk2, 1);
    outputNums.setElementAt(new Integer(1), 1);
  }

  public int getNumInput() {
    return 1;
  }
  public int getNumOutput() {
    return 2;
  }

  public boolean isOutputPositive(int n) {
    return (n==0);
  }
}