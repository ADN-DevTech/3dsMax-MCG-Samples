plugin simpleMeshMod Combine_MCG
	name:"Combine_MCG"
	classID:#(0x2AFE27AE, 0x3529BE60)
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
	local paramsOpen = false
	local nodes_List = undefined
	local nodes_selection = #()
	local meshWrapper, meshWrapper_SetValue


	parameters main rollout:params
	(
		nodes_Tab type:#nodeTab tabSizeVariable:true useNodeTmValidity:true useNodeOsValidity:true
		on nodes_Tab tabChanged action index count do
		(
			mcgOps.INodeA_TabChanged action index count (this.params.nodes_UI) nodes_List nodes_Tab paramsOpen
		)
		on nodes_Tab set val index do
		(
			mcgOps.INodeA_TabSet val index (this.params.nodes_UI) nodes_List paramsOpen
		)
		x_offset ui:x_offset default:0 type:#float animatable:true
		y_offset ui:y_offset default:0 type:#float animatable:true
		z_offset ui:z_offset default:0 type:#float animatable:true
		x_rotation ui:x_rotation default:0 type:#float animatable:true
		y_rotation ui:y_rotation default:0 type:#float animatable:true
		z_rotation ui:z_rotation default:0 type:#float animatable:true
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
		pluginDefinitionFile = @"C:/Users/digginc/Autodesk/3ds Max 2017/Max Creation Graph/Tools/3dsMax-MCG-Samples/Tools/Misc. Modifiers/Combine MCG.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodesToMeshesInWorldSpace-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeMeshInWorldSpace-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeCanGetMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\NodeMeshInWorldSpace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToRadians-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorMapComponents-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorFromArray-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\QuaternionFromEuler.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RotationMatrixFromEuler.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MultiplyThreeNumbers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromPRS-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Multiply3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromScalingVector-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\OnesVector-ext.maxcompound")

		-- value wrapper local initializations
		mcgOps.INodeA_Initialization list:&nodes_List
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue

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
		dotNetControl nodes_UI "ListView" width:140 height:190 align:#center
		checkbutton addToList_nodes_UI mcgOps.AddButtonText width:140
		button removeFromList_nodes_UI mcgOps.RemoveButtonText width:140
		on addToList_nodes_UI changed state do with undo label:"Parameter Change" on mcgOps.INodeA_AddToList nodes_Tab state addToList_nodes_UI
		on removeFromList_nodes_UI pressed do with undo label:"Parameter Change" on mcgOps.INodeA_RemoveFromList nodes_UI nodes_Tab
		spinner x_offset "x offset" range:[-100000, 100000, 0] type:#float
		spinner y_offset "y offset" range:[-100000, 100000, 0] type:#float
		spinner z_offset "z offset" range:[-100000, 100000, 0] type:#float
		spinner x_rotation "x rotation" range:[-100000, 100000, 0] type:#float
		spinner y_rotation "y rotation" range:[-100000, 100000, 0] type:#float
		spinner z_rotation "z rotation" range:[-100000, 100000, 0] type:#float
		on params open do
		(
			paramsOpen = true
			mcgOps.OneColParamsOpen nodes_UI nodes_Tab mcgOps.INodeToStringFunc #("nodes") selected:&nodes_selection






		)
		on params close do
		(
			mcgOps.OneColParamsClose nodes_UI selected:&nodes_selection
			paramsOpen = false
		)
	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(nodes_List, x_offset, y_offset, z_offset, x_rotation, y_rotation, z_rotation, meshWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		mcgOps.INodeA_PreInvoke params.nodes_UI nodes_List nodes_Tab paramsOpen
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
