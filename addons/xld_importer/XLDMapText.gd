tool
class_name XLDMapText
extends XLD.Section

var texts: Array

func loadContents(file: File):
	print("Loading some XLDMapText")
	
	var textsCount = file.get_16()
	
	var textsLengths = []
	
	for i in textsCount:
		textsLengths.append(file.get_16())
		
	for i in textsCount:
		texts.append(file.get_buffer(textsLengths[i]).subarray(0, -1).get_string_from_ascii())
	
	print("Loading some XLDMapText finished")
