package logicsim;

import java.awt.*;
import javax.swing.*;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 * 25.09.2004
 */

public class TextLabel extends Gate{
  static final long serialVersionUID = 6576677427368074734L;

  String text="Text Label";
  
  public TextLabel() {
    super();
    imagename="TextLabel";
    //loadImage();
  }


  public void draw(Graphics g) {
    if (gateimage==null) loadImage();
    
    FontMetrics fm = g.getFontMetrics();    
    String[] a=text.split("\\\\");
    int stringWidth=0;
    for (int i=0; i<a.length; i++) {
        int l=fm.stringWidth(a[i]);
        if (l>stringWidth) stringWidth=l;
    }
    int stringHeight=fm.getHeight();

    gateimagewidth=stringWidth;
    gateimageheight=stringHeight * a.length;
    
    super.draw(g);
    
    for (int i=0; i<a.length; i++) {
        g.drawString(a[i],  x, y+12+(stringHeight*i));
    }

  }
  
  public boolean hasProperties() {
      return true;
  }  
  
  public boolean showProperties(Component frame) {
    String h = (String)JOptionPane.showInputDialog(frame, I18N.getString("MESSAGE_ENTER_LABEL"), "LogicSim",
                                                    JOptionPane.QUESTION_MESSAGE, null,null, text);
    if (h!=null && h.length()>0) text=h;
    return true;
  }  
}