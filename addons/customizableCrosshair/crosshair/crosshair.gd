# Uncomment if you want to see the cursor in the editor
#@tool
extends CenterContainer

@export_category("Crosshair settings")
## The thickness of the lines.
@export var crosshairThickness: float
## The length of the lines.
@export var crosshairSize: float
## The distance between the middle of the screen and the starts of the lines.
@export var crosshairGap: float
## The color of the crosshair.
@export var crosshairColor: Color


@export_group("Style settings")
## List of possible styles for the crosshair lines.
@export_enum(
	"Line",
	"Arrow",
	"Inverse Arrow"
) var crosshairLineStyle: int = 0
## Toggle for the middle dot.
@export var crosshairDot: bool
## Toggle to make the crosshair T style meaning the top line is removed.
@export var crosshairTStyle: bool

@export_subgroup("Outline settings")
## Toggle for an outline for the lines.
@export var crosshairOutline: bool
## The thickness of the outline.
@export var crosshairOutlineThickness: float

@export_subgroup("Horizontal lines settings")
## Toggle to add horizontal lines at the beginning of the crosshair lines.
@export var crosshairHorizontalLines: bool
## The position of the horizontal lines along their local Y-Axis.
## If set to 0 the horizontal lines will be at the start of the crosshair lines.
@export var crosshairHorizontalLinesPosition: float
## The thickness of the horizontal lines.
## If set to 0 crosshairThickness will be used instead.
@export var crosshairHorizontalLinesThickness: float
## The width of the horizontal lines.
## If set to 0 crosshairOffset will be used instead.
@export var crosshairHorizontalLinesLength: float


@export_group("Optional settings")
## Toggle for if the lines should move based on input.
@export var crosshairDynamic: bool
## Controls the maximum amount of offset the lines should have.
@export var crosshairMaxDynamicOffset: float

# Line nodes
@onready var TopLineRef: Node2D = $TopLine
@onready var BottomLineRef: Node2D = $BottomLine
@onready var LeftLineRef: Node2D = $LeftLine
@onready var RightLineRef: Node2D = $RightLine

# Both of these are only used when dynamic crosshair enabled
# This is used to adjust the dynamic offset of the lines
# This could be used to show the accuracy of a weapon while shooting or running
# The expected value for this is in the range of 0 to 1
var crosshairDynamicOffset: float
# Used as a constant offset on the crosshair lines
var crosshairStaticOffset: float

# A dictionary that holds all the config values for the crosshair
# I recommend not directly changing the values as it could cause issues
# Use the getCrosshairSettings function instead
var crosshairConfig: Dictionary


func _ready() -> void:
	update_crosshair()
	# Runs only if @tool is uncommented
	if Engine.is_editor_hint():
		connect("hidden", update_crosshair)


# Checks if the received dictionary matches the crosshairConfig dictionary
func valid_config(config: Dictionary) -> bool:
	# Check if there is a size mismatch
	if config.size() != crosshairConfig.size():
		push_warning("Config validation failed due to size mismatch.")
		return false
	
	# Check if there are any missing entries
	if not config.has_all(crosshairConfig.keys()):
		push_warning("Config validation failed due to key mismatch.")
		return false
	
	# Check if there is a value type mismatch
	for value in config:
		if typeof(config[value]) != typeof(crosshairConfig[value]):
			push_warning(
				"Expected type '"
				+ type_string(typeof(crosshairConfig[value]))
				+ "' for '"
				+ value
				+ "' but got type '"
				+ type_string(typeof(config[value]))
				+ "'."
			)
			return false
	
	return true


# Converts the config dictionary to a JSON string
func get_config_string() -> String:
	var dict: Dictionary = crosshairConfig.duplicate()
	
	# Serialize crosshair color for JSON
	dict["color"] = [
		dict["color"].r,
		dict["color"].g,
		dict["color"].b,
		dict["color"].a
	]
	
	var string = JSON.stringify(dict, "", false)
	return string


# Convert the JSON string form of the config to a dictionary
func parse_config_string(configString: String) -> void:
	var config = JSON.parse_string(configString)
	
	# Check if the parse failed
	if config == null:
		print("Incorrect config string!")
		return
	
	# Deserialize crosshair color
	config["color"] = Color(
		config["color"][0],
		config["color"][1],
		config["color"][2],
		config["color"][3]
	)
	
	# Convert line style back to int
	config["lineStyle"] = type_convert(config["lineStyle"], 2)
	
	get_crosshair_settings(config)


# Get the crosshair config values from the config dictionary
func get_crosshair_settings(config: Dictionary) -> void:
	# Check if the received dictionary is correct
	if valid_config(config):
		crosshairThickness = config["thickness"]
		crosshairSize = config["size"]
		crosshairGap = config["gap"]
		crosshairColor = config["color"]
		crosshairLineStyle = config["lineStyle"]
		crosshairDot = config["dot"]
		crosshairTStyle = config["tStyle"]
		crosshairOutline = config["outline"]
		crosshairOutlineThickness = config["outlineThickness"]
		crosshairHorizontalLines = config["horizontalLines"]
		crosshairHorizontalLinesPosition = config["horizontalLinesPosition"]
		crosshairHorizontalLinesThickness = config["horizontalLinesThickness"]
		crosshairHorizontalLinesLength = config["horizontalLinesLength"]
		crosshairDynamic = config["dynamic"]
		crosshairMaxDynamicOffset = config["maxDynamicOffset"]
		update_crosshair()
	else:
		push_warning("Invalid config.")


# Used to update the dynamic offset of crosshair
func update_dynamic_offset(amount: float) -> void:
	var offsetAmount: float = (amount * crosshairMaxDynamicOffset)
	# Offset the lines positions based on the dynamic offset value
	if crosshairDynamic and amount > 0:
		TopLineRef.position.y = -offsetAmount
		BottomLineRef.position.y = offsetAmount
		LeftLineRef.position.x = -offsetAmount
		RightLineRef.position.x = offsetAmount


# Used to update the static offset of the crosshair
func update_static_offset(amount: float) -> void:
	crosshairStaticOffset = amount
	update_crosshair()


# Select the curve for the corresponding style
func update_line_style(style: int):
	match style:
		0:
			return null
		1:
			return preload(
				"res://addons/customizableCrosshair/crosshair/curves/arrow.tres"
			)
		2:
			return preload(
				"res://addons/customizableCrosshair/crosshair/curves/inverseArrow.tres"
			)
		_:
			return null


# Updates the values of the config dictionary
func update_crosshair_config() -> void:
	crosshairConfig = {
		"thickness": crosshairThickness,
		"size": crosshairSize,
		"gap": crosshairGap,
		"color": crosshairColor,
		"lineStyle": crosshairLineStyle,
		"dot": crosshairDot,
		"tStyle": crosshairTStyle,
		"outline": crosshairOutline,
		"outlineThickness": crosshairOutlineThickness,
		"horizontalLines": crosshairHorizontalLines,
		"horizontalLinesPosition": crosshairHorizontalLinesPosition,
		"horizontalLinesThickness": crosshairHorizontalLinesThickness,
		"horizontalLinesLength": crosshairHorizontalLinesLength,
		"dynamic": crosshairDynamic,
		"maxDynamicOffset": crosshairMaxDynamicOffset
	}
	


# Used to update the crosshairs looks
func update_crosshair() -> void:
	var i: int = 0
	var lines: Array = get_children()
	var crosshairOffset: float = crosshairGap
	
	# Apply the static offset to the crosshair if dynamic crosshair is enabled
	if crosshairDynamic:
		crosshairOffset += crosshairStaticOffset
	
	# Determine if the crosshair values should be used
	# or the user defined ones for the horizontal lines
	var offset: float =\
		crosshairOffset if crosshairHorizontalLinesLength == 0\
		else crosshairHorizontalLinesLength
	var thickness: float =\
		crosshairThickness if crosshairHorizontalLinesPosition == 0\
		else crosshairHorizontalLinesPosition
	var horizontalLineThickness: float =\
		crosshairThickness if crosshairHorizontalLinesThickness == 0\
		else crosshairHorizontalLinesThickness
	
	var horizontalLineOffset: float = crosshairOffset + (thickness / 2)
	var horizontalLinePoint: float = (offset + crosshairThickness) / 2
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
	
	var lineStartPoint: float = crosshairOffset + (crosshairThickness / 2)
	var lineEndPoint: float =\
		crosshairSize + crosshairOffset + (crosshairThickness / 2)
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
	var dir: int = sign(crosshairOffset)
	
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
		TopLineRef.visible = false
	else:
		TopLineRef.visible = true
	
	# Apply the configurations to the lines
	for LineRef in lines:
		LineRef.points = linePoints.slice(i, i + 2)
		LineRef.width = crosshairThickness
		LineRef.default_color = crosshairColor
		LineRef.width_curve = update_line_style(crosshairLineStyle)
		
		# Apply the configurations to the outline lines
		if crosshairOutline:
			var OutlineRef: Line2D = LineRef.get_child(0)
			OutlineRef.visible = true
			OutlineRef.points = PackedVector2Array([
				linePoints[i] - linePoints[i].normalized() *\
				crosshairOutlineThickness * dir,
				linePoints[i + 1] + linePoints[i + 1].normalized() *\
				crosshairOutlineThickness * dir
			])
			OutlineRef.width =\
				crosshairThickness + crosshairOutlineThickness * 2
			OutlineRef.width_curve = update_line_style(crosshairLineStyle)
		else:
			LineRef.get_child(0).set_visible(false)
		
		# Apply the configurations to the horizontal lines
		if crosshairHorizontalLines:
			var HorizontalLineRef: Line2D = LineRef.get_child(1)
			HorizontalLineRef.visible = true
			HorizontalLineRef.points = horizontalLinePoints.slice(i, i + 2)
			HorizontalLineRef.width = horizontalLineThickness
			HorizontalLineRef.default_color = crosshairColor
			
			# Apply the configurations to the outline lines
			if crosshairOutline:
				var OutlineRef: Line2D = HorizontalLineRef.get_child(0)
				OutlineRef.visible = true
				OutlineRef.points = PackedVector2Array([
					horizontalLinePoints[i] +\
					horizontalLineOutlineDirections[i] * crosshairOutlineThickness,
					horizontalLinePoints[i + 1] +\
					horizontalLineOutlineDirections[i + 1] * crosshairOutlineThickness
				])
				OutlineRef.width =\
					horizontalLineThickness + crosshairOutlineThickness * 2
			else:
				HorizontalLineRef.get_child(0).set_visible(false)
		else:
			LineRef.get_child(1).set_visible(false)
		
		# Itterate to the next line
		i += 2
	
	# Queue a redraw for the center dot
	queue_redraw()
	
	# Update the values of the config dictionary
	update_crosshair_config()


func _draw() -> void:
	# Draw a square behind the actual dot to be used as an outline
	if crosshairOutline && crosshairDot:
		draw_rect(
			Rect2(
				-(crosshairThickness / 2 + crosshairOutlineThickness),
				-(crosshairThickness / 2 + crosshairOutlineThickness),
				crosshairThickness + crosshairOutlineThickness * 2,
				crosshairThickness + crosshairOutlineThickness * 2
			),
			Color.BLACK
		)
	
	# Draw a square in the middle of the screen
	if crosshairDot:
		draw_rect(
			Rect2(
				-crosshairThickness / 2,
				-crosshairThickness / 2,
				crosshairThickness,
				crosshairThickness
			),
			crosshairColor
		)
