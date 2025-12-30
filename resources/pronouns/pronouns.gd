class_name Pronouns
extends Resource

## ex: they
@export var subject: String
## ex: them
@export var object: String
## ex: their
@export var possessive_adjective: String
## ex: theirs
@export var possessive_pronoun: String
## ex: reflexive
@export var reflexive: String

func get_full_string() -> String:
    return "{subject}/{object}/{possessive_adjective}/{possessive_pronoun}/{reflexive}".format({
        "subject" : subject,
        "object" : object,
        "possessive_adjective" : possessive_adjective,
        "possessive_pronoun" : possessive_pronoun,
        "reflexive" : reflexive
    })
## returns subject/object/possessive_pronoun (they/them/theirs)
func get_half_string() -> String:
    return "{subject}/{object}/{possessive_pronoun}".format({
        "subject" : subject,
        "object" : object,
        "possessive_pronoun" : possessive_pronoun
    })
## returns subject/object (they/them)
func get_simple_string() -> String:
    return "{subject}/{object}".format({
        "subject" : subject,
        "object" : object
    })

func _to_string() -> String:
    return get_full_string()