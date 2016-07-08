plugin simpleSpline MCG_MeshPlotter
	name:"MCG_MeshPlotter"
	classID:#(0x500216C2, 0x22457942)
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
	local nodeWrapper, nodeWrapper_SetValue
	local shapeTransformWrapper, shapeTransformWrapper_SetValue


    parameters main rollout:params
	(
		node ui:node type:#node useNodeOsValidity:true useNodeTmValidity:true
		maxSegments ui:maxSegments default:50 type:#integer animatable:true
		_dummy type:#boolean -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)

	parameters simParams rollout:simRollout
	(
		StepsPerFrame default:1.0 type:#float animatable:false
	)

	-- If we are running a simulation, this force the updateFxn to be called at regular time intervals
	-- which forces the internal caches to be updated.
	fn RunSimLoop updateFxn = ( 
		local result = ok

		-- If we are not running a simulation, simply call the updateFxn and return the result  
		if interactiveMode then
		(
			--interact with the sim, step one frame forward
			_lastTime += 1.0
			try (
				at time _lastTime (
					result = updateFxn()
				)
			)
			catch()
			return result
		)

		currentFrameTime = (currentTime as float)/TicksPerFrame
		-- We are in simulation mode. 		
		-- If we are at the currentTime just return the updateFxn 
		if (_lastTime == currentFrameTime) then (
			try ( result = updateFxn() )
			catch()
			return result
		)
		-- If we move backwards in time, we reset the simulation
		if ( _lastTime > (ceil currentFrameTime)) then
		(
			_lastTime = (animationRange.start as float)/TicksPerFrame
			pluginInstance.ClearPluginCaches() --clear the cahce, reinitializing the sim
			-- There is a special case that we moved to the begin of the simulation
			-- In this case we have to call the updateFxn once 
			if (_lastTime == currentFrameTime) then (
				try ( result = updateFxn() )
				catch()
				return result
			)
		)
		-- We are moving forwards in time, step forward rounding up to the
		-- nearest subframe step
		lastFrame = floor (currentFrameTime)
		diff = currentFrameTime - lastFrame
		stepSize = (1.0/StepsPerFrame)
		-- the last hard frame + the number of steps to take * step size
		stepToFrame = lastFrame + ((ceil (diff / stepSize)) * stepSize)
		stepped = false
		try
		(
			if _lastTime == ((animationRange.start as float)/TicksPerFrame) then
			( --evaluate at the beginning
				at time _lastTime (
					result = updateFxn ()
				)
			)
			while _lastTime < stepToFrame do 
			(
				stepped = true
				_lastTime += (1.0/StepsPerFrame) --step one forward at our rate
				at time _lastTime (
					result = updateFxn ()
				)
			)
			if not stepped then
			(	--we did not step a frame, return our current result
				at time _lastTime (
					result = updateFxn ()
				)
			)
		)
		catch()
		_lastTime = stepToFrame
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\MCG_MeshPlotter.maxtool"
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
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CheckNodeValidity.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeMeshInLocalSpace-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\NodeMeshInLocalSpace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\NodeMeshInWorldSpace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MeshInLocalSpace.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeCanGetMesh-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshBoundingBox-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoundingBoxCenter.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractCurrentValueFromCache.maxcompound")

		-- value wrapper local initializations
		local nodeWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		nodeWrapper = nodeWrapperClass._CreateWrapper (undefined)
		nodeWrapper_SetValue = nodeWrapper._SetValue
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
		pickbutton node "node" autodisplay:true type:#node toolTip:"node"
		spinner maxSegments "maxSegments" range:[2, 100, 50] type:#integer

	)

	rollout simRollout "Simulation"
	(
		button resetSimulation mcgOps.ReinitSimButtonText
		on resetSimulation pressed do
		(
			--clear the caches related to this graph
			pluginInstance.ClearPluginCaches()
			_lastTime = 0.0
			_dummy = not _dummy
		)
	)


	fn transformGetter = 
	(
		if(isValidNode(owningNode)) then owningNode.Transform else matrix3 1
	)

	fn updateShape = 
	(
        if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(nodeWrapper, shapeTransformWrapper, maxSegments) argsType
		pluginInstance_UpdateShape (currentTime as integer) _shapeWrapper args
		ok
	)

	on buildShape do
	(
		nodeWrapper_SetValue node
		shapeTransformWrapper_SetValue (transformGetter())

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
        _shapeWrapper_SetValue BezierShape
		RunSimLoop updateShape
		_shapeWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
