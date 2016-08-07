plugin simpleObject Grid_Cloner
	name:"Grid_Cloner"
	classID:#(0x38155EB4, 0x67A13277)
	category:"MCG Cloners"
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
	local cloneTargetWrapper, cloneTargetWrapper_SetValue


	parameters main rollout:params
	(
		total_x ui:total_x default:20 type:#worldUnits animatable:true
		total_y ui:total_y default:20 type:#worldUnits animatable:true
		total_z ui:total_z default:20 type:#worldUnits animatable:true
		channel ui:channel default:2 type:#integer animatable:true
		grid_y ui:grid_y default:10 type:#integer animatable:true
		grid_x ui:grid_x default:10 type:#integer animatable:true
		grid_z ui:grid_z default:10 type:#integer animatable:true
		box_radius ui:box_radius default:1 type:#worldUnits animatable:true
		clone_mesh ui:clone_mesh default:False type:#boolean animatable:true
		createNodes ui:createNodes default:False type:#boolean animatable:true
		useChildren ui:useChildren default:False type:#boolean animatable:true
		randomizeChildren ui:randomizeChildren default:False type:#boolean animatable:true
		cloneTarget ui:cloneTarget type:#node useNodeOsValidity:true useNodeTmValidity:true
		seed ui:seed default:0 type:#integer animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Cloners\Grid Cloner.maxtool"
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
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SubdivideBox.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SubdivideBoxAlongX.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SubdivideBoxAlongDiagonal.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ArrayOfLerpedVectors.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SampleLerp.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SkipOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DropLast.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MatchBoxX.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SubdivideBoxAlongY.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MatchBoxY.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SubdivideBoxAlongZ.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MatchBoxZ.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BoxFromExtent-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoundingBoxCenter.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelStoreMatrices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerMeshAsBoxes-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatricesFromMapChannel-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshCopyCustomMapChannelVertexBuffers-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelCopyVertexBuffer-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelExists-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\IsNullFix2-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometryGet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CreateCubeMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadToTriMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerClone-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AppendIf.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerTransformChildMeshes-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerChildNodes-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArraySetLength-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MapRange.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\AtModulo-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LessThanZero-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RandomizeArray-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArrayRandomIndices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RandomArray-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GreaterThanZero.maxcompound")

		-- value wrapper local initializations
		local cloneTargetWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		cloneTargetWrapper = cloneTargetWrapperClass._CreateWrapper (undefined)
		cloneTargetWrapper_SetValue = cloneTargetWrapper._SetValue

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
		spinner total_x "total x" range:[0, 100000, 20] type:#worldUnits
		spinner total_y "total y" range:[0, 10000, 20] type:#worldUnits
		spinner total_z "total z" range:[0, 10000, 20] type:#worldUnits
		spinner channel "channel" range:[-2, 100, 2] type:#integer
		spinner grid_y "grid_y" range:[1, 1000, 10] type:#integer
		spinner grid_x "grid_x" range:[1, 10000, 10] type:#integer
		spinner grid_z "grid_z" range:[1, 1000, 10] type:#integer
		spinner box_radius "box radius" range:[0, 10000, 1] type:#worldUnits
		checkbox clone_mesh "clone mesh" checked:False
		checkbox createNodes "createNodes" checked:False
		checkbox useChildren "useChildren" checked:False
		checkbox randomizeChildren "randomizeChildren" checked:False
		pickbutton cloneTarget "cloneTarget" autodisplay:true type:#node toolTip:"cloneTarget"
		spinner seed "seed" range:[0, 100, 0] type:#integer

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(total_x, total_y, total_z, channel, grid_y, grid_x, grid_z, box_radius, clone_mesh, createNodes, useChildren, randomizeChildren, cloneTargetWrapper, seed) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(
		cloneTargetWrapper_SetValue cloneTarget

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
