class_name Alignment
extends Resource

const LAWFUL_GOOD: StringName = "Lawful Good"
const NEUTRAL_GOOD: StringName = "Neutral Good"
const CHAOTIC_GOOD: StringName = "Chaotic Good"
const LAWFUL_NEUTRAL: StringName = "Lawful Neutral"
const TRUE_NEUTRAL: StringName = "True Neutral"
const CHAOTIC_NEUTRAL: StringName = "Chaotic Neutral"
const LAWFUL_EVIL: StringName = "Lawful Evil"
const NEUTRAL_EVIL: StringName = "Neutral Evil"
const CHAOTIC_EVIL: StringName = "Chaotic Evil"

const _alignment_title_dictionary: Dictionary = {
	Vector2i(1, 1)  : LAWFUL_GOOD,
	Vector2i(0, 1)  : LAWFUL_NEUTRAL,
	Vector2i(-1, 1) : LAWFUL_EVIL,
	Vector2i(1, 0)  : NEUTRAL_GOOD,
	Vector2i(0, 0)  : TRUE_NEUTRAL,
	Vector2i(-1, 0) : NEUTRAL_EVIL,
	Vector2i(1, -1) : CHAOTIC_GOOD,
	Vector2i(0, -1) : CHAOTIC_NEUTRAL,
	Vector2i(-1, -1): CHAOTIC_EVIL
}

## X = Motive (-1 = evil, 1 = good)
## Y = Method (-1 = chaotic, 1 = lawful)
## (0, 0) = True Neutral
@export var _alignment: Vector2i = Vector2i.ZERO

func get_alignment() -> Vector2i:
	return _alignment

func get_alignment_title() -> StringName:
	return _alignment_title_dictionary[_alignment]
