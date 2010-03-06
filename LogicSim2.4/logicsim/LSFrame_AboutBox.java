package logicsim;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.geom.*;

public class LSFrame_AboutBox extends JWindow {
  Toolkit toolkit = Toolkit.getDefaultToolkit ();
  Image imgSplash;
  SplashPanel splashPanel = new SplashPanel();


  public LSFrame_AboutBox(Frame parent) {
    super(parent);
    Dimension scrSize;
    int imgWidth, imgHeight;

    this.imgSplash = new ImageIcon(logicsim.LSFrame.class.getResource("images/about.jpg")).getImage();

    imgWidth = imgSplash.getWidth(this);
    imgHeight = imgSplash.getHeight(this)+100;
    scrSize = toolkit.getScreenSize();
    setLocation ( ( scrSize.width / 2 ) - ( imgWidth / 2 ),
                 ( scrSize.height / 2 ) - ( imgHeight / 2 ) );
    setSize ( imgWidth, imgHeight );
    getContentPane().setLayout(new BorderLayout(0,0));
    getContentPane().add(splashPanel,"Center");
    this.enableEvents(AWTEvent.MOUSE_EVENT_MASK);

    this.show();
  }

  protected void processMouseEvent(MouseEvent e) {
    super.processMouseEvent(e);
    int id = e.getID();
    if (id==MouseEvent.MOUSE_CLICKED) {
      this.hide();
      this.dispose();
    }
  }

  class SplashPanel extends JPanel
  {
    public void paint ( Graphics g )
    {
      g.setColor(Color.black);
      g.fillRect(0,0,getWidth(), getHeight());
      g.drawImage ( imgSplash, 0, 0, this );

      Graphics2D g2 = (Graphics2D)g;
//      g2.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
      g2.setColor(Color.white);


      FontMetrics fm = g2.getFontMetrics();
      Font of = fm.getFont();
      Font f=new Font(of.getName(), of.getStyle(), 12);
      g2.setFont(f);

      //g2.drawString("Version 2.0 2001/06/06", 10, 240);
      String version=App.class.getPackage().getImplementationVersion();
      g2.drawString("Version "+version, 10, 240);
      //g2.drawString("Version 2.3.3 2007-08-02", 10, 240);
      g2.drawString("Copyright (c) 1995-2009 by Andreas Tetzl", 10, 260);
      g2.drawString("andreas@tetzl.de         www.tetzl.de", 10, 280);
      g2.drawString("This program is free software", 250, 240);
      g2.drawString("Released under the GPL", 250, 280);
      //g2.drawString("Please send me an eMail.", 250, 280);

      //g2.drawString("Artwork by Jens Borsdorf, www.jens-borsdorf.de", 10, 310);


    }
  }

}