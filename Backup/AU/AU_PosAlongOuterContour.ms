plugin simpleObject AU_PosAlongOuterContour
	name:"AU_PosAlongOuterContour"
	classID:#(0x457B281D, 0x4F212939)
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
		spline ui:spline type:#node useNodeOsValidity:true useNodeTmValidity:true
		distance ui:distance default:0 type:#worldUnits animatable:true
		spacing ui:spacing default:4 type:#worldUnits animatable:true
		rotationDeviation ui:rotationDeviation default:45 type:#float animatable:true
		boxSize ui:boxSize default:0.05 type:#worldUnits animatable:true
		box_stretch ui:box_stretch default:2 type:#float animatable:true
		probability ui:probability default:50 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\AU_PosAlongOuterContour.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\FilterRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CloneMeshAtTransforms.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MatrixArrayRotateGaussianNoise.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\PseudoRandomGaussianFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\PseudoRandomNormalFloats.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CombinePairwiseElements.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\DropLast.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SkipOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\PseudoRandomFloats.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\BoxMuller.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MatrixRotateUsingEuler.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToMatrix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToQuaternion.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\QuaternionFromVector3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\EulerDegreesToRadians.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\VectorMapComponents.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\ArrayToVector.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\SplineLines.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\CombineEveryTwoElements.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MatricesSpacedAlongLineWithOffset.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixInterpolateWithSpacing.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\SampleLerpBetween.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RangeFloatBetween.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixDistance.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixComponentsLerp.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\First.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\LineMatrices.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MatrixSetOrientation.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\SetMatrixRotation.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RotationBetweenVectorsFix.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\RotationBetweenUnitVectors.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\LineVector.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\OffsetLine.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\SetVectorLength.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Second.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\MeshScale.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Tools\AU\compounds\CubeMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\builds\PR654\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\MultiplyTwoFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2016\Max Creation Graph\Compounds\DivideBy100.maxcompound")

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
		spinner seed "seed" range:[0, 100, 0] type:#integer
		pickbutton spline "spline" autodisplay:true type:#node toolTip:"spline"
		spinner distance "distance" range:[-1000, 1000, 0] type:#worldUnits
		spinner spacing "spacing" range:[0, 1000, 4] type:#worldUnits
		spinner rotationDeviation "rotationDeviation" range:[0, 360, 45] type:#float
		spinner boxSize "boxSize" range:[0, 100, 0.05] type:#worldUnits
		spinner box_stretch "box stretch" range:[0, 100, 2] type:#float
		spinner probability "probability" range:[0, 100, 50] type:#float

	)





	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(seed, splineWrapper, distance, spacing, rotationDeviation, boxSize, box_stretch, probability) argsType
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
