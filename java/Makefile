.PHONY: build
build:
	javac -d out src/foo/Main.java src/foo/Point.java

.PHONY: run
run: build
	java -cp out -verbosegc foo.Main
