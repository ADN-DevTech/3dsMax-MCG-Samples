plugin simpleMeshMod ACloneModifier
	name:"ACloneModifier"
	classID:#(0x394210E6, 0x6FC18E2B)
	category:"MCG Clone Tools"
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
		__Clones ui:__Clones default:1 type:#integer animatable:true
		X_Offset ui:X_Offset default:0 type:#float animatable:true
		Y_Offset ui:Y_Offset default:0 type:#float animatable:true
		Z_Offset ui:Z_Offset default:0 type:#float animatable:true
		Y_Rotation ui:Y_Rotation default:0 type:#float animatable:true
		X_Rotation ui:X_Rotation default:0 type:#float animatable:true
		Z_Rotation ui:Z_Rotation default:0 type:#float animatable:true
		scale ui:scale default:1 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Sample Pack 1 Tools\ACloneModifier.maxtool"
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
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CloneAndTransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound")

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

rollout params "Clone Modifer"
    (
		spinner __Clones "# Clones" range:[0, 999, 1] type:#integer
	Group "Offset" (
		spinner X_Offset "X Offset" range:[-100, 100, 0] type:#float
		spinner Y_Offset "Y Offset" range:[-100, 100, 0] type:#float
		spinner Z_Offset "Z Offset" range:[-100, 100, 0] type:#float
	)

	Group "Rotate" (
		spinner X_Rotation "X Rotation" range:[-100, 100, 0] type:#float
		spinner Y_Rotation "Y Rotation" range:[-100, 100, 0] type:#float
		spinner Z_Rotation "Z Rotation" range:[-100, 100, 0] type:#float

	)

	Group "Scale" (
		spinner scale "scale" range:[0, 10, 1] type:#float
	)


    )
   rollout infoRoll "Info" rolledUp:true
   (
	group "Tool Info"(
		label lab1 "Author: Autodesk" align:#center
		label lab2 "Autodesk" align:#center
		label lab3 "(c) 2014 Autodesk, Inc." align:#center	
		hyperlink hl1 "http://autodesk.com" align:#center
	)

   )

	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, __Clones, X_Offset, Y_Offset, Z_Offset, Y_Rotation, X_Rotation, Z_Rotation, scale) argsType
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
