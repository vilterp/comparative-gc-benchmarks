package foo;

import java.util.LinkedList;
import java.util.Queue;
import java.util.Random;
import java.util.TreeMap;

public class Main {
    public static void main(String[] args) {
        tvbench(10_000_000, 0, 600);
    }
    
    public static void tvbench(int n, int minSeconds, int maxSeconds) {
        Random r = new Random();
        
        TreeMap<Integer, Point> pointsByX = new TreeMap<Integer, Point>();
        TreeMap<Integer, Point> pointsByY = new TreeMap<Integer, Point>();
        Queue<Point> queue = new LinkedList<Point>();

        int count = 0;
        // tcheck = 0
        // i = 0

        while (true) {
            count++;
            Point p = new Point(r.nextInt(), r.nextInt());
            queue.add(p);
            pointsByX.put(p.x, p);
            pointsByY.put(p.y, p);

            if (queue.size() > n) {
                p = queue.remove();
                pointsByX.remove(p.x);
                pointsByY.remove(p.y);
            }

            int remainder = count % 1_000_000;
            if (remainder == 0) {
                System.out.printf("count %d\n", count);
            }
        }

    }
}
