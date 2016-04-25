utility Cloner_Create_Nodes "Cloner_Create_Nodes"
(
	local pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Cloner Create Nodes.maxtool"
	local _pluginInstance -- the plugin instance created from the plugin definition
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject

	-- value wrapper local declarations
	local cloneSourceWrapper, cloneSourceWrapper_SetValue
	local fluxSourceWrapper, fluxSourceWrapper_SetValue


	pickbutton cloneSource "cloneSource" autodisplay:true type:#node toolTip:"cloneSource"
	pickbutton fluxSource "fluxSource" autodisplay:true type:#node toolTip:"fluxSource"
	spinner channel "channel" range:[-3, 100, 2] type:#integer


	fn initialize = 
	(
		local c = dotNetClass "Viper3dsMaxBridge.UtilityPluginInstance"
		_pluginInstance = c.CreateInstance pluginDefinitionFile

		-- value wrapper local initializations
		local cloneSourceWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		cloneSourceWrapper = cloneSourceWrapperClass._CreateWrapper (undefined)
		cloneSourceWrapper_SetValue = cloneSourceWrapper._SetValue
		local fluxSourceWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		fluxSourceWrapper = fluxSourceWrapperClass._CreateWrapper (undefined)
		fluxSourceWrapper_SetValue = fluxSourceWrapper._SetValue

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
		cloneSourceWrapper_SetValue cloneSource.object
		fluxSourceWrapper_SetValue fluxSource.object

			if (PreInvokeMethod != undefined ) then PreInvokeMethod ()
			local args = dotnet_ValueToDotNetObject #(cloneSourceWrapper, fluxSourceWrapper, channel.value) argsType
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
