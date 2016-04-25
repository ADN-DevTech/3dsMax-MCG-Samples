utility Create_Cloner_Nodes "Create_Cloner_Nodes"
(
	local pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Create Cloner Nodes.maxtool"
	local _pluginInstance -- the plugin instance created from the plugin definition
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject

	-- value wrapper local declarations
	local targetWrapper, targetWrapper_SetValue
	local clonerWrapper, clonerWrapper_SetValue


	pickbutton target "target" autodisplay:true type:#node toolTip:"target"
	pickbutton cloner "cloner" autodisplay:true type:#node toolTip:"cloner"
	spinner channel "channel" range:[-3, 100, 2] type:#integer


	fn initialize = 
	(
		local c = dotNetClass "Viper3dsMaxBridge.UtilityPluginInstance"
		_pluginInstance = c.CreateInstance pluginDefinitionFile

		-- value wrapper local initializations
		local targetWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		targetWrapper = targetWrapperClass._CreateWrapper (undefined)
		targetWrapper_SetValue = targetWrapper._SetValue
		local clonerWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		clonerWrapper = clonerWrapperClass._CreateWrapper (undefined)
		clonerWrapper_SetValue = clonerWrapper._SetValue

	)

	fn execute = 
	(
		if (_pluginInstance == undefined) then 
		( 
			initialize()
			if (_pluginInstance == undefined) then ( return undefined )
		)
		try 
		(
		targetWrapper_SetValue target.object
		clonerWrapper_SetValue cloner.object

			if (PreInvokeMethod != undefined ) then PreInvokeMethod ()
			local args = dotnet_ValueToDotNetObject #(targetWrapper, clonerWrapper, channel.value) argsType
			_pluginInstance.Execute (currentTime as integer) args

		)
		catch 
		(
			local msg = "evaluating procedural tool: " + (getCurrentException())
			displayTempPrompt msg 5000 -- 5 sec display of message
		)
		if (PostInvokeMethod != undefined ) then PostInvokeMethod ()
		ok
	)

	button doit "Execute" 
	on doit pressed do ( execute () )
)