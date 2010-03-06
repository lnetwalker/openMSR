package logicsim;

import java.awt.*;
import java.awt.image.BufferedImage;
import javax.swing.*;


/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

import java.io.*;
import java.net.URL;

public class Module extends Gate{
    static final long serialVersionUID = 3938879095465005332L;
    
    String fname;
    transient private MODIN ModIn = null;
    transient private MODOUT ModOut = null;
    transient GateList gates;
    transient boolean moduleLoaded=false;
    
    public Module(String fname) {
        super();
        imagename="module";
        //loadImage();
        this.fname=fname;
        loadModule();
    }
    
    /**
     * L�dt Modul aus Datei und initialisiert es.
     * Diese Funktion wird beim Laden einer GateList in der reconnect() Funktion
     * f�r alle Module Objekte aufgerufen, weil erst dann die Eing�nge richtig gesetzt sind.
     */
    public void loadModule() {
        try {
            InputStream in=null;
            if (LSFrame.isApplet) {
                in=new URL(LSFrame.applet.getCodeBase()+"modules/"+fname+".mod").openStream();
            } else {
                File f=new File(App.getModulePath() + fname + ".mod");
                if (!f.exists()) {
                    String s=I18N.getString("ERROR_MODULENOTFOUND").replaceFirst("%s", fname);
                    JOptionPane.showMessageDialog(null, s);
                    return;
                }
                in=new FileInputStream(f);
            }
            
            
            ObjectInputStream s = new ObjectInputStream(in);
            gates = (GateList)s.readObject();
            s.close();
        } catch (FileNotFoundException x) {
            JOptionPane.showMessageDialog(null, I18N.getString("ERROR_FILENOTFOUND"));
        } catch (StreamCorruptedException x) {
            JOptionPane.showMessageDialog(null, I18N.getString("ERROR_FILECORRUPTED"));
        } catch (IOException x) {
            JOptionPane.showMessageDialog(null, I18N.getString("ERROR_READ"));
        } catch (ClassNotFoundException x) {
            JOptionPane.showMessageDialog(null, I18N.getString("ERROR_CLASS"));
        }
        
        if (gates==null) return;
        gates.reconnect();
        
        
        // in der geladenen GateList nach MODIN und MODOUT Gattern suchen
        for (int i=0; i<gates.size(); i++) {
            Gate g=gates.get(i);
            if (g instanceof MODIN) ModIn=(MODIN)g;
            if (g instanceof MODOUT) ModOut=(MODOUT)g;
        }
        
        if (ModIn==null || ModOut==null) {
            JOptionPane.showMessageDialog(null, I18N.getString("ERROR_NOMODULE"));
            return;  // kein Modul
        }
        
        // Eing�nge des ModIn auf Eing�nge des Moduls setzen
        for (int i=0; i<16; i++)
            ModIn.setInput(i, getInput(i));
        
        moduleLoaded=true;
    }
    
    
    public void simulate() {
        for (int i=0; i<16; i++)
            ModIn.inputTypes[i]=inputTypes[i];
        
        
        if (gates!=null) gates.simulate();
        
        // Ausgangswerte auf Werte des ModOut setzen
/*    if (ModOut!=null)
    for (int i=0; i<8; i++) {
      out[i]=ModOut.out[i];
    }
 */  }
    
    public boolean getOutput(int n) {
        if (ModOut!=null && n>=0 && n<getNumOutput())
            return ModOut.getOutput(n);
        else
            return false;
    }
    
    public void setInput(int n, Wire w) {
        super.setInput(n,w);
        
        if (n>=0 && n<16)
            ModIn.in.setElementAt(w, n);
    }
    
    public int getNumInput() {
        int numInput=0;
        if (gates==null) return 8;
        // letzten Ausgang des ModIn suchen, an den ein Wire angeschlossen ist
        for (int i=0; i<gates.size(); i++) {
            Gate g=gates.get(i);
            if (!(g instanceof MODIN)) {
                for (int j=0; j<g.getNumInput(); j++) {
                    Wire w=g.getInput(j);
                    if (w!=null && w.gate==ModIn && w.outNum>numInput)
                        numInput=w.outNum;
                }
            }
        }
        return numInput+1;
    }
    public int getNumOutput() {
        if (ModOut==null) return 8;
        int numOutput=0;
        for (int i=0; i<16; i++) {
            Wire w=ModOut.getInput(i);
            if (w!=null) numOutput=i+1;
        }
        return numOutput;
    }
    
    public void loadImage() {
        // Gatter-Grafik zusammenbauen, deren Hoehe der Anzahl der Eingaenge entspricht
        Image img=null;
        String path="images/din/";
        if (LSFrame.gatedesign.equals("iso"))
            path="images/iso/";
        img=new ImageIcon(logicsim.LSFrame.class.getResource(path + imagename + ".gif")).getImage();
        
        if (img!=null) {
            int width=img.getWidth(null);
            int numinput=getNumInput();
            if (getNumOutput()>numinput) numinput=getNumOutput(); // Falls es mehr Aus- als Eingänge gibt
            if (numinput<4) numinput=4; // Mindeshoehe 4 Eingaenge, damit das Label passt
            int height=10+(numinput-1)*10;
            
            BufferedImage bi = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
            Graphics2D g2=bi.createGraphics();
            g2.drawImage(img, 0, 0, width, 10, 0, 0, width, 10, null);
            for (int i=0; i<numinput-1; i++) {
                g2.drawImage(img, 0, 10+i*10, width, 10+i*10+10, 0, 10, width, 20, null);
            }
            g2.drawImage(img, 0, height-10, width, height, 0, img.getHeight(null)-10, width, img.getHeight(null), null);
            gateimage=bi;
            gateimagewidth=gateimage.getWidth(null);
            gateimageheight=gateimage.getHeight(null);
            
            
        }
    }
    
    public void draw(Graphics g) {
        super.draw(g);
        Graphics2D g2 = (Graphics2D)g;
        if (ModIn!=null) {
            //AffineTransform at = g2.getTransform();
            //g2.rotate(Math.PI*1.5, x+gateimagewidth/2+10, y+gateimageheight/2);
            g.setClip(x,y,gateimagewidth,gateimageheight);
            String str=new String(((MODIN)ModIn).ModuleLabel);
            g.setColor(Color.black);
            g.drawString(str, x+7, y+20);
            g.setClip(0,0,Integer.MAX_VALUE,Integer.MAX_VALUE);
            //g2.setTransform(at);
        }
    }
    
    public boolean hasProperties() {
        return true;
    }
    
    public boolean showProperties(Component frame) {
        if (ModIn!=null) {
            JOptionPane.showMessageDialog(frame, I18N.getString("MESSAGE_MODULE_NAME")+": "+
                    ModIn.ModuleName + "\n"+I18N.getString("MESSAGE_MODULE_DESCRIPTION")+":\n"+ModIn.ModuleDescription);
        }
        return true;
    }
    
    
    public int getOutputPosition(int n) {
        return getConnectorPosition(n, getNumOutput());
    }
    public int getInputPosition(int n) {
        return getConnectorPosition(n, getNumInput());
    }
    public int getConnectorPosition(int n, int total) {
        if (total==0) return -1;
        return 5+n*10;
    }
    
    
}