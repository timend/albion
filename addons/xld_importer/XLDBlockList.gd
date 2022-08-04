tool
class_name XLDBlockList
extends XLD.Section

var blockLists: Array

func loadContents(file: File):
	print("Loading some XLDBlocksList")
	
	var remainingBytes = self.length
	
	blockLists = []
	
	while remainingBytes > 0:
		var blockList = BlockList.new()
		blockList.width = file.get_8()
		blockList.height = file.get_8()
		blockList.tileLayers = []
		
		XLDMap.loadTiles(blockList.width, blockList.height, blockList.tileLayers, file)
		
		blockLists.append(blockList)
		
		remainingBytes = remainingBytes - 2 - 3 * blockList.width * blockList.height
	print("Loading some XLDBlockList finished")


class BlockList:
	var width: int
	var height: int
	var tileLayers : Array
