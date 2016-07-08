plugin simpleSpline MCGBendGizmo
	name:"MCGBendGizmo"
	classID:#(0x56AAEBDE, 0x7F6FB01)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _shapeWrapper -- the dotnet wrapper around our shape pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	local owningNode
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _shapeWrapper_SetValue
	local pluginInstance_UpdateShape

	-- value wrapper local and function wrapper declarations
	local paramsOpen = false
	local minCornerWrapper, minCornerWrapper_SetValue
	local maxCornerWrapper, maxCornerWrapper_SetValue
	local shapeTransformWrapper, shapeTransformWrapper_SetValue


    parameters main rollout:params
	(
		minCorner type:#point3 default:[-10,-10,0]
		on minCorner set val do 
		( 
			if paramsOpen then (
				this.params.minCorner_XSpinner.value = val.X
				this.params.minCorner_YSpinner.value = val.Y
				this.params.minCorner_ZSpinner.value = val.Z 
			)
		)
		maxCorner type:#point3 default:[10,10,40]
		on maxCorner set val do 
		( 
			if paramsOpen then (
				this.params.maxCorner_XSpinner.value = val.X
				this.params.maxCorner_YSpinner.value = val.Y
				this.params.maxCorner_ZSpinner.value = val.Z 
			)
		)
		numSubdivisions ui:numSubdivisions default:20 type:#integer animatable:true
		angle ui:angle default:15 type:#float animatable:true
		axis ui:axis default:2 type:#integer animatable:true
		direction ui:direction default:0 type:#float animatable:true
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
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Tools\MCGBendGizmo.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.ShapePluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		local _pluginOwner = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile _pluginOwner
		pluginInstance_UpdateShape = pluginInstance.UpdateShape
		local shapeWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.BezierShape"
		_shapeWrapper = shapeWrapperClass._CreateWrapper undefined
		_shapeWrapper_SetValue = _shapeWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\SplineBoxPrimitive.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array2.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\First.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Second.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\ArraySlidingWindow.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SelectByIndex.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\Int32ArrayType.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Last.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\LastIndex.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\MinusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\CombineToSubArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorArrayType-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BendSpline-ext.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BoundingBoxFromSpline.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\BendDeformer-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoundingBoxExtent.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\VectorComponent-ext.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\3dsMax-MCG-Samples\Compounds\SplineDeformKnots.maxcompound")

		-- value wrapper local initializations
		local minCornerWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		minCornerWrapper = minCornerWrapperClass._CreateWrapper ([0,0,0])
		minCornerWrapper_SetValue = minCornerWrapper._SetValue
		local maxCornerWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Point3"
		maxCornerWrapper = maxCornerWrapperClass._CreateWrapper ([0,0,0])
		maxCornerWrapper_SetValue = maxCornerWrapper._SetValue
		local shapeTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		shapeTransformWrapper = shapeTransformWrapperClass._CreateWrapper (matrix3 1)
		shapeTransformWrapper_SetValue = shapeTransformWrapper._SetValue

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

--*****************************************************************************************************************
-- MCG Bend Gizmo Rollout
-----------------------------------
-- The following rollout template is intended to be copied into the Custom UI definition of an MCG .maxtool file:
-- Edit > Edit Graph Properties > Custom UI > Paste this code.
-- 
-- To adapt this template to your own needs, modify the code contained within the "Modifier Creation and Parameter Wiring"
-- section below. This rollout template assumes the parameters exposed by your gizmo match the ones defined on the 
-- modifier (so that they may be wired correctly).
--*****************************************************************************************************************
rollout params "Parameters" width:160 height:128
(	
	-- Define a  filter function to ensure the pick buttons below can only select geometry.
	fn IsGeometry obj = (superclassof obj == GeometryClass)
	
	-- The string below will be replaced by the auto-generated UI definitions from MCG.
	-- This way, we do not have to redefine the spinners and other UI elements expected by the plugin's parameter block.
			label minCorner_Label "minCorner" align:#left
		spinner minCorner_XSpinner range:[-1000000, 1000000, -10] width:48 height:16 align:#left across:3
		spinner minCorner_YSpinner range:[-1000000, 1000000, -10] width:48 height:16 align:#left
		spinner minCorner_ZSpinner range:[-1000000, 1000000, 0] width:48 height:16 align:#left
		on minCorner_XSpinner changed val do minCorner.X = val
		on minCorner_YSpinner changed val do minCorner.Y = val
		on minCorner_ZSpinner changed val do minCorner.Z = val

		label maxCorner_Label "maxCorner" align:#left
		spinner maxCorner_XSpinner range:[-1000000, 1000000, 10] width:48 height:16 align:#left across:3
		spinner maxCorner_YSpinner range:[-1000000, 1000000, 10] width:48 height:16 align:#left
		spinner maxCorner_ZSpinner range:[-1000000, 1000000, 40] width:48 height:16 align:#left
		on maxCorner_XSpinner changed val do maxCorner.X = val
		on maxCorner_YSpinner changed val do maxCorner.Y = val
		on maxCorner_ZSpinner changed val do maxCorner.Z = val

		spinner numSubdivisions "numSubdivisions" range:[2, 100, 20] type:#integer
		spinner angle "angle" range:[-10000, 10000, 15] type:#float
		spinner axis "axis" range:[0, 2, 2] type:#integer
		spinner direction "direction" range:[-10000, 10000, 0] type:#float
	
	-- Add the custom UI elements after the MCG UI definitions.
	pickbutton 'updatePickBtn' "Update Box from Object" width:155 height:16 message:"Pick a Mesh" filter:IsGeometry align:#left
	pickbutton 'applyPickBtn' "Apply to Object" width:155 height:16 message:"Pick a Mesh" filter:IsGeometry align:#left
	
	-- The string below will be replaced by the auto-generated UI element event handlers from MCG.
			on params open do
		(
			paramsOpen = true
			minCorner_XSpinner.value = minCorner.X
			minCorner_YSpinner.value = minCorner.Y
			minCorner_ZSpinner.value = minCorner.Z

			maxCorner_XSpinner.value = maxCorner.X
			maxCorner_YSpinner.value = maxCorner.Y
			maxCorner_ZSpinner.value = maxCorner.Z





		)
		on params close do
		(

			paramsOpen = false
		)
	
	-- Update the box corners with the given object's bounding box. This affects how the spline is generated within MCG.
	fn UpdateBoundingBoxParams obj = (
		bb = nodeGetBoundingBox obj obj.transform
		min_point = bb[1]
		max_point = bb[2]
		
		-- minCorner and maxCorner correspond to the Vector3 parameters defined inside the MCG graph,
		-- which subsequently translate into entries inside this plugin's parameter block.
		minCorner.X = min_point[1]
		minCorner.Y = min_point[2]
		minCorner.Z = min_point[3]
		
		maxCorner.X = max_point[1]
		maxCorner.Y = max_point[2]
		maxCorner.Z = max_point[3]
	)
	
	-- Apply the modifier to the given object.
	fn ApplyMCGModifier obj = (
		
		-- Update the local bounding box parameters.
		UpdateBoundingBoxParams obj
		
		--*****************************************************************************************************************
		-- Modifier Creation and Parameter Wiring                                                                                                               *
		--*****************************************************************************************************************
		-- Create an instance of the associated modifier.
		-- If you are using this file as a template, change this to an instance of your custom modifier
		newMod = MCGBend() 
		
		-- Wire the current gizmo's parameters to the modifier's parameters.
		-- If you are using this file as a template, change the parameter wiring below to suit the parameters on your own modifier.
		--
		-- (!) Note: Due to a recently discovered issue (from Max 2014 through 2017),  paramWire.connect2way causes a crash
		-- when a wired object is cloned (this applies to non-MCG objects as well). As a workaround, we're using the more stable 
		-- paramWire.connect instead. The limitation is that the modifier's parameters will now be driven by the gizmo exclusively.
 		paramWire.connect owningNode.baseObject[#axis] newMod[#axis] "axis"
 		paramWire.connect owningNode.baseObject[#angle] newMod[#angle] "angle"
 		paramWire.connect owningNode.baseObject[#direction] newMod[#direction] "direction"
		--*****************************************************************************************************************
		
		-- Add the instance of the modifier
		addModifier obj newMod
		
		newMod.gizmo = owningNode
	)
	
	-- Apply pick button event handler.
	on applyPickBtn picked obj do
	(
		ApplyMCGModifier obj
	)
	
	-- Update pick button event handler.
	on updatePickBtn picked obj do
	(
		UpdateBoundingBoxParams obj
	)
)

	fn transformGetter = 
	(
		if(isValidNode(owningNode)) then owningNode.Transform else matrix3 1
	)

	fn updateShape = 
	(
        if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(minCornerWrapper, maxCornerWrapper, numSubdivisions, angle, axis, direction, shapeTransformWrapper) argsType
		pluginInstance_UpdateShape (currentTime as integer) _shapeWrapper args
		ok
	)

	on buildShape do
	(
		minCornerWrapper_SetValue minCorner
		if (paramsOpen) then (
		 	params.minCorner_XSpinner.value = minCorner.X
		 	params.minCorner_YSpinner.value = minCorner.Y
		 	params.minCorner_ZSpinner.value = minCorner.Z
		)
		maxCornerWrapper_SetValue maxCorner
		if (paramsOpen) then (
		 	params.maxCorner_XSpinner.value = maxCorner.X
		 	params.maxCorner_YSpinner.value = maxCorner.Y
		 	params.maxCorner_ZSpinner.value = maxCorner.Z
		)
		shapeTransformWrapper_SetValue (transformGetter())

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
        _shapeWrapper_SetValue BezierShape
		RunSimLoop updateShape
		_shapeWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
