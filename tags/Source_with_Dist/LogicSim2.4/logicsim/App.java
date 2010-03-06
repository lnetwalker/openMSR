package logicsim;

import java.awt.*;
import java.awt.event.WindowEvent;
import javax.swing.*;
import java.io.*;
import javax.swing.plaf.basic.BasicInternalFrameUI;


public class App {
    
    LSFrame lsframe;
    
    /**Construct the application*/
    public App() {
        new I18N();
        JFrame frame = new MyFrame();
        lsframe = new LSFrame(frame);
        ((BasicInternalFrameUI) lsframe.getUI()).setNorthPane(null);
        lsframe.setBorder(null);
        frame.getContentPane().add(lsframe);
        
        lsframe.window=frame;
        
        //Image si = new ImageIcon(App.class.getResource("images/splash.jpg")).getImage();
        //Splash splash = new Splash(frame, si);
        
        
        lsframe.validate();
        frame.validate();
        //Center the window
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        Dimension frameSize = new Dimension(1024,768);
        if (frameSize.height > screenSize.height) {
            frameSize.height = screenSize.height;
        }
        if (frameSize.width > screenSize.width) {
            frameSize.width = screenSize.width;
        }
        lsframe.setSize(frameSize);
        frame.setSize(frameSize);
        lsframe.setLocation((screenSize.width - frameSize.width) / 2, (screenSize.height - frameSize.height) / 2);
        frame.setLocation((screenSize.width - frameSize.width) / 2, (screenSize.height - frameSize.height) / 2);
        lsframe.setVisible(true);
        frame.setVisible(true);
        
    }
    
    /**Main method*/
    public static void main(String[] args) {
        try {
            //UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch(Exception e) {
            e.printStackTrace();
        }
        new App();
    }
    
    public static String getModulePath() {
        
        File f=new File("");
        String fname=f.getAbsolutePath() + "/modules/";
        f=new File(fname);
        if (f!=null && f.exists() && f.isDirectory()) {
            return new String(f.getAbsolutePath() + "/");
        } else {
            JOptionPane.showMessageDialog(null, "Directory modules not found.\nPlease run the program from its directory");
            System.exit(0);
        }
        
        return "";
    }
    
    
    class MyFrame extends JFrame {
    	static final long serialVersionUID = -6532037559895208999L;
        public MyFrame() {
            super();
            enableEvents(AWTEvent.WINDOW_EVENT_MASK);
        }
        /**Overridden so we can exit when window is closed*/
        protected void processWindowEvent(WindowEvent e) {
            if (e.getID() == WindowEvent.WINDOW_CLOSING)
                if (lsframe.showDiscardDialog(I18N.getString("MENU_EXIT"))==false)
                    return;
            super.processWindowEvent(e);
            if (e.getID() == WindowEvent.WINDOW_CLOSING) {
                lsframe.jMenuFileExit_actionPerformed(null);
            }
        }
        
    }
}