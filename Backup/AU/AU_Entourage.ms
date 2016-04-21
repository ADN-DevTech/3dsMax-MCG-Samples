plugin simpleMeshMod AU_Entourage
	name:"AU_Entourage"
	classID:#(0x56A648F0, 0x4335189B)
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
	local rand_scaleWrapper, rand_scaleWrapper_SetValue
	local rand_rotationWrapper, rand_rotationWrapper_SetValue
	local rand_translationWrapper, rand_translationWrapper_SetValue
	local splineWrapper, splineWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue
	local preRotationWrapper, preRotationWrapper_SetValue
	local preTranslateWrapper, preTranslateWrapper_SetValue


	parameters main rollout:params
	(
		seed ui:seed default:0 type:#integer animatable:true
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		rand_scale type:#point3 default:[0,0,0]
		on rand_scale set val do 
		( 
			if paramsOpen then (
				this.params.rand_scale_XSpinner.value = val.X
				this.params.rand_scale_YSpinner.value = val.Y
				this.params.rand_scale_ZSpinner.value = val.Z 
			)
		)
		rand_rotation type:#point3 default:[0,0,0]
		on rand_rotation set val do 
		( 
			if paramsOpen then (
				this.params.rand_rotation_XSpinner.value = val.X
				this.params.rand_rotation_YSpinner.value = val.Y
				this.params.rand_rotation_ZSpinner.value = val.Z 
			)
		)
		rand_translation type:#point3 default:[0,0,0]
		on rand_translation set val do 
		( 
			if paramsOpen then (
				this.params.rand_translation_XSpinner.value = val.X
				this.params.rand_translation_YSpinner.value = val.Y
				this.params.rand_translation_ZSpinner.value = val.Z 
			)
		)
		spline ui:spline type:#node useNodeOsValidity:true useNodeTmValidity:true
		cornerA_X_offset ui:cornerA_X_offset default:0 type:#float animatable:true
		corner_B_X_offset ui:corner_B_X_offset default:0 type:#float animatable:true
		spacing ui:spacing default:20 type:#float animatable:true
		probability ui:probability default:50 type:#float animatable:true
		preRotation type:#point3 default:[0,0,0]
		on preRotation set val do 
		( 
			if paramsOpen then (
				this.params.preRotation_XSpinner.value = val.X
				this.params.preRotation_YSpinner.value = val.Y
				this.params.preRotation_ZSpinner.value = val.Z 
			)
		)
		preTranslate type:#point3 default:[0,0,0]
		on preTranslate set val do 
		( 
			if paramsOpen then (
				this.params.preTranslate_XSpinner.value = val.X
				this.params.preTranslate_YSpinner.value = val.Y
				this.params.preTranslate_ZSpinner.value = val.Z 
			)
		)
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\AU_Entourage.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\SplineLines.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\CombineEveryTwoElements.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\SplineFromNodeOrExit.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\LineMatrices.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixLookatDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixLookat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixOrientAroundAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorAngleSigned.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\AngleOfVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GtEqZ.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ProjectionOntoPlaneSpecifiedByNormal.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Projection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\LineVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixOrientAroundZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorProjectionOnXYPlane.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetZ.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\MatrixInterpolateWithSpacing2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixDistance.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\SampleLerpExclusive.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\DivideBy100.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\FilterRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\TransformMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\Multiply5.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\Multiply3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\RotateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\MatrixRotateUsingEuler.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\PseudoRandomVectorPlusMinusHalfRange.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PseudoRandomVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\TranslateMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixTranslate.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixApplyTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\NodeTMInLocalSpace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MapWithIndexes.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEqualsZero.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AlongXAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\ScaleMatricesRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorUnit.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalarToVector.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ScalingMatrix.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local rand_scaleWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		rand_scaleWrapper = rand_scaleWrapperClass._CreateWrapper ([0,0,0])
		rand_scaleWrapper_SetValue = rand_scaleWrapper._SetValue
		local rand_rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		rand_rotationWrapper = rand_rotationWrapperClass._CreateWrapper ([0,0,0])
		rand_rotationWrapper_SetValue = rand_rotationWrapper._SetValue
		local rand_translationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		rand_translationWrapper = rand_translationWrapperClass._CreateWrapper ([0,0,0])
		rand_translationWrapper_SetValue = rand_translationWrapper._SetValue
		local splineWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		splineWrapper = splineWrapperClass._CreateWrapper (undefined)
		splineWrapper_SetValue = splineWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue
		local preRotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		preRotationWrapper = preRotationWrapperClass._CreateWrapper ([0,0,0])
		preRotationWrapper_SetValue = preRotationWrapper._SetValue
		local preTranslateWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		preTranslateWrapper = preTranslateWrapperClass._CreateWrapper ([0,0,0])
		preTranslateWrapper_SetValue = preTranslateWrapper._SetValue

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
		spinner seed "seed" range:[0, 10000, 0] type:#integer
		spinner flux_channel "flux channel" range:[-2, 100, 2] type:#integer
		label rand_scale_Label "rand scale" align:#left
		spinner rand_scale_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner rand_scale_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner rand_scale_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on rand_scale_XSpinner changed val do rand_scale.X = val
		on rand_scale_YSpinner changed val do rand_scale.Y = val
		on rand_scale_ZSpinner changed val do rand_scale.Z = val

		label rand_rotation_Label "rand rotation" align:#left
		spinner rand_rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner rand_rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner rand_rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on rand_rotation_XSpinner changed val do rand_rotation.X = val
		on rand_rotation_YSpinner changed val do rand_rotation.Y = val
		on rand_rotation_ZSpinner changed val do rand_rotation.Z = val

		label rand_translation_Label "rand translation" align:#left
		spinner rand_translation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner rand_translation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner rand_translation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on rand_translation_XSpinner changed val do rand_translation.X = val
		on rand_translation_YSpinner changed val do rand_translation.Y = val
		on rand_translation_ZSpinner changed val do rand_translation.Z = val

		pickbutton spline "spline" autodisplay:true type:#node toolTip:"spline"
		spinner cornerA_X_offset "cornerA X offset" range:[-1000, 1000, 0] type:#float
		spinner corner_B_X_offset "corner B X offset" range:[-1000, 1000, 0] type:#float
		spinner spacing "spacing" range:[0, 10000, 20] type:#float
		spinner probability "probability" range:[0, 100, 50] type:#float
		label preRotation_Label "preRotation" align:#left
		spinner preRotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner preRotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner preRotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on preRotation_XSpinner changed val do preRotation.X = val
		on preRotation_YSpinner changed val do preRotation.Y = val
		on preRotation_ZSpinner changed val do preRotation.Z = val

		label preTranslate_Label "preTranslate" align:#left
		spinner preTranslate_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner preTranslate_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner preTranslate_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on preTranslate_XSpinner changed val do preTranslate.X = val
		on preTranslate_YSpinner changed val do preTranslate.Y = val
		on preTranslate_ZSpinner changed val do preTranslate.Z = val

		on params open do
		(
			paramsOpen = true


			rand_scale_XSpinner.value = rand_scale.X
			rand_scale_YSpinner.value = rand_scale.Y
			rand_scale_ZSpinner.value = rand_scale.Z

			rand_rotation_XSpinner.value = rand_rotation.X
			rand_rotation_YSpinner.value = rand_rotation.Y
			rand_rotation_ZSpinner.value = rand_rotation.Z

			rand_translation_XSpinner.value = rand_translation.X
			rand_translation_YSpinner.value = rand_translation.Y
			rand_translation_ZSpinner.value = rand_translation.Z






			preRotation_XSpinner.value = preRotation.X
			preRotation_YSpinner.value = preRotation.Y
			preRotation_ZSpinner.value = preRotation.Z

			preTranslate_XSpinner.value = preTranslate.X
			preTranslate_YSpinner.value = preTranslate.Y
			preTranslate_ZSpinner.value = preTranslate.Z

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
		local args = dotnet_ValueToDotNetObject #(seed, meshWrapper, flux_channel, rand_scaleWrapper, rand_rotationWrapper, rand_translationWrapper, splineWrapper, modifierTransformWrapper, cornerA_X_offset, corner_B_X_offset, spacing, probability, preRotationWrapper, preTranslateWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		rand_scaleWrapper_SetValue rand_scale
		if (paramsOpen) then (
		 	params.rand_scale_XSpinner.value = rand_scale.X
		 	params.rand_scale_YSpinner.value = rand_scale.Y
		 	params.rand_scale_ZSpinner.value = rand_scale.Z
		)
		rand_rotationWrapper_SetValue rand_rotation
		if (paramsOpen) then (
		 	params.rand_rotation_XSpinner.value = rand_rotation.X
		 	params.rand_rotation_YSpinner.value = rand_rotation.Y
		 	params.rand_rotation_ZSpinner.value = rand_rotation.Z
		)
		rand_translationWrapper_SetValue rand_translation
		if (paramsOpen) then (
		 	params.rand_translation_XSpinner.value = rand_translation.X
		 	params.rand_translation_YSpinner.value = rand_translation.Y
		 	params.rand_translation_ZSpinner.value = rand_translation.Z
		)
		splineWrapper_SetValue spline
		preRotationWrapper_SetValue preRotation
		if (paramsOpen) then (
		 	params.preRotation_XSpinner.value = preRotation.X
		 	params.preRotation_YSpinner.value = preRotation.Y
		 	params.preRotation_ZSpinner.value = preRotation.Z
		)
		preTranslateWrapper_SetValue preTranslate
		if (paramsOpen) then (
		 	params.preTranslate_XSpinner.value = preTranslate.X
		 	params.preTranslate_YSpinner.value = preTranslate.Y
		 	params.preTranslate_ZSpinner.value = preTranslate.Z
		)
		meshWrapper_SetValue mesh
		modifierTransformWrapper_SetValue owningNode.Transform

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
