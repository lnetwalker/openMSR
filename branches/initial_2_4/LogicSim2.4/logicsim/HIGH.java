package logicsim;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class HIGH extends Gate {
  static final long serialVersionUID = -1012596625872465916L;

  public HIGH() {
    out[0]=true;
  }

  public int getNumInput() {
    return 0;
  }
  public int getNumOutput() {
    return 1;
  }
  
  public void reset() {
      out[0]=true;
  }
}