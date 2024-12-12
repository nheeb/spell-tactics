extends EntityLogic

@export var spell_type: SpellType

func on_load():
	if spell_type:
		entity.visual_entity.set_spell_type(spell_type)

func set_random_card():
	var spell_pool := Utility.array_unique(
		combat.get_all_castables().filter(
			func (c): return c is Spell
		).map(
			func (spell): return spell.type
		)
	)
	spell_type = spell_pool.pick_random()
	entity.visual_entity.set_spell_type(spell_type)

func on_birth():
	TimedEffect.new_combat_change(set_random_card).set_oneshot().register(combat)

func on_interact() -> void:
	combat.cards.draw_from_type(spell_type)
