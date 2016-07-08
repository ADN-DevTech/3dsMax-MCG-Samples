plugin simpleObject AMorph3
	name:"AMorph3"
	classID:#(0x30227585, 0x718F2CFF)
	category:"Max Creation Graph"
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
	local node1Wrapper, node1Wrapper_SetValue
	local node2Wrapper, node2Wrapper_SetValue
	local node3Wrapper, node3Wrapper_SetValue


	parameters main rollout:params
	(
		node1 ui:node1 type:#node useNodeOsValidity:true useNodeTmValidity:true
		node2 ui:node2 type:#node useNodeOsValidity:true useNodeTmValidity:true
		node3 ui:node3 type:#node useNodeOsValidity:true useNodeTmValidity:true
		weight1 ui:weight1 default:1 type:#float animatable:true
		weight2 ui:weight2 default:1 type:#float animatable:true
		weight3 ui:weight3 default:1 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\AMorph3.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Add3-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\NodeMeshOrExit-ext.maxcompound")

		-- value wrapper local initializations
		local node1WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		node1Wrapper = node1WrapperClass._CreateWrapper (undefined)
		node1Wrapper_SetValue = node1Wrapper._SetValue
		local node2WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		node2Wrapper = node2WrapperClass._CreateWrapper (undefined)
		node2Wrapper_SetValue = node2Wrapper._SetValue
		local node3WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		node3Wrapper = node3WrapperClass._CreateWrapper (undefined)
		node3Wrapper_SetValue = node3Wrapper._SetValue

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
		pickbutton node1 "node1" autodisplay:true type:#node toolTip:"node1"
		pickbutton node2 "node2" autodisplay:true type:#node toolTip:"node2"
		pickbutton node3 "node3" autodisplay:true type:#node toolTip:"node3"
		spinner weight1 "weight1" range:[0, 101, 1] type:#float
		spinner weight2 "weight2" range:[0, 100, 1] type:#float
		spinner weight3 "weight3" range:[0, 100, 1] type:#float

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(node1Wrapper, node2Wrapper, node3Wrapper, weight1, weight2, weight3) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(
		node1Wrapper_SetValue node1
		node2Wrapper_SetValue node2
		node3Wrapper_SetValue node3

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
