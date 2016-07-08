
plugin TransformController MCG_BulletController
	name:"MCG_BulletController"
	classID:#(0x4738561A, 0x217740B3)
	category:"Bullet Physics"
	usePBValidity:false
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local pluginInstance_GetValue
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- value wrapper local declarations
	local paramsOpen = false
	local Colliders_List = undefined
	local Colliders_selection = #()
	local Pick_Start_NodeWrapper, Pick_Start_NodeWrapper_SetValue
	local InertiaWrapper, InertiaWrapper_SetValue
	local Linear_VelocityWrapper, Linear_VelocityWrapper_SetValue
	local Angular_VelocityWrapper, Angular_VelocityWrapper_SetValue


	parameters pblock rollout:params
	(
		Colliders_Tab type:#nodeTab tabSizeVariable:true useNodeTmValidity:true useNodeOsValidity:true
		on Colliders_Tab tabChanged action index count do
		(
			mcgOps.INodeA_TabChanged action index count (this.params.Colliders_UI) Colliders_List Colliders_Tab paramsOpen
		)
		on Colliders_Tab set val index do
		(
			mcgOps.INodeA_TabSet val index (this.params.Colliders_UI) Colliders_List paramsOpen
		)
		Pick_Start_Node ui:Pick_Start_Node type:#node useNodeOsValidity:true useNodeTmValidity:true
		Mass ui:Mass default:1 type:#float animatable:true
		Friction ui:Friction default:1 type:#float animatable:true
		Rolling_Friction ui:Rolling_Friction default:1 type:#float animatable:true
		Restitution ui:Restitution default:1 type:#float animatable:true
		Linear_Damping ui:Linear_Damping default:0.1 type:#float animatable:true
		Angular_Damping ui:Angular_Damping default:0 type:#float animatable:true
		Inertia type:#point3 default:[0,0,0]
		on Inertia set val do 
		( 
			if paramsOpen then (
				this.params.Inertia_XSpinner.value = val.X
				this.params.Inertia_YSpinner.value = val.Y
				this.params.Inertia_ZSpinner.value = val.Z 
			)
		)
		Linear_Velocity type:#point3 default:[0,0,0]
		on Linear_Velocity set val do 
		( 
			if paramsOpen then (
				this.params.Linear_Velocity_XSpinner.value = val.X
				this.params.Linear_Velocity_YSpinner.value = val.Y
				this.params.Linear_Velocity_ZSpinner.value = val.Z 
			)
		)
		Angular_Velocity type:#point3 default:[0,0,0]
		on Angular_Velocity set val do 
		( 
			if paramsOpen then (
				this.params.Angular_Velocity_XSpinner.value = val.X
				this.params.Angular_Velocity_YSpinner.value = val.Y
				this.params.Angular_Velocity_ZSpinner.value = val.Z 
			)
		)
		Gravity ui:Gravity default:-50 type:#worldUnits animatable:true
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
		local result = Matrix3 1

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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\MCG_BulletController.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.TransformControllerPlugin"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_GetValue = pluginInstance.GetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MCG_CreateSimNode.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Vector3FromZ.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetZ.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MCG_CreateWorldController.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractCurrentValueFromCache.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MCG_UpdateCollisionNodes.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MCG_UpdateWorld.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MCG_CreateCollisionNodes.maxcompound")

		-- value wrapper local initializations
		mcgOps.INodeA_Initialization list:&Colliders_List
		local Pick_Start_NodeWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		Pick_Start_NodeWrapper = Pick_Start_NodeWrapperClass._CreateWrapper (undefined)
		Pick_Start_NodeWrapper_SetValue = Pick_Start_NodeWrapper._SetValue
		local InertiaWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		InertiaWrapper = InertiaWrapperClass._CreateWrapper ([0,0,0])
		InertiaWrapper_SetValue = InertiaWrapper._SetValue
		local Linear_VelocityWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		Linear_VelocityWrapper = Linear_VelocityWrapperClass._CreateWrapper ([0,0,0])
		Linear_VelocityWrapper_SetValue = Linear_VelocityWrapper._SetValue
		local Angular_VelocityWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		Angular_VelocityWrapper = Angular_VelocityWrapperClass._CreateWrapper ([0,0,0])
		Angular_VelocityWrapper_SetValue = Angular_VelocityWrapper._SetValue

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
		group "Start Node"
		(
		pickbutton Pick_Start_Node "Pick Start Node" autodisplay:true type:#node toolTip:"Pick Start Node"
		)
		group "Dynamic Properties"
		(
		spinner Mass "Mass" range:[-1000, 1000, 1] type:#float width:72 height:16 align:#right
		spinner Friction "Friction" range:[0, 1000, 1] type:#float width:81 height:16 align:#right
		spinner Rolling_Friction "Rolling Friction" range:[0, 1000, 1] type:#float width:107 height:16 align:#right
		spinner Restitution "Restitution" range:[0, 100, 1] type:#float width:95 height:16 align:#right
		spinner Linear_Damping "Linear Damping" range:[0, 100, 0.1] type:#float width:110 height:16 align:#right
		spinner Angular_Damping "Angular Damping" range:[0, 100, 0] type:#float width:117 height:16 align:#right
		label Inertia_Label "Inertia" align:#left 
		spinner Inertia_XSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left across:3
		spinner Inertia_YSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left
		spinner Inertia_ZSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left
		on Inertia_XSpinner changed val do Inertia.X = val
		on Inertia_YSpinner changed val do Inertia.Y = val
		on Inertia_ZSpinner changed val do Inertia.Z = val

		label Linear_Velocity_Label "Linear Impulse Velocity" align:#left
		spinner Linear_Velocity_XSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left across:3
		spinner Linear_Velocity_YSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left
		spinner Linear_Velocity_ZSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left
		on Linear_Velocity_XSpinner changed val do Linear_Velocity.X = val
		on Linear_Velocity_YSpinner changed val do Linear_Velocity.Y = val
		on Linear_Velocity_ZSpinner changed val do Linear_Velocity.Z = val

		label Angular_Velocity_Label "Angular Impulse Velocity" align:#left
		spinner Angular_Velocity_XSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left across:3
		spinner Angular_Velocity_YSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left
		spinner Angular_Velocity_ZSpinner range:[-2147483648, 2147483648, 0] width:48 height:16 align:#left
		on Angular_Velocity_XSpinner changed val do Angular_Velocity.X = val
		on Angular_Velocity_YSpinner changed val do Angular_Velocity.Y = val
		on Angular_Velocity_ZSpinner changed val do Angular_Velocity.Z = val
		)
		group "Colliders"
		(
		dotNetControl Colliders_UI "ListView" width:140 height:190 align:#center
		checkbutton addToList_Colliders_UI mcgAPOps.AddButtonText width:140
		button removeFromList_Colliders_UI mcgAPOps.RemoveButtonText width:140
		on addToList_Colliders_UI changed state do with undo label:"Parameter Change" on mcgAPOps.INodeA_AddToList Colliders_Tab state addToList_Colliders_UI
		on removeFromList_Colliders_UI pressed do with undo label:"Parameter Change" on mcgAPOps.INodeA_RemoveFromList Colliders_UI Colliders_List_Tab
		)
		group "World"
		( 
		spinner Gravity "Gravity" range:[-1000, 1000, -50] type:#worldUnits
		)
		on params open do
		(
			paramsOpen = true
			mcgAPOps.OneColParamsOpen Colliders_UI Colliders_Tab mcgAPOps.INodeToStringFunc #("Colliders") selected:&Colliders_selection			Inertia_XSpinner.value = Inertia.X
			Inertia_YSpinner.value = Inertia.Y
			Inertia_ZSpinner.value = Inertia.Z
			Linear_Velocity_XSpinner.value = Linear_Velocity.X
			Linear_Velocity_YSpinner.value = Linear_Velocity.Y
			Linear_Velocity_ZSpinner.value = Linear_Velocity.Z
			Angular_Velocity_XSpinner.value = Angular_Velocity.X
			Angular_Velocity_YSpinner.value = Angular_Velocity.Y
			Angular_Velocity_ZSpinner.value = Angular_Velocity.Z

		)
		on params close do
		(
			mcgAPOps.OneColParamsClose Colliders_UI selected:&Colliders_selection
			paramsOpen = false
		)
	)

	rollout simRollout "Simulation"
	(
		button resetSimulation mcgAPOps.ReinitSimButtonText
		on resetSimulation pressed do
		(
			--clear the caches related to this graph
			pluginInstance.ClearPluginCaches()
			_lastTime = 0.0
			_dummy = not _dummy
		)
	)

	fn GetValueFunction = (
		--evaluate the graph
		local _res = Matrix3 1
		mcgOps.INodeA_PreInvoke params.Colliders_UI Colliders_List Colliders_Tab paramsOpen
		Pick_Start_NodeWrapper_SetValue Pick_Start_Node
		InertiaWrapper_SetValue Inertia
		if (paramsOpen) then (
		 	params.Inertia_XSpinner.value = Inertia.X
		 	params.Inertia_YSpinner.value = Inertia.Y
		 	params.Inertia_ZSpinner.value = Inertia.Z
		)
		Linear_VelocityWrapper_SetValue Linear_Velocity
		if (paramsOpen) then (
		 	params.Linear_Velocity_XSpinner.value = Linear_Velocity.X
		 	params.Linear_Velocity_YSpinner.value = Linear_Velocity.Y
		 	params.Linear_Velocity_ZSpinner.value = Linear_Velocity.Z
		)
		Angular_VelocityWrapper_SetValue Angular_Velocity
		if (paramsOpen) then (
		 	params.Angular_Velocity_XSpinner.value = Angular_Velocity.X
		 	params.Angular_Velocity_YSpinner.value = Angular_Velocity.Y
		 	params.Angular_Velocity_ZSpinner.value = Angular_Velocity.Z
		)

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		local args = dotnet_ValueToDotNetObject #(Colliders_List, Pick_Start_NodeWrapper, Mass, Friction, Rolling_Friction, Restitution, Linear_Damping, Angular_Damping, InertiaWrapper, Linear_VelocityWrapper, Angular_VelocityWrapper, Gravity, currentTime.ticks) argsType
		local v = pluginInstance_GetValue (currentTime as integer) args
		c1 = v.GetColumn 0
			c2 = v.GetColumn 1
			c3 = v.GetColumn 2
			_res = Matrix3 [c1.X,c2.X,c3.X] [c1.Y,c2.Y,c3.Y] [c1.Z,c2.Z,c3.Z] [c1.W,c2.W,c3.W]

		if (PostInvokeMethod != undefined ) do _res = (PostInvokeMethod _res)
		_res
	)

	on getValue do
	(
		--evaluate the graph		
		RunSimLoop getValueFunction
	)
)
