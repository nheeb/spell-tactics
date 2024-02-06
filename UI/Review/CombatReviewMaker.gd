extends Control

const REVIEW_QUESTION = preload("res://UI/Review/ReviewQuestion.tscn")

var review: CombatReview
var questions: Array[ReviewQuestion]

func _ready() -> void:
	if Game.combat_to_review:
		review = CombatReview.from_combat(Game.combat_to_review)
		create_questions()
	else:
		printerr("No Combat to review given")

func create_questions():
	pass
