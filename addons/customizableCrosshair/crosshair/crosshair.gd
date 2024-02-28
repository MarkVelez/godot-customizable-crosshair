# Uncomment if you want to see the cursor in the editor
#@tool
extends CenterContainer

@export_category("Crosshair settings")
@export var crosshairThickness: float ## The thickness of the lines.
@export var crosshairSize: float ## The length of the lines.
@export var crosshairGap: float ## The distance between the middle of the screen and the starts of the lines.
@export var crosshairColor: Color ## The color of the crosshair.


@export_group("Style settings")
@export_enum("Line" ,"Arrow", "Inverse Arrow") var crosshairLineStyle: int = 0
@export var crosshairDot: bool ## Toggle for the middle dot
@export var crosshairTStyle: bool ## Toggle to make the crosshair T style meaning the top line is removed.

@export_subgroup("Outline settings")
@export var crosshairOutline: bool ## Toggle for an outline for the lines
@export var crosshairOutlineThickness: float ## The thickness of the outline

@export_subgroup("Horizontal lines settings")
@export var crosshairHorizontalLines: bool ## Toggle to add horizontal lines at the beginning of the crosshair lines.
@export var crosshairHorizontalLinesPosition: float ## The position of the horizontal lines along their local Y-Axis. If set to 0 the horizontal lines will be at the start of the crosshair lines.
@export var crosshairHorizontalLinesThickness: float ## The thickness of the horizontal lines. If set to 0 crosshairThickness will be used instead.
@export var crosshairHorizontalLinesLength: float ## The width of the horizontal lines. If set to 0 crosshairOffset will be used instead.


@export_group("Optional settings")
@export var crosshairDynamic: bool ## Toggle for if the lines should move based on input
@export var crosshairMaxDynamicOffset: float ## Controls the maximum amount of offset the lines should have

# Line nodes
@onready var topLine: Node2D = %topLine
@onready var bottomLine: Node2D = %bottomLine
@onready var leftLine: Node2D = %leftLine
@onready var rightLine: Node2D = %rightLine

# Both of these are only used when dynamic crosshair enabled
# This is used to adjust the dynamic offset of the lines
# This could be used to show the accuracy of a weapon while shooting or running
# The expected value for this is in the range of 0 to 1
var crosshairDynamicOffset: float
# Used as a constant offset on the crosshair lines
var crosshairStaticOffset: float


func _ready() -> void:
	updateCrosshair()


# Used to update the dynamic offset of crosshair
func updateDynamicOffset(amount: float) -> void:
	# Calculate the offset amount
	var offsetAmount: float = (amount * crosshairMaxDynamicOffset)
	# Offset the lines positions based on the dynamic offset value when dynamic crosshair is enabled
	if crosshairDynamic && amount > 0:
		topLine.position.y = -offsetAmount
		bottomLine.position.y = offsetAmount
		leftLine.position.x = -offsetAmount
		rightLine.position.x = offsetAmount


# Used to update the static offset of the crosshair
func updateStaticOffset(amount: float) -> void:
	crosshairStaticOffset = amount
	updateCrosshair()


func updateLineStyle(style: int):
	match style:
		0:
			return null
		1:
			return preload("res://addons/customizableCrosshair/crosshair/curves/arrow.tres")
		2:
			return preload("res://addons/customizableCrosshair/crosshair/curves/inverseArrow.tres")


# Used to update the crosshairs looks
func updateCrosshair() -> void:
	# Index for itterating through the PackedVector2Arrays
	var i: int = 0
	# Get all the lines
	var lines: Array = self.get_children()
	# Set the offset of the crosshair lines
	var crosshairOffset: float = crosshairGap
	
	# Apply the static offset to the crosshair if dynamic crosshair is enabled
	if crosshairDynamic:
		crosshairOffset += crosshairStaticOffset
	
	# Determine if the crosshair values should be used or the user defined ones for the horizontal lines
	var offset: float = crosshairOffset if crosshairHorizontalLinesLength == 0 else crosshairHorizontalLinesLength
	var thickness: float = crosshairThickness if crosshairHorizontalLinesPosition == 0 else crosshairHorizontalLinesPosition
	var horizontalLineThickness: float = crosshairThickness if crosshairHorizontalLinesThickness == 0 else crosshairHorizontalLinesThickness
	
	# Formula for the offset from the middle for the horizontal lines
	var horizontalLineOffset: float = (crosshairOffset + (thickness / 2))
	# Formular for the start and end point of the horizontal lines
	var horizontalLinePoint: float = ((offset + crosshairThickness) / 2)
	
	# Array of the start point and end point vectors of each horizontal line
	var horizontalLinePoints: PackedVector2Array = [
		Vector2(-horizontalLinePoint, -horizontalLineOffset), # Top start
		Vector2(horizontalLinePoint, -horizontalLineOffset), # Top end
		Vector2(-horizontalLinePoint, horizontalLineOffset), # Bottom start
		Vector2(horizontalLinePoint, horizontalLineOffset), # Bottom end
		Vector2(-horizontalLineOffset, horizontalLinePoint), # Left start
		Vector2(-horizontalLineOffset, -horizontalLinePoint), # Left end
		Vector2(horizontalLineOffset, horizontalLinePoint), # Right start
		Vector2(horizontalLineOffset, -horizontalLinePoint) # Right end
	]
	
	# Apply an extra offset to the crosshair lines when the horizontal lines are enabled
	if crosshairHorizontalLines:
		crosshairOffset += crosshairThickness / 2
	
	# Formular for the start point of the crosshair lines
	var lineStartPoint: float = (crosshairOffset + (crosshairThickness / 2))
	# Formular for the end point of the crosshair lines
	var lineEndPoint: float = (crosshairSize + crosshairOffset + (crosshairThickness / 2))
	
	# Array of the start point and end point vectors of each crosshair line
	var linePoints: PackedVector2Array = [
		Vector2(0.0, -lineStartPoint), # Top start
		Vector2(0.0, -lineEndPoint), # Top end
		Vector2(0.0, lineStartPoint), # Bottom start
		Vector2(0.0, lineEndPoint), # Bottom end
		Vector2(-lineStartPoint, 0.0), # Left start
		Vector2(-lineEndPoint, 0.0), # Left end
		Vector2(lineStartPoint, 0.0), # Right start
		Vector2(lineEndPoint, 0.0) # Right end
	]
	
	# Used to determine if crosshairOffset is negative or positive
	var dir: int = 1 if crosshairOffset >= -(crosshairSize - crosshairThickness + crosshairOutlineThickness) else -1
	
	# Used to get the direction of the horizontal lines
	var horizontalLineOutlineDirections: PackedVector2Array = [
		Vector2(-dir, 0), # Top start
		Vector2(dir, 0), # Top end
		Vector2(-dir, 0), # Bottom start
		Vector2(dir, 0), # Bottom end
		Vector2(0, dir), # Left start
		Vector2(0, -dir), # Left end
		Vector2(0, dir), # Right start
		Vector2(0, -dir) # Right end
	]
	
	# Make the top line invisible if T-Style is enabled
	if crosshairTStyle:
		topLine.visible = false
	else:
		topLine.visible = true
	
	# Apply the configurations to the lines
	for line in lines:
		line.points = linePoints.slice(i, i + 2)
		line.width = crosshairThickness
		line.default_color = crosshairColor
		line.width_curve = updateLineStyle(crosshairLineStyle)
		
		# Apply the configurations to the outline lines that are children of the crosshair lines if crosshair outline is enabled
		if crosshairOutline:
			var outline: Node2D = line.get_child(0)
			outline.visible = true
			outline.points = PackedVector2Array([
				linePoints[i] - linePoints[i].normalized() * crosshairOutlineThickness * dir,
				linePoints[i + 1] + linePoints[i + 1].normalized() * crosshairOutlineThickness * dir
			])
			outline.width = crosshairThickness + crosshairOutlineThickness * 2
			outline.width_curve = updateLineStyle(crosshairLineStyle)
		else:
			# If crosshair outlines are disabled make the lines invisible
			line.get_child(0).visible = false
		
		# Apply the configurations to the horizontal lines that are children of the crosshair lines if they are enabled
		if crosshairHorizontalLines:
			var horizontalLine: Node2D = line.get_child(1)
			horizontalLine.visible = true
			horizontalLine.points = horizontalLinePoints.slice(i, i + 2)
			horizontalLine.width = horizontalLineThickness
			horizontalLine.default_color = crosshairColor
			
			# Apply the configurations to the outline lines that are children of the horizontal lines if crosshair outline is enabled
			if crosshairOutline:
				var outline: Node2D = horizontalLine.get_child(0)
				outline.visible = true
				outline.points = PackedVector2Array([
					horizontalLinePoints[i] + horizontalLineOutlineDirections[i] * crosshairOutlineThickness,
					horizontalLinePoints[i + 1] + horizontalLineOutlineDirections[i + 1] * crosshairOutlineThickness
				])
				outline.width = horizontalLineThickness + crosshairOutlineThickness * 2
			else:
				# If crosshair outlines are disabled make the lines invisible
				horizontalLine.get_child(0).visible = false
		else:
			# If crosshair outlines are disabled make the lines invisible
			line.get_child(1).visible = false
		
		# Itterate to the next line
		i += 2
	
	# Queue a redraw for the center dot
	queue_redraw()


func _draw() -> void:
	# Draw a square behind the actual dot to be used as an outline if crosshair outline is enabled
	if crosshairOutline && crosshairDot:
		draw_rect(Rect2(-(crosshairThickness / 2 + crosshairOutlineThickness), -(crosshairThickness / 2 + crosshairOutlineThickness), crosshairThickness + crosshairOutlineThickness * 2, crosshairThickness + crosshairOutlineThickness * 2), Color.BLACK)
	
	# Draw a square in the middle of the screen if crosshair dot is enabled
	if crosshairDot:
		draw_rect(Rect2(-crosshairThickness / 2, -crosshairThickness / 2, crosshairThickness, crosshairThickness), crosshairColor)
	
	# Runs only if @tool is uncommented
	if Engine.is_editor_hint():
		# Used to update the crosshair when the visibility is toggled
		if visibility_changed:
			updateCrosshair()
