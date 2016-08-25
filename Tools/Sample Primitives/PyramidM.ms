plugin simpleObject PyramidM
	name:"PyramidM"
	classID:#(0x3127EF4D, 0x48DC86C9)
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
		circleOrPolygon ui:circleOrPolygon default:False type:#boolean animatable:true
		points ui:points default:4 type:#integer animatable:true
		base ui:base default:10 type:#float animatable:true
		height ui:height default:10 type:#float animatable:true
		bipyramid ui:bipyramid default:False type:#boolean animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Primitives\PyramidM.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Pyramid-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AverageVector.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Sum.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\OffsetZ.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BiFan-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshTriFanIndices-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Circle-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PointsAroundAxis-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PointsInArc-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RotatePoint.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RangeInclusiveFloatTo.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RangeExclusiveFloatTo.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PointsPolygon-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RotatePoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorsScale-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound")

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
		checkbox circleOrPolygon "circleOrPolygon" checked:False
		spinner points "points" range:[3, 100, 4] type:#integer
		spinner base "base" range:[-1000000, 1000000, 10] type:#float
		spinner height "height" range:[-1000000, 1000000, 10] type:#float
		checkbox bipyramid "bipyramid" checked:False

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(circleOrPolygon, points, base, height, bipyramid) argsType
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
