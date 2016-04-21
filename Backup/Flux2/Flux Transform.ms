plugin simpleMeshMod Flux_Transform
	name:"Flux_Transform"
	classID:#(0x5D9883E8, 0x32FB25A3)
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
	local orient_targetWrapper, orient_targetWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue
	local affect_region_targetWrapper, affect_region_targetWrapper_SetValue
	local clone_targetWrapper, clone_targetWrapper_SetValue


	parameters main rollout:params
	(
		keep_custom_channels ui:keep_custom_channels default:True type:#boolean animatable:true
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		setOrOffset ui:setOrOffset default:False type:#boolean animatable:true
		posX ui:posX default:0 type:#float animatable:true
		posY ui:posY default:0 type:#float animatable:true
		posZ ui:posZ default:0 type:#float animatable:true
		rotX ui:rotX default:0 type:#float animatable:true
		rotY ui:rotY default:0 type:#float animatable:true
		rotZ ui:rotZ default:0 type:#float animatable:true
		scaleX ui:scaleX default:1 type:#float animatable:true
		scaleY ui:scaleY default:1 type:#float animatable:true
		scaleZ ui:scaleZ default:1 type:#float animatable:true
		localOrGlobal ui:localOrGlobal default:False type:#boolean animatable:true
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
		minStrength ui:minStrength default:0 type:#float animatable:true
		maxStrength ui:maxStrength default:100 type:#float animatable:true
		randomStrength ui:randomStrength default:0 type:#float animatable:true
		Use_Falloff ui:Use_Falloff default:False type:#boolean animatable:true
		invert_falloff ui:invert_falloff default:False type:#boolean animatable:true
		peakX ui:peakX default:50 type:#float animatable:true
		symmetric ui:symmetric default:True type:#boolean animatable:true
		linearOrCubic ui:linearOrCubic default:False type:#boolean animatable:true
		falloffDistance ui:falloffDistance default:10 type:#float animatable:true
		Random_shuffles ui:Random_shuffles default:0 type:#integer animatable:true
		shuffleSeed ui:shuffleSeed default:0 type:#integer animatable:true
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
		pluginDefinitionFile = @"C:/Users/digginc/Autodesk/3ds Max 2016/Max Creation Graph/Tools/Flux2/Flux Transform.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxClone.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshCopyCustomMapChannelVertexBuffers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelCopyVertexBuffer.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\AppendIf.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshFromNodeWithDefault.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayShuffle.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArraySwap.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\SetValue.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayRandomIndices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\MultiplyByTwo.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxFalloffInterpolateMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FloatWeightsUsingFalloff.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RangeFloatBetween.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\SkipOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\ClampFloatToOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\OneMinus.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FloatDistanceFalloffCubicOrLinear.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\DivideDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FloatIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\DivideBy100.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxLinearInterpolateMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GenerateFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ScaleFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\FluxAffectRegion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatrixCombineAffectRegion.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\AffectRegionCompound.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodeTMInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatricesOrientTowardsNode.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLookat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixOrientAroundAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorAngleSigned.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GtEqZ.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\AngleOfVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ProjectionOntoPlaneSpecifiedByNormal.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Projection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpaceOrOrigin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpaceOrTarget.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodePositionInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\NodeTMInLocalSpace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ChooseAxis.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\MatrixApplyOrSetTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PositionRotationScaleMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\Multiply3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ScalingMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2016\MaxCreationGraph\Compounds\Array3.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
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
		spinner posX "posX" range:[-100000, 100000, 0] type:#float
		spinner posY "posY" range:[-100000, 100000, 0] type:#float
		spinner posZ "posZ" range:[-100000, 100000, 0] type:#float
		spinner rotX "rotX" range:[-100000, 100000, 0] type:#float
		spinner rotY "rotY" range:[-100000, 100000, 0] type:#float
		spinner rotZ "rotZ" range:[-100000, 100000, 0] type:#float
		spinner scaleX "scaleX" range:[-100000, 100000, 1] type:#float
		spinner scaleY "scaleY" range:[-100000, 100000, 1] type:#float
		spinner scaleZ "scaleZ" range:[-100000, 100000, 1] type:#float
		checkbox localOrGlobal "localOrGlobal" checked:False
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
		spinner minStrength "minStrength" range:[0, 100, 0] type:#float
		spinner maxStrength "maxStrength" range:[0, 100, 100] type:#float
		spinner randomStrength "randomStrength" range:[0, 100, 0] type:#float
		checkbox Use_Falloff "Use Falloff" checked:False
		checkbox invert_falloff "invert falloff" checked:False
		spinner peakX "peakX" range:[-500, 500, 50] type:#float
		checkbox symmetric "symmetric" checked:True
		checkbox linearOrCubic "linearOrCubic" checked:False
		spinner falloffDistance "falloffDistance" range:[0, 500, 10] type:#float
		spinner Random_shuffles "Random shuffles" range:[0, 1000, 0] type:#integer
		spinner shuffleSeed "shuffleSeed" range:[0, 10000, 0] type:#integer
		checkbox include_original "include original" checked:False
		pickbutton clone_target "clone target" autodisplay:true type:#node toolTip:"clone target"
		spinner default_box_size "default box size" range:[0, 100000, 1] type:#float

	)




	fn updateMesh = 
	(
		if (tmHandler == undefined) then ( tmHandler = when transform owningNode changes do _dummy = not _dummy )
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(keep_custom_channels, meshWrapper, flux_channel, setOrOffset, posX, posY, posZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ, localOrGlobal, Use_orientation, orient_targetWrapper, modifierTransformWrapper, rotation_axis_1, rotation_axis_2, orientation_axis, affect_region_targetWrapper, Use_affect_region, falloff, pinch, bubble, interpolateSeed, minStrength, maxStrength, randomStrength, Use_Falloff, invert_falloff, peakX, symmetric, linearOrCubic, falloffDistance, Random_shuffles, shuffleSeed, include_original, clone_targetWrapper, default_box_size) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
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
