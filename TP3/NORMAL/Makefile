CC = g++
SOURCES = src/matrix.cpp src/crs_omp.cpp src/omp_main.cpp
NAME = normal

CFLAGS = -O3 -g -fopenmp
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

obj/crs_omp.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c src/crs_omp.cpp -o obj/crs_omp.o

obj/omp_main.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c src/omp_main.cpp -o obj/omp_main.o

clean:
	$(RM) -r obj
	$(RM) $(NAMES)
