plugin simpleObject Transform_Demo
	name:"Transform_Demo"
	classID:#(0x2B51E69, 0x4B16FFB2)
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
	local paramsOpen = false
	local translation1Wrapper, translation1Wrapper_SetValue
	local rotation1Wrapper, rotation1Wrapper_SetValue
	local translation2Wrapper, translation2Wrapper_SetValue
	local rotation2Wrapper, rotation2Wrapper_SetValue


	parameters main rollout:params
	(
		radius ui:radius default:10 type:#float animatable:true
		translation1 type:#point3 default:[0,0,0]
		on translation1 set val do 
		( 
			if paramsOpen then (
				this.params.translation1_XSpinner.value = val.X
				this.params.translation1_YSpinner.value = val.Y
				this.params.translation1_ZSpinner.value = val.Z 
			)
		)
		rotation1 type:#point3 default:[0,0,0]
		on rotation1 set val do 
		( 
			if paramsOpen then (
				this.params.rotation1_XSpinner.value = val.X
				this.params.rotation1_YSpinner.value = val.Y
				this.params.rotation1_ZSpinner.value = val.Z 
			)
		)
		scale1 ui:scale1 default:1 type:#float animatable:true
		relative ui:relative default:True type:#boolean animatable:true
		translation2 type:#point3 default:[0,0,0]
		on translation2 set val do 
		( 
			if paramsOpen then (
				this.params.translation2_XSpinner.value = val.X
				this.params.translation2_YSpinner.value = val.Y
				this.params.translation2_ZSpinner.value = val.Z 
			)
		)
		rotation2 type:#point3 default:[0,0,0]
		on rotation2 set val do 
		( 
			if paramsOpen then (
				this.params.rotation2_XSpinner.value = val.X
				this.params.rotation2_YSpinner.value = val.Y
				this.params.rotation2_ZSpinner.value = val.Z 
			)
		)
		scale2 ui:scale2 default:1 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Transform Demo.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CubeMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadToTriMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToQuaternion-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuaternionFromVector3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\EulerDegreesToRadians-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorMapComponents-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArrayToVector-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PositionRotationScaleMatrix-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ScalingMatrix-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Multiply3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixApplyTransform-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ScalarToVector-ext.maxcompound")

		-- value wrapper local initializations
		local translation1WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		translation1Wrapper = translation1WrapperClass._CreateWrapper ([0,0,0])
		translation1Wrapper_SetValue = translation1Wrapper._SetValue
		local rotation1WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		rotation1Wrapper = rotation1WrapperClass._CreateWrapper ([0,0,0])
		rotation1Wrapper_SetValue = rotation1Wrapper._SetValue
		local translation2WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		translation2Wrapper = translation2WrapperClass._CreateWrapper ([0,0,0])
		translation2Wrapper_SetValue = translation2Wrapper._SetValue
		local rotation2WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		rotation2Wrapper = rotation2WrapperClass._CreateWrapper ([0,0,0])
		rotation2Wrapper_SetValue = rotation2Wrapper._SetValue

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
		spinner radius "radius" range:[0, 1000000, 10] type:#float
		label translation1_Label "translation1" align:#left
		spinner translation1_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner translation1_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner translation1_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on translation1_XSpinner changed val do translation1.X = val
		on translation1_YSpinner changed val do translation1.Y = val
		on translation1_ZSpinner changed val do translation1.Z = val

		label rotation1_Label "rotation1" align:#left
		spinner rotation1_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner rotation1_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner rotation1_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on rotation1_XSpinner changed val do rotation1.X = val
		on rotation1_YSpinner changed val do rotation1.Y = val
		on rotation1_ZSpinner changed val do rotation1.Z = val

		spinner scale1 "scale1" range:[0, 100, 1] type:#float
		checkbox relative "relative" checked:True
		label translation2_Label "translation2" align:#left
		spinner translation2_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner translation2_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner translation2_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on translation2_XSpinner changed val do translation2.X = val
		on translation2_YSpinner changed val do translation2.Y = val
		on translation2_ZSpinner changed val do translation2.Z = val

		label rotation2_Label "rotation2" align:#left
		spinner rotation2_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner rotation2_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner rotation2_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on rotation2_XSpinner changed val do rotation2.X = val
		on rotation2_YSpinner changed val do rotation2.Y = val
		on rotation2_ZSpinner changed val do rotation2.Z = val

		spinner scale2 "scale2" range:[0, 100, 1] type:#float
		on params open do
		(
			paramsOpen = true

			translation1_XSpinner.value = translation1.X
			translation1_YSpinner.value = translation1.Y
			translation1_ZSpinner.value = translation1.Z

			rotation1_XSpinner.value = rotation1.X
			rotation1_YSpinner.value = rotation1.Y
			rotation1_ZSpinner.value = rotation1.Z



			translation2_XSpinner.value = translation2.X
			translation2_YSpinner.value = translation2.Y
			translation2_ZSpinner.value = translation2.Z

			rotation2_XSpinner.value = rotation2.X
			rotation2_YSpinner.value = rotation2.Y
			rotation2_ZSpinner.value = rotation2.Z


		)
		on params close do
		(

			paramsOpen = false
		)
	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(radius, translation1Wrapper, rotation1Wrapper, scale1, relative, translation2Wrapper, rotation2Wrapper, scale2) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(
		translation1Wrapper_SetValue translation1
		if (paramsOpen) then (
		 	params.translation1_XSpinner.value = translation1.X
		 	params.translation1_YSpinner.value = translation1.Y
		 	params.translation1_ZSpinner.value = translation1.Z
		)
		rotation1Wrapper_SetValue rotation1
		if (paramsOpen) then (
		 	params.rotation1_XSpinner.value = rotation1.X
		 	params.rotation1_YSpinner.value = rotation1.Y
		 	params.rotation1_ZSpinner.value = rotation1.Z
		)
		translation2Wrapper_SetValue translation2
		if (paramsOpen) then (
		 	params.translation2_XSpinner.value = translation2.X
		 	params.translation2_YSpinner.value = translation2.Y
		 	params.translation2_ZSpinner.value = translation2.Z
		)
		rotation2Wrapper_SetValue rotation2
		if (paramsOpen) then (
		 	params.rotation2_XSpinner.value = rotation2.X
		 	params.rotation2_YSpinner.value = rotation2.Y
		 	params.rotation2_ZSpinner.value = rotation2.Z
		)

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
