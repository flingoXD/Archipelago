extends ColorRect

func _ready():
    var silly_shader = Globals.get_persistent_flag("silly_shader")
    if silly_shader and silly_shader in Globals.silly_shaders and Globals.silly_shaders[silly_shader]:
        self.show()
        self.material.shader = Globals.silly_shaders[silly_shader]
