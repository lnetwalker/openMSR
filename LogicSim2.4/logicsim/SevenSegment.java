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
 *
 *
 * Created on 1. Juni 2006, 15:25*
 */

public class SevenSegment extends Gate{
  static final long serialVersionUID = 8068938713485037151L;

  public SevenSegment() {
    super();
    imagename="SevenSegment";
  }

  public int getNumInput() {
    return 7;
  }
  public int getNumOutput() {
    return 0;
  }

  public void simulate() {
  }


  public void draw(Graphics g) {
    if (gateimage==null) loadImage();

    super.draw(g);

    g.drawImage(gateimage, x+3, y, null);    


    for (int i=0; i<getNumInput(); i++) {
        if (getInput(i)!=null && getInputState(i)) {
            g.setColor(Color.red);
        } else {
            g.setColor(new Color(0xee, 0xee, 0xee));
        }
        switch (i) {
            case 0: drawHorizontalSegment(g, x+3+ 13, y+ 18); break;
            case 1: drawVerticalSegment(g, x+3+ 30, y+ 21); break;
            case 2: drawVerticalSegment(g, x+3+ 30, y+ 41); break;
            case 3: drawHorizontalSegment(g, x+3+ 13, y+ 58); break;
            case 4: drawVerticalSegment(g, x+3+ 10, y+ 41); break;
            case 5: drawVerticalSegment(g, x+3+ 10, y+ 21); break;
            case 6: drawHorizontalSegment(g, x+3+ 13, y+ 38); break;
        }
    }
    
  }

  private void drawHorizontalSegment(Graphics g, int x, int y) {
      g.drawLine(x+1, y, x+1+15, y);
      g.drawLine(x, y+1, x+17, y+1);
      g.drawLine(x, y+2, x+17, y+2);
      g.drawLine(x+1, y+3, x+1+15, y+3);
  }
  
  private void drawVerticalSegment(Graphics g, int x, int y) {
      g.drawLine(x, y+1, x, y+1+15);
      g.drawLine(x+1, y, x+1, y+17);
      g.drawLine(x+2, y, x+2, y+17);
      g.drawLine(x+3, y+1, x+3, y+1+15);
  }
  
}