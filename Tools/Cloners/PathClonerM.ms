plugin simpleObject PathClonerM
	name:"PathClonerM"
	classID:#(0xC393353, 0x207D9B55)
	category:"MCG Cloners"
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
	local geometryTransformWrapper, geometryTransformWrapper_SetValue


	parameters main rollout:params
	(
		spline ui:spline type:#node useNodeOsValidity:true useNodeTmValidity:true
		apply_spacing ui:apply_spacing default:True type:#boolean animatable:true
		box_radius ui:box_radius default:1 type:#float animatable:true
		channel_id ui:channel_id default:2 type:#integer animatable:true
		bidirectional ui:bidirectional default:False type:#boolean animatable:true
		world_space ui:world_space default:True type:#boolean animatable:true
		cornerA_offset ui:cornerA_offset default:0 type:#float animatable:true
		cornerB_offset ui:cornerB_offset default:0 type:#float animatable:true
		scale_when_spacing ui:scale_when_spacing default:False type:#boolean animatable:true
		max_distance ui:max_distance default:5 type:#float animatable:true
		probability ui:probability default:100 type:#float animatable:true
		seed ui:seed default:0 type:#integer animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\Cloners\PathClonerM.maxtool"
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
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelStoreMatrices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LineMatrices-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixLookatDefault-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixLookat-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixOrientAroundAxis-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorAngleSigned-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorAngle-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorIsSmall-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorLengthEpsilon-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\GtEqZ-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ProjectionOntoPlaneSpecifiedByNormal-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Projection.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LineVector-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\LineReverse-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixTranslate-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixApplyTransform-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\AlongXAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapWithIndexes-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEqualsZero.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerSpacing-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelStoreMatrices-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CombineEveryTwoElements-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatricesFromMapChannel-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromRows-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixInterpolateWithSpacingAndScaling-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixLerp-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixComponentsLerp-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixDistance-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixFromScalingVector2-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MatrixApplyTransform-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SampleLerp.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CombinePairwiseElements-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DropLast.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SkipOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerMeshAsBoxes-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MeshCopyCustomMapChannelVertexBuffers-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelCopyVertexBuffer-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelExists-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\IsNullFix2-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\MapChannelOrGeometryGet-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Cube-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\QuadToTriMesh-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DivideByTwoFloat.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Cube-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\SplineLinesInLocalSpace-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CombineEveryTwoElements-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformPoints.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\SplineFromNodeOrExit-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ClonerFilterRandomly-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\FilterRandomly-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\DivideBy100-ext.maxcompound")

		-- value wrapper local initializations
		local splineWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		splineWrapper = splineWrapperClass._CreateWrapper (undefined)
		splineWrapper_SetValue = splineWrapper._SetValue
		local geometryTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		geometryTransformWrapper = geometryTransformWrapperClass._CreateWrapper (matrix3 1)
		geometryTransformWrapper_SetValue = geometryTransformWrapper._SetValue

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

	fn installTMHandler theNode =
	(
		owningNode = theNode
		if (tmHandler == undefined and owningNode != undefined) then ( tmHandler = when transform owningNode changes do ( _dummy = not _dummy ))
	)

	on postload do
	(
		installTMHandler(refs.dependentnodes this firstonly:true)
	)

	on attachedToNode theNode do
	(
		installTMHandler(theNode)
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
		pickbutton spline "spline" autodisplay:true type:#node toolTip:"spline"
		checkbox apply_spacing "apply spacing" checked:True
		spinner box_radius "box radius" range:[0, 100, 1] type:#float
		spinner channel_id "channel id" range:[-2, 100, 2] type:#integer
		checkbox bidirectional "bidirectional" checked:False
		checkbox world_space "world space" checked:True
		spinner cornerA_offset "cornerA offset" range:[-1000, 1000, 0] type:#float
		spinner cornerB_offset "cornerB offset" range:[-1000, 1000, 0] type:#float
		checkbox scale_when_spacing "scale when spacing" checked:False
		spinner max_distance "max distance" range:[0, 100000, 5] type:#float
		spinner probability "probability" range:[0, 100, 100] type:#float
		spinner seed "seed" range:[0, 10000, 0] type:#integer

	)




	fn transformGetter = 
	(
		if(isValidNode(owningNode)) then owningNode.Transform else matrix3 1
	)

	fn updateMesh = 
	(
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(splineWrapper, apply_spacing, box_radius, channel_id, bidirectional, world_space, geometryTransformWrapper, cornerA_offset, cornerB_offset, scale_when_spacing, max_distance, probability, seed) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)

	on buildMesh do
	(
		splineWrapper_SetValue spline
		geometryTransformWrapper_SetValue (transformGetter())

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
_meshWrapper_SetValue mesh
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
