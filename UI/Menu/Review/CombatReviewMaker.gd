extends Control

const REVIEW_QUESTION = preload("res://UI/Menu/Review/ReviewQuestion.tscn")

var review: CombatReview
var questions: Array[ReviewQuestion]

func _ready() -> void:
	if Game.combat_to_review:
		review = CombatReview.from_combat(Game.combat_to_review)
		create_questions()
	else:
		push_error("No Combat to review given")

func create_questions():
	for q in questions:
		q.queue_free()
	questions.clear()
	add_new_qestion().setup_text("player", "What is your name?")
	add_new_qestion().setup_text("bugs", "Did you encounter any (new) bugs?")
	add_new_qestion().setup_text("remarks", "Do you have some general remarks / critique / suggestions?")
	add_new_qestion().setup_number_slider("rating",\
	"How would you rate this combat in terms of fun? (compared to your previous combats)")
	for spell_type in review.deck:
		var word := "event" if spell_type.is_event_spell else "spell"
		var choices : Array[String] = [
			"too strong",
			"too weak",
			"too complicated",
			"too simple / lame",
			"very nice spell"
		]
		add_new_qestion().setup_multiple_choice("card_remarks", "Do you have a strong opinion on this %s?" % word, choices)\
		.set_target_index(spell_type.internal_name).set_spell(spell_type)
	for entity_type in review.entities:
		if entity_type is EnemyEntityType:
			var choices : Array[String] = [
				"too strong",
				"too weak",
				"weird behaviour",
				"very nice enemy"
			]
			add_new_qestion().setup_multiple_choice("enemy_remarks", "Do you have a strong opinion on this enemy?", choices)\
			.set_target_index(entity_type.internal_name).set_image(entity_type.get_prototype_texture())
	for i in Game.review_questions.size():
		add_new_qestion().setup_text("special_answers", Game.review_questions[i]).set_target_index(i)

func add_new_qestion() -> ReviewQuestion:
	var question := REVIEW_QUESTION.instantiate()
	questions.append(question)
	%Questions.add_child(question)
	return question

func update_review() -> void:
	for q in questions:
		q.fill_property(review)

func save_review() -> void:
	if not DirAccess.dir_exists_absolute(Game._SAVE_DIR_USER_REVIEWS):
		DirAccess.make_dir_absolute(Game._SAVE_DIR_USER_REVIEWS)
	var filename := review.date + "-" + review.player + "-" + Utility.random_hash(6) + ".tres"
	ResourceSaver.save(review, Game._SAVE_DIR_USER_REVIEWS + filename)

func _on_button_save_pressed() -> void:
	update_review()
	save_review()
	%ButtonUpload.disabled = false

func _on_button_upload_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(Game._SAVE_DIR_USER_REVIEWS))
	OS.shell_open(Game.GOOGLE_DRIVE_REVIEWS_LINK)

func _on_button_exit_pressed() -> void:
	get_tree().quit()
