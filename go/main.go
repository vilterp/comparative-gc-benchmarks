package main

import (
	"fmt"
	"math/rand"
	"runtime"
	"time"

	"github.com/emirpasic/gods/queues/linkedlistqueue"
	"github.com/emirpasic/gods/trees/redblacktree"
)

type Point struct {
	x int
	y int
}

func main() {
	tvbench(10_000_000, 0, 600)
}

func tvbench(n int, minSeconds int, maxSeconds int) {
	pointsByX := redblacktree.NewWithIntComparator()
	pointsByY := redblacktree.NewWithIntComparator()
	queue := linkedlistqueue.New()

	count := 0
	// tcheck := 0
	// i := 0

	for {
		count = count + 1
		p := &Point{x: rand.Int(), y: rand.Int()}
		queue.Enqueue(p)
		pointsByX.Put(p.x, p)
		pointsByY.Put(p.y, p)

		if queue.Size() > n {
			pt, _ := queue.Dequeue()
			p = pt.(*Point)
			pointsByX.Remove(p.x)
			pointsByY.Remove(p.y)
		}

		remainder := count % 1_000_000
		if remainder == 0 {
			before := time.Now()
			runtime.GC()
			after := time.Now()

			fmt.Println("gc time:", after.Sub((before)))
			fmt.Println("count ", count)
		}
		// TODO: break out after we've gotten to N
	}
}
