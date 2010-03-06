package logicsim;

import java.util.*;
import java.io.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class GateList implements Serializable {
  static final long serialVersionUID = 3458986578856078326L;

  Vector gates;

  public GateList() {
    gates=new Vector();
  }

  public void addGate(Gate g) {
    gates.addElement(g);
  }

  public int size() {
    return gates.size();
  }

  public void clear() {
    gates.clear();
  }

  public void remove(int n) {
    gates.remove(n);

    /* Wire Objekte suchen und l�schen, die an ein Gate angeschlossen sind, dass
       nicht in der Liste ist. */
    for (int i=0; i<size(); i++) {
      Gate g = get(i);
      for (int j=0; j<g.getNumInput() && g.getInput(j)!=null; j++) {
        if (gates.contains(g.getInput(j).gate)==false) {
          g.setInput(j, null);
        }
      }
    }

  }

  public Gate get(int n) {
    return (Gate)gates.get(n);
  }

  public void simulate() {
    for (int j=0; j<2; j++) {
      for (int i=0; i<gates.size(); i++) {
        Gate g = (Gate)gates.get(i);
        g.simulate();
      }
    }
    for (int i=0; i<gates.size(); i++) {
        Gate g = (Gate)gates.get(i);
        g.clock();
      }
  }

  /**
   * Nach dem Laden m�ssen in allen Wire Objekten die Gatter, an die sie
   * angeschlossen sind, neu gesetzt werden, weil diese nicht mit abgespeichert
   * werden (Rekursion, weil alle Gatter ja schon �ber die Liste gespeichert wurden).
   * Dazu wird versucht, den jeweils ersten Punkt des Wire-Polygons mittels
   * tryConnectOutput() an ein Gatter anzuschliessen, weil dieser erste Punkt
   * genau auf dem Ausgang ein Gatters liegen muss.
   */
  public void reconnect() {
    for (int i=0; i<size(); i++) {
      Gate g=(Gate)gates.get(i);
      
      //for (int j=0; j<g.getNumInput(); j++) {  // Geändert, damit Module mit 16 Eingängen funktionieren
      for (int j=0; j<16; j++) {
        Wire w=g.getInput(j);
        if (w!=null) {
          for (int k=0; k<size(); k++) {
            Gate ng=(Gate)gates.get(k);
            Wire nw = ng.tryConnectOutput(w.poly.xpoints[0], w.poly.ypoints[0]);
            if (nw!=null) {
              w.gate=nw.gate;
              w.outNum=nw.outNum;
            }
          }
        }
      }
    }

    // f�r alle Module Objekte loadModule() Funktion aufrufen
    for (int i=0; i<size(); i++) {
      Gate g=get(i);
      if (g instanceof Module) {
        Module m=(Module)g;
        m.loadModule();
      }
    }
  }

  // Alle Gatter und zugeh�rige Wires deaktivieren
  public void deactivateAll() {
    for (int i=0; i<gates.size(); i++) {
      Gate g=(Gate)gates.get(i);
      g.deactivate();
      for (int j=0; j<g.getNumInput(); j++) {
        if (g.getInput(j)!=null)
          g.getInput(j).deactivate();
      }
    }
  }

  public void printInfo() {
    for (int i=0; i<size(); i++) {
      Gate g=(Gate)get(i);
      g.printInfo();
    }
  }
  
  public void reloadImages() {
      // alle Gate-Bilder neu laden, nachdem das Design umgestellt wurde
      for (int i=0; i<gates.size(); i++) {
          Gate g=(Gate)gates.get(i);
          g.loadImage();
      }
  }

}