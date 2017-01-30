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
 *
 *
 * @todo alle Konstruktoren mit Parametern bei dieser und Unterklassen entfernen (nur zum Test)
 *
 * 2006-07-02: Anschluesse auf 16 erweitert
 */

import java.util.Vector;

 /**
  * Base class for all classes in Gates directory
  */
public abstract class Gate implements Serializable {
  static final long serialVersionUID = -6775454761569297690L;

  static final int INTYPE_NORMAL = 0;
  static final int INTYPE_NEGATIVE = 1;
  static final int INTYPE_HIGH = 2;
  static final int INTYPE_LOW = 3;

  String imagename;
  String onimagename;
  transient Image gateimage;
  transient Image onimage;
  int gateimagewidth;
  int gateimageheight;
  public int x;
  public int y;

  transient boolean active;


  Vector in;  // enthaelt fuer jeden Eingang ein Wire Objekt
  boolean[] out = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };
  int[] inputTypes = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
  int numInput;

  public Gate() {
    in=new Vector(16);
    for (int i=0; i<16; i++)
      in.addElement(null);
    active=true;
  }
  public Gate(Wire w) {
    this();
    in.setElementAt(w, 0);
  }
  public Gate(Wire w1, Wire w2) {
    this();
    in.setElementAt(w1, 0);
    in.setElementAt(w2, 1);
  }
  public Gate(Wire w1, Wire w2, Wire w3) {
    this();
    in.setElementAt(w1, 0);
    in.setElementAt(w2, 1);
    in.setElementAt(w3, 2);
  }
  public Gate(int n) {
    this();
    numInput=n;
  }

  public final void activate() {
    active=true;
  }
  public final void deactivate() {
    active=false;
  }


  public void simulate() {
  }
  public void clock() {
  }
  
  public boolean getOutput(int n) {
  //if (in.get(1)!=null) System.out.println(this.toString() + " " + getNumInput() + " " + in.get(1).toString());
    if (n>=0 && n<getNumOutput())
      return out[n];
    else
      return false;
  }

  public void setOutput(boolean s) {
  }

  public int getNumInput() {
    return 0;
  }

  public int getNumOutput() {
    return 0;
  }

  public void setInput(int n, Wire w) {
    if (n>=0 && n<getNumInput()) {
      in.setElementAt(w, n);
      if (inputTypes[n]==INTYPE_HIGH || inputTypes[n]==INTYPE_LOW)
        inputTypes[n]=INTYPE_NORMAL;
    }
  }


  public final Wire getInput(int n) {
    // Workaround, damit alte Module geladen werden koennen, die nur 8 Eingaenge haben.
    // Eingaenge auf 16 auffuellen
    if (in.size()<16) {
      for (int i=in.size(); i<=16; i++) {
        in.addElement(null);
      }
      int[] d = new int[16];
      for (int i=0; i<16; i++) {
          if (i<=inputTypes.length-1) 
              d[i]=inputTypes[i];
          else
              d[i]=0;
      }
      inputTypes=d;
    }
    
    
      
    Wire w=(Wire)in.get(n);
    if (w==null && inputTypes[n]!=INTYPE_NORMAL) return new Wire(null,0);
    return w;
  }

  public boolean getInputState(int n) {
    if (inputTypes[n]==INTYPE_NORMAL && getInput(n)!=null)
      return getInput(n).getState();  // normal input
    else if (inputTypes[n]==INTYPE_NEGATIVE && getInput(n)!=null)
      return !getInput(n).getState();  // input negator
    else if (inputTypes[n]==INTYPE_HIGH)
      return true;  // input high
    else if (inputTypes[n]==INTYPE_LOW)
      return false;  // input low
    else
      return false;
  }

  public void loadImage() {
    String path="images/din/";
    if (LSFrame.gatedesign.equals("iso"))
        path="images/iso/";
    gateimage=new ImageIcon(logicsim.LSFrame.class.getResource(path + imagename + ".gif")).getImage();
    if (onimagename!=null)
      onimage=new ImageIcon(logicsim.LSFrame.class.getResource(path + onimagename + ".gif")).getImage();

    if (gateimage!=null) {
      gateimagewidth=gateimage.getWidth(null);
      gateimageheight=gateimage.getHeight(null);
    }
  }

  public void draw(Graphics g) {
    if (gateimage==null) loadImage(); // wenn Image noch nicht geladen wurde, wird es hier geladen, z.b. wenn dieses Gatter deserialisiert wurde

    g.setColor(Color.black);
    g.drawImage(gateimage, x+3, y, null);
    for (int i=0; i<getNumInput(); i++) {
      int cy=getInputPosition(i);
      if (inputTypes[i]==INTYPE_NEGATIVE)
        g.drawOval(x-1,y+cy-2, 4, 4);
      else if (inputTypes[i]==INTYPE_HIGH)
        g.drawString("1", x-4, y+cy+4);
      else if (inputTypes[i]==INTYPE_LOW)
        g.drawString("0", x-4, y+cy+4);
      else
        g.drawLine(x, y+cy, x+3, y+cy);
    }
    for (int i=0; i<getNumOutput(); i++) {
      int cy=getOutputPosition(i);
      int w=gateimage.getWidth(null);
      if (isOutputPositive(i))
        g.drawLine(x+w+3, y+cy, x+w+6, y+cy);
      else
        g.drawOval(x+w+3, y+cy-2, 4, 4);
    }

    if (active) {
      g.setColor(Color.blue);
      g.drawLine(x-5, y-5, x-5, y);
      g.drawLine(x-5, y-5, x, y-5);
      g.drawLine(x+gateimagewidth+3, y-5, x+gateimagewidth+3+5, y-5);
      g.drawLine(x+gateimagewidth+3+5, y-5, x+gateimagewidth+3+5, y);
      g.drawLine(x+gateimagewidth+3+5, y+gateimageheight, x+gateimagewidth+3+5, y+gateimageheight+5);
      g.drawLine(x+gateimagewidth+3, y+gateimageheight+5, x+gateimagewidth+3+5, y+gateimageheight+5);
      g.drawLine(x-5, y+gateimageheight+5, x, y+gateimageheight+5);
      g.drawLine(x-5, y+gateimageheight, x-5, y+gateimageheight+5);
      g.setColor(Color.black);
    }


    for (int j=0; j<getNumInput(); j++) {
      Wire w=(Wire)in.get(j);
      if (w!=null) w.draw(g);
    }
  }

  public final Wire tryConnectOutput(int mx, int my) {
    for (int i=0; i<getNumOutput(); i++) {
      if (mx>x+gateimagewidth+6-5 && mx<x+gateimagewidth+6+5 && my>y+getOutputPosition(i)-4 && my<y+getOutputPosition(i)+4) {
        Wire w = new Wire(this, i);
        w.addPoint(x+gateimagewidth+6, y+getOutputPosition(i));
        return w;
      }
    }
    return null;
  }

  public final boolean tryConnectInput(int mx, int my, Wire w) {
    if (w==null) return false;
    for (int i=0; i<getNumInput(); i++) {
      if (mx>x-5 && mx<x+5 && my>y+getInputPosition(i)-4 && my<y+getInputPosition(i)+4) {
        this.setInput(i,w);
        w.addPoint(x, y+getInputPosition(i));
        return true;
      }
    }
    return false;
  }

  public final boolean trySetInputType(int mx, int my, int type) {
    for (int i=0; i<getNumInput(); i++) {
      if (mx>x-5 && mx<x+5 && my>y+getInputPosition(i)-4 && my<y+getInputPosition(i)+4) {
        if (type==INTYPE_HIGH || type==INTYPE_LOW) setInput(i,null);
        inputTypes[i]=type;
        return true;
      }
    }
    return false;
  }


  /** wird aufgerufen, wenn auf das Gatter geklickt wird, z.B. fuer Switch */
  public void clicked(int mx, int my) {
  }

  /** wird aufgerufen, wenn auf das Gatter die Maus ueber dem Gatter losgelassen wird, z.Buer Switch */
  public void mouseReleased() {
  }
  
  
  /**
   * True zurueckgeben, wenn Gatter Einstellungen hat.
   * Wird benutzt, damit bei Gattern ohne Einstellungen der Punkt "Properties" im Context-Menue ausgblendet wird
   */
  public boolean hasProperties() {
      return false;
  }
  /** ueber Context-Menue aufgerufen */
  public boolean showProperties(Component frame) {
    return false;
  }

  /** true, wenn Koordinaten mx,my innerhalb des Gatters liegen */
  public final boolean inside(int mx, int my) {
   return new Rectangle(x,y,gateimagewidth,gateimageheight).contains(mx,my);
  }

  /**
   * gibt die y Pixelposition des Ausgangs n zurueck
   */
  public int getOutputPosition(int n) {
    return getConnectorPosition(n, getNumOutput());
  }
  /**
   * gibt die y Pixelposition des Eingangs n zurueck
   */
  public int getInputPosition(int n) {
    return getConnectorPosition(n, getNumInput());
  }


  public int getConnectorPosition(int n, int total) {
    if (total==0) return -1;
    if (total==1) return 25;
    if (total==2) {
      switch(n) {
        case 0 : return 5;
        case 1 : return 45;
      }
    }
    if (total==3) {
      switch(n) {
        case 0 : return 5;
        case 1 : return 25;
        case 2 : return 45;
      }
    }
    if (total==4) {
      switch(n) {
        case 0 : return 5;
        case 1 : return 15;
        case 2 : return 35;
        case 3 : return 45;
      }
    }
    if (total==5) {
      switch(n) {
        case 0 : return 5;
        case 1 : return 15;
        case 2 : return 25;
        case 3 : return 35;
        case 4 : return 45;
      }
    }
    if (total>=6) {
      return 5+n*10;
    }        

    return -1;

  }


  /**
   * Gibt true zurueck, wenn Ausgang n positiv ist.
   * Ist der Ausgang n negativ (false), muss in der draw() Methode ein Kreis an
   * den Ausgang gemalt werden
   */
  public boolean isOutputPositive(int n) {
    return true;
  }


  public void moveTo(int mx, int my, GateList gates) {
    x=mx-20;
    y=my-25;
      // Mauszeiger beim Verschieben in der Mitte das Gatters platzierenup
    //x=mx-(int)((gateimagewidth/2)/5)*5;    
    //y=my-(int)((gateimageheight/2)/5)*5+5;

    // jeweils letzten Punkt der Wires am Eingang auf neue Position setzen
    for (int i=0; i<getNumInput(); i++) {
      Wire w=getInput(i);
      if (w!=null)
        w.setLastPoint(x, y+getInputPosition(i));
    }

    // in GateList nach Wire suchen, welches an dieses Gatter angeschlossen ist und dessen
    // ersten Punkt auf neue Position setzen
    for (int i=0; i<gates.size(); i++) {
      Gate g=gates.get(i);
      for (int j=0; j<g.getNumInput(); j++) {
        Wire w=g.getInput(j);
        if (w!=null && w.gate==this)
          w.setFirstPoint(x+gateimagewidth+6, y+getOutputPosition(w.outNum));
      }
    }

  }

  /* Reset Gate: default: alle Ausgaenge auf LOW 
   * manche Gates ueberschreiben diese Funktion und setzen bestimmte Ausgaenge auf HIGH */
  public void reset() {
      for (int i=0; i<out.length; i++) {
          out[i]=false;
      }  
  }
  
  public void printInfo() {
    System.out.println("this gate is an " + this.toString());
    System.out.println("it contains these wires:");
    for (int i=0; i<getNumInput(); i++)
      getInput(i).printInfo();
  }

}
