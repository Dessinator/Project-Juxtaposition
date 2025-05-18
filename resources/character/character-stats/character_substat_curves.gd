class_name CharacterSubstatCurves extends Resource

# ATTK
@export var _ATDM_curve: Curve ## Attack Damage
@export var _CRCH_curve: Curve ## Crit. Chance
@export var _CRML_curve: Curve ## Crit. Mult.

# DFNS
@export var _DMMT_curve: Curve ## Damage Mitigation
@export var _DBRS_curve: Curve ## Debuff Resistance
@export var _BFRT_curve: Curve ## Buff Retention

# VTLY
@export var _MXHL_curve: Curve ## Max Health
@export var _HLRG_curve: Curve ## Health Regeneration
@export var _MXST_curve: Curve ## Max Stamina
@export var _STRG_curve: Curve ## Stamina Regeneration
@export var _AGLT_curve: Curve ## Agility

var _atdm_constant: float = 0.0
var _crch_constant: float = 0.0
var _crml_constant: float = 0.0

var _dmmt_constant: float = 0.0
var _dbrs_constant: float = 0.0
var _bfrt_constant: float = 0.0

var _mxhl_constant: float = 0.0
var _hlrg_constant: float = 0.0
var _mxst_constant: float = 0.0
var _strg_constant: float = 0.0
var _aglt_constant: float = 0.0

func set_atdm_constant(constant_value: float):
	_atdm_constant = constant_value
func set_crch_constant(constant_value: float):
	_crch_constant = constant_value
func set_crml_constant(constant_value: float):
	_crml_constant = constant_value
func set_dmmt_constant(constant_value: float):
	_dmmt_constant = constant_value
func set_dbrs_constant(constant_value: float):
	_dbrs_constant = constant_value
func set_bfrt_constant(constant_value: float):
	_bfrt_constant = constant_value
func set_mxhl_constant(constant_value: float):
	_mxhl_constant = constant_value
func set_mxst_constant(constant_value: float):
	_mxst_constant = constant_value
func set_aglt_constant(constant_value: float):
	_aglt_constant = constant_value

func get_atdm_constant() -> float:
	return _atdm_constant
func get_crch_constant() -> float:
	return _crch_constant
func get_crml_constant() -> float:
	return _crml_constant
func get_dmmt_constant() -> float:
	return _dmmt_constant
func get_dbrs_constant() -> float:
	return _dbrs_constant
func get_bfrt_constant() -> float:
	return _bfrt_constant
func get_mxhl_constant() -> float:
	return _mxhl_constant
func get_mxst_constant() -> float:
	return _mxst_constant
func get_aglt_constant() -> float:
	return _aglt_constant

func sample_atdm_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _ATDM_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _atdm_constant) if sampled + _atdm_constant > 0.0 else 0.0
	return (sampled + _atdm_constant) * 100
func sample_crch_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _CRCH_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _crch_constant) if sampled + _crch_constant > 0.0 else 0.0
	return (sampled + _crch_constant) * 100
func sample_crml_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _CRML_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _crml_constant) if sampled + _crml_constant > 0.0 else 0.0
	return (sampled + _crml_constant) * 100

func sample_dmmt_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _DMMT_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _dmmt_constant) if sampled + _dmmt_constant > 0.0 else 0.0
	return (sampled + _dmmt_constant) * 100
func sample_dbrs_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _DBRS_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _dbrs_constant) if sampled + _dbrs_constant > 0.0 else 0.0
	return (sampled + _dbrs_constant) * 100
func sample_bfrt_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _BFRT_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _bfrt_constant) if sampled + _bfrt_constant > 0.0 else 0.0
	return (sampled + _bfrt_constant) * 100

func sample_mxhl_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _MXHL_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _mxhl_constant) if sampled + _mxhl_constant > 0.0 else 0.0
	return (sampled + _mxhl_constant) * 100
func sample_mxst_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _MXST_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _mxst_constant) if sampled + _mxst_constant > 0.0 else 0.0
	return (sampled + _mxst_constant) * 100
func sample_aglt_curve(offset: float, base_value: bool, as_percentage: bool) -> float:
	var sampled = _AGLT_curve.sample(offset)
	
	if base_value:
		if as_percentage:
			return sampled
		return sampled * 100
	if as_percentage:
		return (sampled + _aglt_constant) if sampled + _aglt_constant > 0.0 else 0.0
	return (sampled + _aglt_constant) * 100
