plugin simpleMeshMod Cloner_Transform_MCG
	name:"Cloner_Transform_MCG"
	classID:#(0x6FD622C, 0x5C3B7052)
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


	parameters main rollout:params
	(
		channel_id ui:channel_id default:2 type:#integer animatable:true
		duplicates ui:duplicates default:1 type:#integer animatable:true
		relative ui:relative default:True type:#boolean animatable:true
		translation_x ui:translation_x default:0 type:#float animatable:true
		translation_y ui:translation_y default:0 type:#float animatable:true
		translation_z ui:translation_z default:0 type:#float animatable:true
		rotation_x ui:rotation_x default:0 type:#float animatable:true
		rotation_y ui:rotation_y default:0 type:#float animatable:true
		rotation_z ui:rotation_z default:0 type:#float animatable:true
		scaling_x ui:scaling_x default:1 type:#float animatable:true
		scaling_y ui:scaling_y default:1 type:#float animatable:true
		scaling_z ui:scaling_z default:1 type:#float animatable:true
		random_seed ui:random_seed default:0 type:#integer animatable:true
		rand_offset__x ui:rand_offset__x default:0 type:#float animatable:true
		rand_offset_y ui:rand_offset_y default:0 type:#float animatable:true
		rand_offset_z ui:rand_offset_z default:0 type:#float animatable:true
		rand_rotation_x ui:rand_rotation_x default:0 type:#float animatable:true
		rand_rotation_y ui:rand_rotation_y default:0 type:#float animatable:true
		rand_rotation_z ui:rand_rotation_z default:0 type:#float animatable:true
		rand_scaling_x ui:rand_scaling_x default:0 type:#float animatable:true
		rand_scaling_y ui:rand_scaling_y default:0 type:#float animatable:true
		rand_scaling_z ui:rand_scaling_z default:0 type:#float animatable:true
		radius ui:radius default:1 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Cloners\Cloner Transform MCG.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromPositionRotationScale-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromScalingVector2-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Multiply3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToQuaternion-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuaternionFromVector3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToRadians-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorMapComponents-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorFromArray-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelStoreMatrices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatricesRandomize-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\TranslateMatricesRandomly-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RandomArray-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixTranslate-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixApplyTransform-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PseudoRandomVectorPlusMinusHalfRange-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PseudoRandomVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RotateMatricesRandomly-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixRotateUsingEuler-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToMatrix-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToQuaternion-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ScaleMatricesRandomly-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorUnit-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ScalarToVector-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerMeshAsBoxes-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatricesFromMapChannel-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshCopyCustomMapChannelVertexBuffers-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelCopyVertexBuffer-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelExists-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\IsNullFix2-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometryGet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CreateCubeMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadToTriMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerMatricesWithRepetition-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerMatricesOrIdentity-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\IfNot-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelStoreMatrices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\GreaterThanOne-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RepeatElements-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixApplyTransform-ext.maxcompound")

		-- value wrapper local initializations
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
		spinner channel_id "channel id" range:[-3, 100, 2] type:#integer
		spinner duplicates "duplicates" range:[0, 1000, 1] type:#integer
		checkbox relative "relative" checked:True
		spinner translation_x "translation x" range:[-1000000, 1000000, 0] type:#float
		spinner translation_y "translation y" range:[-1000000, 1000000, 0] type:#float
		spinner translation_z "translation z" range:[-1000000, 1000000, 0] type:#float
		spinner rotation_x "rotation x" range:[-1000000, 1000000, 0] type:#float
		spinner rotation_y "rotation y" range:[-1000000, 1000000, 0] type:#float
		spinner rotation_z "rotation z" range:[-1000000, 1000000, 0] type:#float
		spinner scaling_x "scaling x" range:[-1000000, 1000000, 1] type:#float
		spinner scaling_y "scaling y" range:[-1000000, 1000000, 1] type:#float
		spinner scaling_z "scaling z" range:[-1000000, 1000000, 1] type:#float
		spinner random_seed "random seed" range:[0, 10000, 0] type:#integer
		spinner rand_offset__x "rand offset  x" range:[-1000000, 1000000, 0] type:#float
		spinner rand_offset_y "rand offset y" range:[-1000000, 1000000, 0] type:#float
		spinner rand_offset_z "rand offset z" range:[-1000000, 1000000, 0] type:#float
		spinner rand_rotation_x "rand rotation x" range:[-1000000, 1000000, 0] type:#float
		spinner rand_rotation_y "rand rotation y" range:[-1000000, 1000000, 0] type:#float
		spinner rand_rotation_z "rand rotation z" range:[-1000000, 1000000, 0] type:#float
		spinner rand_scaling_x "rand scaling x" range:[-1000000, 1000000, 0] type:#float
		spinner rand_scaling_y "rand scaling y" range:[-1000000, 1000000, 0] type:#float
		spinner rand_scaling_z "rand scaling z" range:[-1000000, 1000000, 0] type:#float
		spinner radius "radius" range:[0, 100, 1] type:#float

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, channel_id, duplicates, relative, translation_x, translation_y, translation_z, rotation_x, rotation_y, rotation_z, scaling_x, scaling_y, scaling_z, random_seed, rand_offset__x, rand_offset_y, rand_offset_z, rand_rotation_x, rand_rotation_y, rand_rotation_z, rand_scaling_x, rand_scaling_y, rand_scaling_z, radius) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
