"""
    is_connected(graph::DAG)

Return whether the given graph is connected.
"""
function is_connected(graph::DAG)
    nodeQueue = Deque{Node}()
    push!(nodeQueue, get_exit_node(graph))
    seenNodes = Set{Node}()

    while !isempty(nodeQueue)
        current = pop!(nodeQueue)
        push!(seenNodes, current)

        for child in current.children
            push!(nodeQueue, child[1])
        end
    end

    return length(seenNodes) == length(graph.nodes)
end

"""
    is_valid(graph::DAG)

Validate the entire graph using asserts. Intended for testing with `@assert is_valid(graph)`.
"""
function is_valid(graph::DAG)
    for node in graph.nodes
        @assert is_valid(graph, node)
    end

    for op in graph.operations_to_apply
        @assert is_valid(graph, op)
    end

    for nr in graph.possible_operations.node_reductions
        @assert is_valid(graph, nr)
    end
    for ns in graph.possible_operations.node_splits
        @assert is_valid(graph, ns)
    end

    for node in graph.dirty_nodes
        @assert node in graph "Dirty Node is not part of the graph!"
        @assert ismissing(node.node_reduction) "Dirty Node has a NodeReduction!"
        @assert ismissing(node.node_split) "Dirty Node has a NodeSplit!"
    end

    @assert is_connected(graph) "Graph is not connected!"

    return true
end

"""
    is_scheduled(graph::DAG)

Validate that the entire graph has been scheduled, i.e., every [`ComputeTaskNode`](@ref) has its `.device` set.
"""
function is_scheduled(graph::DAG)
    for node in graph.nodes
        if (node isa DataTaskNode)
            continue
        end
        @assert !ismissing(node.device)
    end

    return true
end
