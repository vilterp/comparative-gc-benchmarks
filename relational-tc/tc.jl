module TransitiveClosure

using AbstractTrees

# Mutable so that every node is heap-allocated
mutable struct Node{T}
    v::T
    left::Union{Nothing,Node{T}}
    right::Union{Nothing,Node{T}}

    marked::Bool
end
Node{T}(v::T) where {T} = Node{T}(v, nothing, nothing, false)
Node(v::T) where {T} = Node{T}(v)

"""
    head, nodes = TransitiveClosure.make_balanced_tree(T, n[, distribution])

# Examples
```
head, nodes = TransitiveClosure.make_balanced_tree(Int, 127, 1:10);
head, nodes = TransitiveClosure.make_balanced_tree(Int, 13);
```
"""
function make_balanced_tree(T::Type, n::Integer, distribution=T)
    all_nodes = sizehint!(Node{T}[], n)

    function new_node()
        # Generate some garbage in-between nodes, to get these spread out throughout the
        # heap.
        _ = generate_garbage()

        let n = Node{T}(rand(distribution))
            push!(all_nodes, n)
            return n
        end
    end

    length(all_nodes) >= n && @goto DONE
    head = new_node()
    i = 1
    while true
        parent_start = 2^(i-1)
        for node_idx in 1:2^(i-1)
            parent_idx = parent_start - 1 + node_idx
            parent = all_nodes[parent_idx]

            length(all_nodes) >= n && @goto DONE
            parent.left = new_node()
            length(all_nodes) >= n && @goto DONE
            parent.right = new_node()
        end
        i += 1
    end

    @label DONE
    return head, all_nodes
end

@noinline function generate_garbage()
    v = []; v2 = [rand(), 2]; v3 = [v, v2, 5]
    n = Node(v3)
    return [n]
end

# ---------------------------------
# For pretty-printing
# --------------------
function AbstractTrees.children(t::Node{T}) where {T}
    if t.left === nothing && t.right === nothing
        return Node{T}[]
    elseif t.left === nothing
        return Node{T}[t.right]
    elseif t.right === nothing
        return Node{T}[t.left]
    else
        return Node{T}[t.left, t.right]
    end
end
function AbstractTrees.printnode(io::IO, t::Node)
    print(io, t.v)
    t.marked && print(io, " x")
end
Base.show(io::IO, n::Node) = print(io, "Node(", n.v ,")")

# ---------------------------------

using DataStructures
using Random
import Base: isless

mutable struct Point
    x::Int
    y::Int
end

struct PointByX
    p::Point
end
Base.isless(a::PointByX, b::PointByX) = isless(a.p.x, b.p.x)

struct PointByY
    p::Point
end
Base.isless(a::PointByY, b::PointByY) = isless(a.p.y, b.p.y)

function tvbench_setup(N = 100_000_000)
    queue = DataStructures.Queue{Point}()
    xtree = RBTree{PointByX}()
    ytree = RBTree{PointByY}()
    count = 0
    while true
        count = count + 1
        p = Point(Random.rand(Int), Random.rand(Int))
        enqueue!(queue, p)
        push!(xtree, PointByX(p))
        push!(ytree, PointByY(p))

        if length(queue) >= N
            break
        end
    end
    return xtree
end

# ---------------------------------

abstract type SearchContainer{T} end

function visit_algorithm(F, container::SearchContainer{<:Node})
    while !isempty(container)
        n = take!(container)
        if n.right !== nothing
            put!(container, n.right)
        end
        if n.left !== nothing
            put!(container, n.left)
        end
        F(n)
    end
end

function visit_algorithm(F, container::SearchContainer{Any})
    seen = Set{Any}()
    while !isempty(container)
        n = take!(container)
        if n in seen
            continue
        else
            push!(seen, n)
        end
        T = typeof(n)
        for (fname, ftyp) in zip(fieldnames(T), fieldtypes(T))
            if ftyp <: Union{Node, Point, DataStructures.RBTreeNode, Union{Node,Nothing}, Union{Nothing, DataStructures.RBTreeNode}}
                f = getfield(n, fname)
                put!(container, f)
            end
        end
        F(n)
    end
end

struct Queue{T} <: SearchContainer{T} v::Vector{T} end
struct Stack{T} <: SearchContainer{T} v::Vector{T} end

Base.take!(c::Queue) = popfirst!(c.v)
Base.take!(c::Stack) = pop!(c.v)
Base.put!(c::Queue, v) = push!(c.v, v)
Base.put!(c::Stack, v) = push!(c.v, v)
Base.isempty(c::Queue) = isempty(c.v)
Base.isempty(c::Stack) = isempty(c.v)

function visit_depth_first(F, head)
    stack = Stack(Any[head])
    visit_algorithm(F, stack)
end
function visit_breadth_first(F, head)
    queue = Queue(Any[head])
    visit_algorithm(F, queue)
end

@noinline mark(_) = nothing
@noinline mark(n::Node) = n.marked = true
@noinline mark(n::DataStructures.RBTreeNode) = n.color = true  # Just twiddle a bit 🤷
ismarked(n::Node) = n.marked
ismarked(n::DataStructures.RBTreeNode) = n.color

function sweep_all(live_objects::Vector)
    for n in live_objects
        if !n.marked
            println("GARBAGE: ", n)
        end
        n.marked = false
    end
end

function bench(n = 10_000_000)
    @info "Setup: n = $n"

    #@time tree, nodes = make_balanced_tree(Int, n)

    @time rbtree = tvbench_setup(n)
    #nodes = [rbtree[i] for i in 1:length(rbtree)]
    tree = rbtree.root

    # The nodes list acts as our "live objects" list. GC would already have this created.
    # ?? For this benchmark, we will assume it can be kept sorted. ??
    #live_objects = nodes

    # The tree acts as our object graph in the heap.

    # -------------------------------------------
    @info "Navigational mark phase: DFS"

    @time visit_depth_first(mark, tree)

    #@info "sweep"

    #@time sweep_all(live_objects)

    # -------------------------------------------
    @info "Navigational mark phase: BFS"

    @time visit_breadth_first(mark, tree)

    #@info "sweep"

    #@time sweep_all(live_objects)

    # -------------------------------------------


end




end # module TransitiveClosure
