class_name BehaviorGraphEdit
extends GraphEdit

var graph_nodes: Array[GraphNode] = []

var min_graph_node_size := Vector2(30, 20)


func _ready() -> void:
	create_graph_node()
	create_graph_node()

	for node in graph_nodes:
		set_selected(node)
	# arrange_nodes()


func create_graph_node() -> GraphNode:
	var graph_node := GraphNode.new()
	graph_nodes.push_back(graph_node)
	graph_node.size = min_graph_node_size
	graph_node.position = get_rect().get_center() - (graph_node.size / 2)
	graph_node.title = "Wassup"

	var label := Label.new()
	label.text = "Yo whatup"
	graph_node.add_child(label)

	add_child(graph_node)
	return graph_node


func clear_graph_nodes() -> void:
	for graph_node in graph_nodes:
		if is_instance_valid(graph_node):
			graph_node.queue_free()
