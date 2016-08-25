plugin simpleObject TorusM
	name:"TorusM"
	classID:#(0x732BED86, 0x134F3C26)
	category:"MCG Sample Primitives"
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


	parameters main rollout:params
	(
		_segments ui:_segments default:16 type:#integer animatable:true
		sides ui:sides default:12 type:#integer animatable:true
		major_radius ui:major_radius default:10 type:#float animatable:true
		minor_radius ui:minor_radius default:2 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Primitives\TorusM.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Torus-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadMeshFromUVs-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadMeshFromUVPoints-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CartesianProduct.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RangeFloat-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PointOnTorus-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\FunctionSwapArgs-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadToTriMesh-ext.maxcompound")

		-- value wrapper local initializations

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
		spinner _segments " segments" range:[1, 1000, 16] type:#integer
		spinner sides "sides" range:[1, 10000, 12] type:#integer
		spinner major_radius "major radius" range:[-10000, 10000, 10] type:#float
		spinner minor_radius "minor radius" range:[-10000, 10000, 2] type:#float

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(_segments, sides, major_radius, minor_radius) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
