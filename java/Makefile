.PHONY: build
build:
	javac -d out src/foo/Main.java src/foo/Point.java


# use G1 garbage collector
# - default on macos in java 19
# - concurrent marking
.PHONY: run
run-g1: build
	java -cp out -verbosegc -XX:+UseG1GC foo.Main

# use serial garbage collector
# - no concurrent marking
# - stops the world and uses one thread (?) for marking
# - similar to julia GC
.PHONY: run
run-serial-gc: build
	java -cp out -verbosegc -XX:+UseSerialGC foo.Main
