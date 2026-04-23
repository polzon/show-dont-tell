class_name CameraZoomComponent
extends Node
## Controls zoom and subpixel-offset for a Camera2D that renders into a SubViewport.
##
## Two display modes are supported and selected by [member stretch_enabled]:
##
## [b]Stretch enabled[/b] ([code]SubViewportContainer.stretch = true[/code]):
## The container already scales the SubViewport to fill its rect, so the Camera2D
## does not need to compensate for the viewport-to-container ratio.  The effective
## base zoom used internally is [code]Vector2.ONE[/code], and [member zoom_level]
## maps directly to the Camera2D zoom.
##
## [b]Stretch disabled[/b]:
## The SubViewport is rendered at its native size.  The Camera2D must scale by
## [code]container_size / subviewport_size[/code] so that game pixels fill the
## container at [member zoom_level] = 1.
##
## [b]Subpixel offset[/b]:
## When [member use_subpixel_offset] is [code]true[/code] the camera is snapped
## to the nearest pixel boundary each frame and [code]Camera2D.offset[/code] is
## set to the fractional remainder.  Because [code]Camera2D.offset[/code] is a
## world-space value, [b]no stretch scale factor is applied[/b]; Godot's own
## rendering pipeline converts the world-space offset to screen pixels correctly
## regardless of the [code]SubViewportContainer[/code] stretch setting.


## The Camera2D this component drives.
@export var camera: Camera2D

## The SubViewport the camera renders into.
@export var sub_viewport: SubViewport

## The SubViewportContainer that displays the SubViewport.
## Only required when [member stretch_enabled] is [code]false[/code].
@export var sub_viewport_container: SubViewportContainer

## Must match [code]SubViewportContainer.stretch[/code].
## When [code]true[/code] the container already handles viewport scaling, so the
## Camera2D base zoom is kept at [code]Vector2.ONE[/code].
## When [code]false[/code] the base zoom is computed as
## [code]container_size / subviewport_size[/code].
@export var stretch_enabled: bool = true

## Logical zoom level.  1.0 = one game pixel per SubViewport pixel.
## Values above 1 zoom in; values below 1 zoom out.
## Clamped to [[member min_zoom_level], [member max_zoom_level]] on assignment.
@export var zoom_level: float = 1.0:
	set(value):
		zoom_level = clamp(value, min_zoom_level, max_zoom_level)
		_apply_zoom()

## Minimum allowed logical zoom level (zoomed-out limit).
@export var min_zoom_level: float = 0.25

## Maximum allowed logical zoom level (zoomed-in limit).
@export var max_zoom_level: float = 8.0

## When [code]true[/code], applies subpixel-offset correction every frame for
## smooth pixel-perfect camera following.
@export var use_subpixel_offset: bool = true

## Godot's internal Camera2D hard zoom limits.
## Values outside this range cause the 2D camera internals to break.
const CAMERA2D_MIN_ZOOM: float = 0.01
const CAMERA2D_MAX_ZOOM: float = 100.0

## Cached base zoom computed from viewport/container geometry.
## This is [code]Vector2.ONE[/code] when stretch is enabled, or
## [code]container_size / subviewport_size[/code] when stretch is disabled.
var _base_zoom: Vector2 = Vector2.ONE


func _ready() -> void:
	_update_base_zoom()
	_apply_zoom()


func _process(_delta: float) -> void:
	if use_subpixel_offset:
		_apply_subpixel_offset()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Sets the zoom level, clamped to [[member min_zoom_level], [member max_zoom_level]].
func set_zoom_level(new_level: float) -> void:
	zoom_level = new_level


## Adjusts the current zoom level by [param delta].
func adjust_zoom(delta: float) -> void:
	zoom_level += delta


## Re-reads the container/viewport geometry and recomputes the base zoom.
## Call this if the container or viewport is resized at runtime.
func refresh() -> void:
	_update_base_zoom()
	_apply_zoom()


## Returns the current [code]Camera2D.zoom[/code] that was last written.
func get_camera_zoom() -> Vector2:
	if camera:
		return camera.zoom
	return Vector2.ONE


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

## Computes [member _base_zoom] from the SubViewport and SubViewportContainer.
##
## When [member stretch_enabled] is [code]true[/code] the container already
## scales the SubViewport, so the Camera2D must not compensate → base = (1, 1).
##
## When [member stretch_enabled] is [code]false[/code] the SubViewport is
## shown at its native resolution.  The Camera2D must scale by
## [code]container_size / subviewport_size[/code] to fill the container at
## [member zoom_level] = 1.
func _update_base_zoom() -> void:
	if stretch_enabled or not sub_viewport or not sub_viewport_container:
		_base_zoom = Vector2.ONE
		return

	var vp_size := Vector2(sub_viewport.size)
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		_base_zoom = Vector2.ONE
		return

	var container_size := sub_viewport_container.size
	if container_size.x <= 0.0 or container_size.y <= 0.0:
		_base_zoom = Vector2.ONE
		return

	_base_zoom = container_size / vp_size


## Applies [member zoom_level] combined with [member _base_zoom] to the Camera2D.
##
## The resulting [code]Camera2D.zoom[/code] is clamped to Godot's hard limits
## ([constant CAMERA2D_MIN_ZOOM], [constant CAMERA2D_MAX_ZOOM]) to prevent
## Camera2D internals from breaking.  The logical [member zoom_level] is never
## constrained by Camera2D's hard limits; only the value written to the node is.
func _apply_zoom() -> void:
	if not camera:
		return

	# Combine base scale with logical zoom and clamp to Camera2D's hard limits.
	var target_zoom: Vector2 = _base_zoom * zoom_level
	target_zoom.x = clamp(target_zoom.x, CAMERA2D_MIN_ZOOM, CAMERA2D_MAX_ZOOM)
	target_zoom.y = clamp(target_zoom.y, CAMERA2D_MIN_ZOOM, CAMERA2D_MAX_ZOOM)
	camera.zoom = target_zoom


## Snaps the camera to a whole-pixel boundary and stores the fractional
## remainder in [code]Camera2D.offset[/code] for smooth sub-pixel motion.
##
## The pixel grid size in world units equals [code]1 / camera.zoom[/code].
## Snapping to this grid and storing the remainder as Camera2D.offset ensures
## that game pixels are always rendered at whole-pixel boundaries on the
## SubViewport, regardless of whether the container uses stretch or not.
##
## [b]Note:[/b] [code]Camera2D.offset[/code] is a world-space value.  Godot
## converts it to screen-space internally, taking the stretch factor into
## account automatically.  No manual stretch scaling is needed here.
func _apply_subpixel_offset() -> void:
	if not camera:
		return

	var world_pos: Vector2 = camera.global_position

	# Determine the world-unit size of one SubViewport pixel at the current zoom.
	# camera.zoom.x > 1 means more world units per pixel (zoomed in).
	# pixel_size = 1 / camera.zoom so we snap to the correct grid.
	var cam_zoom_x: float = camera.zoom.x
	var cam_zoom_y: float = camera.zoom.y
	var pixel_w: float = 1.0 / cam_zoom_x if cam_zoom_x > 0.0 else 1.0
	var pixel_h: float = 1.0 / cam_zoom_y if cam_zoom_y > 0.0 else 1.0

	# Snap the camera world position to the nearest pixel boundary.
	var snapped := Vector2(
		snappedf(world_pos.x, pixel_w),
		snappedf(world_pos.y, pixel_h)
	)

	# The subpixel remainder is the offset between the true position and the
	# snapped position, in world space.  Applying it via Camera2D.offset
	# compensates for the fractional pixel so motion appears smooth without
	# jitter.  No stretch scale factor is required here because Camera2D.offset
	# is a world-space property.
	camera.offset = world_pos - snapped
