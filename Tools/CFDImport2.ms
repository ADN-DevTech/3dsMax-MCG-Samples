plugin simpleObject CFDImport2
	name:"CFDImport2"
	classID:#(0x1696190A, 0x69D3756A)
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
	local paramsOpen = false


	parameters main rollout:params
	(
		Weld_Dst ui:Weld_Dst default:0.001 type:#worldUnits animatable:true
		Force_Reload_Signal ui:Force_Reload default:false type:#boolean animatable:false
		CSV_File type:#filename assettype:#Other enumAsAsset:true
		on CSV_File set val do ( mcgOps.AssetParamSetToolTip paramsOpen CSV_File this.params.CSV_File_UI )
		Separator type:#string default:","
		on Separator set val do ( if paramsOpen then (this.params.Separator_EditText.text = Separator) )
		NbHeaderLines ui:NbHeaderLines default:1 type:#integer animatable:true
		NbBottomLines ui:NbBottomLines default:8 type:#integer animatable:true
		Default_Value ui:Default_Value default:0 type:#float animatable:true
		X_Pos__Chn ui:X_Pos__Chn default:2 type:#integer animatable:true
		Y_Pos__Chn ui:Y_Pos__Chn default:3 type:#integer animatable:true
		Z_Pos__Chn ui:Z_Pos__Chn default:4 type:#integer animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\CFDImport2.maxtool"
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
		pluginGraphDependencies = #(@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ParseCSVData.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Parse2DStringArrayToFloat.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ParseStringArrayToFloat.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RemoveEnds.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractVectors.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CacheValueResettable-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ExtractCurrentValueFromCache.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FilterCFDMeshVertices.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransferPerVertexDataByIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HasPerVertexChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FilterOverlappingPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\First.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\RemoveDuplicates.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SameAsPreviousElement.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\GreaterThanZero.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound")

		-- value wrapper local initializations
		if(CSV_File == undefined ) then CSV_File = ""
		mcgOps.AssetParamSetToolTip paramsOpen CSV_File this.params.CSV_File_UI

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
		spinner Weld_Dst "Weld Dst" range:[0, 10000, 0.001] type:#worldUnits
		button Force_Reload "Force Reload"
		on Force_Reload pressed do Force_Reload_Signal = true
		button CSV_File_UI "CSV_File" tooltip:""
		on CSV_File_UI pressed do (
			local f = mcgOps.AssetParamPickFile CSV_File CSV_File_UI
			if(f != undefined and f != CSV_File ) then ( CSV_File = f )
		)
		EditText Separator_EditText "Separator  " text:"," labelOnTop:true
		on Separator_EditText changed arg do ( mcgOps.StringParameterEdit Separator_EditText MyString )
		on Separator_EditText entered arg do (
			Separator = Separator_EditText.text
			mcgOps.StringParameterEdit Separator_EditText Separator
		)
		spinner NbHeaderLines "NbHeaderLines" range:[0, 999999999, 1] type:#integer
		spinner NbBottomLines "NbBottomLines" range:[0, 999999999, 8] type:#integer
		spinner Default_Value "Default Value" range:[-1E+09, 1E+09, 0] type:#float
		spinner X_Pos__Chn "X Pos. Chn" range:[0, 100, 2] type:#integer
		spinner Y_Pos__Chn "Y Pos. Chn" range:[0, 100, 3] type:#integer
		spinner Z_Pos__Chn "Z Pos. Chn" range:[0, 100, 4] type:#integer
		on params open do
		(
			paramsOpen = true


			mcgOps.AssetParamSetToolTip paramsOpen CSV_File CSV_File_UI

			Separator_EditText.Text = Separator







		)
		on params close do
		(

			paramsOpen = false
		)
	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(Weld_Dst, Force_Reload_Signal, CSV_File, Separator, NbHeaderLines, NbBottomLines, Default_Value, X_Pos__Chn, Y_Pos__Chn, Z_Pos__Chn) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined
		if(Force_Reload_Signal) do (Force_Reload_Signal = false)
		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
