CC = g++
SOURCES = src/matrix.cpp src/main.cpp
NAME = pthreads

CFLAGS = -O3 -g -lpthread -fopenmp
INCLUDES = -I include

OUT=obj

OBJECTS := $(patsubst src/%.cpp, obj/%.o, $(SOURCES))

all: $(OUT) $(OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(NAME) $(OBJECTS)

$(OUT)/:
	  mkdir -p $@

obj/%.o: src/%.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	$(RM) -r obj
	$(RM) $(NAME)
