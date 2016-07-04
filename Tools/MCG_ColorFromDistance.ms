
plugin Point4Controller MCG_ColorFromDistance
	name:"MCG_ColorFromDistance"
	classID:#(0x43961FC2, 0x7D02B602)
	category:"Max Creation Graph"
	usePBValidity:true
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
	local color1Wrapper, color1Wrapper_SetValue
	local color2Wrapper, color2Wrapper_SetValue
	local color3Wrapper, color3Wrapper_SetValue
	local nodeAWrapper, nodeAWrapper_SetValue
	local nodeBWrapper, nodeBWrapper_SetValue


	parameters pblock rollout:params
	(
		color1 ui:color1_ColorPicker type:#color default:(color 255 0 0)
		color2 ui:color2_ColorPicker type:#color default:(color 0 255 0)
		color3 ui:color3_ColorPicker type:#color default:(color 0 0 255)
		minDist ui:minDist default:0 type:#worldUnits animatable:true
		nodeA ui:nodeA type:#node useNodeOsValidity:true useNodeTmValidity:true
		nodeB ui:nodeB type:#node useNodeOsValidity:true useNodeTmValidity:true
		maxDist ui:maxDist default:50 type:#worldUnits animatable:true
		_dummy type:#boolean -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)



	fn RunSimLoop updateFxn = (
		local result = Point4 0 0 0 0
		try (
			result = updateFxn ()
		)
		catch()
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\MCG_ColorFromDistance.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.Point4ControllerPlugin"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_GetValue = pluginInstance.GetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\CheckNodeValidity.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BlendNColors.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Last.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\InverseFloatLerp.maxcompound")

		-- value wrapper local initializations
		local color1WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		color1Wrapper = color1WrapperClass._CreateWrapper ([0,0,0])
		color1Wrapper_SetValue = color1Wrapper._SetValue
		local color2WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		color2Wrapper = color2WrapperClass._CreateWrapper ([0,0,0])
		color2Wrapper_SetValue = color2Wrapper._SetValue
		local color3WrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		color3Wrapper = color3WrapperClass._CreateWrapper ([0,0,0])
		color3Wrapper_SetValue = color3Wrapper._SetValue
		local nodeAWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		nodeAWrapper = nodeAWrapperClass._CreateWrapper (undefined)
		nodeAWrapper_SetValue = nodeAWrapper._SetValue
		local nodeBWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		nodeBWrapper = nodeBWrapperClass._CreateWrapper (undefined)
		nodeBWrapper_SetValue = nodeBWrapper._SetValue

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
		colorpicker color1_ColorPicker "color1" color:(color 0 0 0) modal:false align:#center

		colorpicker color2_ColorPicker "color2" color:(color 0 0 0) modal:false align:#center

		colorpicker color3_ColorPicker "color3" color:(color 0 0 0) modal:false align:#center

		spinner minDist "minDist" range:[0, 10000, 0] type:#worldUnits
		pickbutton nodeA "nodeA" autodisplay:true type:#node toolTip:"nodeA"
		pickbutton nodeB "nodeB" autodisplay:true type:#node toolTip:"nodeB"
		spinner maxDist "maxDist" range:[0, 10000, 50] type:#worldUnits

	)




	fn GetValueFunction = (
		--evaluate the graph
		local _res = Point4 0 0 0 0
		color1Wrapper_SetValue [color1.r/255.0,color1.g/255.0,color1.b/255.0]
		color2Wrapper_SetValue [color2.r/255.0,color2.g/255.0,color2.b/255.0]
		color3Wrapper_SetValue [color3.r/255.0,color3.g/255.0,color3.b/255.0]
		nodeAWrapper_SetValue nodeA
		nodeBWrapper_SetValue nodeB

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		local args = dotnet_ValueToDotNetObject #(color1Wrapper, color2Wrapper, color3Wrapper, minDist, nodeAWrapper, nodeBWrapper, maxDist) argsType
		local v = pluginInstance_GetValue (currentTime as integer) args
		_res = Point4 v.x v.y v.z v.w

		if (PostInvokeMethod != undefined ) do _res = (PostInvokeMethod _res)
		_res
	)

	on getValue do
	(
		--evaluate the graph		
		RunSimLoop getValueFunction
	)
)
