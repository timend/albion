tool
class_name XLD
extends Reference

var path: String
var sections: Array

func load(path: String, sectionConstructor: FuncRef):
	self.path = path
	
	var file = File.new()
	file.open(path, File.READ)
	
	file.get_buffer(6)
	var sectionCount = file.get_16()
	
	# beginning of first section
	var sectionOffset = 8 + sectionCount * 4
	
	for sectionIndex in sectionCount:
		var sectionLength = file.get_32()
		var section = sectionConstructor.call_func()
		section.parent = self
		section.index = sectionIndex
		section.offset = sectionOffset
		section.length = sectionLength
		sections.append(section)
		sectionOffset += sectionLength
		
	file.close()
	
	
class Section:
	var index: int
	var offset: int
	var length: int
	var parent: XLD
	var loaded = false

	func load():
		if loaded:
			return
			
		var file = File.new()
		file.open(parent.path, File.READ)
		file.seek(offset)
		loadContents(file)
		file.close()
		loaded = true
		
	func loadContents(file: File):
		pass
