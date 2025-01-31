CC = gcc
CFLAGS = -g -Wall -std=c99 -I${GOLDILOCKS_HOME}/include
LIB = -L$(GOLDILOCKS_HOME)/lib -lgoldilocksc -lgoldilocks -lpthread -ldl -lm -lrt

TARGET = ss
OBJECTS = $(TARGET).o
SRCS = $(TARGET).c

$(TARGET): $(OBJECTS)
	$(CC) -o $(TARGET) $(OBJECTS) $(LIB)

$(OBJECTS): $(SRCS)
	$(CC) $(CFLAGS) -c $(SRCS)

clean:
	rm -f $(TARGET) $(OBJECTS)

