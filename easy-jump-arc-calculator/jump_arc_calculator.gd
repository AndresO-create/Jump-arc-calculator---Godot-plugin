@tool
@icon("res://icon.png")
extends Node2D
class_name EasyJumpArc

@export_category("Velocity components")
##presumed jump velocity of character
@export_range(1, 1024, 1.0, "prefer_slider") var jump_velocity : float = 128.0
##presumed rising gravity of character
@export_range(1, 1024, 1.0, "prefer_slider") var rising_gravity : float = 128.0
##presumed falling gravity of character
@export_range(1, 1024, 1.0, "prefer_slider") var falling_gravity : float = 298.0
##presumed movement speed of character
@export_range(0, 1024, 1.0, "prefer_slider") var horizontal_velocity : float = 64.0

@export_category("Time Component")
##time it takes for character to reach peak jump height
@export_range(0.01, 1.99, 0.1, "prefer_slider") var time_to_peak : float = 1.0

@export_category("Drawing Parameters")
##line color for rising arc
@export var line_color_a : Color = Color.BLUE
##line color for falling arc
@export var line_color_b : Color = Color.RED
##thickness line is drawn with in editor
@export var line_thickness : float = 1.0
##how many points are used when drawing jump arc. More points = higher resolution
@export_range(1, 100, 1.0, "prefer_slider") var point_count : int = 50

@export_category("Label Parameters")
##set info label to visible on runtime
@export var visible_info : bool = true
##option to select whether to display peak in absolute pixels or relative to character height
@export var absolute_peak : bool = true
##option to select wheter to display center in absolute pixels or relative to character size
@export var absolute_center : bool = true

@export_category("Character Parameters")
##height of characterBody parent so peak can be calculated in terms of character height
@export var character_height : float = 16.0
##width of characterBody parent so center can be calculated in terms of character width
@export var character_width : float = 16.0

##contains information on peak, center, time it takes to reach peak height, time it takes to reach floor
@onready var info: Label = $Info

##time it takes to travel from peak jump height to floor
##TIME = (2*PEAK/FALLING_GRAV)^1/2
var time_to_floor : float

##PEAK = JUMP * TIME + (1/2 * GRAVITY * TIME^2)
var peak : float

##Angle at which arc travels to peak
##PEAK_ANGLE = ARCTAN(JUMPVELOCITY/HORIZONTAL_VELOCITY)
var peak_angle : float

##center of arc
##CENTER = <(POS_X - ENDPOINT_FLOOR_X)/2, (POS_Y, PEAK)>
var center : Vector2 #= 0.5 * Vector2(horizontal_velocity, peak)

#endpoints of lines
var endpoint_peak : Vector2
var endpoint_floor : Vector2

func _process(_delta: float) -> void:
	#update values each frame
	peak = (jump_velocity * time_to_peak) - (0.5 * rising_gravity * time_to_peak * time_to_peak)
	center = Vector2((position.x + endpoint_floor.x)/2, (position.y + peak)/2)
	info.text = str("Peak: %s \nCenter: %s \nTime to peak %.2fs \nTime to floor: %.2fs" % [peak_to_string(), center_to_string(), time_to_peak, time_to_floor])
	peak_angle = atan2(jump_velocity, horizontal_velocity)
	time_to_floor = sqrt(abs(2 * -peak/falling_gravity))
	
	if Engine.is_editor_hint(): queue_redraw()
	
	#hide info label if visible_info flag is set to false
	if !Engine.is_editor_hint(): $Info.visible = visible_info
		
func _draw() -> void:
	if Engine.is_editor_hint():
		#line to peak
		endpoint_peak = Vector2(horizontal_velocity, -peak)
		draw_line(position, endpoint_peak, line_color_a, line_thickness)

		#line to floor
		endpoint_floor = Vector2(endpoint_peak.x + horizontal_velocity * time_to_floor, 0)
		draw_line(endpoint_peak, endpoint_floor, line_color_b, line_thickness)
	
##convert peak from absolute terms to relative terms if absolute_peak is set to false
func peak_to_string() -> String:
	if absolute_peak: return "%.2fpx" % peak
	else: return "%.2f character heights" % (peak/character_height)

##convert center from absolute terms to relative terms if absolute_center is set to false
func center_to_string() -> String:
	if absolute_center: return "%.2fpx, %.2fpx" % [center.x, center.y]
	else: return "%.2f character widths, %.2f character heights" % [center.x/character_width, center.y/character_height]
