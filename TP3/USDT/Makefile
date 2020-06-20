default: crs

sparseget.h: sparseget.d
	dtrace -h -s sparseget.d

crsdtrace.o: crsdtrace.cpp sparseget.h crsdtrace.h
	g++ -c crsdtrace.cpp sparseget.h

main.o:  main.cpp crsdtrace.h
	g++ -c main.cpp

crs.o: sparseget.d crsdtrace.o main.o
	dtrace -G -s sparseget.d crsdtrace.o main.o -o crs.o

crs: crs.o
	g++ -o crs crs.o crsdtrace.o main.o sparseget.h -lm -O3 -g -fopenmp

clean:
	$(RM) *.o
	$(RM) crs
	$(RM) sparseget.h
