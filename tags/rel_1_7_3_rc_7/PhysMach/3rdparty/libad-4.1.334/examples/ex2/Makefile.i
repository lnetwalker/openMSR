# makefile to build ex2

NAME = ex2

CFLAGS = -Wall $(INCLUDES)

SOURCE = main.c

LIBS = \
  -L$(SRC)/libad4/lib/$(ARCH)/$(CPU) -lad4^

#  $(SRC)/libos/$(ARCH)/$(CPU)/libos^.pre.a

