CXX = g++-7

INCLUDES = -lstdc++fs -lpthread 

CXXFLAGS = -std=c++17 -O2 

parallel: par_cmp.o
	$(CXX) $(CXXFLAGS) par_cmp.cpp $(INCLUDES) -o parallel

par_cmp.o:

.PHONY: clean
clean:
	rm -f *~ *.o a.out core parallel

.PHONY: all
all: clean parallel
