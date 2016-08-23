plugin simpleMeshMod Noise_MCG
	name:"Noise_MCG"
	classID:#(0x3ACE77DA, 0x7DC4C8AA)
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
	local gizmo_nodeWrapper, gizmo_nodeWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue


	parameters main rollout:params
	(
		numIterations ui:numIterations default:6 type:#integer animatable:true
		roughness ui:roughness default:0 type:#float animatable:true
		phase ui:phase default:0 type:#integer animatable:true
		frequency ui:frequency default:0.25 type:#float animatable:true
		scale ui:scale default:200 type:#float animatable:true
		strengthX ui:strengthX default:100 type:#worldUnits animatable:true
		strengthY ui:strengthY default:100 type:#worldUnits animatable:true
		strengthZ ui:strengthZ default:100 type:#worldUnits animatable:true
		seed ui:seed default:1234 type:#integer animatable:true
		use_gizmo_node ui:use_gizmo_node default:False type:#boolean animatable:true
		gizmo_node ui:gizmo_node type:#node useNodeOsValidity:true useNodeTmValidity:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Sample Deformers\Noise MCG.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseMesh-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformer-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformerfBm1-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\First.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Second.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Last.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformerNoise3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformerNoiseVarSetup-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorComponent-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformerSCurve.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformerAt3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\FloatIsNaN.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NoiseDeformerNoiseInit-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ZipToTuple.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorToArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArrayToVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshDeformVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshSetVertices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LerpVectors-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasSoftSelection.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasPerVertexChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SoftSelection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeTransformInLocalSpaceConditionally-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeTransformInLocalSpaceOrIdentity-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeTMInLocalSpace-ext.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local gizmo_nodeWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		gizmo_nodeWrapper = gizmo_nodeWrapperClass._CreateWrapper (undefined)
		gizmo_nodeWrapper_SetValue = gizmo_nodeWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue

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
		spinner numIterations "numIterations" range:[1, 20, 6] type:#integer
		spinner roughness "roughness" range:[0, 1, 0] type:#float
		spinner phase "phase" range:[-10000, 10000, 0] type:#integer
		spinner frequency "frequency" range:[-10000, 10000, 0.25] type:#float
		spinner scale "scale" range:[-10000, 10000, 200] type:#float
		spinner strengthX "strengthX" range:[-10000, 10000, 100] type:#worldUnits
		spinner strengthY "strengthY" range:[-10000, 10000, 100] type:#worldUnits
		spinner strengthZ "strengthZ" range:[-10000, 10000, 100] type:#worldUnits
		spinner seed "seed" range:[0, 100000, 1234] type:#integer
		checkbox use_gizmo_node "use gizmo node" checked:False
		pickbutton gizmo_node "gizmo node" autodisplay:true type:#node toolTip:"gizmo node"

	)




	fn updateMesh = 
	(
		if (tmHandler == undefined) then ( tmHandler = when transform owningNode changes do _dummy = not _dummy )
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, numIterations, roughness, phase, frequency, scale, strengthX, strengthY, strengthZ, seed, use_gizmo_node, gizmo_nodeWrapper, modifierTransformWrapper) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		gizmo_nodeWrapper_SetValue gizmo_node
		meshWrapper_SetValue mesh
		modifierTransformWrapper_SetValue owningNode.Transform

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
