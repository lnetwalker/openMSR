/*
 * Applet.java
 *
 * Created on 1. August 2007, 12:15
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package logicsim;

import java.io.ObjectInputStream;
import java.net.URL;
import javax.swing.plaf.basic.*;

/**
 *
 * @author atetzl
 */
public class Applet extends javax.swing.JApplet {
    
    LSFrame lsframe;
    
    /**
     * Creates a new instance of Applet
     */
    public Applet() {
        
    }
    
    public void init() {
        new I18N(this);
        
        lsframe = new LSFrame(this);
        lsframe.setVisible(true);
        ((BasicInternalFrameUI) lsframe.getUI()).setNorthPane(null);
        lsframe.setBorder(null);
    
        this.getContentPane().add(lsframe);
    
    }
    
    public void start() {
        // check applet params
        
        String loadcircuit = getParameter( "loadcircuit" );
        System.out.println(loadcircuit);
        if (loadcircuit!=null && loadcircuit.length()>0) {
            loadCircuit(loadcircuit);
        }
        
        String startsim = getParameter("startsimulation");
        if (startsim!=null && startsim.equals("true")) {
            lsframe.jToggleButton_simulate.setSelected(true);
            lsframe.sim=new Simulate(lsframe.lspanel);
        }
    }
    
    
    public void loadCircuit(String fname) {

        try { 
            URL url=new URL(getCodeBase()+fname);
            ObjectInputStream s = new ObjectInputStream(url.openStream());
            lsframe.lspanel.gates = (GateList)s.readObject();
            s.close();
        } catch (Exception ex) {
            lsframe.showMessage(ex.toString());
        }
        
        lsframe.lspanel.gates.reconnect();
        lsframe.lspanel.repaint();
        lsframe.lspanel.changed=false;
    }
    
}
