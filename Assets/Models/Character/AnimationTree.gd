extends AnimationTree

### export functions

# movement

func anim_idle(AnimationSpeed:float = get_default_timescale_scale("MovementTimeScale")):
	var MovementBlendSpace_target:float = 1
	var MovementBlendSpace_duration:float = 0.2
	reset_cast_blend()
	blend_movement(MovementBlendSpace_target, MovementBlendSpace_duration, AnimationSpeed)

func anim_walk(AnimationSpeed:float = get_default_timescale_scale("MovementTimeScale")):
	var MovementBlendSpace_target:float = 0
	var MovementBlendSpace_duration:float = 0.2
	reset_cast_blend()
	blend_movement(MovementBlendSpace_target, MovementBlendSpace_duration, AnimationSpeed)

func anim_run(AnimationSpeed:float = get_default_timescale_scale("MovementTimeScale")):
	var MovementBlendSpace_target:float = 2
	var MovementBlendSpace_duration:float = 0.2
	reset_cast_blend()
	blend_movement(MovementBlendSpace_target, MovementBlendSpace_duration, AnimationSpeed)

# oneshots

func anim_idle_break(AnimationSpeed:float = get_default_timescale_scale("ActionsTimeScale")):
	var ActionsBlendSpace_target:float = 3
	set_oneshot_actions(ActionsBlendSpace_target, AnimationSpeed)

func anim_melee_attack(AnimationSpeed:float = get_default_timescale_scale("ActionsTimeScale")):
	var ActionsBlendSpace_target:float = 0
	set_oneshot_actions(ActionsBlendSpace_target, AnimationSpeed)

func anim_get_hit(AnimationSpeed:float = get_default_timescale_scale("ActionsTimeScale")):
	var ActionsBlendSpace_target:float = 2
	set_oneshot_actions(ActionsBlendSpace_target, AnimationSpeed)

func anim_death(AnimationSpeed:float = get_default_timescale_scale("ActionsTimeScale")):
	var ActionsBlendSpace_target:float = 1
	set_oneshot_actions(ActionsBlendSpace_target, AnimationSpeed)

	# TODO stop animation tree / keep death anim end pose

# cast transition

func anim_cast_start(AnimationSpeed:float = get_default_timescale_scale("AttackCastTimeScale")):
	set_cast_blend()
	self.set("parameters/ActionsTimeScale/scale", AnimationSpeed)
	self.set("parameters/AttackCastTransition/transition_request", "AttackCastStart")
	
func anim_cast_end(AnimationSpeed:float = get_default_timescale_scale("AttackCastTimeScale")):
	self.set("parameters/ActionsTimeScale/scale", AnimationSpeed)
	self.set("parameters/AttackCastTransition/transition_request", "AttackCastEnd")
	
	# TODO call reset_cast_blend after animation is ended

### internal functions

func get_default_timescale_scale(TimeScaleName:String):
	return self.get("parameters/"+str(TimeScaleName)+"/scale")

func blend_movement(MovementBlendSpace_target, MovementBlendSpace_duration, AnimationSpeed):
	var blend_tween = get_tree().create_tween()
	self.set("parameters/MovementTimeScale/scale", AnimationSpeed)
	blend_tween.tween_property(self, "parameters/MovementBlendSpace/blend_position", MovementBlendSpace_target, MovementBlendSpace_duration).set_trans(Tween.TRANS_LINEAR)

func set_cast_blend():
	var AttackCastBlend = 1
	self.set("parameters/AttackCastBlend/blend_amount", AttackCastBlend)

func reset_cast_blend():
	var AttackCastBlend = 0
	self.set("parameters/AttackCastBlend/blend_amount", AttackCastBlend)

func set_oneshot_actions(ActionBlendSpace_target, AnimationSpeed):
	self.set("parameters/ActionsTimeScale/scale", AnimationSpeed)
	self.set("parameters/ActionsBlendSpace/blend_position", ActionBlendSpace_target)
	self.set("parameters/ActionsOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
