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

public class DFlipFlop extends ModularGate{
  static final long serialVersionUID = -3038268922756642547L;
  
  transient Gate jk; 

  public DFlipFlop() {
    super();
    imagename="DFF";
    out[1]=true;
  }


  public void createModule() {
    Gate d = new Dummy(getInput(0));
    Gate clk = new Dummy(getInput(1));
    //Gate and1 = new AND(new Wire(d, 0), new Wire(clk,0));
    Gate not = new NOT(new Wire(d,0));
    //Gate and2 = new AND(new Wire(clk, 0), new Wire(not, 0));
    //Gate rs = new RSFlipFlop();
    Gate jk = new JKCFlipFlop ();
    this.jk = jk;
    //rs.setInput(0, new Wire(and1, 0));
    //rs.setInput(1, new Wire(and2, 0));

    jk.setInput(2, new Wire(not, 0));
    jk.setInput(0, new Wire(d, 0));
    jk.setInput(1, new Wire(clk, 0));
    
    gates.addGate(d);
    gates.addGate(clk);
    //gates.addGate(and1);
    gates.addGate(not);
    //gates.addGate(and2);
    gates.addGate(jk);
   
    // Eingang 0 dieses Moduls auf Eingang 0 des Gatters d setzen
    inputGates.setElementAt(d, 0);
    inputNums.setElementAt(new Integer(0), 0);
    // Eingang 1 dieses Moduls auf Eingang 0 des Gatters clk setzen
    inputGates.setElementAt(clk, 1);
    inputNums.setElementAt(new Integer(0), 1);

    // Ausgang 0 dieses Moduls auf Ausgang 0 des Gatters rs setzen
    outputGates.setElementAt(jk, 0);
    outputNums.setElementAt(new Integer(0), 0);
    // Ausgang 1 dieses Moduls auf Ausgang 1 des Gatters rs setzen
    outputGates.setElementAt(jk, 1);
    outputNums.setElementAt(new Integer(1), 1);
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
      //out[0]=true;
	 this.jk.reset();
  }
}