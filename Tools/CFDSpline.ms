plugin simpleSpline CFDSpline
	name:"CFDSpline"
	classID:#(0x61BA0182, 0x36D9EC97)
	category:"CFD"
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
	local CFD_PointsWrapper, CFD_PointsWrapper_SetValue
	local shapeTransformWrapper, shapeTransformWrapper_SetValue


    parameters main rollout:params
	(
		CFD_Points ui:CFD_Points type:#node useNodeOsValidity:true useNodeTmValidity:true
		Spline_Vertices ui:Spline_Vertices default:20 type:#integer animatable:true
		Refresh_Data_Signal ui:Refresh_Data default:false type:#boolean animatable:false
		update_cache_Signal ui:update_cache default:false type:#boolean animatable:false
		Field_Interpolation ui:Field_Interpolation default:8 type:#integer animatable:true
		Smoothing ui:Smoothing default:1 type:#float animatable:true
		Field_Sampling ui:Field_Sampling default:2 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\CFDSpline.maxtool"
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
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CheckNodeValidity.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\NodeMeshInWorldSpace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GenerateSplineFromVelocity.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\InterpMeshVerticesVelocityWeighted.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GetVelocity.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GetPVData.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Sum.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CacheOctreeMod.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CacheValueUntilControlChanged.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractCurrentValueFromCache.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoolToINT.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GetMeshVerticesWeights.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CacheValueUntilControlChanged.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractCurrentValueFromCache.maxcompound")

		-- value wrapper local initializations
		local CFD_PointsWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		CFD_PointsWrapper = CFD_PointsWrapperClass._CreateWrapper (undefined)
		CFD_PointsWrapper_SetValue = CFD_PointsWrapper._SetValue
		local shapeTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		shapeTransformWrapper = shapeTransformWrapperClass._CreateWrapper (matrix3 1)
		shapeTransformWrapper_SetValue = shapeTransformWrapper._SetValue

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

	fn installTMHandler theNode =
	(
		owningNode = theNode
		if (tmHandler == undefined and owningNode != undefined) then ( tmHandler = when transform owningNode changes do ( _dummy = not _dummy ))
	)

	on postload do
	(
		installTMHandler(refs.dependentnodes this firstonly:true)
	)

	on attachedToNode theNode do
	(
		installTMHandler(theNode)
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
		pickbutton CFD_Points "CFD Points" autodisplay:true type:#node toolTip:"CFD Points"
		spinner Spline_Vertices "Spline Vertices" range:[3, 9999999, 20] type:#integer
		button Refresh_Data "Refresh Data"
		on Refresh_Data pressed do Refresh_Data_Signal = true
		button update_cache "update cache"
		on update_cache pressed do update_cache_Signal = true
		spinner Field_Interpolation "Field Interpolation" range:[1, 9999999, 8] type:#integer
		spinner Smoothing "Smoothing" range:[0, 2, 1] type:#float
		spinner Field_Sampling "Field Sampling" range:[0.001, 1E+09, 2] type:#float

	)




	fn transformGetter = 
	(
		if(isValidNode(owningNode)) then owningNode.Transform else matrix3 1
	)

	fn updateShape = 
	(
        if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(CFD_PointsWrapper, shapeTransformWrapper, Spline_Vertices, Refresh_Data_Signal, update_cache_Signal, Field_Interpolation, Smoothing, Field_Sampling) argsType
		pluginInstance_UpdateShape (currentTime as integer) _shapeWrapper args
		ok
	)

	on buildShape do
	(
		CFD_PointsWrapper_SetValue CFD_Points
		shapeTransformWrapper_SetValue (transformGetter())

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
        _shapeWrapper_SetValue BezierShape
		RunSimLoop updateShape
		_shapeWrapper_SetValue undefined
		if(Refresh_Data_Signal) do (Refresh_Data_Signal = false)		if(update_cache_Signal) do (update_cache_Signal = false)
		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
