plugin simpleSpline AU_SplineCycles
	name:"AU_SplineCycles"
	classID:#(0x1C73D9FD, 0x70CCF912)
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
	local splineWrapper, splineWrapper_SetValue


    parameters main rollout:params
	(
		name ui:name default:0.05 type:#worldUnits animatable:true
		spline ui:spline type:#node useNodeOsValidity:true useNodeTmValidity:true
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
		pluginDefinitionFile = @"C:/Users/digginc/Autodesk/3ds Max 2016/Max Creation Graph/Tools/AU/AU_SplineCycles.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\SplineCycles.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\CreateSpline.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CombineEveryTwoElements.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\GraphContours.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\SplineWeld.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\TriMeshToSpline.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DivideByTwo.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SplineToTriMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SplineSegmentKnots.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SplineSegmentKnotA.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SplineSegmentKnotB.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\First.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Second.maxcompound")

		-- value wrapper local initializations
		local splineWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		splineWrapper = splineWrapperClass._CreateWrapper (undefined)
		splineWrapper_SetValue = splineWrapper._SetValue

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
		spinner name "name" range:[0, 100, 0.05] type:#worldUnits
		pickbutton spline "spline" autodisplay:true type:#node toolTip:"spline"

	)





	fn updateShape = 
	(
        if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(name, splineWrapper) argsType
		pluginInstance_UpdateShape (currentTime as integer) _shapeWrapper args
		ok
	)

	on buildShape do
	(
		splineWrapper_SetValue spline

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
        _shapeWrapper_SetValue BezierShape
		RunSimLoop updateShape
		_shapeWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
