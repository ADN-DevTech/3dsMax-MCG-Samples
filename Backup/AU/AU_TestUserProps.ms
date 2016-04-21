struct _WrapperStruct_AU_TestUserProps 
(
	-- param: node  - type: MAXNode

	pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\AU_TestUserProps.maxtool",
	c = dotNetClass "Viper3dsMaxBridge.MAXScriptFunctionPlugin",
	_pluginInstance = c.CreateInstance pluginDefinitionFile,
	argsType = dotNetClass "System.Object[]",

	function _function node = (
	-- value wrapper local declarations
	local nodeWrapper, nodeWrapper_SetValue

	-- value wrapper local initializations
	local nodeWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
	nodeWrapper = nodeWrapperClass._CreateWrapper (undefined)
	nodeWrapper_SetValue = nodeWrapper._SetValue

	nodeWrapper_SetValue node

	local args = dotnet.ValueToDotNetObject #(nodeWrapper) argsType
	local _res = _pluginInstance.Execute (currentTime as integer) args


	_res
	)
)

AU_TestUserProps = (_WrapperStruct_AU_TestUserProps())._function
