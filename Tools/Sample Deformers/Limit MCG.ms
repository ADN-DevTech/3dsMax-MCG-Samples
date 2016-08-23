plugin simpleMeshMod Limit_MCG
	name:"Limit_MCG"
	classID:#(0x52A8030F, 0x70B3A9BE)
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
	local meshWrapper, meshWrapper_SetValue
	local originWrapper, originWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue
	local obstacleWrapper, obstacleWrapper_SetValue


	parameters main rollout:params
	(
		origin ui:origin type:#node useNodeOsValidity:true useNodeTmValidity:true
		updateCache_Signal ui:updateCache default:false type:#boolean animatable:false
		obstacle ui:obstacle type:#node useNodeOsValidity:true useNodeTmValidity:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Deformers\Limit MCG.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshMoveVerticesLimitedTowardsNode-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshMoveVerticesLimited-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshSetVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LerpVectors-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasSoftSelection.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasPerVertexChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SoftSelection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RayTracePointMoveLimited-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RayBetweenPoints-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\PointMoveToClampDistance-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\FloatIsSmall-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorLengthEpsilon-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\SetVectorLength-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GreaterThanOrEqualToZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\AndAlso3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshMoveToNewOrigin-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\OffsetMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RayTraceCachedSceneFromNode-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RayTraceSceneCached-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractCurrentValueFromCache.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\RayTraceScene-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ScalarToVector-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeTransformOrIdentity-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeMeshOrDefault-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodePosition-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local originWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		originWrapper = originWrapperClass._CreateWrapper (undefined)
		originWrapper_SetValue = originWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue
		local obstacleWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		obstacleWrapper = obstacleWrapperClass._CreateWrapper (undefined)
		obstacleWrapper_SetValue = obstacleWrapper._SetValue

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
		pickbutton origin "origin" autodisplay:true type:#node toolTip:"origin"
		button updateCache "updateCache"
		on updateCache pressed do updateCache_Signal = true
		pickbutton obstacle "obstacle" autodisplay:true type:#node toolTip:"obstacle"

	)




	fn updateMesh = 
	(
		if (tmHandler == undefined) then ( tmHandler = when transform owningNode changes do _dummy = not _dummy )
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, originWrapper, modifierTransformWrapper, updateCache_Signal, obstacleWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		originWrapper_SetValue origin
		obstacleWrapper_SetValue obstacle
		meshWrapper_SetValue mesh
		modifierTransformWrapper_SetValue owningNode.Transform

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined
		if(updateCache_Signal) do (updateCache_Signal = false)
		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
