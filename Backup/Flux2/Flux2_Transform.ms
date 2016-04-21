plugin simpleMeshMod Flux2_Transform
	name:"Flux2_Transform"
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
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		duplicates ui:duplicates default:1 type:#integer animatable:true
		transform_overwrite ui:transform_overwrite default:False type:#boolean animatable:true
		translation_x ui:translation_x default:0 type:#float animatable:true
		translation_y ui:translation_y default:0 type:#float animatable:true
		translation_z ui:translation_z default:0 type:#float animatable:true
		rotation_x ui:rotation_x default:0 type:#float animatable:true
		rotation_y ui:rotation_y default:0 type:#float animatable:true
		rotation_z ui:rotation_z default:0 type:#float animatable:true
		scaling_x ui:scaling_x default:1 type:#float animatable:true
		scaling_y ui:scaling_y default:1 type:#float animatable:true
		scaling_z ui:scaling_z default:1 type:#float animatable:true
		transform__local ui:transform__local default:False type:#boolean animatable:true
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
		createMesh ui:createMesh default:True type:#boolean animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\Flux2_Transform.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\PositionRotationScaleMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\Multiply3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\MatrixApplyOrSetTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\MatricesRandomize.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\TranslateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixTranslate.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixApplyTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\PseudoRandomVectorPlusMinusHalfRange.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PseudoRandomVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\RotateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\MatrixRotateUsingEuler.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\ScaleMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorUnit.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalarToVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMeshAsBoxes.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshCopyCustomMapChannelVertexBuffers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelCopyVertexBuffer.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMatricesWithRepetition.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMatricesOrIdentity.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IfNot.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\GreaterThanOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RepeatElements.maxcompound")

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
		spinner flux_channel "flux channel" range:[-3, 100, 2] type:#integer
		spinner duplicates "duplicates" range:[0, 1000, 1] type:#integer
		checkbox transform_overwrite "transform overwrite" checked:False
		spinner translation_x "translation x" range:[-1000000, 1000000, 0] type:#float
		spinner translation_y "translation y" range:[-1000000, 1000000, 0] type:#float
		spinner translation_z "translation z" range:[-1000000, 1000000, 0] type:#float
		spinner rotation_x "rotation x" range:[-1000000, 1000000, 0] type:#float
		spinner rotation_y "rotation y" range:[-1000000, 1000000, 0] type:#float
		spinner rotation_z "rotation z" range:[-1000000, 1000000, 0] type:#float
		spinner scaling_x "scaling x" range:[-1000000, 1000000, 1] type:#float
		spinner scaling_y "scaling y" range:[-1000000, 1000000, 1] type:#float
		spinner scaling_z "scaling z" range:[-1000000, 1000000, 1] type:#float
		checkbox transform__local "transform  local" checked:False
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
		checkbox createMesh "createMesh" checked:True
		spinner radius "radius" range:[0, 100, 1] type:#float

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, flux_channel, duplicates, transform_overwrite, translation_x, translation_y, translation_z, rotation_x, rotation_y, rotation_z, scaling_x, scaling_y, scaling_z, transform__local, random_seed, rand_offset__x, rand_offset_y, rand_offset_z, rand_rotation_x, rand_rotation_y, rand_rotation_z, rand_scaling_x, rand_scaling_y, rand_scaling_z, createMesh, radius) argsType
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
