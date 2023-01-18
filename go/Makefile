.PHONY: build
build: main.go
	go build main.go

.PHONY: run
run: build
	GODEBUG=gctrace=1 go run main.go
