plugin simpleMeshMod Relax_MCG
	name:"Relax_MCG"
	classID:#(0x1AFD6E89, 0x35764F81)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _meshWrapper -- the dotnet wrapper around the stack mesh pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _meshWrapper_SetValue
	local pluginInstance_UpdateMesh

	-- value wrapper local and function wrapper declarations
	local meshWrapper, meshWrapper_SetValue
	local original_meshWrapper, original_meshWrapper_SetValue


	parameters main rollout:params
	(
		maintain_edge_lengths ui:maintain_edge_lengths default:False type:#boolean animatable:true
		iterations ui:iterations default:1 type:#integer animatable:true
		original_mesh ui:original_mesh type:#node useNodeOsValidity:true useNodeTmValidity:true
		amount ui:amount default:0.5 type:#float animatable:true
		_dummy type:#boolean -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)



	fn RunSimLoop updateFxn = (
		local result = ok
		try (
			result = updateFxn ()
		)
		catch()
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Deformers\Relax MCG.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.ModifierPluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_UpdateMesh = pluginInstance.UpdateMesh
		local meshWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.Mesh"
		_meshWrapper = meshWrapperClass._CreateWrapper undefined
		_meshWrapper_SetValue = _meshWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RelaxIterative-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Relax-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AdjacentVertexIndices.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FaceToVertexIndices.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MultiplyByThree.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RemoveDuplicates.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SameAsPreviousElement.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GreaterThanZero.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectVertices.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AverageVector.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Sum.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshSetVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LerpVectors-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasSoftSelection.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasPerVertexChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SoftSelection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Iterate-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RelaxTowardsOriginal-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VertexNeighbourDeltas-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VertexNeighbours-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Vertex-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArrayAdd-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapIndices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshMoveVerticesToward-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeMeshOrDefault-ext.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local original_meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		original_meshWrapper = original_meshWrapperClass._CreateWrapper (undefined)
		original_meshWrapper_SetValue = original_meshWrapper._SetValue

	)

	on create do 
	(
		initialize()
	)

	on clone fromObj do 
	(
		initialize()
	)

	on load do 
	(
		initialize()
	)

	on update do 
	(
		initialize()
	)

	rollout params "Parameters"
	(
		checkbox maintain_edge_lengths "maintain edge lengths" checked:False
		spinner iterations "iterations" range:[0, 100, 1] type:#integer
		pickbutton original_mesh "original mesh" autodisplay:true type:#node toolTip:"original mesh"
		spinner amount "amount" range:[0, 100, 0.5] type:#float

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(maintain_edge_lengths, meshWrapper, iterations, original_meshWrapper, amount) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		original_meshWrapper_SetValue original_mesh
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
