#include <chrono>
#include <ctime>
#include <random>
#include <climits>
#include <queue>
#include <set>  // TODO: Red Black Tree??
#include <iostream>
#include <memory>

using std::cout;
using std::endl;
using std::shared_ptr;
using std::make_shared;
using namespace std::chrono;

struct Point {
    int x;
    int y;
    Point(int a, int b) : x(a), y(b) {}
};
struct PointByX {
    shared_ptr<Point> p;
};
struct PointByY {
    shared_ptr<Point> p;
};
bool operator <(const PointByX &a, const PointByX &b) {
    return a.p->x < b.p->x;
}
bool operator <(const PointByY &a, const PointByY &b) {
    return a.p->y < b.p->y;
}

// Driver Code
void tvbench(int N = 10000000, int min_seconds_full = 120, int max_seconds = 600)
{
    std::random_device dev;
    std::mt19937 rng(dev());
    std::uniform_int_distribution<std::mt19937::result_type> rand_int(-INT_MAX,INT_MAX); // distribution in range [1, 6]

    // std::cout << dist6(rng) << std::endl;


    shared_ptr<Point> p1 = make_shared<Point>(1,2);
    shared_ptr<Point> p2 = make_shared<Point>(2,1);

    PointByX x1 = {p1};
    PointByX x2 = {p2};

    PointByY y1 = {p1};
    PointByY y2 = {p2};

    auto t0 = high_resolution_clock::now();
    decltype(t0) full_time;

    auto queue = std::queue< shared_ptr<Point> >();
    std::set<PointByX> x_tree;
    std::set<PointByY> y_tree;

    int count = 0;
    //int tcheck = 0;

    while (true) {
        count = count + 1;
        shared_ptr<Point> p = make_shared<Point>((int)rand_int(rng), (int)rand_int(rng));
        queue.push(p);
        PointByX px = {p};
        PointByY py = {p};
        x_tree.insert(px);
        y_tree.insert(py);

        if (queue.size() == N) {
            full_time = high_resolution_clock::now();
            auto elapsed = duration_cast<seconds>(full_time - t0).count();

			cout << "Reached full queue (" << N << " elements):" << elapsed << " seconds" << endl;
        }
        if (queue.size() > N) {
            auto now = high_resolution_clock::now();
            auto elapsed = duration_cast<seconds>(now - full_time).count();
            if (elapsed > min_seconds_full) {
                break;
            }

            shared_ptr<Point> p = queue.back();
            PointByX px = {p};
            PointByY py = {p};
            queue.pop();
            x_tree.erase(px);
            y_tree.erase(py);
        }

        /*
        i = i + 1
        if i == 100 {
            i = 0
            @assert length(xtree) <= N
            elapsed = time() - t0
            tcheck2 = floor(elapsed/10)
            if tcheck != tcheck2 {
                tcheck = tcheck2
                println("elapsed=$(elapsed)s, $(length(queue)) current points, $(count) total, $(floor(count/elapsed)) per second")
            }
            if (count >= N) && (elapsed > min_seconds) {
                break
            }
        }
        */

        auto nr = count % 1000000;
        if (nr == 0) {
            cout << "-------------" << endl;

            cout << "count: " << count << endl;
            cout << "queue: " << queue.size() << endl;

            auto ti = high_resolution_clock::now();
            auto elapsed = duration_cast<seconds>(ti - t0).count();
            cout << "elapsed: " << elapsed << " seconds" << endl;

            if (elapsed >= max_seconds) {
                cout << "Exceeded max seconds: " << elapsed << " seconds" << endl;
                break;
            }
        }
    }

    cout << "Destructing the queue..." << endl;
    return;
}

int main() {
    auto t0 = high_resolution_clock::now();

    tvbench();

    auto ti = high_resolution_clock::now();
    auto elapsed = duration_cast<seconds>(ti - t0).count();
    cout << "Fully finished: " << elapsed << " seconds" << endl;
}
