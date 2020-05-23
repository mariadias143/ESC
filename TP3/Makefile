ifeq ($(MPI),yes)
	CC = mpicxx
	SOURCES = src/matrix.cpp src/crs_mpi.cpp src/mpi_main.cpp
	NAME = mpi
else
	CC = g++
	SOURCES = src/matrix.cpp src/crs_omp.cpp src/omp_main.cpp
	NAME = normal
endif

CFLAGS = -O3 -g -fopenmp
INCLUDES = -I include
NAMES = mpi normal

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
	$(RM) $(NAMES)
