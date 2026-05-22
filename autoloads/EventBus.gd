extends Node

# === OBJECT INTERACTION ===
signal object_tapped(obj)
signal match_found(type_id: String)
signal match_failed()

# === SLOT BAR ===
signal slot_added(type_id: String)
signal slot_cleared(type_id: String)
signal slots_full()

# === GAME STATE ===
signal level_started()
signal level_completed()
signal level_failed()
signal score_changed(new_score: int)

# === UI ===
signal hint_requested()
signal pause_toggled(is_paused: bool)

# === BOARD ===
signal board_changed()
