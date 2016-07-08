plugin simpleMeshMod TerrainColor
	name:"TerrainColor"
	classID:#(0x686DB440, 0x5D353B9C)
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
	local water_colorWrapper, water_colorWrapper_SetValue
	local snow_colorWrapper, snow_colorWrapper_SetValue
	local default_colorWrapper, default_colorWrapper_SetValue


	parameters main rollout:params
	(
		channel ui:channel default:0 type:#integer animatable:true
		sealevel ui:sealevel default:0 type:#float animatable:true
		water_color ui:water_color_ColorPicker type:#color default:(color 0 0 178)
		snowline ui:snowline default:20 type:#float animatable:true
		snow_color ui:snow_color_ColorPicker type:#color default:(color 255 255 255)
		default_color ui:default_color_ColorPicker type:#color default:(color 76 76 76)
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\TerrainColor.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshFaceVertex-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArrayIndirectLookup-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometrySet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelFromFace-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelFromFaceVertex-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometrySet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapIndices-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByThree.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local water_colorWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		water_colorWrapper = water_colorWrapperClass._CreateWrapper ([0,0,0])
		water_colorWrapper_SetValue = water_colorWrapper._SetValue
		local snow_colorWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		snow_colorWrapper = snow_colorWrapperClass._CreateWrapper ([0,0,0])
		snow_colorWrapper_SetValue = snow_colorWrapper._SetValue
		local default_colorWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		default_colorWrapper = default_colorWrapperClass._CreateWrapper ([0,0,0])
		default_colorWrapper_SetValue = default_colorWrapper._SetValue

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
		spinner channel "channel" range:[-3, 100, 0] type:#integer
		spinner sealevel "sealevel" range:[-10000, 100000, 0] type:#float
		colorpicker water_color_ColorPicker "water color" color:(color 0 0 0) modal:false align:#center

		spinner snowline "snowline" range:[-10000, 100000, 20] type:#float
		colorpicker snow_color_ColorPicker "snow color" color:(color 0 0 0) modal:false align:#center

		colorpicker default_color_ColorPicker "default color" color:(color 0 0 0) modal:false align:#center


	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(channel, meshWrapper, sealevel, water_colorWrapper, snowline, snow_colorWrapper, default_colorWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		water_colorWrapper_SetValue [water_color.r/255.0,water_color.g/255.0,water_color.b/255.0]
		snow_colorWrapper_SetValue [snow_color.r/255.0,snow_color.g/255.0,snow_color.b/255.0]
		default_colorWrapper_SetValue [default_color.r/255.0,default_color.g/255.0,default_color.b/255.0]
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
