package logicsim;

import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;
/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class LCD extends Gate{
  static final long serialVersionUID = -6532037559895208921L;

  transient Image digits;
  int displayType;  // 0=HEX  1=DEC

  public LCD() {
    super();
    imagename="LCD";
  }

  public int getNumInput() {
    return 8;
  }
  public int getNumOutput() {
    return 0;
  }

  public void simulate() {
  }


  public void draw(Graphics g) {
    if (onimage==null || gateimage==null) loadImage();
    if (digits==null)
      digits=new ImageIcon(logicsim.LSFrame.class.getResource("images/LCDdigits.gif")).getImage();

    super.draw(g);

    int value=0;
    for (int i=0; i<8; i++) {
      if (getInput(i)!=null && getInputState(i))
        value+=(1<<i);
    }

    int offset=0, offset1=0, offset2=0;
    String sval = "";
    if (displayType==1)
      sval=Integer.toString(value);
    else
      sval=Integer.toHexString(value);

    if (sval.length()==0)
      sval="00";
    if (sval.length()==1)
      sval="0" + sval;

    for (int i=0; i<=1; i++) {
      switch (sval.charAt(i)) {
        case '0' : offset=0; break;
        case '1' : offset=15; break;
        case '2' : offset=30; break;
        case '3' : offset=45; break;
        case '4' : offset=60; break;
        case '5' : offset=75; break;
        case '6' : offset=90; break;
        case '7' : offset=105; break;
        case '8' : offset=120; break;
        case '9' : offset=135; break;
        case 'a' : offset=150; break;
        case 'b' : offset=165; break;
        case 'c' : offset=180; break;
        case 'd' : offset=195; break;
        case 'e' : offset=210; break;
        case 'f' : offset=225; break;
      }
      if (i==0) offset1=offset;
      if (i==1) offset2=offset;
    }

    g.setClip(x+5+5,y+24,15,30);
    g.drawImage(digits, x+5+5-offset1, y+24, null);
    g.setClip(x+20+5,y+24,15,30);
    g.drawImage(digits, x+20+5-offset2, y+24, null);
    g.setClip(0,0,Integer.MAX_VALUE,Integer.MAX_VALUE);
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

    if (displayType==1)
      jRadioButton2.setSelected(true);
    else
      jRadioButton1.setSelected(true);

    JPanel jPanel1 = new JPanel();
    Border border1;
    TitledBorder titledBorder1;
    BorderLayout borderLayout1 = new BorderLayout();

    border1 = new EtchedBorder(EtchedBorder.RAISED,Color.white,new Color(142, 142, 142));
    titledBorder1 = new TitledBorder(new EtchedBorder(EtchedBorder.RAISED,Color.white,new Color(142, 142, 142)),I18N.getString("GATE_BINARYINPUT_DISPLAYTYPE"));
    jRadioButton1.setText(I18N.getString("GATE_BINARYINPUT_HEX"));
    jRadioButton2.setText(I18N.getString("GATE_BINARYINPUT_DEC"));
    jPanel1.setBorder(titledBorder1);
    jPanel1.setBounds(new Rectangle(11, 11, 171, 150));
    jPanel1.setLayout(borderLayout1);
    jPanel1.add(jRadioButton1, BorderLayout.NORTH);
    jPanel1.add(jRadioButton2, BorderLayout.CENTER);

    JOptionPane pane = new JOptionPane(jPanel1);
    pane.setMessageType(JOptionPane.QUESTION_MESSAGE);
    pane.setOptions(new String[] {I18N.getString("BUTTON_USE"), I18N.getString("BUTTON_CANCEL")});
    JDialog dlg=pane.createDialog(frame, I18N.getString("GATE_LCD_PROPERTIES"));
    dlg.setResizable(true);
    dlg.setSize(290,180);
    dlg.show();
    if (I18N.getString("BUTTON_USE").equals((String)pane.getValue())) {
      if (jRadioButton1.isSelected())
        displayType=0;
      else if (jRadioButton2.isSelected())
        displayType=1;
      return true;
    }
    return false;
  }

}