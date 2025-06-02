extends Node


func remap_range(old_min: float, old_max: float, new_min: float, new_max: float, value: float) -> float:
	return lerp(new_min, new_max, (value - old_min) / (old_max - old_min))

