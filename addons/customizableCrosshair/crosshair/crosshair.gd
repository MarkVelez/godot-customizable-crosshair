# Uncomment if you want to see the cursor in the editor
#@tool
extends CenterContainer

@export_category("Crosshair settings")
@export var crosshairThickness: float ## The thickness of the lines
@export var crosshairSize: float ## The length of the lines
@export var crosshairGap: float ## The distance between the middle of the screen and the starts of the lines
@export var crosshairColor: Color ## The color of the crosshair

@export_subgroup("Optional settings")
@export var crosshairDot: bool ## Toggle for the middle dot
@export var crosshairDynamic: bool ## Toggle for if the lines should move based on input
@export var crosshairMaxDynamicOffset: float ## Controls the maximum amount of offset the lines should have
@export var crosshairOutline: bool ## Toggle for an outline for the lines
@export var crosshairOutlineThickness: float ## The thickness of the outline
@export var crosshairTStyle: bool ## Toggle to make the crosshair T style meaning the top line is removed

# Line nodes
@onready var topLine = %topLine
@onready var bottomLine = %bottomLine
@onready var leftLine = %leftLine
@onready var rightLine = %rightLine

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
	# Offset the lines positions based on the dynamic offset value when dynamic crosshair is enabled
	if crosshairDynamic && amount > 0:
		topLine.position.y = -amount * crosshairMaxDynamicOffset
		bottomLine.position.y = amount * crosshairMaxDynamicOffset
		leftLine.position.x = -amount * crosshairMaxDynamicOffset
		rightLine.position.x = amount * crosshairMaxDynamicOffset


# Used to update the static offset of the crosshair
func updateStaticOffset(amount: float) -> void:
	crosshairStaticOffset = amount
	updateCrosshair()


# Used to update the crosshairs looks
func updateCrosshair() -> void:
	var i := 0
	var crosshairOffset := crosshairGap
	
	# Apply the static offset to the crosshair if dynamic crosshair is enabled
	if crosshairDynamic:
		crosshairOffset += crosshairStaticOffset
	
	# Array of the start point and end point vectors of each line
	var linePoints := PackedVector2Array([
		Vector2(0.0, -crosshairOffset - (crosshairThickness/2)), # Top start
		Vector2(0.0, -crosshairSize - crosshairOffset - (crosshairThickness/2)), # Top end
		Vector2(0.0, crosshairOffset + (crosshairThickness/2)), # Bottom start
		Vector2(0.0, crosshairSize + crosshairOffset + (crosshairThickness/2)), # Bottom end
		Vector2(-crosshairOffset - (crosshairThickness/2), 0.0), # Left start
		Vector2(-crosshairSize - crosshairOffset - (crosshairThickness/2), 0.0), # Left end
		Vector2(crosshairOffset + (crosshairThickness/2), 0.0), # Right start
		Vector2(crosshairSize + crosshairOffset + (crosshairThickness/2), 0.0) # Right end
		])
	
	if crosshairTStyle:
		topLine.visible = false
	else:
		topLine.visible = true
	
	# Get all the lines
	var lines = get_children()
	# Apply the configurations to the lines
	for line in lines:
		line.points = linePoints.slice(i, i + 2)
		line.width = crosshairThickness
		line.default_color = crosshairColor
		
		# Apply the configurations to the outline lines that are children of the crosshair lines if crosshair outline is enabled
		if crosshairOutline:
			var outline = line.get_child(0)
			outline.visible = true
			outline.points = PackedVector2Array([linePoints[i]-linePoints[i].normalized()*crosshairOutlineThickness, linePoints[i+1]+linePoints[i+1].normalized()*crosshairOutlineThickness])
			outline.width = crosshairThickness + crosshairOutlineThickness*2
		else:
			# If crosshair outlines are disabled make the lines invisible
			var outline = line.get_child(0)
			outline.visible = false
		
		# Itterate to the next line
		i += 2
	
	# Queue a redraw for the center dot
	queue_redraw()


func _draw() -> void:
	# Draw a square behind the actual dot to be used as an outline if crosshair outline is enabledwd
	if crosshairOutline && crosshairDot:
		draw_rect(Rect2(-(crosshairThickness/2 + crosshairOutlineThickness), -(crosshairThickness/2 + crosshairOutlineThickness), crosshairThickness + crosshairOutlineThickness*2, crosshairThickness + crosshairOutlineThickness*2), Color.BLACK)
	
	# Draw a square in the middle of the screen if crosshair dot is enabled
	if crosshairDot:
		draw_rect(Rect2(-crosshairThickness/2, -crosshairThickness/2, crosshairThickness, crosshairThickness), crosshairColor)
	
	# Runs only if @tool is uncommented
	if Engine.is_editor_hint():
		# Used to update the crosshair when the visibility is toggled
		if visibility_changed:
			updateCrosshair()
