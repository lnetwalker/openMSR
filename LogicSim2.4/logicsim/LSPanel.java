package logicsim;

import javax.swing.*;
import java.awt.image.*;
import java.awt.*;
import java.awt.event.*;
import java.text.*;
import java.util.*;
import java.awt.print.*;


public class LSPanel extends JPanel implements Printable {

  public GateList gates;
  private Gate currentGate;  // das Gate-Objekt, das gerade verschoben wird
  private Wire drawingWire;  // das Wire-Objekt, das gerade gezeichnet wird/dessen Punkt bearbeitet wird
  private int movingPoint;
  private int currentAction;
  private JLabel statusBar;
  private Point lastWirePoint = new Point();
  private Point mousePos = new Point();
  public boolean simulationRunning=false;
  private int lastAction;
  private int lastActionInputNum;
  private Gate lastClickedGate=null; // Gatter, das im Simulationsmodus zuletzt angeklickt wurde
  private boolean paintGrid = true;
  public boolean changed=false;  // true, wenn etwas geaendert wurde, damit beim Oeffnen eine Sicherheitsabfrage angezeigt wird

  private Dimension panelSize = new Dimension(1280, 1024);

  static final int ACTION_AND = 1;
  static final int ACTION_NAND = 2;
  static final int ACTION_NOT = 3;
  static final int ACTION_SWITCH = 4;
  static final int ACTION_LED = 5;
  static final int ACTION_RSFF = 6;
  static final int ACTION_JKFFC = 7;
  static final int ACTION_JKMSFF = 8;
  static final int ACTION_OR = 9;
  static final int ACTION_NOR = 10;
  static final int ACTION_XOR = 11;
  static final int ACTION_EQU = 12;
  static final int ACTION_CLK = 13;
  static final int ACTION_CONNECT = 14;
  static final int ACTION_DRAWWIRE = 15;
  static final int ACTION_ADDPOINT = 16;
  static final int ACTION_DELPOINT = 17;
  static final int ACTION_MODULE = 18;
  static final int ACTION_BININ = 19;
  static final int ACTION_LCD = 20;
  static final int ACTION_TFF = 21;
  static final int ACTION_MONOFLOP = 22;
  static final int ACTION_DFF = 23;
  static final int ACTION_INNORM = 24;
  static final int ACTION_INNEG = 25;
  static final int ACTION_INHIGH = 26;
  static final int ACTION_INLOW = 27;
  static final int ACTION_ONDELAY = 28;
  static final int ACTION_OFFDELAY = 29;
  static final int ACTION_TEXTLABEL = 30;
  static final int ACTION_SEVENSEGMENT = 31;
  static final int ACTION_DRFF = 32;

  public LSPanel(JLabel statusBar) {
    this.statusBar=statusBar;
    gates=new GateList();
    this.setSize(panelSize);
    this.setPreferredSize(panelSize);
    this.revalidate();
    this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
    this.enableEvents(AWTEvent.MOUSE_EVENT_MASK);
    this.enableEvents(AWTEvent.MOUSE_MOTION_EVENT_MASK);
    this.addKeyListener(new java.awt.event.KeyAdapter() {
      public void keyPressed(KeyEvent e) {
        myKeyPressed(e);
      }
    });
  }

  public void setAction(int a) {
    setAction(a, 2);
  }

  public void setAction(int a, int n) {
    lastAction=a; lastActionInputNum=n;
    Gate g=null;
    switch (a) {
      case ACTION_AND : g=new AND(n); break;
      case ACTION_NAND : g=new NAND(n); break;
      case ACTION_OR : g=new OR(n); break;
      case ACTION_NOR : g=new NOR(n); break;
      case ACTION_XOR : g=new XOR(n); break;
      case ACTION_EQU : g=new EQU(n); break;
      case ACTION_NOT : g=new NOT(); break;
      case ACTION_SWITCH : g=new SWITCH(); break;
      case ACTION_LED : g=new LED(); break;
      case ACTION_RSFF : g=new RSFlipFlop(); break;
      case ACTION_JKFFC : g=new JKCFlipFlop(); break;
      case ACTION_JKMSFF : g=new JKMSFlipFlop(); break;
      case ACTION_TFF : g=new TFlipFlop(); break;
      case ACTION_CLK : g=new CLK(); break;
      case ACTION_BININ : g=new BININ(); break;
      case ACTION_LCD : g=new LCD(); break;
      case ACTION_SEVENSEGMENT : g=new SevenSegment(); break;
      case ACTION_MONOFLOP : g=new MonoFlop(); break;
      case ACTION_ONDELAY : g=new OnDelay(); break;
      case ACTION_OFFDELAY : g=new OffDelay(); break;
      case ACTION_DFF : g=new DFlipFlop(); break;
      case ACTION_DRFF : g=new DRFlipFlop(); break;
      case ACTION_TEXTLABEL : g=new TextLabel(); break;      
      case ACTION_INNORM : statusBar.setText(I18N.getString("STATUS_INPUTNORMAL")); break;
      case ACTION_INNEG : statusBar.setText(I18N.getString("STATUS_INPUTINV")); break;
      case ACTION_INHIGH : statusBar.setText(I18N.getString("STATUS_INPUTHIGH")); break;
      case ACTION_INLOW : statusBar.setText(I18N.getString("STATUS_INPUTLOW")); break;
      case ACTION_ADDPOINT : statusBar.setText(I18N.getString("STATUS_ADDPOINT")); break;
      case ACTION_DELPOINT : statusBar.setText(I18N.getString("STATUS_REMOVEPOINT")); break;
    }

    currentAction=a;

    if (g!=null) {
      //gates.addGate(g);
      gates.deactivateAll();
      currentGate=g;
    }
  }

  public void setAction(int a, Gate g) {
    currentAction=a;
    if (g!=null) {
      //gates.addGate(g);
      currentGate=g;
    }
  }

  public void setPaintGrid(boolean onoff) {
    paintGrid=onoff;
  }

  public void draw(Graphics g) {
    for (int i=0; i<gates.size(); i++) {
      Gate gate=gates.get(i);
      gate.draw(g);
    }
  }

  public void paintComponent(Graphics g) {
    super.paintComponent(g);
    g.setColor(Color.white);
    g.fillRect(0,0,panelSize.width,panelSize.height);

    if (paintGrid) {
      g.setColor(Color.black);
      for (int x=0; x<panelSize.width; x+=10)
        for (int y=0; y<panelSize.height; y+=10)
            g.drawLine(x,y, x,y);
          //g.drawRect(x,y,1,1);
    }

    draw(g);

    if (currentGate!=null) {
      currentGate.draw(g);
    }

    if (drawingWire!=null && movingPoint==0) {
      drawingWire.draw(g);
      g.drawLine(lastWirePoint.x, lastWirePoint.y, mousePos.x, mousePos.y);
    }
  }


  protected void processMouseMotionEvent(MouseEvent e) {
    int id = e.getID();
    int mod=e.getModifiers();

    Graphics g = this.getGraphics();
    if (id == MouseEvent.MOUSE_DRAGGED || id == MouseEvent.MOUSE_MOVED) {
      int x=e.getPoint().x;
      int y=e.getPoint().y;
      x=x/10*10;
      y=y/10*10;

      if (mod==1 && drawingWire!=null && movingPoint==0) {   // SHIFT
        Polygon poly = drawingWire.poly;
        int lastx=poly.xpoints[poly.npoints-1];
        int lasty=poly.ypoints[poly.npoints-1];
        if (Math.abs(x-lastx)<Math.abs(y-lasty))
          x=lastx;
        else
          y=lasty;
      }


      if (drawingWire!=null && movingPoint==0) {
        Polygon poly=drawingWire.poly;
        lastWirePoint.setLocation(poly.xpoints[poly.npoints-1], poly.ypoints[poly.npoints-1]);
        mousePos.setLocation(x, y);
        changed=true;
        repaint();
      }

      if (drawingWire!=null && movingPoint>0) {  // Wire-Punkt verschieben
        int ox=drawingWire.poly.xpoints[movingPoint];
        int oy=drawingWire.poly.ypoints[movingPoint];

        drawingWire.setPolyPoint(movingPoint, x, y);

        // wenn ein Punkt eines anderen Wires an der gleichen Stelle war, wie der verschobene Punkt,
        // wird dieser auch verschoben. Aber nur, wenn bei beiden Wires der vorherige Punkt identisch ist.
        for (int i=0; i<gates.size(); i++) {
          Gate gate=gates.get(i);
          for (int j=0; j<gate.getNumInput(); j++) {
            Wire w=gate.getInput(j);
            if (w!=null) {
               int p=w.hasPointAt(ox,oy);
               if (p>0 && w.poly.xpoints[p-1]==drawingWire.poly.xpoints[movingPoint-1] &&
                   w.poly.ypoints[p-1]==drawingWire.poly.ypoints[movingPoint-1]) {
                  w.setPolyPoint(p, x, y);
                  changed=true;
               }
            }
          }

        }

        repaint();
      }

      if (currentGate!=null) {
        currentGate.moveTo(x,y,gates);
        changed=true;
        repaint();
      }
    }
  }

  protected void processMouseEvent(MouseEvent e) {
    super.processMouseEvent(e);
    int id = e.getID();
    int x=e.getPoint().x;
    int y=e.getPoint().y;
    int mod=e.getModifiers();

    //this.requestFocus();
    this.requestFocusInWindow();

    /*if (id==MouseEvent.MOUSE_CLICKED && mod==MouseEvent.BUTTON1_MASK && currentAction==0) {
      for (int i=0; i<gates.size(); i++) {
        Gate g=gates.get(i);
        if (x>g.x && x<g.x+g.gateimagewidth && y>g.y+5 && y<g.y+g.gateimageheight-5)
          g.clicked();
      }
    } else */
    if (id==MouseEvent.MOUSE_PRESSED && (mod & MouseEvent.BUTTON1_MASK)>0) {

    /*  if (currentAction==ACTION_REMOVEWIRE) {
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null && w.inside(x,y)) {
              g.setInput(j, null);
              repaint();
              break;
            }
          }
        }
        statusBar.setText(" ");
        currentAction=0;
      } else if (currentAction==ACTION_REMOVE) {
        for (int i=0; i<gates.size(); i++) {
          if (gates.get(i).inside(x, y)) {
            gates.remove(i);
            repaint();
            break;
          }
        }
        statusBar.setText(" ");
        currentAction=0;
      } else*/
      if (currentAction==ACTION_ADDPOINT && drawingWire==null) {
          // Auf Wire geklickt -> neuen Punkt einf�gen
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null) {
              int p=w.tryInsertPoint(x,y);
              if (p>0) {
                drawingWire=w;
                w.activate();
                repaint();
                movingPoint=p;    // eingef�gten Punkt verschieben
                changed=true;
                break;
              }
            }
          }
        }
        statusBar.setText(" ");
        currentAction=0;
      } else if (currentAction==ACTION_DELPOINT && drawingWire==null) {
          // Auf Wirepunkt geklickt -> l�schen
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null) {
              if (w.tryRemovePoint(x,y)) {
                w.activate();
                repaint();
                changed=true;
                break;
              }
            }
          }
        }
        statusBar.setText(" ");
        currentAction=0;
      } else if (drawingWire!=null && movingPoint==0) {
        x=x/10*10;
        y=y/10*10;
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          if (g.getNumInput()>0 && g.tryConnectInput(mousePos.x, mousePos.y, drawingWire)) {
            drawingWire=null;
            statusBar.setText(I18N.getString("STATUS_CONNECTED"));
            repaint();
            changed=true;
          }
        }
        if (statusBar.getText()!=I18N.getString("STATUS_CONNECTED")) {
          drawingWire.addPoint(mousePos.x,mousePos.y);
          drawingWire.draw(this.getGraphics());
          changed=true;
        }
      } else if (currentAction==ACTION_INNEG || currentAction==ACTION_INHIGH || currentAction==ACTION_INLOW || currentAction==ACTION_INNORM) {
        int type=0;
        switch (currentAction) {
          case ACTION_INNEG : type=Gate.INTYPE_NEGATIVE; break;
          case ACTION_INHIGH : type=Gate.INTYPE_HIGH; break;
          case ACTION_INLOW : type=Gate.INTYPE_LOW; break;
          case ACTION_INNORM : type=Gate.INTYPE_NORMAL; break;
        }
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          if (g.trySetInputType(x,y,type)) {
            repaint();
            changed=true;
            break;
          }
        }
        statusBar.setText(" ");
        currentAction=0;
      } else {
        gates.deactivateAll();

        // Auf Gatter geklickt ?
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          if (g.inside(x,y)) {
            if (simulationRunning) {
              g.clicked(x,y);
              lastClickedGate=g;
            } else {
              currentGate=g;    // dieses Gatter verschieben
              currentGate.activate();  // aktivieren
              changed=true;            
            }
            repaint();
            return;
          }
        }

        // Auf Ausgang geklickt ?
        if (currentGate==null)
        for (int i=0; i<gates.size(); i++) {
          Wire w=gates.get(i).tryConnectOutput(x, y);
          if (w!=null) {
            drawingWire=w;
            currentAction=0;
            statusBar.setText(I18N.getString("STATUS_SETINPUT"));
            changed=true;
            return;
          }
        }

        // Auf Punkt eines Wires geklickt ?
        if (drawingWire==null && (mod & 1)==0)  // ohne shift
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null) {
              int p=w.hasPointAt(x,y);
              if (p>0) {
                drawingWire=w;
                drawingWire.activate();
                movingPoint=p;    // diesen Punkt verschieben
                changed=true;
                return;
              }
            }
          }
        }

        // mit SHIFT auf Punkt eines Wires geklickt ?
        if (drawingWire==null && (mod & 1)==1)
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null) {
              int p=w.hasPointAt(x,y);
              if (p>0) {
                w.setNode(p);
                drawingWire=(Wire)w.clone();
                drawingWire.setPolySize(p+1);
                drawingWire.activate();
                movingPoint=0;
                Polygon poly=drawingWire.poly;
                statusBar.setText(" ");
                changed=true;
                return;
              }
            }
          }
        }

        int tx=x/10*10;
        int ty=y/10*10;

           // mit SHIFT auf Wire geklickt ? -> punkt als node einf�gen und neues wire anschliessen
        if ((mod & 1) == 1)
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null) {
              int p=w.tryInsertPoint(tx,ty);
              if (p>0) {
                // bei allen anderen wires, die an dieser Stelle verlaufen,
                // wird an diese Stelle eine Punkt als Node einf�gen
                for (int k=0; k<gates.size(); k++) {
                  Gate g2=gates.get(k);
                  for (int l=0; l<g2.getNumInput(); l++) {
                    Wire w2=g2.getInput(l);
                    if (w2!=null) {
                      int p2=w2.inside(tx,ty);
                      if (p2>=0 && w2.hasPointAt(tx,ty)==-1) {
                        w2.insertPointAfter(p2, tx, ty);
                        w2.setNode(p2);
                      }
                    }
                  }
                }

                w.setNode(p);
                drawingWire=(Wire)w.clone();
                drawingWire.setPolySize(p+1);
                drawingWire.activate();
                movingPoint=0;
                Polygon poly=drawingWire.poly;
                statusBar.setText(" ");
                repaint();
                changed=true;
                return;
              }
            }
          }
        }

           // mit STRG auf Wire geklickt ? -> Punkt einf�gen
        if ((mod & 2) == 2)
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null) {
              int p=w.tryInsertPoint(x,y);
              if (p>0) {
                drawingWire=w;
                w.activate();
                repaint();
                movingPoint=p;    // eingef�gten Punkt verschieben
                statusBar.setText(" ");
                changed=true;
                return;
              }
            }
          }
        }


           // Auf Wire geklickt ? -> aktivieren
        for (int i=0; i<gates.size(); i++) {
          Gate g=gates.get(i);
          for (int j=0; j<g.getNumInput(); j++) {
            Wire w=g.getInput(j);
            if (w!=null && w.inside(x,y)>=0) {
              w.activate();
              repaint();
              changed=true;
            }
          }
        }

      }
    } else if (id==MouseEvent.MOUSE_RELEASED && (mod & MouseEvent.BUTTON1_MASK)>0) {
        // Maustaste losgelassen
      if (currentGate!=null) {
        if (!gates.gates.contains(currentGate))
            // Gatter platzieren wenn es noch nicht in der Liste ist
          gates.addGate(currentGate);
        currentGate=null;
        currentAction=0;
        changed=true;
      }
      if (movingPoint>0) {
        drawingWire=null;
        movingPoint=0;
      }
      if (simulationRunning && lastClickedGate!=null) {
        // Das Loslassen der Maustasten an Gatter melden
        lastClickedGate.mouseReleased();
      }
    }
    
  }

  protected void myKeyPressed(KeyEvent e) {
    int keyCode = e.getKeyCode();
    int modifiers = e.getModifiers();
    String tmpString = KeyEvent.getKeyModifiersText(modifiers);
/*
    System.out.println(keyCode);
    System.out.println(modifiers);
    System.out.println(tmpString);
*/
    if (keyCode==27) { //Escape
      if (currentGate!=null) {
        currentGate=null;
      } else if (drawingWire!=null) {
        if (drawingWire.removeLastPoint()) {
          Polygon poly=drawingWire.poly;
          lastWirePoint.setLocation(poly.xpoints[poly.npoints-1], poly.ypoints[poly.npoints-1]);
        } else {
          drawingWire=null;
        }
      }
      statusBar.setText(I18N.getString("STATUS_ABORTED"));
      repaint();
    } else if (keyCode==127) { // DEL
      //aktives Objekt suchen und l�schen
      for (int i=0; i<gates.size(); i++) {
        Gate g=gates.get(i);
        if (g.active) {
          gates.remove(i);
          repaint();
          changed=true;
          break;
        }
        for (int j=0; j<g.getNumInput(); j++) {
          Wire w=g.getInput(j);
          if (w!=null && w.active && g.inputTypes[j]<=1) {
            g.setInput(j, null);
            repaint();
            changed=true;
            //break;
            return;
          }
        }
      }

    } else if (keyCode==32) { // space
      setAction(lastAction, lastActionInputNum);
      changed=true;
      repaint();
    }

  }



  public int print(Graphics g, PageFormat pf, int pi) throws PrinterException {
    if (pi >= 1) {
      return Printable.NO_SUCH_PAGE;
    }
    draw(g);
    return Printable.PAGE_EXISTS;
  }

  public void doPrint() {
    PrinterJob printJob = PrinterJob.getPrinterJob();
    printJob.setPrintable(this);
    if (printJob.printDialog()) {
      try {
        printJob.print();
      } catch (Exception ex) {
        ex.printStackTrace();
      }
    }
  }

}