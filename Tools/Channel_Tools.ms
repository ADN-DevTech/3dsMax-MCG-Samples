plugin simpleMeshMod Channel_Tools
	name:"Channel_Tools"
	classID:#(0x7D2CCE65, 0x370A7B93)
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
	local pre_multiplyWrapper, pre_multiplyWrapper_SetValue
	local offsetWrapper, offsetWrapper_SetValue
	local multiplyWrapper, multiplyWrapper_SetValue
	local lower_limitWrapper, lower_limitWrapper_SetValue
	local upper_limitWrapper, upper_limitWrapper_SetValue


	parameters main rollout:params
	(
		channel_ID ui:channel_ID default:0 type:#integer animatable:true
		clamp ui:clamp default:False type:#boolean animatable:true
		pre_multiply type:#point3 default:[1,1,1]
		on pre_multiply set val do 
		( 
			if paramsOpen then (
				this.params.pre_multiply_XSpinner.value = val.X
				this.params.pre_multiply_YSpinner.value = val.Y
				this.params.pre_multiply_ZSpinner.value = val.Z 
			)
		)
		offset type:#point3 default:[0,0,0]
		on offset set val do 
		( 
			if paramsOpen then (
				this.params.offset_XSpinner.value = val.X
				this.params.offset_YSpinner.value = val.Y
				this.params.offset_ZSpinner.value = val.Z 
			)
		)
		multiply type:#point3 default:[1,1,1]
		on multiply set val do 
		( 
			if paramsOpen then (
				this.params.multiply_XSpinner.value = val.X
				this.params.multiply_YSpinner.value = val.Y
				this.params.multiply_ZSpinner.value = val.Z 
			)
		)
		lower_limit type:#point3 default:[0,0,0]
		on lower_limit set val do 
		( 
			if paramsOpen then (
				this.params.lower_limit_XSpinner.value = val.X
				this.params.lower_limit_YSpinner.value = val.Y
				this.params.lower_limit_ZSpinner.value = val.Z 
			)
		)
		upper_limit type:#point3 default:[1,1,1]
		on upper_limit set val do 
		( 
			if paramsOpen then (
				this.params.upper_limit_XSpinner.value = val.X
				this.params.upper_limit_YSpinner.value = val.Y
				this.params.upper_limit_ZSpinner.value = val.Z 
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Channel_Tools.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelTransform-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrCreate-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelExists-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\IsNullFix2-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometryGet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelClear-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MultiplyByThree.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometrySet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometrySet-ext.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local pre_multiplyWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		pre_multiplyWrapper = pre_multiplyWrapperClass._CreateWrapper ([0,0,0])
		pre_multiplyWrapper_SetValue = pre_multiplyWrapper._SetValue
		local offsetWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		offsetWrapper = offsetWrapperClass._CreateWrapper ([0,0,0])
		offsetWrapper_SetValue = offsetWrapper._SetValue
		local multiplyWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		multiplyWrapper = multiplyWrapperClass._CreateWrapper ([0,0,0])
		multiplyWrapper_SetValue = multiplyWrapper._SetValue
		local lower_limitWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		lower_limitWrapper = lower_limitWrapperClass._CreateWrapper ([0,0,0])
		lower_limitWrapper_SetValue = lower_limitWrapper._SetValue
		local upper_limitWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		upper_limitWrapper = upper_limitWrapperClass._CreateWrapper ([0,0,0])
		upper_limitWrapper_SetValue = upper_limitWrapper._SetValue

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
		spinner channel_ID "channel ID" range:[-3, 100, 0] type:#integer
		checkbox clamp "clamp" checked:False
		label pre_multiply_Label "pre multiply" align:#left
		spinner pre_multiply_XSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left across:3
		spinner pre_multiply_YSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		spinner pre_multiply_ZSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		on pre_multiply_XSpinner changed val do pre_multiply.X = val
		on pre_multiply_YSpinner changed val do pre_multiply.Y = val
		on pre_multiply_ZSpinner changed val do pre_multiply.Z = val

		label offset_Label "offset" align:#left
		spinner offset_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner offset_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner offset_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on offset_XSpinner changed val do offset.X = val
		on offset_YSpinner changed val do offset.Y = val
		on offset_ZSpinner changed val do offset.Z = val

		label multiply_Label "multiply" align:#left
		spinner multiply_XSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left across:3
		spinner multiply_YSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		spinner multiply_ZSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		on multiply_XSpinner changed val do multiply.X = val
		on multiply_YSpinner changed val do multiply.Y = val
		on multiply_ZSpinner changed val do multiply.Z = val

		label lower_limit_Label "lower limit" align:#left
		spinner lower_limit_XSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left across:3
		spinner lower_limit_YSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		spinner lower_limit_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on lower_limit_XSpinner changed val do lower_limit.X = val
		on lower_limit_YSpinner changed val do lower_limit.Y = val
		on lower_limit_ZSpinner changed val do lower_limit.Z = val

		label upper_limit_Label "upper limit" align:#left
		spinner upper_limit_XSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left across:3
		spinner upper_limit_YSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		spinner upper_limit_ZSpinner range:[-1000000, 1000000, 1] width:48 height:16 align:#left
		on upper_limit_XSpinner changed val do upper_limit.X = val
		on upper_limit_YSpinner changed val do upper_limit.Y = val
		on upper_limit_ZSpinner changed val do upper_limit.Z = val

		on params open do
		(
			paramsOpen = true


			pre_multiply_XSpinner.value = pre_multiply.X
			pre_multiply_YSpinner.value = pre_multiply.Y
			pre_multiply_ZSpinner.value = pre_multiply.Z

			offset_XSpinner.value = offset.X
			offset_YSpinner.value = offset.Y
			offset_ZSpinner.value = offset.Z

			multiply_XSpinner.value = multiply.X
			multiply_YSpinner.value = multiply.Y
			multiply_ZSpinner.value = multiply.Z

			lower_limit_XSpinner.value = lower_limit.X
			lower_limit_YSpinner.value = lower_limit.Y
			lower_limit_ZSpinner.value = lower_limit.Z

			upper_limit_XSpinner.value = upper_limit.X
			upper_limit_YSpinner.value = upper_limit.Y
			upper_limit_ZSpinner.value = upper_limit.Z

		)
		on params close do
		(

			paramsOpen = false
		)
	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(channel_ID, meshWrapper, clamp, pre_multiplyWrapper, offsetWrapper, multiplyWrapper, lower_limitWrapper, upper_limitWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		pre_multiplyWrapper_SetValue pre_multiply
		if (paramsOpen) then (
		 	params.pre_multiply_XSpinner.value = pre_multiply.X
		 	params.pre_multiply_YSpinner.value = pre_multiply.Y
		 	params.pre_multiply_ZSpinner.value = pre_multiply.Z
		)
		offsetWrapper_SetValue offset
		if (paramsOpen) then (
		 	params.offset_XSpinner.value = offset.X
		 	params.offset_YSpinner.value = offset.Y
		 	params.offset_ZSpinner.value = offset.Z
		)
		multiplyWrapper_SetValue multiply
		if (paramsOpen) then (
		 	params.multiply_XSpinner.value = multiply.X
		 	params.multiply_YSpinner.value = multiply.Y
		 	params.multiply_ZSpinner.value = multiply.Z
		)
		lower_limitWrapper_SetValue lower_limit
		if (paramsOpen) then (
		 	params.lower_limit_XSpinner.value = lower_limit.X
		 	params.lower_limit_YSpinner.value = lower_limit.Y
		 	params.lower_limit_ZSpinner.value = lower_limit.Z
		)
		upper_limitWrapper_SetValue upper_limit
		if (paramsOpen) then (
		 	params.upper_limit_XSpinner.value = upper_limit.X
		 	params.upper_limit_YSpinner.value = upper_limit.Y
		 	params.upper_limit_ZSpinner.value = upper_limit.Z
		)
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
