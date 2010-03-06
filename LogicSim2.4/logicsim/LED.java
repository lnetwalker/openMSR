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
 */

public class LED extends Gate{
  static final long serialVersionUID = 6576677427368074734L;

   
  private Color color_off = null;
  private Color color_on = null;
  
    
  public LED() {
    super();
    imagename="LED";
    onimagename="LED_on";
    //loadImage();
  }
  public LED(Wire w1) {
    super(w1);
  }

  public int getNumInput() {
    return 1;
  }
  public int getNumOutput() {
    return 0;
  }

  public void simulate() {
  }


  public void draw(Graphics g) {
    if (onimage==null || gateimage==null) loadImage();
    super.draw(g);
    if (getInput(0)!=null && getInputState(0))
      g.drawImage(onimage, x+3, y, null);
//    else
//      super.draw(g);
    
    
    if (this.color_on!=null) {
        g.setColor(this.color_on);
        g.fillOval(x+9, y+3, 31, 31);
    }
     
  }
  

  public boolean hasProperties() {
      return true;
  }
  
  public boolean showProperties(Component frame) {
    this.color_on = JColorChooser.showDialog(
                     null,
                     "Choose",
                     this.color_on);

    return true;
  }
  
}