plugin simpleMeshMod Stretch_MCG
	name:"Stretch_MCG"
	classID:#(0x1387DCB9, 0x6FA00042)
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
	local gizmo_nodeWrapper, gizmo_nodeWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue
	local deformer_translationWrapper, deformer_translationWrapper_SetValue
	local deformer_rotationWrapper, deformer_rotationWrapper_SetValue
	local deformer_scaleWrapper, deformer_scaleWrapper_SetValue


	parameters main rollout:params
	(
		axis ui:axis default:2 type:#integer animatable:true
		amount ui:amount default:0 type:#float animatable:true
		amplify ui:amplify default:0 type:#float animatable:true
		use_node_transform ui:use_node_transform default:False type:#boolean animatable:true
		gizmo_node ui:gizmo_node type:#node useNodeOsValidity:true useNodeTmValidity:true
		deformer_translation type:#point3 default:[0,0,0]
		on deformer_translation set val do 
		( 
			if paramsOpen then (
				this.params.deformer_translation_XSpinner.value = val.X
				this.params.deformer_translation_YSpinner.value = val.Y
				this.params.deformer_translation_ZSpinner.value = val.Z 
			)
		)
		deformer_rotation type:#point3 default:[0,0,0]
		on deformer_rotation set val do 
		( 
			if paramsOpen then (
				this.params.deformer_rotation_XSpinner.value = val.X
				this.params.deformer_rotation_YSpinner.value = val.Y
				this.params.deformer_rotation_ZSpinner.value = val.Z 
			)
		)
		deformer_scale type:#point3 default:[0,0,0]
		on deformer_scale set val do 
		( 
			if paramsOpen then (
				this.params.deformer_scale_XSpinner.value = val.X
				this.params.deformer_scale_YSpinner.value = val.Y
				this.params.deformer_scale_ZSpinner.value = val.Z 
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Deformers\Stretch MCG.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\GizmoTransformInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixParameterWorldToLocalTransform-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeToLocalTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeValidateAndGetWorldTransform-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromPositionRotationScale-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromScalingVector2-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Multiply3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToQuaternion-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuaternionFromVector3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToRadians-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorMapComponents-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorFromArray-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\OnesVector-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Stretch-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MeshBoundingBox.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\StretchDeformer-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorComponent-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshDeformVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshSetVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LerpVectors-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasSoftSelection.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasPerVertexChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SoftSelection.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local gizmo_nodeWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		gizmo_nodeWrapper = gizmo_nodeWrapperClass._CreateWrapper (undefined)
		gizmo_nodeWrapper_SetValue = gizmo_nodeWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue
		local deformer_translationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		deformer_translationWrapper = deformer_translationWrapperClass._CreateWrapper ([0,0,0])
		deformer_translationWrapper_SetValue = deformer_translationWrapper._SetValue
		local deformer_rotationWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		deformer_rotationWrapper = deformer_rotationWrapperClass._CreateWrapper ([0,0,0])
		deformer_rotationWrapper_SetValue = deformer_rotationWrapper._SetValue
		local deformer_scaleWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		deformer_scaleWrapper = deformer_scaleWrapperClass._CreateWrapper ([0,0,0])
		deformer_scaleWrapper_SetValue = deformer_scaleWrapper._SetValue

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
		spinner axis "axis" range:[0, 2, 2] type:#integer
		spinner amount "amount" range:[-10000, 10000, 0] type:#float
		spinner amplify "amplify" range:[-10000, 10000, 0] type:#float
		checkbox use_node_transform "use node transform" checked:False
		pickbutton gizmo_node "gizmo node" autodisplay:true type:#node toolTip:"gizmo node"
		label deformer_translation_Label "deformer translation" align:#left
		spinner deformer_translation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner deformer_translation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner deformer_translation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on deformer_translation_XSpinner changed val do deformer_translation.X = val
		on deformer_translation_YSpinner changed val do deformer_translation.Y = val
		on deformer_translation_ZSpinner changed val do deformer_translation.Z = val

		label deformer_rotation_Label "deformer rotation" align:#left
		spinner deformer_rotation_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner deformer_rotation_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner deformer_rotation_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on deformer_rotation_XSpinner changed val do deformer_rotation.X = val
		on deformer_rotation_YSpinner changed val do deformer_rotation.Y = val
		on deformer_rotation_ZSpinner changed val do deformer_rotation.Z = val

		label deformer_scale_Label "deformer scale" align:#left
		spinner deformer_scale_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner deformer_scale_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner deformer_scale_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on deformer_scale_XSpinner changed val do deformer_scale.X = val
		on deformer_scale_YSpinner changed val do deformer_scale.Y = val
		on deformer_scale_ZSpinner changed val do deformer_scale.Z = val

		on params open do
		(
			paramsOpen = true





			deformer_translation_XSpinner.value = deformer_translation.X
			deformer_translation_YSpinner.value = deformer_translation.Y
			deformer_translation_ZSpinner.value = deformer_translation.Z

			deformer_rotation_XSpinner.value = deformer_rotation.X
			deformer_rotation_YSpinner.value = deformer_rotation.Y
			deformer_rotation_ZSpinner.value = deformer_rotation.Z

			deformer_scale_XSpinner.value = deformer_scale.X
			deformer_scale_YSpinner.value = deformer_scale.Y
			deformer_scale_ZSpinner.value = deformer_scale.Z

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
		local args = dotnet_ValueToDotNetObject #(meshWrapper, axis, amount, amplify, use_node_transform, gizmo_nodeWrapper, modifierTransformWrapper, deformer_translationWrapper, deformer_rotationWrapper, deformer_scaleWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		gizmo_nodeWrapper_SetValue gizmo_node
		deformer_translationWrapper_SetValue deformer_translation
		if (paramsOpen) then (
		 	params.deformer_translation_XSpinner.value = deformer_translation.X
		 	params.deformer_translation_YSpinner.value = deformer_translation.Y
		 	params.deformer_translation_ZSpinner.value = deformer_translation.Z
		)
		deformer_rotationWrapper_SetValue deformer_rotation
		if (paramsOpen) then (
		 	params.deformer_rotation_XSpinner.value = deformer_rotation.X
		 	params.deformer_rotation_YSpinner.value = deformer_rotation.Y
		 	params.deformer_rotation_ZSpinner.value = deformer_rotation.Z
		)
		deformer_scaleWrapper_SetValue deformer_scale
		if (paramsOpen) then (
		 	params.deformer_scale_XSpinner.value = deformer_scale.X
		 	params.deformer_scale_YSpinner.value = deformer_scale.Y
		 	params.deformer_scale_ZSpinner.value = deformer_scale.Z
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
