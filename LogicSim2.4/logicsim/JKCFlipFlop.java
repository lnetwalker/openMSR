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

  /* positiv-taktflankengesteuertes JK FilpFlop */

public class JKCFlipFlop extends Gate {
  static final long serialVersionUID = -5614329713407328370L;

  transient boolean lastStateOfC;
  transient boolean clk;
  transient boolean out0;
  transient boolean out1;
  
  public JKCFlipFlop() {
    super();
    imagename="JKCFF";
    //loadImage();
    out[1]=true;
    out1=true;
  }


  /**
   * Wenn der Konstruktor Wire-Parameter enthaelt, wird kein image geladen, weil
   * dieses Gatter dann innerhalb eines Moduls verwendet wird.
   */
  public JKCFlipFlop(Wire w1, Wire w2, Wire w3) {
    super(w1,w2,w3);
    out[1]=true;
    out1= true;
    clk=false;
  }


  public int getNumInput() {
    return 3;
  }
  public int getNumOutput() {
    return 2;
  }

//  public void simulate() {
//    if (getInput(0)!=null && getInputState(0)==true &&
//        lastStateOfC==false && getInput(1)!=null && getInputState(1)==true && getOutput(1)==true) {
//      out[0]=true;
//      out[1]=false;
//    } else
//    if (getInput(2)!=null && getInputState(2)==true &&
//        lastStateOfC==false && getInput(1)!=null && getInputState(1)==true && getOutput(0)==true) {
//      out[0]=false;
//      out[1]=true;
//    }
//    if (getInput(1)!=null) lastStateOfC=getInputState(1);
//  }

  
  public void simulate() {

	  if (clk) {
	      out[0]=out0;
	      out[1]=out1;
	      clk=false;
	  }
  }
  
  public void clock () {
	    if (getInput(0)!=null && getInputState(0)==true &&
		        lastStateOfC==false && getInput(1)!=null && getInputState(1)==true && getOutput(1)==true) {
		      out0=true;
		      out1=false;
		      clk=true;
		    } else
		    if (getInput(2)!=null && getInputState(2)==true &&
		        lastStateOfC==false && getInput(1)!=null && getInputState(1)==true && getOutput(0)==true) {
		      out0=false;
		      out1=true;
		      clk=true;
		    }
	    if (getInput(1)!=null) lastStateOfC=getInputState(1);
		    
		    
  }
  
  public boolean isOutputPositive(int n) {
    return (n==0);
  }
  
  public void reset() {
      out[0]=false;
      out[1]=true;
      out0=false;
      out1=true;
      lastStateOfC=true;
      clk=false;
  }
}
