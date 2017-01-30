package logicsim;

import java.util.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */


 /**
  * Base class for modular gates that consist of basic gates.
  * Has own GateList with basic Gates that form this gate.
  */
public abstract class ModularGate extends Gate{
  static final long serialVersionUID = 1632712342754364805L;

  transient GateList gates;  // Gatter des Moduls nicht mit abspeichern, die werden nach dem Laden neu erzeugt

  Vector inputGates;  // die Gatter, die an den Eingang dieses Moduls angeschlossen sind
  Vector inputNums;  // die jeweilige Nummer des Eingangs der inputGates
  Vector outputGates;  // die Gatter, die die Ausgangswerte fuer dieses Modul bilden
  Vector outputNums; // die jeweilige Nummer des Ausgangs der outputGates

  public ModularGate() {
    super();
    gates=new GateList();

    inputGates=new Vector(16);
    for (int i=0; i<16; i++)
      inputGates.addElement(null);
    inputNums=new Vector(16);
    for (int i=0; i<16; i++)
      inputNums.addElement(new Integer(0));
    outputGates=new Vector(16);
    for (int i=0; i<16; i++)
      outputGates.addElement(null);
    outputNums=new Vector(16);
    for (int i=0; i<16; i++)
      outputNums.addElement(new Integer(0));

    createModule();
  }

  public void createModule() {
  }

  public void simulate() {
    // inputTypes der inputGates auf den entsprechenden inputType des ModularGate setzen
    for (int i=0; i<inputGates.size(); i++) {
      Gate g=(Gate)inputGates.get(i);
      if (g==null) continue;
      Integer in=(Integer)inputNums.get(i);

      g.inputTypes[in.intValue()]=inputTypes[i];
    }

    if (gates==null) {  // nach dem Laden neu initialisieren
      gates=new GateList();
      createModule();
    }
    gates.simulate();
  }

  /**
   * getOutput Methode der Gate Klasse ueberschreiben, weil beim Modul die Ausgangswerte von den outputGates abgefragt werden,
   * statt aus dem out Array
   */
  public boolean getOutput(int n) {
    Gate g=(Gate)outputGates.get(n);
    Integer on=(Integer)outputNums.get(n);
    if (g!=null)
      return g.getOutput(on.intValue());
    else
      return false;
  }

  public void setInput(int n, Wire w) {

    Gate g=(Gate)inputGates.get(n);
    if (g==null) return;
    Integer in=(Integer)inputNums.get(n);
    g.setInput(in.intValue(), w);

    // Eingang n dieses Moduls auf neues Wire w setzen
    super.setInput(n,w);
  }

  public void reset() {

      for (int i=0; i<gates.size(); i++) {
          Gate g=(Gate)gates.get(i);
          if (g!=null) g.reset();
      }
  }
}
