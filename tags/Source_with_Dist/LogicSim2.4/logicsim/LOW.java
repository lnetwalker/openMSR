package logicsim;

/**
 * Title:        LogicSim
 * Description:  digital logic circuit simulator
 * Copyright:    Copyright (c) 2001
 * Company:
 * @author Andreas Tetzl
 * @version 1.0
 */

public class LOW extends Gate {
  static final long serialVersionUID = -5700587147010116562L;

  public LOW() {
    out[0]=false;
  }

  public int getNumInput() {
    return 0;
  }
  public int getNumOutput() {
    return 1;
  }
}