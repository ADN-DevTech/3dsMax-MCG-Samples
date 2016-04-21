plugin simpleMeshMod Flux2_Init_Geometry
	name:"Flux2_Init_Geometry"
	classID:#(0x633B4DF, 0x6F3D9DBB)
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


	parameters main rollout:params
	(
		channelId ui:channelId default:0 type:#integer animatable:true
		probability ui:probability default:100 type:#float animatable:true
		verticesOrFaces ui:verticesOrFaces default:False type:#boolean animatable:true
		fomrIndex ui:fomrIndex default:0 type:#integer animatable:true
		stride ui:stride default:0 type:#integer animatable:true
		ignoreRotation ui:ignoreRotation default:False type:#boolean animatable:true
		axis ui:axis default:0 type:#integer animatable:true
		seed ui:seed default:0 type:#integer animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\Flux2_Init_Geometry.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxInitGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RayToMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RotationBetweenVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RotationBetweenUnitVectors.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ChooseAxis.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorOrZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorOrDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshVertexNormalsAsRays.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshFaceNormalsAsRays.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FaceToRay.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\FilterRandomly.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue

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
		spinner channelId "channelId" range:[0, 100, 0] type:#integer
		spinner probability "probability" range:[0, 100, 100] type:#float
		checkbox verticesOrFaces "verticesOrFaces" checked:False
		spinner fomrIndex "fomrIndex" range:[0, 100, 0] type:#integer
		spinner stride "stride" range:[0, 100, 0] type:#integer
		checkbox ignoreRotation "ignoreRotation" checked:False
		spinner axis "axis" range:[0, 100, 0] type:#integer
		spinner seed "seed" range:[0, 100, 0] type:#integer

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, channelId, probability, verticesOrFaces, fomrIndex, stride, ignoreRotation, axis, seed) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
