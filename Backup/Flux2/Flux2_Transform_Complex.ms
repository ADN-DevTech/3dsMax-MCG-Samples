plugin simpleMeshMod Flux2_Transform_Complex
	name:"Flux2_Transform_Complex"
	classID:#(0x6A198AA8, 0x8D8B672)
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
	local meshWrapper, meshWrapper_SetValue
	local transform_positionWrapper, transform_positionWrapper_SetValue
	local transform_rotationWrapper, transform_rotationWrapper_SetValue
	local transform__scalingWrapper, transform__scalingWrapper_SetValue
	local random__positionWrapper, random__positionWrapper_SetValue
	local random_rotationWrapper, random_rotationWrapper_SetValue
	local random_scalingWrapper, random_scalingWrapper_SetValue


	parameters main rollout:params
	(
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		duplicates ui:duplicates default:1 type:#integer animatable:true
		transform_overwrite ui:transform_overwrite default:False type:#boolean animatable:true
		transform_position type:#point3 default:[0,0,0]
		on transform_position set val do 
		( 
			if paramsOpen then (
				this.params.transform_position_XSpinner.value = val.X
				this.params.transform_position_YSpinner.value = val.Y
				this.params.transform_position_ZSpinner.value = val.Z 
			)
		)
		transform_rotation type:#point3 default:[0,0,0]
		on transform_rotation set val do 
		( 
			if paramsOpen then (
				this.params.transform_rotation_XSpinner.value = val.X
				this.params.transform_rotation_YSpinner.value = val.Y
				this.params.transform_rotation_ZSpinner.value = val.Z 
			)
		)
		transform__scaling type:#point3 default:[1,1,1]
		on transform__scaling set val do 
		( 
			if paramsOpen then (
				this.params.transform__scaling_XSpinner.value = val.X
				this.params.transform__scaling_YSpinner.value = val.Y
				this.params.transform__scaling_ZSpinner.value = val.Z 
			)
		)
		transform__local ui:transform__local default:False type:#boolean animatable:true
		random_seed ui:random_seed default:0 type:#integer animatable:true
		random__position type:#point3 default:[0,0,0]
		on random__position set val do 
		( 
			if paramsOpen then (
				this.params.random__position_XSpinner.value = val.X
				this.params.random__position_YSpinner.value = val.Y
				this.params.random__position_ZSpinner.value = val.Z 
			)
		)
		random_rotation type:#point3 default:[0,0,0]
		on random_rotation set val do 
		( 
			if paramsOpen then (
				this.params.random_rotation_XSpinner.value = val.X
				this.params.random_rotation_YSpinner.value = val.Y
				this.params.random_rotation_ZSpinner.value = val.Z 
			)
		)
		random_scaling type:#point3 default:[0,0,0]
		on random_scaling set val do 
		( 
			if paramsOpen then (
				this.params.random_scaling_XSpinner.value = val.X
				this.params.random_scaling_YSpinner.value = val.Y
				this.params.random_scaling_ZSpinner.value = val.Z 
			)
		)
		Strength_interpolate ui:Strength_interpolate default:False type:#boolean animatable:true
		strength_seed ui:strength_seed default:0 type:#integer animatable:true
		strength_min ui:strength_min default:100 type:#float animatable:true
		strength_max ui:strength_max default:100 type:#float animatable:true
		strength_randomization ui:strength_randomization default:0 type:#float animatable:true
		Use_Falloff ui:Use_Falloff default:False type:#boolean animatable:true
		falloff_invert ui:falloff_invert default:False type:#boolean animatable:true
		falloff_peak_X ui:falloff_peak_X default:50 type:#float animatable:true
		falloff_symmetric ui:falloff_symmetric default:True type:#boolean animatable:true
		falloff_linear ui:falloff_linear default:False type:#boolean animatable:true
		falloff_distance ui:falloff_distance default:10 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\Flux2_Transform_Complex.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\PositionRotationScaleMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\Multiply3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\MatrixApplyOrSetTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxLinearInterpolateMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GenerateFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ScaleFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\DivideBy100.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxFalloffInterpolateMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FloatWeightsUsingFalloff.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RangeFloatBetween.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SkipOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FloatDistanceFalloffCubicOrLinear.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\DivideDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FloatIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\OneMinus.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ClampFloatToOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\MatricesRandomize.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\TranslateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixTranslate.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixApplyTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\PseudoRandomVectorPlusMinusHalfRange.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PseudoRandomVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\RotateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\MatrixRotateUsingEuler.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\ScaleMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorUnit.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalarToVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxAffectRegion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\MatrixCombineAffectRegion.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AffectRegionCompound.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\NodePositionInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\NodeTMInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMeshAsBoxes.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshCopyCustomMapChannelVertexBuffers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelCopyVertexBuffer.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMatricesWithRepetition.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMatricesOrIdentity.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IfNot.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\GreaterThanOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RepeatElements.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local transform_positionWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		transform_positionWrapper = transform_positionWrapperClass._CreateWrapper ([0,0,0])
		transform_positionWrapper_SetValue = transform_positionWrapper._SetValue
		local transform_rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		transform_rotationWrapper = transform_rotationWrapperClass._CreateWrapper ([0,0,0])
		transform_rotationWrapper_SetValue = transform_rotationWrapper._SetValue
		local transform__scalingWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		transform__scalingWrapper = transform__scalingWrapperClass._CreateWrapper ([0,0,0])
		transform__scalingWrapper_SetValue = transform__scalingWrapper._SetValue
		local random__positionWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		random__positionWrapper = random__positionWrapperClass._CreateWrapper ([0,0,0])
		random__positionWrapper_SetValue = random__positionWrapper._SetValue
		local random_rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		random_rotationWrapper = random_rotationWrapperClass._CreateWrapper ([0,0,0])
		random_rotationWrapper_SetValue = random_rotationWrapper._SetValue
		local random_scalingWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		random_scalingWrapper = random_scalingWrapperClass._CreateWrapper ([0,0,0])
		random_scalingWrapper_SetValue = random_scalingWrapper._SetValue

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
		label transform_position_Label "transform position" align:#left
		spinner transform_position_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner transform_position_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner transform_position_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on transform_position_XSpinner changed val do transform_position.X = val
		on transform_position_YSpinner changed val do transform_position.Y = val
		on transform_position_ZSpinner changed val do transform_position.Z = val

		label transform_rotation_Label "transform rotation" align:#left
		spinner transform_rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner transform_rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner transform_rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on transform_rotation_XSpinner changed val do transform_rotation.X = val
		on transform_rotation_YSpinner changed val do transform_rotation.Y = val
		on transform_rotation_ZSpinner changed val do transform_rotation.Z = val

		label transform__scaling_Label "transform  scaling" align:#left
		spinner transform__scaling_XSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left across:3
		spinner transform__scaling_YSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		spinner transform__scaling_ZSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		on transform__scaling_XSpinner changed val do transform__scaling.X = val
		on transform__scaling_YSpinner changed val do transform__scaling.Y = val
		on transform__scaling_ZSpinner changed val do transform__scaling.Z = val

		checkbox transform__local "transform  local" checked:False
		spinner random_seed "random seed" range:[0, 10000, 0] type:#integer
		label random__position_Label "random  position" align:#left
		spinner random__position_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner random__position_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner random__position_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on random__position_XSpinner changed val do random__position.X = val
		on random__position_YSpinner changed val do random__position.Y = val
		on random__position_ZSpinner changed val do random__position.Z = val

		label random_rotation_Label "random rotation" align:#left
		spinner random_rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner random_rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner random_rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on random_rotation_XSpinner changed val do random_rotation.X = val
		on random_rotation_YSpinner changed val do random_rotation.Y = val
		on random_rotation_ZSpinner changed val do random_rotation.Z = val

		label random_scaling_Label "random scaling" align:#left
		spinner random_scaling_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner random_scaling_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner random_scaling_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on random_scaling_XSpinner changed val do random_scaling.X = val
		on random_scaling_YSpinner changed val do random_scaling.Y = val
		on random_scaling_ZSpinner changed val do random_scaling.Z = val

		checkbox Strength_interpolate "Strength interpolate" checked:False
		spinner strength_seed "strength seed" range:[0, 10000, 0] type:#integer
		spinner strength_min "strength min" range:[0, 100, 100] type:#float
		spinner strength_max "strength max" range:[0, 100, 100] type:#float
		spinner strength_randomization "strength randomization" range:[0, 100, 0] type:#float
		checkbox Use_Falloff "Use Falloff" checked:False
		checkbox falloff_invert "falloff invert" checked:False
		spinner falloff_peak_X "falloff peak X" range:[-500, 500, 50] type:#float
		checkbox falloff_symmetric "falloff symmetric" checked:True
		checkbox falloff_linear "falloff linear" checked:False
		spinner falloff_distance "falloff distance" range:[0, 500, 10] type:#float
		checkbox createMesh "createMesh" checked:True
		spinner radius "radius" range:[0, 100, 1] type:#float
		on params open do
		(
			paramsOpen = true



			transform_position_XSpinner.value = transform_position.X
			transform_position_YSpinner.value = transform_position.Y
			transform_position_ZSpinner.value = transform_position.Z

			transform_rotation_XSpinner.value = transform_rotation.X
			transform_rotation_YSpinner.value = transform_rotation.Y
			transform_rotation_ZSpinner.value = transform_rotation.Z

			transform__scaling_XSpinner.value = transform__scaling.X
			transform__scaling_YSpinner.value = transform__scaling.Y
			transform__scaling_ZSpinner.value = transform__scaling.Z



			random__position_XSpinner.value = random__position.X
			random__position_YSpinner.value = random__position.Y
			random__position_ZSpinner.value = random__position.Z

			random_rotation_XSpinner.value = random_rotation.X
			random_rotation_YSpinner.value = random_rotation.Y
			random_rotation_ZSpinner.value = random_rotation.Z

			random_scaling_XSpinner.value = random_scaling.X
			random_scaling_YSpinner.value = random_scaling.Y
			random_scaling_ZSpinner.value = random_scaling.Z














		)
		on params close do
		(

			paramsOpen = false
		)
	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, flux_channel, duplicates, transform_overwrite, transform_positionWrapper, transform_rotationWrapper, transform__scalingWrapper, transform__local, random_seed, random__positionWrapper, random_rotationWrapper, random_scalingWrapper, Strength_interpolate, strength_seed, strength_min, strength_max, strength_randomization, Use_Falloff, falloff_invert, falloff_peak_X, falloff_symmetric, falloff_linear, falloff_distance, createMesh, radius) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		transform_positionWrapper_SetValue transform_position
		if (paramsOpen) then (
		 	params.transform_position_XSpinner.value = transform_position.X
		 	params.transform_position_YSpinner.value = transform_position.Y
		 	params.transform_position_ZSpinner.value = transform_position.Z
		)
		transform_rotationWrapper_SetValue transform_rotation
		if (paramsOpen) then (
		 	params.transform_rotation_XSpinner.value = transform_rotation.X
		 	params.transform_rotation_YSpinner.value = transform_rotation.Y
		 	params.transform_rotation_ZSpinner.value = transform_rotation.Z
		)
		transform__scalingWrapper_SetValue transform__scaling
		if (paramsOpen) then (
		 	params.transform__scaling_XSpinner.value = transform__scaling.X
		 	params.transform__scaling_YSpinner.value = transform__scaling.Y
		 	params.transform__scaling_ZSpinner.value = transform__scaling.Z
		)
		random__positionWrapper_SetValue random__position
		if (paramsOpen) then (
		 	params.random__position_XSpinner.value = random__position.X
		 	params.random__position_YSpinner.value = random__position.Y
		 	params.random__position_ZSpinner.value = random__position.Z
		)
		random_rotationWrapper_SetValue random_rotation
		if (paramsOpen) then (
		 	params.random_rotation_XSpinner.value = random_rotation.X
		 	params.random_rotation_YSpinner.value = random_rotation.Y
		 	params.random_rotation_ZSpinner.value = random_rotation.Z
		)
		random_scalingWrapper_SetValue random_scaling
		if (paramsOpen) then (
		 	params.random_scaling_XSpinner.value = random_scaling.X
		 	params.random_scaling_YSpinner.value = random_scaling.Y
		 	params.random_scaling_ZSpinner.value = random_scaling.Z
		)
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
