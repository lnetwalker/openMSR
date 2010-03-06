package logicsim;

import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferedImage;
import javax.swing.*;
import java.io.*;
import java.util.Properties;
import javax.imageio.ImageIO;
import java.io.File;
import java.io.IOException;

public class LSFrame extends JInternalFrame implements java.awt.event.ActionListener {
    Object[] gateNames = {I18N.getString("GATE_SWITCH"), I18N.getString("GATE_LED"), I18N.getString("GATE_AND"), I18N.getString("GATE_NAND"),
    I18N.getString("GATE_OR"), I18N.getString("GATE_NOR"), I18N.getString("GATE_NOT"), I18N.getString("GATE_XOR"),
    I18N.getString("GATE_EQUIVALENCE"),
    "---", I18N.getString("GATE_NORMALINPUT"), I18N.getString("GATE_INPUT_INVERTER"),
    I18N.getString("GATE_INPUT_HIGH"), I18N.getString("GATE_INPUT_LOW"),
    "---", I18N.getString("GATE_RSFF"), I18N.getString("GATE_DFF"), I18N.getString("GATE_DRFF"), I18N.getString("GATE_JKFF"),
    I18N.getString("GATE_JKMSFF"), I18N.getString("GATE_TFF"),
    "---", I18N.getString("GATE_CLOCK"), I18N.getString("GATE_MONOFLOP"), I18N.getString("GATE_TURNONDELAY"), I18N.getString("GATE_TURNOFFDELAY"),
    "---", I18N.getString("GATE_BINARYINPUT"), I18N.getString("GATE_LCD"),  I18N.getString("GATE_DSIN"), I18N.getString("GATE_DSOUT"),I18N.getString("GATE_SEVENSEGMENT"),
    I18N.getString("GATE_TEXTLABEL"), "---"};
    int[] actions = { LSPanel.ACTION_SWITCH, LSPanel.ACTION_LED, LSPanel.ACTION_AND, LSPanel.ACTION_NAND,
    LSPanel.ACTION_OR, LSPanel.ACTION_NOR, LSPanel.ACTION_NOT, LSPanel.ACTION_XOR,
    LSPanel.ACTION_EQU, 0, LSPanel.ACTION_INNORM, LSPanel.ACTION_INNEG, LSPanel.ACTION_INHIGH,
    LSPanel.ACTION_INLOW, 0, LSPanel.ACTION_RSFF, LSPanel.ACTION_DFF, LSPanel.ACTION_DRFF, LSPanel.ACTION_JKFFC,
    LSPanel.ACTION_JKMSFF, LSPanel.ACTION_TFF, 0, LSPanel.ACTION_CLK,LSPanel.ACTION_MONOFLOP,
    LSPanel.ACTION_ONDELAY, LSPanel.ACTION_OFFDELAY, 0, LSPanel.ACTION_BININ, LSPanel.ACTION_LCD,
    LSPanel.ACTION_DSIN,LSPanel.ACTION_DSOUT,LSPanel.ACTION_SEVENSEGMENT,LSPanel.ACTION_TEXTLABEL,0 };
    
    String[] gateInputNums = {"2 "+I18N.getString("MESSAGE_INPUTS"),
                              "3 "+I18N.getString("MESSAGE_INPUTS"),
                              "4 "+I18N.getString("MESSAGE_INPUTS"),
                              "5 "+I18N.getString("MESSAGE_INPUTS") };
    String fileName = "./circuits/";
    
    JPopupMenu popup;
    JPopupMenu popup_list;
    JMenuItem menuItem_remove, menuItem_properties;
    JMenuItem menuItem_list_delmod;
    
    JPanel contentPane;
    JMenuBar jMenuBar1 = new JMenuBar();
    JMenu jMenuFile = new JMenu();
    JMenuItem jMenuFileExit = new JMenuItem();
    JMenu jMenuHelp = new JMenu();
    JMenuItem jMenuHelpAbout = new JMenuItem();
    JLabel statusBar = new JLabel();
    BorderLayout borderLayout1 = new BorderLayout();
    JPanel jPanel1 = new JPanel();
    JPanel jPanel_gates = new JPanel();
    
    DefaultListModel jList_gates_model = new DefaultListModel();
    JList jList_gates = new JList(jList_gates_model);
    LSPanel lspanel = new LSPanel(statusBar);
    JScrollPane jScrollPane_lspanel = new JScrollPane(lspanel);
    JSplitPane jSplitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, true);
    
    int popupGateIdx;  // das Gatter �ber dem das Kontext-Menu ge�ffnet wurde
    int popupModule;      // die Nummer des Listeneintrags, �ber dem das KM ge�ffnet wurde
    JScrollPane jScrollPane_gates = new JScrollPane();
    
    
    Simulate sim;
    public static boolean isApplet = false; // running as Applet
    public static JApplet applet=null;
    JFrame window; // window when running as application
    
    
    JButton jButton_open = new JButton();
    JButton jButton_new = new JButton();
    JButton jButton_save = new JButton();
    JToolBar jToolBar = new JToolBar();
    JToggleButton jToggleButton_simulate = new JToggleButton();
    JButton jButton_reset = new JButton();
    JMenu jMenuModule = new JMenu();
    JMenuItem jMenuItem_createmod = new JMenuItem();
    JMenuItem jMenuItem_modproperties = new JMenuItem();
    JMenuItem jMenuItem_exportimage = new JMenuItem();
    JMenuItem jMenuItem_print = new JMenuItem();
    BorderLayout borderLayout2 = new BorderLayout();
    JPanel jPanel2 = new JPanel();
    JComboBox jComboBox_numinput = new JComboBox(gateInputNums);
    BorderLayout borderLayout3 = new BorderLayout();
    JButton jButton_addpoint = new JButton();
    JMenuItem jMenuItem_new = new JMenuItem();
    JMenuItem jMenuItem_open = new JMenuItem();
    JMenuItem jMenuItem_save = new JMenuItem();
    JMenuItem jMenuItem_saveas = new JMenuItem();
    JMenuItem jMenuItem_help = new JMenuItem();
    Component component1;
    JButton jButton_delpoint = new JButton();
    Component component2;
    JMenu jMenuSettings = new JMenu();
    JCheckBoxMenuItem jCheckBoxMenuItem_paintGrid = new JCheckBoxMenuItem();
    JMenu jMenu_gatedesign = new JMenu();
    ButtonGroup buttongroup_gatedesign = new ButtonGroup();
    JRadioButtonMenuItem jMenuItem_gatedesign_din = new JRadioButtonMenuItem();
    JRadioButtonMenuItem jMenuItem_gatedesign_iso = new JRadioButtonMenuItem();
    JMenu jMenu_language = new JMenu();
    ButtonGroup buttongroup_language = new ButtonGroup();
    
    
    public static String gatedesign="din"; // globale statische Variable auf die auch von Gate aus zugegriffen werden kann
    Properties userProperties = new Properties();
    String use_language;
    
    /**Construct the frame*/
    public LSFrame(JApplet applet) {
        this.applet=applet;
        isApplet=true;
        try {
            jbInit();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    public LSFrame(JFrame window) {
        this.window=window;
        try {
            jbInit();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    
    public LSFrame() {
        
    }
    /**Component initialization*/
    private void jbInit() throws Exception  {
        
        //setIconImage(Toolkit.getDefaultToolkit().createImage(LSFrame.class.getResource("[Your Icon]")));
        contentPane = (JPanel) this.getContentPane();
        component1 = Box.createHorizontalStrut(8);
        component2 = Box.createHorizontalStrut(8);
        contentPane.setLayout(borderLayout1);
        if (window!=null) {
            //window.setSize(new Dimension(1024, 768));
            window.setTitle("LogicSim");
        }
        statusBar.setText(" ");
        jMenuFile.setText(I18N.getString("MENU_FILE"));
        jMenuFileExit.setText(I18N.getString("MENU_EXIT"));
        jMenuFileExit.setAccelerator(javax.swing.KeyStroke.getKeyStroke(88, java.awt.event.KeyEvent.CTRL_MASK, false));
        jMenuFileExit.addActionListener(new java.awt.event.ActionListener()  {
            public void actionPerformed(ActionEvent e) {
                jMenuFileExit_actionPerformed(e);
            }
        });
        jMenuHelp.setText(I18N.getString("MENU_HELP"));
        jMenuHelpAbout.setText(I18N.getString("MENU_ABOUT"));
        jMenuHelpAbout.addActionListener(new java.awt.event.ActionListener()  {
            public void actionPerformed(ActionEvent e) {
                jMenuHelpAbout_actionPerformed(e);
            }
        });
        jScrollPane_lspanel.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
        jScrollPane_lspanel.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        
        jPanel1.setLayout(borderLayout3);
        jButton_open.setIcon(new ImageIcon(logicsim.LSFrame.class.getResource("images/open.gif")));
        jButton_open.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jButton_open_actionPerformed(e);
            }
        });
        jButton_open.setToolTipText(I18N.getString("MENU_OPEN"));
        jButton_new.setIcon(new ImageIcon(logicsim.LSFrame.class.getResource("images/new.gif")));
        jButton_new.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jButton_new_actionPerformed(e);
            }
        });
        jButton_save.setIcon(new ImageIcon(logicsim.LSFrame.class.getResource("images/save.gif")));
        jButton_save.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jButton_save_actionPerformed(e);
            }
        });
        jButton_save.setToolTipText(I18N.getString("MENU_SAVE"));
        jToggleButton_simulate.setText(I18N.getString("BUTTON_SIMULATE"));
        jToggleButton_simulate.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jToggleButton_simulate_actionPerformed(e);
            }
        });
        jButton_reset.setText(I18N.getString("BUTTON_RESET"));
        jButton_reset.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jButton_reset_actionPerformed(e);
            }
        });
        jMenuModule.setText(I18N.getString("MENU_MODULE"));
        jMenuItem_createmod.setText(I18N.getString("MENU_CREATEMODULE"));
        jMenuItem_createmod.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jMenuItem_createmod_actionPerformed(e);
            }
        });
        jMenuItem_modproperties.setText(I18N.getString("MENU_MODULEPROPERTIES"));
        jMenuItem_modproperties.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jMenuItem_modproperties_actionPerformed(e);
            }
        });
        jMenuItem_exportimage.setText(I18N.getString("MENU_EXPORT"));
        jMenuItem_exportimage.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                exportImage();
            }
        });
        jMenuItem_print.setText(I18N.getString("MENU_PRINT"));
        jMenuItem_print.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jMenuItem_print_actionPerformed(e);
            }
        });
        jSplitPane.setOneTouchExpandable(true);
        //jSplitPane.setDividerLocation(120);
        // ** DM 26.12.2008 ** //
        jSplitPane.setDividerLocation(170);
        
        jPanel_gates.setLayout(borderLayout2);
        jList_gates.addMouseListener(new LSFrame_jList_gates_mouseAdapter(this));
        jPanel_gates.setPreferredSize(new Dimension(120, 200));
        jPanel_gates.setMinimumSize(new Dimension(80, 200));
        jButton_addpoint.setToolTipText(I18N.getString("TOOLTIP_ADDPOINT"));
        jButton_addpoint.setIcon(new ImageIcon(logicsim.LSFrame.class.getResource("images/addpoint.gif")));
        jButton_addpoint.addActionListener(new LSFrame_jButton_addpoint_actionAdapter(this));
        jMenuItem_new.setText(I18N.getString("MENU_NEW"));
        jMenuItem_new.setAccelerator(javax.swing.KeyStroke.getKeyStroke(78, java.awt.event.KeyEvent.CTRL_MASK, false));
        jMenuItem_new.addActionListener(new LSFrame_jMenuItem_new_actionAdapter(this));
        jMenuItem_open.setText(I18N.getString("MENU_OPEN"));
        jMenuItem_open.setAccelerator(javax.swing.KeyStroke.getKeyStroke(79, java.awt.event.KeyEvent.CTRL_MASK, false));
        jMenuItem_open.addActionListener(new LSFrame_jMenuItem_open_actionAdapter(this));
        jMenuItem_save.setText(I18N.getString("MENU_SAVE"));
        jMenuItem_save.setAccelerator(javax.swing.KeyStroke.getKeyStroke(87, java.awt.event.KeyEvent.CTRL_MASK, false));
        jMenuItem_save.addActionListener(new LSFrame_jMenuItem_save_actionAdapter(this));
        jMenuItem_saveas.setText(I18N.getString("MENU_SAVEAS"));
        jMenuItem_saveas.setAccelerator(javax.swing.KeyStroke.getKeyStroke(83, java.awt.event.KeyEvent.CTRL_MASK, false));
        jMenuItem_saveas.addActionListener(new LSFrame_jMenuItem_saveas_actionAdapter(this));
                
        jMenuItem_help.setText(I18N.getString("MENU_HELP"));
        jMenuItem_help.addActionListener(new LSFrame_jMenuItem_help_actionAdapter(this));
        jButton_delpoint.setToolTipText(I18N.getString("BUTTON_REMOVE_WIRE_POINT"));
        jButton_delpoint.setIcon(new ImageIcon(logicsim.LSFrame.class.getResource("images/delpoint.gif")));
        jButton_delpoint.addActionListener(new LSFrame_jButton_delpoint_actionAdapter(this));
        jMenuSettings.setText(I18N.getString("MENU_SETTINGS"));
        jCheckBoxMenuItem_paintGrid.setText(I18N.getString("MENU_PAINTGRID"));
        jCheckBoxMenuItem_paintGrid.setSelected(true);
        jCheckBoxMenuItem_paintGrid.addActionListener(new LSFrame_jCheckBoxMenuItem_paintGrid_actionAdapter(this));
        jMenuFile.add(jMenuItem_new);
        jMenuFile.add(jMenuItem_open);
        jMenuFile.add(jMenuItem_save);
        jMenuFile.add(jMenuItem_saveas);
        jMenuFile.add(jMenuItem_exportimage);
        jMenuFile.add(jMenuItem_print);
        jMenuFile.add(jMenuFileExit);
        jMenuHelp.add(jMenuHelpAbout);
        jMenuHelp.add(jMenuItem_help);
        jMenuBar1.add(jMenuFile);
        jMenuBar1.add(jMenuModule);
        jMenuBar1.add(jMenuSettings);
        jMenuBar1.add(jMenuHelp);
        this.setJMenuBar(jMenuBar1);
        contentPane.add(statusBar, BorderLayout.SOUTH);
        lspanel.setBackground(Color.white);
        jPanel_gates.add(jScrollPane_gates, BorderLayout.CENTER);
        jPanel_gates.add(jComboBox_numinput, BorderLayout.SOUTH);

        jSplitPane.add(jPanel_gates, JSplitPane.LEFT);
        jSplitPane.add(jScrollPane_lspanel, JSplitPane.RIGHT);
        contentPane.add(jSplitPane, BorderLayout.CENTER);
        jScrollPane_gates.getViewport().add(jList_gates, null);
        jToolBar.add(jButton_new, null);
        jToolBar.add(jButton_open);
        jToolBar.add(jButton_save);
        jToolBar.add(component1, null);
        jToolBar.add(jButton_addpoint, null);
        jToolBar.add(jButton_delpoint, null);
        jToolBar.add(component2, null);
        jToolBar.add(jToggleButton_simulate, null);
        jToolBar.add(jButton_reset, null);
        jPanel1.add(jToolBar, BorderLayout.CENTER);
        contentPane.add(jPanel1, BorderLayout.NORTH);
        jMenuModule.add(jMenuItem_createmod);
        jMenuModule.add(jMenuItem_modproperties);
        
        jMenu_gatedesign.setText(I18N.getString("MENU_GATEDESIGN"));
        buttongroup_gatedesign.add(jMenuItem_gatedesign_din);
        buttongroup_gatedesign.add(jMenuItem_gatedesign_iso);
        jMenuItem_gatedesign_din.setText(I18N.getString("MENU_GATEDESIGN_DIN"));
        jMenuItem_gatedesign_iso.setText(I18N.getString("MENU_GATEDESIGN_ISO"));
        jMenu_gatedesign.add(jMenuItem_gatedesign_din);
        jMenu_gatedesign.add(jMenuItem_gatedesign_iso);
        jMenuItem_gatedesign_din.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jMenuItem_gatedesign_actionPerformed(e);
            }
        });
        jMenuItem_gatedesign_iso.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(ActionEvent e) {
                jMenuItem_gatedesign_actionPerformed(e);
            }
        });
        
        
        // Properties laden und Men�punkte entsprechend setzen
        boolean paintgrid=true;
        jMenuItem_gatedesign_din.setSelected(true);
        use_language="en";
        try {
            //userProperties.load(new FileInputStream("logicsim.cfg"));
            if (this.isApplet==true) {
                java.net.URL url=new java.net.URL(this.applet.getCodeBase()+"logicsim.cfg");
                userProperties.load(url.openStream());
            } else {
                userProperties.load(new FileInputStream("logicsim.cfg"));
            }
            
            if (userProperties.containsKey("paint_grid"))
                paintgrid=userProperties.getProperty("paint_grid").equals("true");
            String s=userProperties.getProperty("gatedesign");
            if (s!=null && s.equals("iso")) {
                jMenuItem_gatedesign_iso.setSelected(true);
                LSFrame.gatedesign="iso";
            }
            if (userProperties.containsKey("language"))
                use_language=userProperties.getProperty("language");
        } catch (Exception ex) {
        }
        
        jMenu_language.setText(I18N.getString("MENU_LANGUAGE"));
        create_language_menu(jMenu_language, use_language);
        
        jCheckBoxMenuItem_paintGrid.setSelected(paintgrid);
        lspanel.setPaintGrid(paintgrid);
        jMenuSettings.add(jCheckBoxMenuItem_paintGrid);
        jMenuSettings.add(jMenu_gatedesign);
        jMenuSettings.add(jMenu_language);
        
        
        
        //Create the popup menu.
        popup = new JPopupMenu();
        menuItem_remove = new JMenuItem(I18N.getString("MENU_REMOVEGATE"));
        menuItem_remove.addActionListener(this);
        popup.add(menuItem_remove);
        menuItem_properties = new JMenuItem(I18N.getString("MENU_PROPERTIES"));
        menuItem_properties.addActionListener(this);
        popup.add(menuItem_properties);
        //Add listener to components that can bring up popup menus.
        lspanel.addMouseListener(new PopupListener());
        
        popup_list = new JPopupMenu();
        menuItem_list_delmod = new JMenuItem(I18N.getString("MENU_DELETEMODULE"));
        menuItem_list_delmod.addActionListener(this);
        popup_list.add(menuItem_list_delmod);
        jList_gates.addMouseListener(new PopupListener());
        
        fillGateList();
        
        this.requestFocus();
    }
    /**File | Exit action performed*/
    public void jMenuFileExit_actionPerformed(ActionEvent e) {
        if (showDiscardDialog(I18N.getString("MENU_EXIT"))==false) return;
        System.exit(0);
    }
    /**Help | About action performed*/
    public void jMenuHelpAbout_actionPerformed(ActionEvent e) {
        LSFrame_AboutBox dlg = new LSFrame_AboutBox(window);
        //JOptionPane.showMessageDialog(this, "LogicSim 2.0 BETA\n\nCopyright 2001 Andreas Tetzl\nandreas@tetzl.de\nwww.tetzl.de");
    }
    
    public void actionPerformed(ActionEvent e) {   // popup menu
        JMenuItem source = (JMenuItem)(e.getSource());
        if (source==menuItem_remove) {
            lspanel.gates.remove(popupGateIdx);
            lspanel.repaint();
        } else if (source==menuItem_properties) {
            if (popupGateIdx>=0) {
                Gate g=lspanel.gates.get(popupGateIdx);
                g.showProperties(this);
                lspanel.repaint();
            }
        } else if (source==menuItem_list_delmod) {
            if (isApplet) return;
            String fname=App.getModulePath() + jList_gates_model.getElementAt(popupModule) + ".mod";
            String s=I18N.getString("MESSAGE_DELETE").replaceFirst("%s", fname);
            int r=JOptionPane.showConfirmDialog(this, s);
            if (r==0) {
                File f=new File(fname);
                f.delete();
                fillGateList();
            }
        }
    }
    
    
    class PopupListener extends MouseAdapter {
        public void mousePressed(MouseEvent e) { maybeShowPopup(e); }
        public void mouseReleased(MouseEvent e) { maybeShowPopup(e); }
        private void maybeShowPopup(MouseEvent e) {
            if (e.isPopupTrigger()) {
                if (e.getSource()==lspanel) {
                    for (int i=0; i<lspanel.gates.size(); i++) {
                        Gate g=lspanel.gates.get(i);
                        if (g.inside(e.getX(), e.getY())) {
                            popupGateIdx=i;
                            menuItem_properties.setEnabled(g.hasProperties());
                            popup.show(e.getComponent(), e.getX(), e.getY());
                            break;
                        }
                    }
                } else if (e.getSource()==jList_gates) {
                    int idx=jList_gates.locationToIndex(e.getPoint());
                    if (idx>=actions.length) {
                        popupModule=idx;
                        popup_list.show(e.getComponent(), e.getX(), e.getY());
                    }
                }
            }
        }
    }
    
    
    void jButton_addpoint_actionPerformed(ActionEvent e) {
        lspanel.setAction(LSPanel.ACTION_ADDPOINT);
    }
    void jButton_delpoint_actionPerformed(ActionEvent e) {
        lspanel.setAction(LSPanel.ACTION_DELPOINT);
    }
    
    
    void jToggleButton_simulate_actionPerformed(ActionEvent e) {
        if (((JToggleButton)e.getSource()).isSelected()) {
            if (!(sim!=null && sim.running)) sim=new Simulate(lspanel);
        } else {
            if (sim!=null) sim.stop();
        }
    }
    
    void jButton_reset_actionPerformed(ActionEvent e) {
        //if (sim!=null) sim.reset();
        staticReset ();
        if (sim!=null) sim.reset();
    }
    
    // ** DM 26.12.2008 ** //
    // Statischer Reset. Wird ausgefuehrt, wenn die Simulation steht.
    void staticReset (){
        if (!(sim!=null && sim.running)) {
            lspanel.gates.simulate();
            for (int i=0; i<lspanel.gates.size(); i++) {
                Gate g = (Gate)lspanel.gates.get(i);
                g.reset();
            }
            
            lspanel.repaint();
            //lspanel.draw(lspanel.getGraphics());
            lspanel.gates.simulate();
            lspanel.gates.simulate();
        }
    }
    
    void showMessage(String s) {
        JOptionPane.showMessageDialog(this, s);
    }
    
    boolean showDiscardDialog(String title) {
        if (lspanel.changed) {
            int r=JOptionPane.showConfirmDialog(this, I18N.getString("MESSAGE_REALLYNEW"), title, JOptionPane.YES_NO_OPTION);
            if (r!=0) return false;
            lspanel.changed=false;
        }
        return true;
    }
    
    void jMenuItem_new_actionPerformed(ActionEvent e) {
        if (showDiscardDialog(I18N.getString("MENU_NEW"))==false) return;
        
        fileName="./circuits/";
        if (window!=null) {
            window.setTitle("LogicSim");
        }
        lspanel.gates.clear();
        lspanel.repaint();
    }
    
    void jMenuItem_open_actionPerformed(ActionEvent e) {
        if (isApplet) {
            showMessage(I18N.getString("ERROR_APPLET"));
            return;
        }
        
        if (showDiscardDialog(I18N.getString("MENU_OPEN"))==false) return;
        
        JFileChooser chooser = new JFileChooser(fileName);
        //chooser.setLocale(currentLocale);
        if (chooser.showOpenDialog(this)==JFileChooser.APPROVE_OPTION) {
            fileName = chooser.getSelectedFile().getAbsolutePath();
        } else return;  // FileChooser Cancel
        
        // **DM 26.12.2008 ** //
        // Simulation anhalten und einen Reset ausfuehren
        if (sim!=null) {
            sim.stop();
            jToggleButton_simulate.setSelected(false);
        }
        
        try {
            ObjectInputStream s = new ObjectInputStream(new FileInputStream(new File(fileName)));
            lspanel.gates = (GateList)s.readObject();
            s.close();
        } catch (FileNotFoundException x) {
            showMessage(I18N.getString("ERROR_FILENOTFOUND"));
        } catch (StreamCorruptedException x) {
            showMessage(I18N.getString("ERROR_FILECORRUPTED"));
        } catch (IOException x) {
            showMessage(I18N.getString("ERROR_READ"));
        } catch (ClassNotFoundException x) {
            showMessage(I18N.getString("ERROR_CLASS"));
        }
        
        if (window!=null) {
            window.setTitle("LogicSim - " + new File(fileName).getName());
        }
        
        lspanel.gates.reconnect();
        
        lspanel.repaint();
        lspanel.changed=false;
        
        staticReset();
    }
    
    void jMenuItem_save_actionPerformed(ActionEvent e) {
        if (isApplet) {
            showMessage(I18N.getString("ERROR_APPLET"));
            return;
        }
        
        if (fileName==null || fileName.length()==0 || fileName=="." || fileName=="./circuits/")
            if (showSaveDialog()==false) return;
        
        try {
            ObjectOutput s = new ObjectOutputStream(new FileOutputStream(new File(fileName)));
            s.writeObject(lspanel.gates);
            s.close();
        } catch (FileNotFoundException x) {
            showMessage(I18N.getString("ERROR_FILENOTFOUND"));
            return;
        } catch (IOException x) {
            showMessage(I18N.getString("ERROR_SAVE"));
            return;
        }
        
        if (window!=null) {
            window.setTitle("LogicSim - " + new File(fileName).getName());
        }
        String s=I18N.getString("STATUS_SAVED").replaceFirst("%s", fileName);
        statusBar.setText(s);
        fillGateList();
        lspanel.changed=false;
    }
    
    public boolean showSaveDialog() {
        JFileChooser chooser = new JFileChooser(fileName);
        chooser.setDialogTitle(I18N.getString("MESSAGE_SAVEDIALOG"));
        //chooser.setLocale(currentLocale);
        if (chooser.showSaveDialog(this)==JFileChooser.APPROVE_OPTION) {
            fileName = chooser.getSelectedFile().getAbsolutePath();
            return true;
        } else return false;  // FileChooser Cancel
    }
    
    void jMenuItem_saveas_actionPerformed(ActionEvent e) {
        if (isApplet) {
            showMessage(I18N.getString("ERROR_APPLET"));
            return;
        }
        
        if (showSaveDialog()==false) return;
        jMenuItem_save_actionPerformed(e);
    }    
    
    void jMenuItem_help_actionPerformed(ActionEvent e) {
        new HTMLHelp(use_language);
    }
    
    
    void jButton_open_actionPerformed(ActionEvent e) {
        this.jMenuItem_open_actionPerformed(e);
    }
    
    void jButton_save_actionPerformed(ActionEvent e) {
        this.jMenuItem_save_actionPerformed(e);
    }
    
    void jButton_new_actionPerformed(ActionEvent e) {
        this.jMenuItem_new_actionPerformed(e);
    }
    
    void jMenuItem_createmod_actionPerformed(ActionEvent e) {
        if (isApplet) {
            showMessage(I18N.getString("ERROR_APPLET"));
            return;
        }

        MODIN g=new MODIN();
        if (g.showProperties(this)==false) return;
        fileName=App.getModulePath() + g.ModuleName + ".mod";
        if (window!=null) {
            window.setTitle("LogicSim - " + new File(fileName).getName());
        }
        
        g.x=15;
        g.y=15;
        lspanel.gates.addGate(g);
        Gate g2=new MODOUT();
        g2.x=710;
        g2.y=15;
        lspanel.gates.addGate(g2);
        lspanel.repaint();
        
    }
    
  /*
  void jMenuItem_savemod_actionPerformed(ActionEvent e) {
    // nach MODIN suchen, weil Dateiname dort drin steht
    MODIN modin=null;
    for (int i=0; i<lspanel.gates.size(); i++) {
      Gate g=lspanel.gates.get(i);
      if (g instanceof MODIN)
        modin=(MODIN)g;
    }
    if (modin==null) {
      showMessage("create module first");
      return;
    }
   
    String fname=App.getModulePath() + modin.ModuleName + ".mod";
    System.out.println(fname);
    try {
      ObjectOutput s = new ObjectOutputStream(new FileOutputStream(new File(fname)));
      s.writeObject(lspanel.gates);
      s.close();
    } catch (FileNotFoundException x) {
      showMessage("File not found");
    } catch (IOException x) {
      showMessage("Error saving file");
    }
   
    fillGateList();
  }
   */
    
    void jMenuItem_modproperties_actionPerformed(ActionEvent e) {
        if (isApplet) {
            showMessage(I18N.getString("ERROR_APPLET"));
            return;
        }

        // nach MODIN suchen
        MODIN modin=null;
        for (int i=0; i<lspanel.gates.size(); i++) {
            Gate g=lspanel.gates.get(i);
            if (g instanceof MODIN)
                modin=(MODIN)g;
        }
        if (modin==null) {
            showMessage(I18N.getString("ERROR_NOMODULE"));
            return;
        }
        
        if (modin.showProperties(this)) {
            fileName=App.getModulePath() + modin.ModuleName + ".mod";
            if (window!=null) {
                window.setTitle("LogicSim - " + new File(fileName).getName());
            }
            fillGateList();
        }
    }
    
    void jMenuItem_print_actionPerformed(ActionEvent e) {
        lspanel.doPrint();
    }
    
    void exportImage() {
      String filename="logicsim.png";
      JFileChooser chooser = new JFileChooser();
      ExampleFileFilter filter = new ExampleFileFilter();
      filter.addExtension("png");
      filter.setDescription("PNG");
      chooser.setFileFilter(filter);

      chooser.setDialogTitle(I18N.getString("MESSAGE_SAVEDIALOG"));
      if (chooser.showSaveDialog(this)==JFileChooser.APPROVE_OPTION) {
        filename = chooser.getSelectedFile().getAbsolutePath();
      } else {
        return;  // FileChooser Cancel
      }
      
      BufferedImage image = (BufferedImage)this.createImage(this.lspanel.getWidth(), this.lspanel.getHeight());
      Graphics g = image.getGraphics();
      lspanel.gates.deactivateAll();
      lspanel.paint(g);
      try {
        ImageIO.write(image, "png", new File(filename));
      } catch (IOException ex) {
        ex.printStackTrace();
      }
    }
    
    void fillGateList() {
        jList_gates_model.clear();
        
        for (int i=0; i<gateNames.length; i++)
            jList_gates_model.addElement(gateNames[i]);
        
        
        if (isApplet) return;
        File mods = new File(App.getModulePath());
        String[] list = mods.list();
        java.util.Arrays.sort(list, String.CASE_INSENSITIVE_ORDER);

        
        for (int i=0; i<list.length; i++) {
            int idx=list[i].lastIndexOf(".mod");
            if (idx>0) {
                jList_gates_model.addElement(list[i].substring(0, idx));
            }
        }
        
    }
    
    
    void jList_gates_mouseClicked(MouseEvent e) {
        int sel=jList_gates.getSelectedIndex();
        if (sel<0) return;
        
        if (sel<actions.length) {  // normales Gatter aus der Liste
            int a=actions[sel];
            if (a!=-1) {
                switch(a) {
                    case LSPanel.ACTION_AND: case LSPanel.ACTION_NAND: case LSPanel.ACTION_OR:
                    case LSPanel.ACTION_NOR: case LSPanel.ACTION_XOR: case LSPanel.ACTION_EQU:
                        lspanel.setAction(a,new Integer(jComboBox_numinput.getSelectedItem().toString().substring(0,1)).intValue()); break;
                    default: lspanel.setAction(a); break;
                }
            }
        } else {    // Modul
            String s=(String)jList_gates.getSelectedValue();
            if (s!=null && s.length()>0) {
                Module mod = new Module(s);
                if (mod.moduleLoaded)
                    lspanel.setAction(LSPanel.ACTION_MODULE, mod);
            }
        }
        jList_gates.clearSelection();
    }
    
    void jCheckBoxMenuItem_paintGrid_actionPerformed(ActionEvent e) {
        lspanel.setPaintGrid(jCheckBoxMenuItem_paintGrid.isSelected());
        lspanel.repaint();
        this.userProperties.setProperty( "paint_grid", ""+jCheckBoxMenuItem_paintGrid.isSelected() );
        try {
            userProperties.store(new FileOutputStream("logicsim.cfg"), "LogicSim Configuration");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
    }
    
    void jMenuItem_gatedesign_actionPerformed(ActionEvent e) {
        // Gate Design ausgew�hlt
        String gatedesign=null;
        if (this.jMenuItem_gatedesign_din.isSelected())
            gatedesign="din";
        else
            gatedesign="iso";
        this.userProperties.setProperty( "gatedesign", gatedesign );
        LSFrame.gatedesign=gatedesign;
        this.lspanel.gates.reloadImages();
        this.lspanel.repaint();
        try {
            userProperties.store(new FileOutputStream("logicsim.cfg"), "LogicSim Configuration");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
    }
    
    void jMenuItem_language_actionPerformed(ActionEvent e, String name) {
        // Sprache ausgew�hlt
        this.userProperties.setProperty( "language", name );
        try {
            userProperties.store(new FileOutputStream("logicsim.cfg"), "LogicSim Configuration");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        showMessage(I18N.getString("MESSAGE_LANGUAGE_RESTART"));
    }
    
    void create_language_menu(JMenu menu, String activeitem) {
        if (isApplet) return;
        File dir = new File("languages/");
        String[] files=dir.list();
        java.util.Arrays.sort(files);
        for (int i=0; i<files.length; i++) {
            if (files[i].endsWith(".txt")) {
                final String name=files[i].substring(0, files[i].length()-4);
                JMenuItem item = new JRadioButtonMenuItem(name);
                if (name.equals(activeitem))
                    item.setSelected(true);
                item.addActionListener(new java.awt.event.ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        jMenuItem_language_actionPerformed(e, name);
                    }
                });
                buttongroup_language.add(item);
                menu.add(item);
            }
        }
    }
    
}

class LSFrame_jList_gates_mouseAdapter extends java.awt.event.MouseAdapter {
    LSFrame adaptee;
    
    LSFrame_jList_gates_mouseAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void mouseClicked(MouseEvent e) {
        adaptee.jList_gates_mouseClicked(e);
    }
}

class LSFrame_jButton_addpoint_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jButton_addpoint_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jButton_addpoint_actionPerformed(e);
    }
}

class LSFrame_jMenuItem_new_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jMenuItem_new_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jMenuItem_new_actionPerformed(e);
    }
}

class LSFrame_jMenuItem_open_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jMenuItem_open_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jMenuItem_open_actionPerformed(e);
    }
}

class LSFrame_jMenuItem_save_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jMenuItem_save_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jMenuItem_save_actionPerformed(e);
    }
}

class LSFrame_jMenuItem_saveas_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jMenuItem_saveas_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jMenuItem_saveas_actionPerformed(e);
    }
}

class LSFrame_jMenuItem_help_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jMenuItem_help_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jMenuItem_help_actionPerformed(e);
    }
}

class LSFrame_jButton_delpoint_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jButton_delpoint_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jButton_delpoint_actionPerformed(e);
    }
}

class LSFrame_jCheckBoxMenuItem_paintGrid_actionAdapter implements java.awt.event.ActionListener {
    LSFrame adaptee;
    
    LSFrame_jCheckBoxMenuItem_paintGrid_actionAdapter(LSFrame adaptee) {
        this.adaptee = adaptee;
    }
    public void actionPerformed(ActionEvent e) {
        adaptee.jCheckBoxMenuItem_paintGrid_actionPerformed(e);
    }
}