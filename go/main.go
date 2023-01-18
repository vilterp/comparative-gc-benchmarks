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
	tvbench(10_000_000, 120, 600, true)
}

func tvbench(n int, minSecondsFull int, maxSeconds int, forcePauses bool) {
	pointsByX := redblacktree.NewWithIntComparator()
	pointsByY := redblacktree.NewWithIntComparator()
	queue := linkedlistqueue.New()

	startTime := time.Now()
	reachedFullTime := time.Now()

	count := 0
	// tcheck := 0
	// i := 0

	for {
		count = count + 1
		p := &Point{x: rand.Int(), y: rand.Int()}
		queue.Enqueue(p)
		pointsByX.Put(p.x, p)
		pointsByY.Put(p.y, p)

		if queue.Size() == n {
			reachedFullTime = time.Now()

			fmt.Println("Reached full queue (", n, " elements):", reachedFullTime.Sub((startTime)))
		}
		if queue.Size() > n {
			fullTime := time.Now().Sub((reachedFullTime))
			if fullTime.Seconds() >= float64(minSecondsFull) {
				break
			}

			pt, _ := queue.Dequeue()
			p = pt.(*Point)
			pointsByX.Remove(p.x)
			pointsByY.Remove(p.y)
		}

		remainder := count % 1_000_000
		if remainder == 0 {
			fmt.Println("-------------")

			if forcePauses {
				before := time.Now()
				runtime.GC()
				after := time.Now()
				fmt.Println("gc time:", after.Sub((before)))
			}

			fmt.Println("count: ", count)
			fmt.Println("queue: ", queue.Size())

			elapsed := time.Now().Sub((startTime))
			fmt.Println("elapsed: ", elapsed)
			if int(elapsed.Seconds()) >= maxSeconds {
				fmt.Println("Exceeded max seconds: ", elapsed)
				break
			}
		}
	}
	fmt.Println("======= Done. =========")
}
