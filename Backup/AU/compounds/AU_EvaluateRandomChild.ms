plugin simpleMeshMod AU_EvaluateRandomChild
	name:"AU_EvaluateRandomChild"
	classID:#(0x2785CDEC, 0x4B9384D3)
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
	local parentWrapper, parentWrapper_SetValue
	local meshWrapper, meshWrapper_SetValue


	parameters main rollout:params
	(
		parent ui:parent type:#node useNodeOsValidity:true useNodeTmValidity:true
		seed ui:seed default:0 type:#integer animatable:true
		flux_channel_id ui:flux_channel_id default:2 type:#integer animatable:true
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
		pluginDefinitionFile = @"C:/Users/digginc/Autodesk/3ds Max 2016/Max Creation Graph/Tools/AU/compounds/AU_EvaluateRandomChild.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\RandomMeshesFromNodes.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\PseudoRandomInts.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MeshesFromNodesOrDefault.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\GreaterThanZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MeshesFromNodes.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\CubeMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MultiplyTwoFloat.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound")

		-- value wrapper local initializations
		local parentWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		parentWrapper = parentWrapperClass._CreateWrapper (undefined)
		parentWrapper_SetValue = parentWrapper._SetValue
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
		pickbutton parent "parent" autodisplay:true type:#node toolTip:"parent"
		spinner seed "seed" range:[0, 100, 0] type:#integer
		spinner flux_channel_id "flux channel id" range:[-2, 100, 2] type:#integer

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(parentWrapper, seed, meshWrapper, flux_channel_id) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		parentWrapper_SetValue parent
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
