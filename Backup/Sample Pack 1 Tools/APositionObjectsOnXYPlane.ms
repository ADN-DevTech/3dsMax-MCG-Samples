utility APositionObjectsOnXYPlane "APositionObjectsOnXYPlane"
(
	local pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Sample Pack 1 Tools\APositionObjectsOnXYPlane.maxtool"
	local _pluginInstance -- the plugin instance created from the plugin definition
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject

	-- value wrapper local declarations


	spinner spacing "spacing" range:[0, 9999, 30] type:#float
	spinner row_size "row size" range:[1, 100, 1] type:#integer


	fn initialize = 
	(
		local c = dotNetClass "Viper3dsMaxBridge.UtilityPluginInstance"
		_pluginInstance = c.CreateInstance pluginDefinitionFile

		-- value wrapper local initializations

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

			if (PreInvokeMethod != undefined ) then PreInvokeMethod ()
			local args = dotnet_ValueToDotNetObject #(spacing.value, row_size.value) argsType
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