package logicsim;

import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class SWITCH extends Gate {
  static final long serialVersionUID = 2459367526586913840L;

  boolean click = false; // True=Click, False=Toggle
  /* Ein Klick-Button bleibt nur so lange an, wie der Nutzer den Mausknopf gedr�ckt h�lt,
   * aber mindestens 2 Simulations-Zyklen. 
   * Daf�r wird beim Klick der Countdown auf 2 gesetzt und in jedem Zyklus heruntergez�hlt.
   * Der Button geht aus, wenn der Countdown auf 0 ist und die Maustaste losgelassen wurde.
   */
  transient long clickCountDown=0; 
  transient boolean mouseDown=false; // true solange der User die Maus �ber dem Gatter gedr�ckt h�lt
  
  public SWITCH() {
    super();
    out[0]=false;
    imagename="Switch";
    onimagename="Switch_on";
    //loadImage();
  }

  public int getNumInput() {
    return 0;
  }
  public int getNumOutput() {
    return 1;
  }

  public void setOutput(boolean s) {
    out[0]=s;
  }

  public void clicked(int mx, int my) {
    if (click) {
      // Click-Button, wird wieder deaktiviert, wenn Maustaste losgelassen wird
      out[0]=true;
      mouseDown=true;
      clickCountDown=2;
    } else {
      // Toggle-Button
      out[0]=!out[0];
    }
  }
  
  public void mouseReleased() {
      mouseDown=false;
  }

  public void simulate() {
      if (click) {
        if (clickCountDown>0) clickCountDown--;
        if (clickCountDown==0 && !mouseDown) 
            out[0]=false;
      }
  }  
  
  public void draw(Graphics g) {
    if (onimage==null) loadImage();
    super.draw(g);
    if (out[0])
      g.drawImage(onimage, x+3, y, null);
//    else
//      super.draw(g);
  }
  

  public boolean hasProperties() {
      return true;
  }
  
  public boolean showProperties(Component frame) {
    JRadioButton jRadioButton1 = new JRadioButton();
    JRadioButton jRadioButton2 = new JRadioButton();

     // Group the radio buttons.
    ButtonGroup group = new ButtonGroup();
    group.add(jRadioButton1);
    group.add(jRadioButton2);

    if (click)
      jRadioButton2.setSelected(true);
    else
      jRadioButton1.setSelected(true);

    JPanel jPanel1 = new JPanel();
    Border border1;
    TitledBorder titledBorder1;
    BorderLayout borderLayout1 = new BorderLayout();

    border1 = new EtchedBorder(EtchedBorder.RAISED,Color.white,new Color(142, 142, 142));
    titledBorder1 = new TitledBorder(new EtchedBorder(EtchedBorder.RAISED,Color.white,new Color(142, 142, 142)),I18N.getString("GATE_SWITCH_TYPE"));
    jRadioButton1.setText(I18N.getString("GATE_SWITCH_TOGGLE"));
    jRadioButton2.setText(I18N.getString("GATE_SWITCH_CLICK"));
    jPanel1.setBorder(titledBorder1);
    jPanel1.setBounds(new Rectangle(11, 11, 171, 150));
    jPanel1.setLayout(borderLayout1);
    jPanel1.add(jRadioButton1, BorderLayout.NORTH);
    jPanel1.add(jRadioButton2, BorderLayout.CENTER);

    JOptionPane pane = new JOptionPane(jPanel1);
    pane.setMessageType(JOptionPane.QUESTION_MESSAGE);
    pane.setOptions(new String[] {I18N.getString("BUTTON_USE"), I18N.getString("BUTTON_CANCEL")});
    JDialog dlg=pane.createDialog(frame, I18N.getString("GATE_SWITCH_TYPE"));
    dlg.setResizable(true);
    dlg.setSize(290,180);
    dlg.show();
    if (I18N.getString("BUTTON_USE").equals((String)pane.getValue())) {
      if (jRadioButton1.isSelected())
        click=false;
      else if (jRadioButton2.isSelected())
          click=true;
      return true;
    }
    return false;
  }
  
  public void reset() {
      // kein Reset beim Switch
      
  }
  
}