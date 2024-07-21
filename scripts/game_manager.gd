extends Node

var rows = 5
var columns = 5
var equipement = []

# Called when the node enters the scene tree for the first time.
func _ready():

	for i in range(rows):
		var row = []
		for j in range(columns):
			row.append(0) 
			equipement.append(row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
