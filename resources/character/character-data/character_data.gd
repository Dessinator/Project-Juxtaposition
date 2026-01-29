class_name CharacterData
extends Resource

# responsible for holding character data not necessarily integral to
# regular play (experience, name, nickname, pronouns, etc.)

signal rank_changed
signal experience_level_changed
signal experience_points_changed

enum CharacterRank
{
    RANK_8_BIT,
    RANK_16_BIT,
    RANK_32_BIT,
    RANK_64_BIT
}

enum CharacterGender
{
    GENDER_NONBINARY,
    GENDER_MALE,
    GENDER_FEMALE
}

# name, gender  and info

@export var full_name: String
@export var nickname: String
@export var internal_name: StringName

@export var pronouns: Pronouns
@export var gender: CharacterGender = CharacterGender.GENDER_NONBINARY

@export var portrait: Texture2D

@export_multiline var short_description: String
@export_multiline var long_description: String

# dissociation and worldliness

@export var dissociation: float

# code to conscience
@export var method: float
# maleficent to benevolent
@export var morals: float

# experience and rank

var rank: CharacterRank = CharacterRank.RANK_8_BIT
var experience_level: int
var experience_points: int

# talents

@export var light_attack_talents: Array[CharacterTalent]
@export var heavy_attack_talents: Array[CharacterTalent]
@export var dodge_talents: Array[CharacterTalent]
@export var parry_talents: Array[CharacterTalent]
@export var juxtaposition_talents: Array[CharacterTalent]

func add_experience_points(amount: int):
    experience_points += amount

    var level_addend = int(experience_points / 9999)
    experience_level += level_addend

    if level_addend > 0:
        experience_points = int(experience_points % 9999)