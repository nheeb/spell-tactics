class_name CombatReview extends Resource

@export var player: String
@export var date: String
@export var result: Combat.Result

@export var combat_log: Array[String]
@export var deck: Array[SpellType]
@export var entities: Array[EntityType]

@export var game_version: String
@export var level_name: String

@export var bugs: String
@export var remarks: String
@export var rating: String
@export var card_remarks: Dictionary
@export var enemy_remarks: Dictionary

@export var special_questions: Array[String]
@export var special_answers: Array[String]

@export var statistics: Dictionary

func initialize_with_combat(combat: Combat) -> void:
	result = combat.result
	date = Time.get_date_string_from_system()
	combat_log = combat.log.log_entries.duplicate(true)
	deck = []
	deck.append_array(Utility.array_unique(combat.get_all_castables().map(func(s): return s.type)))
	entities = []
	entities.append_array(Utility.array_unique(combat.level.entities().get_all_entities().map(func(e): return e.type)))
	game_version = Game.game_version_string
	# TODO Level name
	if Game.review_questions:
		special_questions = Game.review_questions.duplicate(true)
		special_answers = []
		special_answers.append_array(range(special_questions.size()).map(func (x): return ""))
	# TODO Get / Make statistics

static func from_combat(combat: Combat) -> CombatReview:
	var review = CombatReview.new()
	review.initialize_with_combat(combat)
	return review

func array_unique(array: Array) -> Array:
	var unique: Array = []

	for item in array:
		if not unique.has(item):
			unique.append(item)

	return unique
