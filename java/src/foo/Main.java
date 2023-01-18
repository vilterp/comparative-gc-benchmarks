package foo;

import java.util.LinkedList;
import java.util.Queue;
import java.util.Random;
import java.util.TreeMap;

import java.time.Duration;
import java.time.Instant;

public class Main {
    public static void main(String[] args) {
        tvbench(10_000_000, 120, 600, true);
    }

    public static void tvbench(int n, int minSecondsFull, int maxSeconds, boolean forcePauses) {
        Random r = new Random();

        TreeMap<Integer, Point> pointsByX = new TreeMap<Integer, Point>();
        TreeMap<Integer, Point> pointsByY = new TreeMap<Integer, Point>();
        Queue<Point> queue = new LinkedList<Point>();

        Instant startTime = Instant.now();
        Instant reachedFullTime = Instant.now();

        int count = 0;
        // tcheck = 0
        // i = 0

        while (true) {
            count++;
            Point p = new Point(r.nextInt(), r.nextInt());
            queue.add(p);
            pointsByX.put(p.x, p);
            pointsByY.put(p.y, p);

            if (queue.size() == n) {
                reachedFullTime = Instant.now();
                Duration timeElapsed = Duration.between(startTime, reachedFullTime);
                System.out.println("Reached full queue ("+ n +" elements): "+ durationString(timeElapsed));
            }
            if (queue.size() > n) {
                Instant now = Instant.now();
                Duration fullTime = Duration.between(reachedFullTime, Instant.now());
                if (fullTime.toSeconds() >= minSecondsFull) {
                    break;
                }

                p = queue.remove();
                pointsByX.remove(p.x);
                pointsByY.remove(p.y);
            }

            int remainder = count % 1_000_000;
            if (remainder == 0) {
                System.out.println("-------------");
                if (forcePauses) {
                    Instant startGC = Instant.now();
                    System.gc();
                    Instant endGC = Instant.now();
                    Duration gc_time = Duration.between(startGC, endGC);
                    System.out.println("gc time: "+ durationString(gc_time));
                }

                System.out.printf("count: %d\n", count);
                System.out.printf("queue: %d\n", queue.size());

                Instant now = Instant.now();
                Duration elapsed = Duration.between(startTime, now);
                System.out.println("elapsed: "+ durationString(elapsed));
                if (elapsed.toSeconds() >= maxSeconds) {
                    System.out.println("Exceeded max seconds: "+ durationString(elapsed));
                    break;
                }
            }
        }

        System.out.println("======= Done. =========");
    }

    private static String durationString(Duration duration) {
        return duration.toSeconds() +"."+ duration.toMillis() +" seconds";
    }

}
