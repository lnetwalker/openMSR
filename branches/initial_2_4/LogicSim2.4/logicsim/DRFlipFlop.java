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

public class DRFlipFlop extends ModularGate{
  static final long serialVersionUID = -8717671986526504937L;
  
  transient Gate jk; 

  public DRFlipFlop() {
    super();
    imagename="DRFF";
    out[1]=true;
  }


  public void createModule() {
    Gate d = new Dummy(getInput(0));
    Gate clk = new Dummy(getInput(1));
    Gate r = new Dummy(getInput(2));
    //Gate and1 = new AND(new Wire(d, 0), new Wire(clk,0));
    Gate not2 = new NOT(new Wire(d,0));

    //Gate and2 = new AND(new Wire(clk, 0), new Wire(not, 0));
    //Gate rs = new RSFlipFlop();
    Gate jk = new JKCFlipFlop ();
    this.jk = jk;
    //rs.setInput(0, new Wire(and1, 0));
    //rs.setInput(1, new Wire(and2, 0));

    jk.setInput(2, new Wire(not2, 0));
    jk.setInput(0, new Wire(d, 0));
    jk.setInput(1, new Wire(clk, 0));
    
    gates.addGate(d);
    gates.addGate(clk);
    gates.addGate(r);
    //gates.addGate(and1);
    gates.addGate(not2);  
    //gates.addGate(and2);
    gates.addGate(jk);
    

    // Eingang 0 dieses Moduls auf Eingang 0 des Gatters d setzen
    inputGates.setElementAt(d, 0);
    inputNums.setElementAt(new Integer(0), 0);
    // Eingang 1 dieses Moduls auf Eingang 0 des Gatters clk setzen
    inputGates.setElementAt(clk, 1);
    inputNums.setElementAt(new Integer(0), 1);
    // Eingang 2 dieses Moduls auf Eingang 0 des Gatters r setzen
    inputGates.setElementAt(r, 2);
    inputNums.setElementAt(new Integer(0), 2);

    // Ausgang 0 dieses Moduls auf Ausgang 0 des Gatters rs setzen
    outputGates.setElementAt(jk, 0);
    outputNums.setElementAt(new Integer(0), 0);
    // Ausgang 1 dieses Moduls auf Ausgang 1 des Gatters rs setzen
    outputGates.setElementAt(jk, 1);
    outputNums.setElementAt(new Integer(1), 1);
    
    
  }

  public int getNumInput() {
    return 3;
  }
  public int getNumOutput() {
    return 2;
  }

  public void simulate() {
	  super.simulate();
	  if (getInputState(2)) {
		  	this.jk.reset();
	  }
  }

  public boolean isOutputPositive(int n) {
    return (n==0);
  }
  
  public void reset() {
      //out[0]=true;
	 this.jk.reset();
  }
}