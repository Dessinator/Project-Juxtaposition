class_name ModSubstat extends StatusEffectComponent

# modifies the affected actor's substat while the modifier is active.
enum AffectedSubstat { ATDM, CRCH, CRML, DMMT, DBRS, BFRT, MXHL, MXST, AGLT }
@export var _affected_substat: AffectedSubstat = AffectedSubstat.ATDM

@export var _use_percentage_of_base_stat_value_instead: bool
@export var _mod_value: float
@export var _percentage_of_base_stat: float = 1.00

var _cached_constant_modification: int

func _init():
	print(_mod_value)

func apply(status_effect_instance: Dictionary, affected_actor: Actor):
	var actor_stats = affected_actor.get_stats()
	var actor_substats = actor_stats.get_substat_curves()

	match _affected_substat:
		AffectedSubstat.ATDM:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_atdm_constant(actor_substats.get_atdm_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_atdm_curve(actor_stats.get_attk(false, true), true, true))
			actor_substats.set_atdm_constant(actor_substats.get_atdm_constant() + _cached_constant_modification)
		AffectedSubstat.CRCH:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_crch_constant(actor_substats.get_crch_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_crch_curve(actor_stats.get_attk(false, true), true, true))
			actor_substats.set_crch_constant(actor_substats.get_crch_constant() + _cached_constant_modification)
		AffectedSubstat.CRML:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_crml_constant(actor_substats.get_crml_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_crml_curve(actor_stats.get_attk(false, true), true, true))
			actor_substats.set_crml_constant(actor_substats.get_crml_constant() + _cached_constant_modification)
		AffectedSubstat.DMMT:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_dmmt_constant(actor_substats.get_dmmt_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_dmmt_curve(actor_stats.get_dfns(false, true), true, true))
			actor_substats.set_dmmt_constant(actor_substats.get_dmmt_constant() + _cached_constant_modification)
		AffectedSubstat.DBRS:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_dbrs_constant(actor_substats.get_dbrs_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_dbrs_curve(actor_stats.get_dfns(false, true), true, true))
			actor_substats.set_dbrs_constant(actor_substats.get_dbrs_constant() + _cached_constant_modification)
		AffectedSubstat.BFRT:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_bfrt_constant(actor_substats.get_bfrt_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_bfrt_curve(actor_stats.get_dfns(false, true), true, true))
			actor_substats.set_bfrt_constant(actor_substats.get_bfrt_constant() + _cached_constant_modification)
		AffectedSubstat.MXHL:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_mxhl_constant(actor_substats.get_mxhl_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_mxhl_curve(actor_stats.get_vtly(false, true), true, true))
			actor_substats.set_mxhl_constant(actor_substats.get_mxhl_constant() + _cached_constant_modification)
		AffectedSubstat.MXST:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_mxst_constant(actor_substats.get_mxst_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_mxst_curve(actor_stats.get_vtly(false, true), true, true))
			actor_substats.set_mxst_constant(actor_substats.get_mxst_constant() + _cached_constant_modification)
		AffectedSubstat.AGLT:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_aglt_constant(actor_substats.get_aglt_constant() + _mod_value)
				return
			_cached_constant_modification = float(_percentage_of_base_stat * actor_substats.sample_aglt_curve(actor_stats.get_vtly(false, true), true, true))
			actor_substats.set_aglt_constant(actor_substats.get_aglt_constant() + _cached_constant_modification)

func end(status_effect_instance: Dictionary, affected_actor: Actor):
	var actor_stats = affected_actor.get_stats()
	var actor_substats = actor_stats.get_substat_curves()

	match _affected_substat:
		AffectedSubstat.ATDM:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_atdm_constant(actor_substats.get_atdm_constant() - _mod_value)
				return
			actor_substats.set_atdm_constant(actor_substats.get_atdm_constant() - _cached_constant_modification)
		AffectedSubstat.CRCH:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_crch_constant(actor_substats.get_crch_constant() - _mod_value)
				return
			actor_substats.set_crch_constant(actor_substats.get_crch_constant() - _cached_constant_modification)
		AffectedSubstat.CRML:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_crml_constant(actor_substats.get_crml_constant() - _mod_value)
				return
			actor_substats.set_crml_constant(actor_substats.get_crml_constant() - _cached_constant_modification)
		AffectedSubstat.DMMT:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_dmmt_constant(actor_substats.get_dmmt_constant() - _mod_value)
				return
			actor_substats.set_dmmt_constant(actor_substats.get_dmmt_constant() - _cached_constant_modification)
		AffectedSubstat.DBRS:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_dbrs_constant(actor_substats.get_dbrs_constant() - _mod_value)
				return
			actor_substats.set_dbrs_constant(actor_substats.get_dbrs_constant() - _cached_constant_modification)
		AffectedSubstat.BFRT:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_bfrt_constant(actor_substats.get_bfrt_constant() - _mod_value)
				return
			actor_substats.set_bfrt_constant(actor_substats.get_bfrt_constant() - _cached_constant_modification)
		AffectedSubstat.MXHL:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_mxhl_constant(actor_substats.get_mxhl_constant() - _mod_value)
				return
			actor_substats.set_mxhl_constant(actor_substats.get_mxhl_constant() - _cached_constant_modification)
		AffectedSubstat.MXST:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_mxst_constant(actor_substats.get_mxst_constant() - _mod_value)
				return
			actor_substats.set_mxst_constant(actor_substats.get_mxst_constant() - _cached_constant_modification)
		AffectedSubstat.AGLT:
			if not _use_percentage_of_base_stat_value_instead:
				actor_substats.set_aglt_constant(actor_substats.get_aglt_constant() - _mod_value)
				return
			actor_substats.set_aglt_constant(actor_substats.get_aglt_constant() - _cached_constant_modification)	
