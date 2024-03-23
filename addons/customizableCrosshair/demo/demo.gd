extends Control

## Reference to the crosshair node
@export var crosshair: CenterContainer

# Weapon stats
var inaccuracyPerShot: float
var accuracyRecoverySpeed: float
var rpm: float
var fullAuto: bool

# Other weapon variables
var inaccuracy: float
var timeBetweenShots: float
var timeSinceLastShot: float
var mouseInPreviewArea: bool



func _ready():
	# Assign inital values to the settings
	updateValues()
	%crosshairConfigText.text = crosshair.getConfigString()


func updateValues():
	%thicknessValue.value = crosshair.crosshairThickness
	%sizeValue.value = crosshair.crosshairSize
	%gapValue.value = crosshair.crosshairGap
	%color.color = crosshair.crosshairColor
	%dot.button_pressed = crosshair.crosshairDot
	%dynamic.button_pressed = crosshair.crosshairDynamic
	%dynamicMaxValue.value = crosshair.crosshairMaxDynamicOffset
	%outline.button_pressed = crosshair.crosshairOutline
	%outlineThicknessValue.value = crosshair.crosshairOutlineThickness
	%lineStyle.selected = crosshair.crosshairLineStyle
	%tStyle.button_pressed = crosshair.crosshairTStyle
	%horizontalLines.button_pressed = crosshair.crosshairHorizontalLines
	%horizontalLinesPositionValue.value = crosshair.crosshairHorizontalLinesPosition
	%horizontalLinesThicknessValue.value = crosshair.crosshairHorizontalLinesThickness
	%horizontalLinesLengthValue.value = crosshair.crosshairHorizontalLinesLength


func _process(delta):
	# Example shooting cooldown
	if timeSinceLastShot < timeBetweenShots:
		timeSinceLastShot += delta
	
	# Example accuracy
	if inaccuracy > 0:
		inaccuracy = move_toward(inaccuracy, 0.0, delta * accuracyRecoverySpeed)
		crosshair.updateDynamicOffset(inaccuracy)
	
	# Example full auto shooting without input actions
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && mouseInPreviewArea && fullAuto:
		shoot()
	
	# Example shooting using input actions
	#if mouseInPreviewArea:
		#if fullAuto:
			# Example full auto shooting
			#if Input.is_action_pressed("lmb"):
				#shoot()
		#else:
			# Example semi auto shooting
			#if Input.is_action_just_pressed("lmb"):
				#shoot()


func _input(event):
	# Example semi auto shooting without input actions
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and mouseInPreviewArea and not fullAuto:
		shoot()


func shoot():
	if inaccuracy < 1.0 && timeSinceLastShot >= timeBetweenShots:
		timeSinceLastShot = 0.0
		if inaccuracy + inaccuracyPerShot > 1.0:
			inaccuracy = 1.0
		else:
			inaccuracy += inaccuracyPerShot


func updateWeaponConfigs():
	%staticOffsetSlider.value = crosshair.crosshairStaticOffset
	%dynamicOffsetSlider.value = inaccuracyPerShot
	%recoverySpeedSlider.value = accuracyRecoverySpeed
	%rpmSlider.value = rpm


func _on_thickness_slider_value_changed(value):
	crosshair.crosshairThickness = value
	%thicknessValue.value = value
	crosshair.updateCrosshair()


func _on_thickness_value_value_changed(value):
	crosshair.crosshairThickness = value
	%thicknessSlider.value = value
	crosshair.updateCrosshair()


func _on_size_slider_value_changed(value):
	crosshair.crosshairSize = value
	%sizeValue.value = value
	crosshair.updateCrosshair()


func _on_size_value_value_changed(value):
	crosshair.crosshairSize = value
	%sizeSlider.value = value
	crosshair.updateCrosshair()


func _on_gap_slider_value_changed(value):
	crosshair.crosshairGap = value
	%gapValue.value = value
	crosshair.updateCrosshair()


func _on_gap_value_value_changed(value):
	crosshair.crosshairGap = value
	%gapSlider.value = value
	crosshair.updateCrosshair()


func _on_color_color_changed(color):
	crosshair.crosshairColor = color
	crosshair.updateCrosshair()


func _on_dot_toggled(toggled_on):
	crosshair.crosshairDot = toggled_on
	crosshair.updateCrosshair()


func _on_dynamic_toggled(toggled_on):
	crosshair.crosshairDynamic = toggled_on
	crosshair.updateCrosshair()


func _on_dynamic_max_slider_value_changed(value):
	crosshair.crosshairMaxDynamicOffset = value
	%dynamicMaxValue.value = value
	crosshair.updateCrosshair()


func _on_dynamic_max_value_value_changed(value):
	crosshair.crosshairMaxDynamicOffset = value
	%dynamicMaxSlider.value = value
	crosshair.updateCrosshair()


func _on_outline_toggled(toggled_on):
	crosshair.crosshairOutline = toggled_on
	crosshair.updateCrosshair()


func _on_outline_thickness_slider_value_changed(value):
	crosshair.crosshairOutlineThickness = value
	%outlineThicknessValue.value = value
	crosshair.updateCrosshair()


func _on_outline_thickness_value_value_changed(value):
	crosshair.crosshairOutlineThickness = value
	%outlineThicknessSlider.value = value
	crosshair.updateCrosshair()


func _on_crosshair_area_mouse_entered():
	mouseInPreviewArea = true


func _on_crosshair_area_mouse_exited():
	mouseInPreviewArea = false


func _on_static_offset_slider_value_changed(value):
	crosshair.crosshairStaticOffset = value
	%staticOffsetValue.value = value
	crosshair.updateCrosshair()


func _on_static_offset_value_value_changed(value):
	crosshair.crosshairStaticOffset = value
	%staticOffsetSlider.value = value
	crosshair.updateCrosshair()


func _on_dynamic_offset_slider_value_changed(value):
	inaccuracyPerShot = value
	%dynamicOffsetValue.value = value


func _on_dynamic_offset_value_value_changed(value):
	inaccuracyPerShot = value
	%dynamicOffsetSlider.value = value


func _on_recovery_speed_slider_value_changed(value):
	accuracyRecoverySpeed = value
	%recoverySpeedValue.value = value


func _on_recovery_speed_value_value_changed(value):
	accuracyRecoverySpeed = value
	%recoverySpeedSlider.value = value


func _on_semi_pressed():
	inaccuracyPerShot = 0.25
	accuracyRecoverySpeed = 1.0
	rpm = 500
	timeBetweenShots = 60 / rpm
	fullAuto = false
	crosshair.updateStaticOffset(2)
	updateWeaponConfigs()


func _on_auto_pressed():
	inaccuracyPerShot = 0.25
	accuracyRecoverySpeed = 0.5
	rpm = 600
	timeBetweenShots = 60 / rpm
	fullAuto = true
	crosshair.updateStaticOffset(7)
	updateWeaponConfigs()


func _on_rpm_slider_value_changed(value):
	rpm = value
	%rpmValue.value = value
	timeBetweenShots = 60 / rpm


func _on_rpm_value_value_changed(value):
	rpm = value
	%rpmSlider.value = value
	timeBetweenShots = 60 / rpm


func _on_horizontal_lines_toggled(toggled_on):
	crosshair.crosshairHorizontalLines = toggled_on
	crosshair.updateCrosshair()


func _on_t_style_toggled(toggled_on):
	crosshair.crosshairTStyle = toggled_on
	crosshair.updateCrosshair()


func _on_line_style_item_selected(index):
	crosshair.crosshairLineStyle = index
	crosshair.updateCrosshair()


func _on_horizontal_lines_thickness_slider_value_changed(value):
	crosshair.crosshairHorizontalLinesThickness = value
	%horizontalLinesThicknessValue.value = value
	crosshair.updateCrosshair()


func _on_horizontal_lines_thickness_value_value_changed(value):
	crosshair.crosshairHorizontalLinesThickness = value
	%horizontalLinesThicknessSlider.value = value
	crosshair.updateCrosshair()


func _on_horizontal_lines_length_slider_value_changed(value):
	crosshair.crosshairHorizontalLinesLength = value
	%horizontalLinesLengthValue.value = value
	crosshair.updateCrosshair()


func _on_horizontal_lines_length_value_value_changed(value):
	crosshair.crosshairHorizontalLinesLength = value
	%horizontalLinesLengthSlider.value = value
	crosshair.updateCrosshair()


func _on_horizontal_lines_position_slider_value_changed(value):
	crosshair.crosshairHorizontalLinesPosition = value
	%horizontalLinesPositionValue.value = value
	crosshair.updateCrosshair()


func _on_horizontal_lines_position_value_value_changed(value):
	crosshair.crosshairHorizontalLinesPosition = value
	%horizontalLinesPositionSlider.value = value
	crosshair.updateCrosshair()


func _on_apply_pressed():
	crosshair.parseConfigString(%crosshairConfigText.text)
	updateValues()


func _on_generate_pressed():
	%crosshairConfigText.text = crosshair.getConfigString()
