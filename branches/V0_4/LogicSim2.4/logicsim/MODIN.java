package logicsim;

import java.awt.*;
import java.io.*;
import javax.swing.*;
import java.util.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

/*  Eingangsgatter f�r Modul.
    Wird beim Erstellen eines Moduls angelegt.
    Eing�nge des Moduls werden daran angeschlossen.
*/

public class MODIN extends Gate {
  static final long serialVersionUID = -2338870902247206767L;

  /*  ACHTUNG! das MODIN enth�lt die Informationen zu einem Modul, weil das
      Module Objekt selber nicht gespeichert wird */
  public String ModuleName;
  public String ModuleDescription;
  public String ModuleLabel;
  public String ModuleImageName;


  public MODIN() {
    super();
    imagename="input";
    ModuleName=new String();
    ModuleDescription=new String();
    ModuleLabel=new String();
    ModuleImageName=new String();
  }



  public int getNumInput() {
    return 16;
  }
  public int getNumOutput() {
    return 16;
  }


  public boolean getOutput(int n) {
    if (getInput(n)!=null)
      return getInputState(n);
    else
      return false;
  }

  public boolean hasProperties() {
      return true;
  }  
  
  public boolean showProperties(Component frame) {
    String NameBak=new String(ModuleName);

    JPanel panel = new JPanel();

    JLabel jLabel1 = new JLabel();
    JTextField jTextField_name = new JTextField(ModuleName);
    JTextArea jTextArea_description = new JTextArea(ModuleDescription);
    JLabel jLabel3 = new JLabel();
    JLabel jLabel4 = new JLabel();
    JTextField jTextField_label = new JTextField(ModuleLabel);
    JLabel jLabel5 = new JLabel();
    JTextField jTextField_image = new JTextField(ModuleImageName);

    jLabel1.setToolTipText("");
    jLabel1.setText(I18N.getString("MESSAGE_MODULE_NAME"));
    jLabel1.setBounds(new Rectangle(15, 15, 106, 24));
    panel.setLayout(null);
    jTextField_name.setBounds(new Rectangle(120, 16, 211, 25));
    jTextArea_description.setBounds(new Rectangle(119, 56, 212, 88));
    jLabel3.setText(I18N.getString("MESSAGE_MODULE_DESCRIPTION"));
    jLabel3.setBounds(new Rectangle(16, 80, 100, 23));
    jLabel4.setText(I18N.getString("MESSAGE_MODULE_LABEL"));
    jLabel4.setBounds(new Rectangle(19, 190, 95, 25));
    jTextField_label.setBounds(new Rectangle(121, 189, 211, 25));
    jLabel5.setText(I18N.getString("MESSAGE_MODULE_IMAGE"));
    jLabel5.setBounds(new Rectangle(19, 229, 95, 21));
    jTextField_image.setBounds(new Rectangle(121, 228, 211, 25));
    panel.add(jTextArea_description, null);
    panel.add(jLabel1, null);
    panel.add(jTextField_name, null);
    panel.add(jLabel3, null);
    panel.add(jLabel4, null);
    panel.add(jTextField_label, null);
    //panel.add(jLabel5, null);
    //panel.add(jTextField_image, null);

    JOptionPane pane = new JOptionPane(panel);
    pane.setMessageType(JOptionPane.QUESTION_MESSAGE);
    pane.setOptions(new String[] {I18N.getString("BUTTON_USE"), I18N.getString("BUTTON_CANCEL")});
    JDialog dlg=pane.createDialog(frame, I18N.getString("MENU_MODULEPROPERTIES"));
    dlg.setResizable(true);
    dlg.setSize(400,350);
    dlg.show();
    if (I18N.getString("BUTTON_USE") == (String)pane.getValue()) {
      ModuleName=new String(jTextField_name.getText());
      ModuleDescription=new String(jTextArea_description.getText());
      ModuleLabel=new String(jTextField_label.getText());
      ModuleImageName=new String(jTextField_image.getText());

      if (ModuleName.length()==0) return false;

      if (ModuleName != NameBak && NameBak.length()>0) {
        File f=new File(App.getModulePath() + NameBak + ".mod");
        f.renameTo(new File(App.getModulePath() + ModuleName + ".mod"));
      }
      return true;
    }
    return false;
  }
  
  
}