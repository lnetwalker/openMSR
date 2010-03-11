/* ===============================================================*/
/* Meter-Applet                                                   */
/*                                           V. 1.01 19.09.1997
/*                                                                           V. 1.0                 22.10.1996                   */
/*  R. Moros :                                                                                                                         */
/*                       University of Leipzig                                                                               */
/*                        Inst. of Technical Chemistry   (ITC)                                                   */  
/*                        e-mail:           moros@sonne.tachemie.uni-leipzig.de                   */ 
/*                        Home-Page: http://techni.tachemie.uni-leipzig.de/~jar/               */   
/*                        ITC-Page:  http://techni.tachemie.uni-leipzig.de                       */
/*                                                                                                                                              */
/* ---------------------------------------------------------------------------------------------------------------  */
/*                                                                                                                                             */
/*                                                                                                                                             */  
/* Permission to use, copy, modify and distribute this software and its        */
/* documentation without fee for NON-COMMERCIAL purposes is hereby  */
/* granted provided that this notice with a reference to the original source*/ 
/* andthe author appears in all copies or derivatives of this software.         */
/*                                                                                                                                             */
/* ----------------------------------------------------------------------------------------------------------------*/
/* Set the value x of the meter-applet via JavaScript                                           */
/*     Use the methode                                                                                                       */
/*              document.umeter.SetMeter(double x)                                                      */ 
/*                                                                                                                                              */
/* Set parameters of the meter by using                                                                   */
/*      1)Applet-Parameter                                                                                                 */
/*                                       NAME  TYPE                                                   DEFAULT       */
/*                                      header [String]                                                ""                      */
/*                                      unit        [String]                                                ""                      */
/*                                      digital   [String]  true: with the dig. part    "true"              */
/*                                                                      false: without                                              */ 
/*                                      analog  [String]  true: with the anal. part  "true"            */  
/*                                      xfrom    [float]      begin of range   (X-Min)       0                 */
/*                                      xto         [float]      end of range       (X-Max)     100              */
/*                                      x             [float]      initial value of x                       0                 */
/*                                      hbgcol  [String]   backgr.-color header       "lightgray"  */
/*                                      hfgcol   [String]   foregroundcol. header    "black"         */
/*                                      abgcol  [String]   backgroundcol. analog    "lightgray" */
/*                                      afgcol   [String]   foregroundcol. analog      "black"       */
/*                                      dbgcol  [String]   backgroundcol. digital      "lightgray" */
/*                                      dfgcol   [String]   foregroundcol. digital        "black"       */                                                              
/*                                      errcol   [String]    color if values are out of range "red"*/
/*                                                                                                                                               */
/*     2) - the methode SetParameter   via JavaScript                                             */
/*               if the name of the applet is umeter you can call the methode          */
/*               SetParameter of the applet by using                                                        */
/*                             document.umeter.SetParameter(header,unit,digital,           */
/*                                                                                              analog,xfrom,xto,x)           */ 
/*                                       NAME    TYPE                                                  DEFAULT     */
/*                                      header [String]                                                      ""               */
/*                                      unit        [String]                                                      ""               */
/*                                      digital   [String]  true: with the dig. part         "true"       */
/*                                                                      false: without                                             */ 
/*                                      analog  [String]  true: with the anal. part       "true"      */  
/*                                      xfrom    [float]      begin of range   (X-Min)            0           */
/*                                      xto         [float]      end of range       (X-Max)         100        */
/*                                      x             [float]      initial value of x                            0           */ 
/*                                                                                                                                              */
/*                                                                                                                                              */
/*         - in order to set the colors via JavaScript                                                     */
/*            use the method                                                                                                   */
/*             document.umeter.SetColors(hbgcol,hfgcol,                                             */
/*                                                                     abcol,afgcol,                                                */
/*                                                                     dbgcol,dfgcol)                                             */
/*                                                                                                                                              */ 
/*                                       NAME   TYPE                                                       DEFAULT   */
/*                                      hbgcol  [String]   backgr.-color header       "lightgray"  */
/*                                      hfgcol   [String]   foregroundcol. header    "black"         */
/*                                      abgcol  [String]   backgroundcol. analog    "lightgray"  */
/*                                      afgcol   [String]   foregroundcol. analog      "black"        */
/*                                      dbgcol  [String]   backgroundcol. digital      "lightgray"  */
/*                                      dfgcol   [String]   foregroundcol. digital        "black"        */                                                              
/*                                      errcol   [String]    color if values are out of range "red"*/                                                              
/*                                                                                                                                               */
/*  LIST of COLORS:                                                                                                            */
/*      "white","black","lightgray","gray","darkgray","red","green","blue"      */
/*      "yellow","magenta","cyan","pink","orange"                                                    */
/*                                                                                                                                                */
/* =============================================================== */
import java.awt.*;
import java.applet.Applet;
 

public class Meter extends Applet  implements Runnable 
{
  Thread runner;
  int delayGlb= 0;            // the refresh/update time 
  int Mhe;
  int Mwi;
  int Hhe;
  int Dhe;
  int Ahe;
  double XMin;                            
  double XMax; 
  double XNew;
  double XOld; 
  boolean WHeader;   // true : with header
  boolean WDigital;     // true: with digital part
  boolean WAnalog;   // true: with analog part
  String Header;            
  String Unit;

  String iStr; 
   boolean CHANGED;

   //Colors
  Color HBGColor;     // Header Background 
  Color HFGColor;     // Header Foreground
  Color ABGColor;     // Analog Background
  Color AFGColor;    // Analog Foreground;
  Color DBGColor;     // Digital Background;
  Color DFGColor;     // Digital Foreground;
  Color ERRColor;       // Color if values are out of range


  //double-buffering
  Image oimg;
  Graphics og;


//INIT
 public void init()
 {   // Set Colors
       HBGColor = Color.lightGray;
       ABGColor = Color.lightGray;
       DBGColor = Color.lightGray;
 
       HFGColor = Color.black;
       AFGColor = Color.black;
       DFGColor = Color.black;
  
       ERRColor = Color.red;

     // INIT  - PARAMETER
       iStr = getParameter("header");
       if (iStr != null) {WHeader = true;
                                    Header = iStr;
                                  }
       else {WHeader = false;
                  Header    = "";
                 }

       iStr = getParameter("unit");
       if (iStr != null) {Unit = iStr;}
       else {Unit = "";}

       iStr = getParameter("digital");
       if (iStr != null) {if  ( iStr.equals("false")) WDigital = false;
                                   else WDigital = true;
                                  }
       else {WDigital = true;}

       iStr = getParameter("analog");
       if (iStr != null) {if (iStr.equals("false")) WAnalog = false;
                                   else WAnalog = true;
                                  }
       else {WAnalog = true;}


       iStr = getParameter("xfrom");
       if  (iStr != null) {XMin = Float.valueOf(iStr).floatValue();}
       else {XMin = 0;}
       
       iStr = getParameter("xto");
       if  (iStr != null) {XMax = Float.valueOf(iStr).floatValue();}
       else {XMax = 100;}

      iStr = getParameter("x");
      if (iStr != null) {XNew = Float.valueOf(iStr).floatValue();}
      else {XNew = 0;}

    // COLOR-Parameters
     iStr = getParameter("hbgcol");
     if (iStr != null) {HBGColor = WhichColor(HBGColor,iStr);}


     iStr = getParameter("hfgcol");
     if (iStr != null) {HFGColor = WhichColor(HFGColor,iStr);}

     iStr = getParameter("abgcol");
     if (iStr != null) {ABGColor = WhichColor(ABGColor,iStr);}

     iStr = getParameter("afgcol");
     if (iStr != null) {AFGColor = WhichColor(AFGColor,iStr);}

     iStr = getParameter("dbgcol");
     if (iStr != null) {DBGColor = WhichColor(DBGColor,iStr);}

     iStr = getParameter("dfgcol");
     if (iStr != null) {DFGColor = WhichColor(DFGColor,iStr);}

     iStr = getParameter("errcol");
     if (iStr != null) {ERRColor = WhichColor(ERRColor,iStr);}


    //END of PARAMETER 

    Mhe = this.size().height;
    Mwi  = this.size().width;
    if (WHeader==true) {Hhe  = Mhe / 5;}                       // height of the header
    else Hhe=0;
    if (WDigital==true) {Dhe  = Mhe / 5;}                         // height of the digital instrument
    else Dhe = 0;
    if (WAnalog==true) {Ahe  = Mhe - Hhe - Dhe;}      // height of the analog instrument
    else
    { Ahe = 0; 
       if (WDigital==true) 
       { if (WHeader == true)
          {Hhe = Mhe /3;
            Dhe = Mhe - Hhe;
           }// DIGITAL with header
          else 
          {Hhe = 0;
            Dhe = Mhe;
          }// DIGITAL without header
       }// WITHOUT ANA
       else    // only header (!!!)
       {Hhe = Mhe;
       }
    }


     //double-buffering
     oimg = createImage(this.size().width,this.size().height);
     og      = oimg.getGraphics();
  
    
      XOld = XNew;

      CHANGED = true;

  } // END of INIT





// SETMETER
// Set the value of the meter via
//  document.meter.SetMeter(double V) (JavaScript)
 public void SetMeter(double V)
 { XNew = V; 
   CHANGED=true;
    repaint();    
  }// END of SETMETER


//GETX 
 public double GetX()
 { boolean DB = Changed();
     return XOld;
 }//End of GETX DOUBLE
 

// CHANGED
 public boolean Changed()
 {  boolean DB;
     if (CHANGED==true) {XOld = XNew;
                                               CHANGED = false;
                                                DB = true;
                                              }
    else {DB = false;}
    return DB;
  }// End of CHANGED 

//WhichColor
 public Color WhichColor(Color old, String s)
 { Color c = new Color(0,0,0);
    c = old; 
    
   String ds = s.toUpperCase();
    if (ds.equals("WHITE")==true) { c= Color.white;}
    else
    {if (ds.equals("BLACK")==true) {c =Color.black;}
      else
      {if (ds.equals("LIGHTGRAY")==true) {c = Color.lightGray;}
        else 
        {if (ds.equals("GRAY")==true) {c = Color.gray;}
          else
          {if (ds.equals("DARKGRAY")==true) {c = Color.darkGray;}
            else
            {if (ds.equals("RED")==true) {c= Color.red;}
              else 
              {if (ds.equals("GREEN")==true) {c= Color.green;}
                 else
                 {if (ds.equals("BLUE")==true) {c = Color.blue;}
                    else
                    {if (ds.equals("YELLOW")==true) {c = Color.yellow;}
                       else
                       {if (ds.equals("MAGENTA")==true) {c = Color.magenta;}
                         else
                          {if (ds.equals("CYAN")==true) {c = Color.cyan;}
                            else 
                            {if (ds.equals("PINK")==true) {c = Color.pink;}
                               else
                               {if (ds.equals("ORANGE")==true) {c = Color.orange;}
                               }    
                            } 
                          }
                       }  
                    }
                 }
              } 
            }
          }
        }   
       }
    } 
  return c;
  }//END of WhichCoor


//SETCOLORS
 public void SetColors(String hbgcolor,
                                            String hfgcolor,
                                            String abgcolor,
                                            String afgcolor,
                                            String dbgcolor,
                                            String dfgcolor,
                                            String errcolor)
 {
      if (hbgcolor.length()!=0) HBGColor = WhichColor(HBGColor,hbgcolor);
      if (hfgcolor.length()!=0)  HFGColor =  WhichColor(HFGColor,hfgcolor);
      if (abgcolor.length()!=0) ABGColor = WhichColor(ABGColor,abgcolor);
      if (afgcolor.length()!=0)  AFGColor = WhichColor(AFGColor,afgcolor);
      if (dbgcolor.length()!=0) DBGColor = WhichColor(DBGColor,dbgcolor);
      if (dfgcolor.length()!=0)  DFGColor = WhichColor(DFGColor,dfgcolor);
      if (errcolor.length()!=0)  ERRColor = WhichColor(ERRColor,errcolor);

     repaint();    

  }//End of SETCOLORS


//SETPARAMETER
// this method is used to set parameters via JavaScript by 
// using document.meter.SetParameter(list of parameter)
 public void SetParameter(String head,
                                                    String unit,
                                                    String digital,
                                                    String analog,
                                                    float xfrom,
                                                    float xto,
                                                    float x)
 { 
    Header = head;
    if (Header.length()==0)   WHeader=false;
                                        else  WHeader=true; 
    Unit = unit;
    if (digital.equals("false")==true) WDigital=false;
                                                 else         WDigital=true; 

    if (analog.equals("false")==true) WAnalog=false;
                                                  else         WAnalog=true;
    XMin = xfrom;
    XMax = xto;
    XNew = x;
    XOld = XNew;
    CHANGED=true; 

    //Recalculation
    if (WHeader==true) {Hhe  = Mhe / 5;}                       // height of the header
    else Hhe=0;
    if (WDigital==true) {Dhe  = Mhe / 5;}                         // height of the digital instrument
    else Dhe = 0;
    if (WAnalog==true) {Ahe  = Mhe - Hhe - Dhe;}      // height of the analog instrument
    else
    { Ahe = 0;
       if (WDigital==true) 
       { if (WHeader == true)
          {Hhe = Mhe /3;
            Dhe = Mhe - Hhe;
           }// DIGITAL with header
          else 
          {Hhe = 0;
            Dhe = Mhe;
          }// DIGITAL without header
       }// WITHOUT ANA
       else    // only header (!!!)
       {Hhe = Mhe;
       }
    }

    //
    repaint(); 


 } // End of SetParameter 

// RUN
 public void run()
 { repaint();
    if (delayGlb != 0)       // it will be used in the future
    {   while (true)
        { pause(delayGlb);
           if (Changed()==true)
           { repaint();
         }
    }//end of dealyGlb != 0
   } 
 }// End of RUN 


// START
 public void start()
 {if (runner == null)
      {runner = new Thread(this);
       runner.start();
     }
  }// End of START


// STOP 
 public void stop()
 {
     if (runner != null)
    {runner.stop();
     runner = null;
     }
  }// End of STOP 


// Pause
   void pause(int time)
   {
     try { Thread.sleep(time);}
     catch (InterruptedException e) {}
   }  

//UPDATE
public void update(Graphics g)
{paint(g);
}

// PAINT
 public void paint(Graphics g)
 { Font f;
    FontMetrics fm;
    String s;
     int i;
     int x,y;
     double XN;
     int Fhe,fhe;
     int xc,yc,r,lz;
     int x1,y1,x2,y2;
     int fx,fy,lx,ly;
     double dx;
     double xx;
     double VAlpha;
     double VAlphaRad; 
     boolean OutOfRange;


/* ============================= FRAMES =========================== */
    // draw the main frame 
    og.setColor(Color.black);
    og. drawRect(0,0,Mwi-1,Mhe-1);

   // draw the  frame around the header
  if  (WHeader ==true)
  {   og.setColor(HBGColor);
       og.fillRect(0,0,Mwi-1,Hhe-1);
       og.setColor(Color.black);
       og.drawRect(0,0,Mwi-1,Hhe-1);
  }
  // draw the frame around the anal. instr.
  if (WAnalog==true)
  {  og.setColor(ABGColor);
     og.fillRect(0,Hhe,Mwi-1,Ahe-1);
     og.setColor(Color.black);
     og.drawRect(0,Hhe,Mwi-1,Ahe-1);
  }
  // draw the frame around the dig. instr.
  if (WDigital==true)
  { og.setColor(DBGColor);
     og.fillRect(0,Hhe+Ahe,Mwi-1,Dhe-1);
     og.setColor(Color.black);
     og.drawRect(0,Hhe+Ahe,Mwi-1,Dhe-1);
   } 
  
  /*===================== HEADER ===========================*/ 
  // HEADER
  if (WHeader == true)
  {  Fhe = 21;  // Calculate the font
     do
     { Fhe--; 
        f     = new Font("TimesRoman",Font.PLAIN,Fhe);
        og.setFont(f);
        fm  = getFontMetrics(f);
        fhe= fm.getHeight();
    } while ((fhe+2)>Hhe);
 
       // print the header       
       x = (Mwi/2) - (fm.stringWidth(Header)/2);
       y = (Hhe/2) + (fhe/2) - 2;
       if (x>0) {og.setColor(HFGColor);
	  og.drawString(Header,x,y);
                     }
  } // End of HEADER  

/* ============================== ANALOG ======================= */
  // ANALOG
  if (WAnalog==true)
  {     fx=0; fy=0;lx=0;ly=0;   
        // Calculate the center and r
    
         if (Ahe < Mwi)
         { r = 3*Ahe / 5;
            lz = (Ahe/5) - 4;
            if (lz>10) {lz=10;}
         }
         else
         { r = 3*Mwi / 5;
            lz = (Mwi/5)-4;
            if (lz>10) {lz=10;}
          }          
          xc     = Mwi / 2 - r;
          yc     = Mhe - Dhe - (Ahe / 5) - r;

         og.setColor(AFGColor);          
          // draw the curve
         og.drawArc(xc,yc,(2*r),(2*r),0,180);          

         // draw the center point
        xc = Mwi/2;                                  // X-Center
        yc = Mhe - Dhe - (Ahe/5);        // Y-Center
        og.fillOval(xc-1,yc-1,2,2);

        // draw the markers
       dx =  (XMax - XMin) / 10.0; 
       for (i=1; i<=11;i++)
       { if (i==11) {xx = (XMax-XMin);}
         else {xx =  (i-1)*dx;}
        VAlpha =  180.0 - xx * (180 / (XMax - XMin)) ;
        // [GRAD] -> [RAD]
        VAlphaRad = (VAlpha * 2.0*Math.PI/360.0);
         //Begin
         x1 = xc + (int) (Math.round(r*Math.cos(VAlphaRad))); 
         y1 = yc  - (int) (Math.round(r*Math.sin(VAlphaRad)));
         //End
         x2 = xc + (int) (Math.round((r+lz)*Math.cos(VAlphaRad))); 
         y2 = yc  - (int) (Math.round((r+lz)*Math.sin(VAlphaRad)));
         //draw the line
         og.drawLine(x1,y1,x2,y2); 
         //notice the first and last x/y-position
         if (i==1)   {fx = x1; fy=y1;}
         if (i==11) {lx = x1; ly=y1;}                 
       }  
        //print the scale- text at th first and last position
         //calculate the font
           Fhe = 21;  // the large font
           do
           { Fhe--; 
              f     = new Font("TimesRoman",Font.PLAIN,Fhe);
              og.setFont(f);
              fm  = getFontMetrics(f);
              fhe= fm.getHeight();
            } while ((fhe+1)>(Ahe/5));
         //left
           s = String.valueOf(XMin);
           x =  fx+2;
           y =  fy+(fm.getHeight()/2)+1;
           og.setColor(AFGColor);
           og.drawString(s,x,y);
         
          //right
           s = String.valueOf(XMax);
           x = lx- fm.stringWidth(s)-2;
           y = ly+(fm.getHeight()/2)+1;
           if ((fm.stringWidth(s))< (r/2)) {og.setColor(AFGColor);
                                                                 og.drawString(s,x,y);
                                                                     }                    
         

        // draw the value
         // Calculate VAlpha [GRAD]
         XN = GetX();
         if (XN < XMin) {XN = XMin;
                                      OutOfRange=true;
                                     }
         else
         { if (XN > XMax) {XN = XMax;
                                         OutOfRange=true;
                                        }
           else {OutOfRange=false;}
         }       
     
         VAlpha = 180.0 - (XN-XMin)* (180.0 / (XMax - XMin));
         if (VAlpha < 0.0)  {VAlpha = 360.0 + VAlpha;}


         // [GRAD] -> [RAD]
        VAlphaRad = (VAlpha * 2.0*Math.PI/360.0);

         // Calculate the positions x,y
         x = xc + (int) (Math.round((r-2)*Math.cos(VAlphaRad))); 
         y = yc  - (int) (Math.round((r-2)*Math.sin(VAlphaRad)));

         // draw the line
         if (OutOfRange==true) {og.setColor(ERRColor);}
         else {og.setColor(AFGColor);}
         og.drawLine(xc,yc,x,y);



  } // End of ANALOG


/* ============================= DIGITAL ======================== */
  //DIGITAL
  if (WDigital == true)
 {  Fhe = 21;  // Calculate the font
     do
     { Fhe--; 
        f     = new Font("TimesRoman",Font.PLAIN,Fhe);
        og.setFont(f);
        fm  = getFontMetrics(f);
        fhe= fm.getHeight();
    } while ((fhe+2)>Dhe);
 
       // print the value       
       XN = GetX(); 
       if (XN < XMin) {OutOfRange=true;}
       else 
       { if (XN > XMax) {OutOfRange=true;}
         else {OutOfRange=false;}
       }       

       if (fm.stringWidth(Unit) == 0) {s = String.valueOf(XN);}
       else {s = String.valueOf(XN) + " "+Unit;}
       x = (Mwi/2) - (fm.stringWidth(s)/2);
       y = Mhe - (Dhe/2) + (fhe/2) - 2;         
       if (x>0) 
      { if (OutOfRange==true) {og.setColor(ERRColor);}
        else {og.setColor(DFGColor);}
        og.drawString(s,x,y);
       }


  }  // End of DIGITAL

  //DOUBLE-BUFFERING
 g.drawImage(oimg,0,0,this);

 }// End of PAINT 


}