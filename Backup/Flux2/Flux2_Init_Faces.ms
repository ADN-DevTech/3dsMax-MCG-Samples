plugin simpleMeshMod Flux2_Init_Faces
	name:"Flux2_Init_Faces"
	classID:#(0x56A8856B, 0x7138ECA1)
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
	local sourceWrapper, sourceWrapper_SetValue
	local meshWrapper, meshWrapper_SetValue


	parameters main rollout:params
	(
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		position_only ui:position_only default:False type:#boolean animatable:true
		source ui:source type:#node useNodeOsValidity:true useNodeTmValidity:true
		seed ui:seed default:0 type:#integer animatable:true
		axis ui:axis default:2 type:#integer animatable:true
		combine_effect ui:combine_effect default:False type:#boolean animatable:true
		strength ui:strength default:100 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\Flux2\Flux2_Init_Faces.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FluxStoreMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\StoreMatricesInMapChannelWithBackup.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CopyMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\AssignMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\SetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapChannelClear.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\MultiplyByThree.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\DivideBy100.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshRandomFacePositionMatrices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MapConditional.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshRandomFacePositions.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RandomIndices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RandomIntsInRange.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RandomArray.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayElementsByTwoFromZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\MultiplyByTwo.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayElementsByTwoFromOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FacePositionFromBarycentric.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FacePosition.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshFacePositionMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshFaceMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RotationBetweenVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RotationBetweenUnitVectors.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ChooseAxis.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorOrZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorOrDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\FacePositionFromTuple.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixTranslationAsMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MeshFromNodeWithDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound")

		-- value wrapper local initializations
		local sourceWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		sourceWrapper = sourceWrapperClass._CreateWrapper (undefined)
		sourceWrapper_SetValue = sourceWrapper._SetValue
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
		checkbox position_only "position only" checked:False
		pickbutton source "source" autodisplay:true type:#node toolTip:"source"
		spinner seed "seed" range:[0, 100000, 0] type:#integer
		spinner axis "axis" range:[-3, 2, 2] type:#integer
		checkbox combine_effect "combine effect" checked:False
		spinner strength "strength" range:[-10000, 10000, 100] type:#float

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(flux_channel, position_only, sourceWrapper, meshWrapper, seed, axis, combine_effect, strength) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		sourceWrapper_SetValue source
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
