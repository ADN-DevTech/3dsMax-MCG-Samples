plugin simpleMeshMod Flux2_Scatter
	name:"Flux2_Scatter"
	classID:#(0x60DA9E2B, 0x34C9A247)
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
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		randomSeed ui:randomSeed default:0 type:#integer animatable:true
		count ui:count default:100 type:#integer animatable:true
		invertFilter ui:invertFilter default:False type:#boolean animatable:true
		exactOrAnyBit ui:exactOrAnyBit default:True type:#boolean animatable:true
		materialId ui:materialId default:0 type:#integer animatable:true
		show_boxes ui:show_boxes default:True type:#boolean animatable:true
		box_radius ui:box_radius default:1 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\Flux2_Scatter.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxScatterOnFaces.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\TestEqualsOrAnyBit.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\TestAnyBitsSet.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GreaterThanZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\XOr.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshFaceMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ChooseAxis.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RotationBetweenVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RotationBetweenUnitVectors.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorOrZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorOrDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RandomElements.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RandomElement.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\IfGreaterThanZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FacePositionFromBarycentric.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FilterWithIndexesOnly.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMeshAsBoxes.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshCopyCustomMapChannelVertexBuffers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelCopyVertexBuffer.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound")

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
		spinner flux_channel "flux channel" range:[-2, 100, 2] type:#integer
		spinner randomSeed "randomSeed" range:[0, 10000, 0] type:#integer
		spinner count "count" range:[0, 10000, 100] type:#integer
		checkbox invertFilter "invertFilter" checked:False
		checkbox exactOrAnyBit "exactOrAnyBit" checked:True
		spinner materialId "materialId" range:[0, 1000000, 0] type:#integer
		checkbox show_boxes "show boxes" checked:True
		spinner box_radius "box radius" range:[0, 10000, 1] type:#float

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, flux_channel, randomSeed, count, invertFilter, exactOrAnyBit, materialId, show_boxes, box_radius) argsType
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