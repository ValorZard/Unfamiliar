class_name System

static func percent_to_db(percent: float) -> float:
	return -80.0 if percent == 0 else 20.0 * (log(percent) / log(10.0))
