# Red Black Tree Benchmark

This directory contains an implementation of the Red/Black Tree GC benchmark in Julia, as
well as comparison implementations in various other languages.

You can run any of them by navigating to this directory, and running e.g. `make julia`.
- `make cpp`
- `make go`
- `make java`
- `make julia`

To run all the benchmarks, run:
- `make all`

The goal of this benchmark is to test _mark phase timings_ over a large, bushy pointer graph
from a tree structure, and to measure the effect they have on overall throughput.

