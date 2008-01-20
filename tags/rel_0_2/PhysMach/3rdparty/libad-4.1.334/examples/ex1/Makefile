# GNU Makefile to build examples

INCLUDES = -I../../include

include Makefile.i

OBJECTS = $(SOURCE:.c=.o)

all: $(NAME)

clean:
	rm -f $(OBJECTS) $(NAME)

$(NAME): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ -L../../lib -lad4
