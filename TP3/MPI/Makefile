CC = /usr/local/bin/mpicxx
SOURCES = src/matrix.cpp src/crs_mpi.cpp src/mpi_main.cpp
NAME = mpi

CFLAGS = -O3 -g
INCLUDES = -I include
NAMES = mpi normal

OUT=obj

OBJECTS := $(patsubst src/%.cpp, obj/%.o, $(SOURCES))

all: $(OUT) $(OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(NAME) $(OBJECTS)

$(OUT):
	  mkdir -p $@

obj/matrix.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c src/matrix.cpp -o obj/matrix.o

obj/crs_mpi.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c src/crs_mpi.cpp -o obj/crs_mpi.o

obj/mpi_main.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c src/mpi_main.cpp -o obj/mpi_main.o


clean:
	$(RM) -r obj
	$(RM) $(NAMES)
