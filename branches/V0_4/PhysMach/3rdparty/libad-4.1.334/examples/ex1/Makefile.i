# makefile to build ex1

NAME = ex1

CFLAGS = -Wall $(INCLUDES)

SOURCE = main.c

LIBS = \
  -L$(SRC)/libad4/lib/$(ARCH)/$(CPU) -lad4^

