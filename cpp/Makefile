CXX=g++
CXXFLAGS=-Wall -MMD -std=c++11

.PHONY: main
main :
	mkdir -p build; $(CXX) $(CXXFLAGS) -o build/main rb_tree.cpp

.PHONY: run
run : main
	./build/main
