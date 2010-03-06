package logicsim;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

import java.awt.*;
import java.awt.geom.*;
import java.io.*;
import java.util.Vector;

public class Wire implements Serializable, Cloneable{
  static final long serialVersionUID = -7554728800898882892L;

  public transient Gate gate;  // das Gatter an dessen Ausgang dieses Wire angeschlossen ist
  public transient int outNum;    // die Nummer des Ausgangs des Gatters, an das dieses Wire angeschlossen ist
  transient boolean active;
  Polygon poly;
  Vector nodes;  /* enth�lt f�r jeden Punkt des Polygons einen Boolean Objekt, welches angibt, ob der
                    Punkt als Node gezeichnet werden soll.  nodes.size == poly.npoints  */

  public Wire(Gate g, int n) {
    gate=g;
    poly=new Polygon();
    nodes=new Vector();
    outNum=n;
    active=true;
  }

  public void addPoint(int x, int y) {
    poly.addPoint(x,y);
    nodes.setSize(poly.npoints);
    for (int i=0; i<nodes.size(); i++) {
      Boolean b=(Boolean)nodes.get(i);
      if (b==null) nodes.setElementAt(new Boolean(false), i);
    }
  }

  public final void activate() {
    active=true;
  }
  public final void deactivate() {
    active=false;
  }

  public boolean removePoint(int n) {
    if (poly.npoints==1) return false;
    Polygon pnew = new Polygon();
    for (int i=0; i<poly.npoints; i++)
      if (i!=n)
        pnew.addPoint(poly.xpoints[i], poly.ypoints[i]);

    nodes.removeElementAt(n);

    poly=pnew;
    return true;
  }


  public boolean removeLastPoint() {
    if (poly.npoints==1) return false;
    Polygon pnew = new Polygon();
    for (int i=0; i<poly.npoints-1; i++)
      pnew.addPoint(poly.xpoints[i], poly.ypoints[i]);

    poly=pnew;
    nodes.setSize(poly.npoints);
    return true;
  }

  public void setFirstPoint(int x, int y) {
    if (poly==null) return;
    poly.xpoints[0]=x;
    poly.ypoints[0]=y;
  }
  public void setLastPoint(int x, int y) {
    if (poly==null || poly.npoints<1) return;
    poly.xpoints[poly.npoints-1]=x;
    poly.ypoints[poly.npoints-1]=y;
  }

  public int inside(int x, int y) {
    for (int i=0; i<poly.npoints-1; i++) {
      Line2D l=new Line2D.Float((float)poly.xpoints[i], (float)poly.ypoints[i],
                                (float)poly.xpoints[i+1], (float)poly.ypoints[i+1]);
      if (l.ptSegDist((double)x, (double)y)<3.0f) return i;
    }
    return -1;
  }

  public void draw(Graphics g) {
    Graphics2D g2=(Graphics2D)g;
    g.setColor(Color.black);
    if (active) {
      g2.setStroke(new BasicStroke(2));
    } else if(getState())
      g.setColor(Color.red);

    g.drawPolyline(poly.xpoints, poly.ypoints, poly.npoints);
    g2.setStroke(new BasicStroke(1));

    // Punkte zeichnen
    for (int i=1; i<poly.npoints-1; i++) {
      if (active) {
        g2.setColor(Color.darkGray);
        g2.fillRect(poly.xpoints[i]-2, poly.ypoints[i]-2, 5, 5);
      }
      g2.setColor(Color.black);

      // node zeichnen
      Boolean b=(Boolean)nodes.get(i);
      if (b!=null && b.booleanValue())
        g2.fillRect(poly.xpoints[i]-2, poly.ypoints[i]-2, 5, 5);
    }


  }

  public boolean getState() {
    if (gate!=null)
      return gate.getOutput(outNum);
    else
      return false;
  }

  // pr�ft, ob �bergebener Punkt in der N�he von einem Polygonpunkt ist (ausser erster und letzter)
  public int hasPointAt(int mx, int my) {
    for (int i=1; i<poly.npoints-1; i++) {
      if (mx>poly.xpoints[i]-3 && mx<poly.xpoints[i]+3 && my>poly.ypoints[i]-3 && my<poly.ypoints[i]+3)
        return i;
    }
    return -1;
  }


  public void setPolyPoint(int n, int mx, int my) {
    poly.xpoints[n]=mx;
    poly.ypoints[n]=my;
  }

  public void insertPointAfter(int n, int mx, int my) {
    Polygon pnew=new Polygon();
    for (int i=0; i<poly.npoints; i++) {
      pnew.addPoint(poly.xpoints[i], poly.ypoints[i]);
      if (i==n) pnew.addPoint(mx,my);
    }
    poly=pnew;
    nodes.setSize(poly.npoints);
  }

  public int tryInsertPoint(int mx, int my) {
    if (hasPointAt(mx,my)>=0) return -1;
    for (int i=0; i<poly.npoints-1; i++) {
      Line2D l=new Line2D.Float((float)poly.xpoints[i], (float)poly.ypoints[i],
                                (float)poly.xpoints[i+1], (float)poly.ypoints[i+1]);
      if (l.ptSegDist((double)mx, (double)my)<3.0f) {
        insertPointAfter(i, mx, my);
        return i+1;
      }
    }
    return -1;
  }

  public boolean tryRemovePoint(int mx, int my) {
    int p=hasPointAt(mx, my);
    if (p>0)
      return removePoint(p);
    else
      return false;
  }

  public void setNode(int p) {
    if (p>0 && p<poly.npoints)
      nodes.setElementAt(new Boolean(true), p);
  }

  /** wenn an (mx,my) ein Punkt des Wires liegt, wird dieser als Node markiert */
  public boolean trySetNode(int mx, int my) {
    int p=hasPointAt(mx,my);
    if (p>0) {
      setNode(p);
      return true;
    } else
      return false;
  }

  public void printInfo() {
    System.out.println("This wire " + this.toString() + " is connected to to gate " + gate);
  }

  public Object clone() {
    Wire clone=null;
    try {
      clone=(Wire)super.clone();
    } catch (CloneNotSupportedException e) {
      throw new InternalError();
    }
    // Kopie von poly & nodes anlegen, Gate bleibt die selbe Referenz wie beim Original
    clone.poly=new Polygon(poly.xpoints, poly.ypoints, poly.npoints);
    clone.nodes=(Vector)nodes.clone();
    return clone;
  }

  public void setPolySize(int s) {
    if (poly.npoints==1) return;
    Polygon pnew = new Polygon();
    for (int i=0; i<s && i<poly.npoints; i++)
      pnew.addPoint(poly.xpoints[i], poly.ypoints[i]);

    nodes.setSize(s);
    poly=pnew;
  }

}