extends Node

signal picked_up_buff(buff_options: Dictionary[Buff, String])
signal selected_buff(buff: Buff, stat_name: String, has_queue: bool)
