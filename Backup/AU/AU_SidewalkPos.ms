plugin simpleObject AU_SidewalkPos
	name:"AU_SidewalkPos"
	classID:#(0x397BA538, 0x7981A21D)
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
	local splineWrapper, splineWrapper_SetValue


	parameters main rollout:params
	(
		seed ui:seed default:0 type:#integer animatable:true
		count ui:count default:10 type:#integer animatable:true
		spline ui:spline type:#node useNodeOsValidity:true useNodeTmValidity:true
		width ui:width default:5 type:#worldUnits animatable:true
		boxSize ui:boxSize default:0.05 type:#worldUnits animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\AU_SidewalkPos.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CloneMeshAtTransforms.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\PseudoRandomMatrixOffsets.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PseudoRandomFloatsInRange.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ScaleFloats.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ScaleFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixTranslate.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixApplyTransform.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\LineArrayMatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\LineMatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\First.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\LineMatrices.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixSetOrientation.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\SetMatrixRotation.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RotationBetweenVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RotationBetweenUnitVectors.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\LineVector.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Second.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\AtModulo.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\LessThanZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\SplineLines.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CombineEveryTwoElements.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\CubeMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MultiplyTwoFloat.maxcompound")

		-- value wrapper local initializations
		local splineWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		splineWrapper = splineWrapperClass._CreateWrapper (undefined)
		splineWrapper_SetValue = splineWrapper._SetValue

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
		spinner seed "seed" range:[0, 10000, 0] type:#integer
		spinner count "count" range:[0, 10000, 10] type:#integer
		pickbutton spline "spline" autodisplay:true type:#node toolTip:"spline"
		spinner width "width" range:[-10000, 10000, 5] type:#worldUnits
		spinner boxSize "boxSize" range:[0, 100, 0.05] type:#worldUnits

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(seed, count, splineWrapper, width, boxSize) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(
		splineWrapper_SetValue spline

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
