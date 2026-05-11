extends AudioStream
class_name AudioStreamSelection

@export var stream_group: AudioStreamGroup
@export_flags("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")
var stream_mask: int

func get_streams(mask = stream_mask):
    var out = []
    for n in range(len(stream_group.streams)):
        if mask & (2 ** n) > 0:
            out.append(stream_group.streams[n])
    return out
