plugin simpleMeshMod Bend_MCG
	name:"Bend_MCG"
	classID:#(0x679AB346, 0x4B8CBC83)
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
	local boundingBoxWrapper, boundingBoxWrapper_SetValue
	local gizmo_nodeWrapper, gizmo_nodeWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue
	local gizmo_translationWrapper, gizmo_translationWrapper_SetValue
	local gizmo_rotationWrapper, gizmo_rotationWrapper_SetValue
	local gizmo_scaleWrapper, gizmo_scaleWrapper_SetValue


	parameters main rollout:params
	(
		limit ui:limit default:False type:#boolean animatable:true
		lower_limit ui:lower_limit default:0 type:#float animatable:true
		upper_limit ui:upper_limit default:100 type:#float animatable:true
		axis ui:axis default:2 type:#integer animatable:true
		angle ui:angle default:15 type:#float animatable:true
		direction ui:direction default:0 type:#float animatable:true
		use_node_transform ui:use_node_transform default:False type:#boolean animatable:true
		gizmo_node ui:gizmo_node type:#node useNodeOsValidity:true useNodeTmValidity:true
		gizmo_translation type:#point3 default:[0,0,0]
		on gizmo_translation set val do 
		( 
			if paramsOpen then (
				this.params.gizmo_translation_XSpinner.value = val.X
				this.params.gizmo_translation_YSpinner.value = val.Y
				this.params.gizmo_translation_ZSpinner.value = val.Z 
			)
		)
		gizmo_rotation type:#point3 default:[0,0,0]
		on gizmo_rotation set val do 
		( 
			if paramsOpen then (
				this.params.gizmo_rotation_XSpinner.value = val.X
				this.params.gizmo_rotation_YSpinner.value = val.Y
				this.params.gizmo_rotation_ZSpinner.value = val.Z 
			)
		)
		gizmo_scale type:#point3 default:[0,0,0]
		on gizmo_scale set val do 
		( 
			if paramsOpen then (
				this.params.gizmo_scale_XSpinner.value = val.X
				this.params.gizmo_scale_YSpinner.value = val.Y
				this.params.gizmo_scale_ZSpinner.value = val.Z 
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Deformers\Bend MCG.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\GizmoTransformInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixParameterWorldToLocalTransform-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeToLocalTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeValidateAndGetWorldTransform-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromPositionRotationScale-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromScalingVector2-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Multiply3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToQuaternion-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuaternionFromVector3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToRadians-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorMapComponents-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorFromArray-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\OnesVector-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Bend-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshDeformVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshSetVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LerpVectors-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasSoftSelection.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasPerVertexChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SoftSelection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BendDeformer-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixRotationFromDirectionAndAxis-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\DivideDefaultToZero-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\DivideDefault-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\FloatIsSmall-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorLengthEpsilon-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BoundingBoxExtentAlongAxis-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorElement-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorAsArray-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Array3-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoundingBoxExtent.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BendDeformPointImplementation-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\FloatAlmostZero-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PointTransformInMatrixSpaceAndRestore-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideBy100Float.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ScalarToVector-ext.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local boundingBoxWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Box3"
		boundingBoxWrapper = boundingBoxWrapperClass._CreateWrapper (box3())
		boundingBoxWrapper_SetValue = boundingBoxWrapper._SetValue
		local gizmo_nodeWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		gizmo_nodeWrapper = gizmo_nodeWrapperClass._CreateWrapper (undefined)
		gizmo_nodeWrapper_SetValue = gizmo_nodeWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue
		local gizmo_translationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		gizmo_translationWrapper = gizmo_translationWrapperClass._CreateWrapper ([0,0,0])
		gizmo_translationWrapper_SetValue = gizmo_translationWrapper._SetValue
		local gizmo_rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		gizmo_rotationWrapper = gizmo_rotationWrapperClass._CreateWrapper ([0,0,0])
		gizmo_rotationWrapper_SetValue = gizmo_rotationWrapper._SetValue
		local gizmo_scaleWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		gizmo_scaleWrapper = gizmo_scaleWrapperClass._CreateWrapper ([0,0,0])
		gizmo_scaleWrapper_SetValue = gizmo_scaleWrapper._SetValue

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
		checkbox limit "limit" checked:False
		spinner lower_limit "lower limit" range:[-10000, 10000, 0] type:#float
		spinner upper_limit "upper limit" range:[-10000, 10000, 100] type:#float
		spinner axis "axis" range:[0, 2, 2] type:#integer
		spinner angle "angle" range:[-10000, 10000, 15] type:#float
		spinner direction "direction" range:[-10000, 10000, 0] type:#float
		checkbox use_node_transform "use node transform" checked:False
		pickbutton gizmo_node "gizmo node" autodisplay:true type:#node toolTip:"gizmo node"
		label gizmo_translation_Label "gizmo translation" align:#left
		spinner gizmo_translation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner gizmo_translation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner gizmo_translation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on gizmo_translation_XSpinner changed val do gizmo_translation.X = val
		on gizmo_translation_YSpinner changed val do gizmo_translation.Y = val
		on gizmo_translation_ZSpinner changed val do gizmo_translation.Z = val

		label gizmo_rotation_Label "gizmo rotation" align:#left
		spinner gizmo_rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner gizmo_rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner gizmo_rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on gizmo_rotation_XSpinner changed val do gizmo_rotation.X = val
		on gizmo_rotation_YSpinner changed val do gizmo_rotation.Y = val
		on gizmo_rotation_ZSpinner changed val do gizmo_rotation.Z = val

		label gizmo_scale_Label "gizmo scale" align:#left
		spinner gizmo_scale_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner gizmo_scale_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner gizmo_scale_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on gizmo_scale_XSpinner changed val do gizmo_scale.X = val
		on gizmo_scale_YSpinner changed val do gizmo_scale.Y = val
		on gizmo_scale_ZSpinner changed val do gizmo_scale.Z = val

		on params open do
		(
			paramsOpen = true








			gizmo_translation_XSpinner.value = gizmo_translation.X
			gizmo_translation_YSpinner.value = gizmo_translation.Y
			gizmo_translation_ZSpinner.value = gizmo_translation.Z

			gizmo_rotation_XSpinner.value = gizmo_rotation.X
			gizmo_rotation_YSpinner.value = gizmo_rotation.Y
			gizmo_rotation_ZSpinner.value = gizmo_rotation.Z

			gizmo_scale_XSpinner.value = gizmo_scale.X
			gizmo_scale_YSpinner.value = gizmo_scale.Y
			gizmo_scale_ZSpinner.value = gizmo_scale.Z

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
		local args = dotnet_ValueToDotNetObject #(meshWrapper, limit, boundingBoxWrapper, lower_limit, upper_limit, axis, angle, direction, use_node_transform, gizmo_nodeWrapper, modifierTransformWrapper, gizmo_translationWrapper, gizmo_rotationWrapper, gizmo_scaleWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		gizmo_nodeWrapper_SetValue gizmo_node
		gizmo_translationWrapper_SetValue gizmo_translation
		if (paramsOpen) then (
		 	params.gizmo_translation_XSpinner.value = gizmo_translation.X
		 	params.gizmo_translation_YSpinner.value = gizmo_translation.Y
		 	params.gizmo_translation_ZSpinner.value = gizmo_translation.Z
		)
		gizmo_rotationWrapper_SetValue gizmo_rotation
		if (paramsOpen) then (
		 	params.gizmo_rotation_XSpinner.value = gizmo_rotation.X
		 	params.gizmo_rotation_YSpinner.value = gizmo_rotation.Y
		 	params.gizmo_rotation_ZSpinner.value = gizmo_rotation.Z
		)
		gizmo_scaleWrapper_SetValue gizmo_scale
		if (paramsOpen) then (
		 	params.gizmo_scale_XSpinner.value = gizmo_scale.X
		 	params.gizmo_scale_YSpinner.value = gizmo_scale.Y
		 	params.gizmo_scale_ZSpinner.value = gizmo_scale.Z
		)
		meshWrapper_SetValue mesh
		boundingBoxWrapper_SetValue boundingBox
		modifierTransformWrapper_SetValue owningNode.Transform

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
