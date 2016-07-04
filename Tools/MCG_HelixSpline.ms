plugin simpleSpline MCG_HelixSpline
	name:"MCG_HelixSpline"
	classID:#(0x6B3A1788, 0x406C54E5)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _shapeWrapper -- the dotnet wrapper around our shape pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	local owningNode
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _shapeWrapper_SetValue
	local pluginInstance_UpdateShape

	-- value wrapper local and function wrapper declarations


    parameters main rollout:params
	(
		numSegments ui:numSegments default:100 type:#integer animatable:true
		angle ui:angle default:1080 type:#float animatable:true
		radius ui:radius default:10 type:#float animatable:true
		height ui:height default:30 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\MCG_HelixSpline.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.ShapePluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		local _pluginOwner = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile _pluginOwner
		pluginInstance_UpdateShape = pluginInstance.UpdateShape
		local shapeWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.BezierShape"
		_shapeWrapper = shapeWrapperClass._CreateWrapper undefined
		_shapeWrapper_SetValue = _shapeWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #()

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
		spinner numSegments "numSegments" range:[3, 1000, 100] type:#integer
		spinner angle "angle" range:[-100000, 100000, 1080] type:#float
		spinner radius "radius" range:[0, 100000, 10] type:#float
		spinner height "height" range:[0, 100000, 30] type:#float

	)





	fn updateShape = 
	(
        if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(numSegments, angle, radius, height) argsType
		pluginInstance_UpdateShape (currentTime as integer) _shapeWrapper args
		ok
	)

	on buildShape do
	(

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
        _shapeWrapper_SetValue BezierShape
		RunSimLoop updateShape
		_shapeWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
