plugin simpleMeshMod Flux_Transform_2
	name:"Flux_Transform_2"
	classID:#(0x54050EAC, 0x74F8F8D8)
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
	local positionWrapper, positionWrapper_SetValue
	local rotationWrapper, rotationWrapper_SetValue
	local scalingWrapper, scalingWrapper_SetValue
	local random__positionWrapper, random__positionWrapper_SetValue
	local random_rotationWrapper, random_rotationWrapper_SetValue
	local random_scalingWrapper, random_scalingWrapper_SetValue
	local orient_targetWrapper, orient_targetWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue
	local affect_region_targetWrapper, affect_region_targetWrapper_SetValue
	local clone_targetWrapper, clone_targetWrapper_SetValue


	parameters main rollout:params
	(
		keep_custom_channels ui:keep_custom_channels default:True type:#boolean animatable:true
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		setOrOffset ui:setOrOffset default:False type:#boolean animatable:true
		position type:#point3 default:[0,0,0]
		on position set val do 
		( 
			if paramsOpen then (
				this.params.position_XSpinner.value = val.X
				this.params.position_YSpinner.value = val.Y
				this.params.position_ZSpinner.value = val.Z 
			)
		)
		rotation type:#point3 default:[0,0,0]
		on rotation set val do 
		( 
			if paramsOpen then (
				this.params.rotation_XSpinner.value = val.X
				this.params.rotation_YSpinner.value = val.Y
				this.params.rotation_ZSpinner.value = val.Z 
			)
		)
		scaling type:#point3 default:[1,1,1]
		on scaling set val do 
		( 
			if paramsOpen then (
				this.params.scaling_XSpinner.value = val.X
				this.params.scaling_YSpinner.value = val.Y
				this.params.scaling_ZSpinner.value = val.Z 
			)
		)
		localOrGlobal ui:localOrGlobal default:False type:#boolean animatable:true
		seed ui:seed default:0 type:#integer animatable:true
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
		Use_orientation ui:Use_orientation default:False type:#boolean animatable:true
		orient_target ui:orient_target type:#node useNodeOsValidity:true useNodeTmValidity:true
		rotation_axis_1 ui:rotation_axis_1 default:2 type:#integer animatable:true
		rotation_axis_2 ui:rotation_axis_2 default:1 type:#integer animatable:true
		orientation_axis ui:orientation_axis default:0 type:#integer animatable:true
		affect_region_target ui:affect_region_target type:#node useNodeOsValidity:true useNodeTmValidity:true
		Use_affect_region ui:Use_affect_region default:False type:#boolean animatable:true
		falloff ui:falloff default:10 type:#float animatable:true
		pinch ui:pinch default:0 type:#float animatable:true
		bubble ui:bubble default:0 type:#float animatable:true
		interpolateSeed ui:interpolateSeed default:0 type:#integer animatable:true
		minStrength ui:minStrength default:100 type:#float animatable:true
		maxStrength ui:maxStrength default:100 type:#float animatable:true
		randomStrength ui:randomStrength default:0 type:#float animatable:true
		Use_Falloff ui:Use_Falloff default:False type:#boolean animatable:true
		invert_falloff ui:invert_falloff default:False type:#boolean animatable:true
		peakX ui:peakX default:50 type:#float animatable:true
		symmetric ui:symmetric default:True type:#boolean animatable:true
		linearOrCubic ui:linearOrCubic default:False type:#boolean animatable:true
		falloffDistance ui:falloffDistance default:10 type:#float animatable:true
		include_original ui:include_original default:False type:#boolean animatable:true
		clone_target ui:clone_target type:#node useNodeOsValidity:true useNodeTmValidity:true
		default_box_size ui:default_box_size default:1 type:#float animatable:true
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
		pluginDefinitionFile = @"C:/Users/digginc/Autodesk/3ds Max 2016/Max Creation Graph/Tools/Flux2/Flux Transform 2.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxClone.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshCopyCustomMapChannelVertexBuffers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelCopyVertexBuffer.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\AppendIf.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshFromNodeWithDefault.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxFalloffInterpolateMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FloatWeightsUsingFalloff.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RangeFloatBetween.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SkipOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ClampFloatToOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\OneMinus.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FloatDistanceFalloffCubicOrLinear.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\DivideDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FloatIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\DivideBy100.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxLinearInterpolateMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GenerateFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ScaleFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxAffectRegion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatrixCombineAffectRegion.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\AffectRegionCompound.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodeTMInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatricesOrientTowardsNode.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLookat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixOrientAroundAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorAngleSigned.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GtEqZ.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\AngleOfVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ProjectionOntoPlaneSpecifiedByNormal.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Projection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpaceOrOrigin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpaceOrTarget.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodeTMInLocalSpace.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ChooseAxis.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatricesRandomize.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\TranslateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\PseudoRandomVectorPlusMinusHalfRange.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PseudoRandomVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixTranslate.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixApplyTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\RotateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MatrixRotateUsingEuler.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\ScaleMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorUnit.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ScalarToVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatrixApplyOrSetTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PositionRotationScaleMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\Multiply3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array3.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local positionWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		positionWrapper = positionWrapperClass._CreateWrapper ([0,0,0])
		positionWrapper_SetValue = positionWrapper._SetValue
		local rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		rotationWrapper = rotationWrapperClass._CreateWrapper ([0,0,0])
		rotationWrapper_SetValue = rotationWrapper._SetValue
		local scalingWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		scalingWrapper = scalingWrapperClass._CreateWrapper ([0,0,0])
		scalingWrapper_SetValue = scalingWrapper._SetValue
		local random__positionWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		random__positionWrapper = random__positionWrapperClass._CreateWrapper ([0,0,0])
		random__positionWrapper_SetValue = random__positionWrapper._SetValue
		local random_rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		random_rotationWrapper = random_rotationWrapperClass._CreateWrapper ([0,0,0])
		random_rotationWrapper_SetValue = random_rotationWrapper._SetValue
		local random_scalingWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		random_scalingWrapper = random_scalingWrapperClass._CreateWrapper ([0,0,0])
		random_scalingWrapper_SetValue = random_scalingWrapper._SetValue
		local orient_targetWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		orient_targetWrapper = orient_targetWrapperClass._CreateWrapper (undefined)
		orient_targetWrapper_SetValue = orient_targetWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue
		local affect_region_targetWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		affect_region_targetWrapper = affect_region_targetWrapperClass._CreateWrapper (undefined)
		affect_region_targetWrapper_SetValue = affect_region_targetWrapper._SetValue
		local clone_targetWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		clone_targetWrapper = clone_targetWrapperClass._CreateWrapper (undefined)
		clone_targetWrapper_SetValue = clone_targetWrapper._SetValue

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
		checkbox keep_custom_channels "keep custom channels" checked:True
		spinner flux_channel "flux channel" range:[-3, 100, 2] type:#integer
		checkbox setOrOffset "setOrOffset" checked:False
		label position_Label "position" align:#left
		spinner position_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner position_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner position_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on position_XSpinner changed val do position.X = val
		on position_YSpinner changed val do position.Y = val
		on position_ZSpinner changed val do position.Z = val

		label rotation_Label "rotation" align:#left
		spinner rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on rotation_XSpinner changed val do rotation.X = val
		on rotation_YSpinner changed val do rotation.Y = val
		on rotation_ZSpinner changed val do rotation.Z = val

		label scaling_Label "scaling" align:#left
		spinner scaling_XSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left across:3
		spinner scaling_YSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		spinner scaling_ZSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		on scaling_XSpinner changed val do scaling.X = val
		on scaling_YSpinner changed val do scaling.Y = val
		on scaling_ZSpinner changed val do scaling.Z = val

		checkbox localOrGlobal "localOrGlobal" checked:False
		spinner seed "seed" range:[0, 10000, 0] type:#integer
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

		checkbox Use_orientation "Use orientation" checked:False
		pickbutton orient_target "orient target" autodisplay:true type:#node toolTip:"orient target"
		spinner rotation_axis_1 "rotation axis 1" range:[-3, 2, 2] type:#integer
		spinner rotation_axis_2 "rotation axis 2" range:[-3, 2, 1] type:#integer
		spinner orientation_axis "orientation axis" range:[-3, 2, 0] type:#integer
		pickbutton affect_region_target "affect region target" autodisplay:true type:#node toolTip:"affect region target"
		checkbox Use_affect_region "Use affect region" checked:False
		spinner falloff "falloff" range:[-100000, 10000, 10] type:#float
		spinner pinch "pinch" range:[0, 100, 0] type:#float
		spinner bubble "bubble" range:[0, 100, 0] type:#float
		spinner interpolateSeed "interpolateSeed" range:[0, 10000, 0] type:#integer
		spinner minStrength "minStrength" range:[0, 100, 100] type:#float
		spinner maxStrength "maxStrength" range:[0, 100, 100] type:#float
		spinner randomStrength "randomStrength" range:[0, 100, 0] type:#float
		checkbox Use_Falloff "Use Falloff" checked:False
		checkbox invert_falloff "invert falloff" checked:False
		spinner peakX "peakX" range:[-500, 500, 50] type:#float
		checkbox symmetric "symmetric" checked:True
		checkbox linearOrCubic "linearOrCubic" checked:False
		spinner falloffDistance "falloffDistance" range:[0, 500, 10] type:#float
		checkbox include_original "include original" checked:False
		pickbutton clone_target "clone target" autodisplay:true type:#node toolTip:"clone target"
		spinner default_box_size "default box size" range:[0, 100000, 1] type:#float
		on params open do
		(
			paramsOpen = true



			position_XSpinner.value = position.X
			position_YSpinner.value = position.Y
			position_ZSpinner.value = position.Z

			rotation_XSpinner.value = rotation.X
			rotation_YSpinner.value = rotation.Y
			rotation_ZSpinner.value = rotation.Z

			scaling_XSpinner.value = scaling.X
			scaling_YSpinner.value = scaling.Y
			scaling_ZSpinner.value = scaling.Z



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
		if (tmHandler == undefined) then ( tmHandler = when transform owningNode changes do _dummy = not _dummy )
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(keep_custom_channels, meshWrapper, flux_channel, setOrOffset, positionWrapper, rotationWrapper, scalingWrapper, localOrGlobal, seed, random__positionWrapper, random_rotationWrapper, random_scalingWrapper, Use_orientation, orient_targetWrapper, modifierTransformWrapper, rotation_axis_1, rotation_axis_2, orientation_axis, affect_region_targetWrapper, Use_affect_region, falloff, pinch, bubble, interpolateSeed, minStrength, maxStrength, randomStrength, Use_Falloff, invert_falloff, peakX, symmetric, linearOrCubic, falloffDistance, include_original, clone_targetWrapper, default_box_size) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		positionWrapper_SetValue position
		if (paramsOpen) then (
		 	params.position_XSpinner.value = position.X
		 	params.position_YSpinner.value = position.Y
		 	params.position_ZSpinner.value = position.Z
		)
		rotationWrapper_SetValue rotation
		if (paramsOpen) then (
		 	params.rotation_XSpinner.value = rotation.X
		 	params.rotation_YSpinner.value = rotation.Y
		 	params.rotation_ZSpinner.value = rotation.Z
		)
		scalingWrapper_SetValue scaling
		if (paramsOpen) then (
		 	params.scaling_XSpinner.value = scaling.X
		 	params.scaling_YSpinner.value = scaling.Y
		 	params.scaling_ZSpinner.value = scaling.Z
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
		orient_targetWrapper_SetValue orient_target
		affect_region_targetWrapper_SetValue affect_region_target
		clone_targetWrapper_SetValue clone_target
		meshWrapper_SetValue mesh
		modifierTransformWrapper_SetValue owningNode.Transform

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
