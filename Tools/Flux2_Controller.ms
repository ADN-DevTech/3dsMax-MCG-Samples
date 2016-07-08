
plugin TransformController Flux2_Controller
	name:"Flux2_Controller"
	classID:#(0x3121D72A, 0x3BF0230F)
	category:"Max Creation Graph"
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
	local sourceWrapper, sourceWrapper_SetValue


	parameters pblock rollout:params
	(
		source ui:source type:#node useNodeOsValidity:true useNodeTmValidity:true
		channel ui:channel default:2 type:#integer animatable:true
		n ui:n default:0 type:#integer animatable:true
		_dummy type:#boolean -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)



	fn RunSimLoop updateFxn = (
		local result = Matrix3 1
		try (
			result = updateFxn ()
		)
		catch()
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Flux2_Controller.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.TransformControllerPlugin"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_GetValue = pluginInstance.GetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatricesFromMapChannel-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound")

		-- value wrapper local initializations
		local sourceWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		sourceWrapper = sourceWrapperClass._CreateWrapper (undefined)
		sourceWrapper_SetValue = sourceWrapper._SetValue

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
		pickbutton source "source" autodisplay:true type:#node toolTip:"source"
		spinner channel "channel" range:[0, 100, 2] type:#integer
		spinner n "n" range:[0, 100000000, 0] type:#integer

	)




	fn GetValueFunction = (
		--evaluate the graph
		local _res = Matrix3 1
		sourceWrapper_SetValue source

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		local args = dotnet_ValueToDotNetObject #(sourceWrapper, currentTime.ticks, channel, n) argsType
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
