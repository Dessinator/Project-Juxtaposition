class_name ModStat extends StatusEffectComponent

# modifies the affected actor's main stat while the modifier is active.
enum AffectedMainStat { ATTK, DFNS, VTLY }
@export var _affected_main_stat: AffectedMainStat = AffectedMainStat.ATTK

@export var _use_percentage_of_base_stat_value_instead: bool
@export var _mod_value: int
@export var _percentage_of_base_stat: float = 1.00

var _cached_constant_modification: int

func apply(status_effect: Dictionary, affected_actor: Actor):
	var actor_stats = affected_actor.get_stats()

	match _affected_main_stat:
		AffectedMainStat.ATTK:
			if not _use_percentage_of_base_stat_value_instead:
				actor_stats.set_attk_constant(actor_stats.get_attk_constant() + _mod_value)
				return
			_cached_constant_modification = int(_percentage_of_base_stat * float(actor_stats.get_attk(true, false)))
			actor_stats.set_attk_constant(actor_stats.get_attk_constant() + _cached_constant_modification)
		AffectedMainStat.DFNS:
			if not _use_percentage_of_base_stat_value_instead:
				actor_stats.set_dfns_constant(actor_stats.get_dfns_constant() + _mod_value)
				return
			_cached_constant_modification = int(_percentage_of_base_stat * float(actor_stats.get_dfns(true, false)))
			actor_stats.set_dfns_constant(actor_stats.get_dfns_constant() + _cached_constant_modification)
		AffectedMainStat.VTLY:
			if not _use_percentage_of_base_stat_value_instead:
				actor_stats.set_vtly_constant(actor_stats.get_vtly_constant() + _mod_value)
				return
			_cached_constant_modification = int(_percentage_of_base_stat * float(actor_stats.get_vtly(true, false)))
			actor_stats.set_vtly_constant(actor_stats.get_vtly_constant() + _cached_constant_modification)
			

func end(status_effect: Dictionary, affected_actor: Actor):
	var actor_stats = affected_actor.get_stats()

	match _affected_main_stat:
		AffectedMainStat.ATTK:
			if not _use_percentage_of_base_stat_value_instead:
				actor_stats.set_attk_constant(actor_stats.get_attk_constant() + _mod_value)
				return
			actor_stats.set_attk_constant(actor_stats.get_attk_constant() - _cached_constant_modification)
		AffectedMainStat.DFNS:
			if not _use_percentage_of_base_stat_value_instead:
				actor_stats.set_dfns_constant(actor_stats.get_dfns_constant() + _mod_value)
				return
			actor_stats.set_dfns_constant(actor_stats.get_dfns_constant() - _cached_constant_modification)
		AffectedMainStat.VTLY:
			if not _use_percentage_of_base_stat_value_instead:
				actor_stats.set_vtly_constant(actor_stats.get_vtly_constant() + _mod_value)
				return
			actor_stats.set_vtly_constant(actor_stats.get_vtly_constant() - _cached_constant_modification)
