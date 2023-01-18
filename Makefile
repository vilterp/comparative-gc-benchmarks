.PHONY: julia
julia: julia/
	cd julia; make run

.PHONY: go
go: go/
	cd go; make run

.PHONY: java
java: java/
	cd java; make run

.PHONY: cpp
cpp: cpp/*
	cd cpp; make run

.PHONY: all
all: julia go java cpp
