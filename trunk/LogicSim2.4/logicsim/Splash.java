package logicsim;

/**
 * Title:        ImageMap
 * Description:  client side imagemap creator
 * Copyright:    Copyright (c) 2001
 * Company:      webdesign-pirna.de
 * @author Andreas Tetzl
 * @version 1.0
 */

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class Splash extends JWindow  implements Runnable {
  Toolkit toolkit = Toolkit.getDefaultToolkit ();
  Image imgSplash;
  SplashPanel splashPanel = new SplashPanel();
  Thread thread;
  boolean running=true;

  public Splash ( Frame frm, Image imgSplash ) {
    super(frm);

    Dimension scrSize;
    int imgWidth, imgHeight;

    this.imgSplash = imgSplash;

    imgWidth = imgSplash.getWidth(this);
    imgHeight = imgSplash.getHeight(this);
    scrSize = toolkit.getScreenSize();
    setLocation ( ( scrSize.width / 2 ) - ( imgWidth / 2 ),
                 ( scrSize.height / 2 ) - ( imgHeight / 2 ) );
    setSize ( imgWidth, imgHeight );
    getContentPane().setLayout(new BorderLayout(0,0));
    getContentPane().add(splashPanel,"Center");
    this.enableEvents(AWTEvent.MOUSE_EVENT_MASK);

    thread = new Thread(this);
    thread.setPriority(Thread.MAX_PRIORITY);
    thread.start();

    show ();
    toFront ();
  }


  protected void processMouseEvent(MouseEvent e) {
    super.processMouseEvent(e);
    int id = e.getID();
    if (id==MouseEvent.MOUSE_CLICKED)
      running=false;
  }

  public void run()
  {
    for (int i=0; i<200 && running; i++) {

      try
      {
       thread.sleep(50);
      }
      catch(Exception e){}

      toFront();
    }
    hide();
  }

  class SplashPanel extends JPanel
  {
    public void paint ( Graphics g )
    {
      g.drawImage ( imgSplash, 0, 0, this );
    }
  }
}

