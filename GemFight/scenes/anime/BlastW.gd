extends Sprite

func _ready():
	$AnimationPlayer.play("blast")

func animeComplete():
	queue_free()