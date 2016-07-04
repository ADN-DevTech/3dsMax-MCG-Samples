plugin simpleObject StairsAndRails
	name:"StairsAndRails"
	classID:#(0x5AE885A5, 0x1FFF67DB)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _meshWrapper -- the dotnet wrapper around our mesh pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	local owningNode
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _meshWrapper_SetValue
	local pluginInstance_UpdateMesh

	-- value wrapper local and function wrapper declarations


	parameters main rollout:params
	(
		num_stairs ui:num_stairs default:12 type:#integer animatable:true
		Y_spacing ui:Y_spacing default:5 type:#float animatable:true
		Z_spacing ui:Z_spacing default:5 type:#float animatable:true
		stair_width ui:stair_width default:30 type:#float animatable:true
		stair_height ui:stair_height default:1 type:#float animatable:true
		stair_depth ui:stair_depth default:8 type:#float animatable:true
		rail_post_width ui:rail_post_width default:1 type:#float animatable:true
		rail_post_height ui:rail_post_height default:20 type:#float animatable:true
		rail_post_depth ui:rail_post_depth default:1 type:#float animatable:true
		rail_post_X_offset ui:rail_post_X_offset default:-1.8 type:#float animatable:true
		rail_post_Y_offset ui:rail_post_Y_offset default:0 type:#float animatable:true
		handrail_width ui:handrail_width default:3 type:#float animatable:true
		handrail_depth ui:handrail_depth default:3 type:#float animatable:true
		handrail_height ui:handrail_height default:2 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\StairsAndRails.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.GeometryPluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		local _pluginOwner = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile _pluginOwner
		pluginInstance_UpdateMesh = pluginInstance.UpdateMesh
		local meshWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.Mesh"
		_meshWrapper = meshWrapperClass._CreateWrapper undefined
		_meshWrapper_SetValue = _meshWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\OffsetMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Vector3FromZ.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetZ.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\First.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Last.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array2.maxcompound")

		-- value wrapper local initializations

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



	tool create 
	(
		on mousePoint click do 
		(
			case click of 
			(
				1: nodeTM.translation = gridPoint
				2: #stop
			) 
		) 
	) 

	rollout params "Parameters"
	(
		spinner num_stairs "num stairs" range:[1, 1000, 12] type:#integer
		spinner Y_spacing "Y-spacing" range:[-1000, 1000, 5] type:#float
		spinner Z_spacing "Z-spacing" range:[-1000, 1000, 5] type:#float
		spinner stair_width "stair width" range:[0, 1000, 30] type:#float
		spinner stair_height "stair height" range:[0, 1000, 1] type:#float
		spinner stair_depth "stair depth" range:[0, 1000, 8] type:#float
		spinner rail_post_width "rail post width" range:[0, 1000, 1] type:#float
		spinner rail_post_height "rail post height" range:[0, 1000, 20] type:#float
		spinner rail_post_depth "rail post depth" range:[0, 1000, 1] type:#float
		spinner rail_post_X_offset "rail post X offset" range:[-1000, 1000, -1.8] type:#float
		spinner rail_post_Y_offset "rail post Y offset" range:[-1000, 1000, 0] type:#float
		spinner handrail_width "handrail width" range:[0, 1000, 3] type:#float
		spinner handrail_depth "handrail depth" range:[0, 1000, 3] type:#float
		spinner handrail_height "handrail height" range:[0, 1000, 2] type:#float

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(num_stairs, Y_spacing, Z_spacing, stair_width, stair_height, stair_depth, rail_post_width, rail_post_height, rail_post_depth, rail_post_X_offset, rail_post_Y_offset, handrail_width, handrail_depth, handrail_height) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
