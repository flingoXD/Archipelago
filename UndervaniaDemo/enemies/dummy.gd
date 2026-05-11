extends Enemy

signal talked

func talk(_act):
    $Textbox.show_text("...", 2)
    talked.emit()

func check():
    do_check("Dummy", "A cotton heart and a button eye.\nYou are the apple of my eye.", 0, 0)
