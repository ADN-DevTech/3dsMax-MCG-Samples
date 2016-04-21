struct _WrapperStruct_AU_MergeSplines 
(

	pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\AU_MergeSplines.maxtool",
	c = dotNetClass "Viper3dsMaxBridge.MAXScriptFunctionPlugin",
	_pluginInstance = c.CreateInstance pluginDefinitionFile,
	argsType = dotNetClass "System.Object[]",

	function _function  = (
	-- value wrapper local declarations

	-- value wrapper local initializations


	local args = dotnet.ValueToDotNetObject #() argsType
	local _res = _pluginInstance.Execute (currentTime as integer) args


	_res
	)
)

AU_MergeSplines = (_WrapperStruct_AU_MergeSplines())._function
