CXX = g++

INCLUDES =

CXXFLAGS = -std=c++17 $(INCLUDES) -O2

test: select_contracts_2.o
	$(CXX) $(CXXFLAGS) select_contracts_2.o -lstdc++fs -lpthread -o test 

select_contracts_2.o: 

.PHONY: clean
clean:
	rm -f *~ *.o a.out core test multi_thread/* single_thread/*

.PHONY: all
all: clean test
