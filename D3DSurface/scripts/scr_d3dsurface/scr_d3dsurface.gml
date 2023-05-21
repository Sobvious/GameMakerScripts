// This script uses scr_math3d
#macro D3DSURF_TYPE_RIGHT 0
#macro D3DSURF_TYPE_LOOKAT 1
#macro D3DSURF_RIGHTHAND 0
#macro D3DSURF_LEFTHAND 1

function D3DSurface(width = window_get_width(), height = window_get_height()) constructor {

	function Initialize() {
		
		// Stop drawing on to application surface
		application_surface_draw_enable(false);
		
		// regenerate or resize surface
		if !surface_exists(m_viewsurf) {
			SurfaceRegenerate();
		}
		else {
			surface_resize(m_viewsurf, m_viewsize[0], m_viewsize[1]);
		}
		
		if surface_exists(m_viewsurf) {
			SetVectorViewDefault();
		}
		
		return surface_exists(m_viewsurf);
		
	}
	
	// Update Lookat matrix effected by right, up, lookat, eye vectors
	function UpdateLookMatrix() {
		
		// Generate facing associated variable
		if m_controltype == D3DSURF_TYPE_RIGHT {
			// Then m_vector_lookat is generated and used for readonly
			m_vector_lookat = gMath3D.Vec3Add(GetFacing(), m_vector_eye);
		}
		else {
			// Then m_vector_right is generated and used for readonly
			m_vector_right = gMath3D.Vec3CrossProduct(m_vector_up, GetFacing());
		}
		
		// Set previous matrix
		m_matrix_lookat_previous = m_matrix_lookat;
		
		// Generate LookAt Matrix
		GenerateLookatMatrix();
		
		return m_vector_eye == m_vector_right;
	}
	
	// Look at matrix
	function GenerateLookatMatrix() {
		if (m_is_righthand) {
			// right hand lookat 
			m_matrix_lookat = gMath3D.MatrixLookatRH(m_vector_eye, m_vector_lookat, m_vector_up);
		}
		else {
			// left hand lookat
			m_matrix_lookat = gMath3D.MatrixLookatLH(m_vector_eye, m_vector_lookat, m_vector_up);
		}
	
		return m_matrix_lookat;
	}
	
	// Perspective matrix
	function UpdatePerspectiveMatrix() {
		// Set previous matrix
		m_matrix_projection_previous = m_matrix_projection;
		
		// Generate Projection Matrix
		if (m_is_righthand) {
			m_matrix_projection = gMath3D.MatrixPerspectiveFovRH(m_perspective_fov, m_perspective_aspect, m_proj_len_znear, m_proj_len_zfar);
		}
		else {
			m_matrix_projection = gMath3D.MatrixPerspectiveFovLH(m_perspective_fov, m_perspective_aspect, m_proj_len_znear, m_proj_len_zfar);
		}
		
		return m_matrix_projection;
	}
	
	// Update Orthography matrix
	function UpdateOrthographyMatrix() {
		// Set previous matrix
		m_matrix_projection_previous = m_matrix_projection;
		
		// Generate Projection Matrix
		if (m_is_righthand) {
			m_matrix_projection = gMath3D.MatrixOrthoRH(m_viewsize[0], m_viewsize[1], m_proj_len_znear, m_proj_len_zfar);
		}
		else {
			m_matrix_projection = gMath3D.MatrixOrthoLH(m_viewsize[0], m_viewsize[1], m_proj_len_znear, m_proj_len_zfar);
		}
		
		return m_matrix_projection;
	
	}
	
	// Set world matrix and target surface, This function usually use right before submit something (=drawing shapes)
	function BeforeSubmit(world_matrix = matrix_build_identity()) {
		var _surf = Surface();
		if surface_exists(_surf) {
			surface_set_target(_surf);
			m_private_matrixes = [matrix_get(matrix_world), matrix_get(matrix_view), matrix_get(matrix_projection)];
			matrix_set(matrix_world, world_matrix);
			matrix_set(matrix_view, m_matrix_lookat);
			matrix_set(matrix_projection, m_matrix_projection);
		}
		
		return surface_exists(_surf);
	}
	
	// Reset world matrix and targetting surface
	function EndSubmit() {
		matrix_set(matrix_world, m_private_matrixes[0]);
		matrix_set(matrix_view, m_private_matrixes[1]);
		matrix_set(matrix_projection, m_private_matrixes[2]);
		if surface_exists(surface_get_target()) {
			surface_reset_target();	
		}
	}
	
	// Release before delete
	function Release() {
		// Free surface
		surface_free(Surface());
	}
	
	// Clear surface before drawing or submit on surface
	function Clear(color = c_black, alpha = 1.0) {
		
		// Check surface existence and if not, regenerate
		if !surface_exists(m_viewsurf) {
			SurfaceRegenerate();
		}
		
		
		if surface_exists(Surface()) {
			// Clear depth and color buffer
			surface_set_target(m_viewsurf);
			draw_clear_alpha(color, alpha);
			surface_reset_target();
		}
		
		return surface_exists(Surface());
	}
	
	// Resize surface
	function Resize(width = window_get_width(), height = window_get_height()) {
		SetViewsize([width, height]);
		
		if surface_get_target() == Surface() {
			show_debug_message("D3DSurface: Cannot resize during drawing");
		}
		else{
			if surface_exists(Surface()) {
				surface_resize(Surface(), m_viewsize[0], m_viewsize[1]);
			}
			else {
				surface_free(Surface());
				SurfaceRegenerate();
			}
		}
		
		return surface_exists(Surface());
	}
	
	// Present surface on post-draw event
	function Present() {
		draw_surface(Surface(), 0, 0);
	}
	
	function PresentFill() {
		draw_surface_ext(Surface(), 0, 0, window_get_width()/surface_get_width(Surface()), window_get_height()/surface_get_height(Surface()), 0.0, c_white, 1.0);
	}
	
	function PresentRatioFix() {
		var scale_width = window_get_width()/surface_get_width(Surface());
		var scale_height = window_get_height()/surface_get_height(Surface());
		var scale = (scale_width > scale_height)? scale_height : scale_width;
		var pos = [(window_get_width()-scale*surface_get_width(Surface()))/2.0, (window_get_height()-scale*surface_get_height(Surface()))/2.0];
		
		draw_surface_ext(Surface(), pos[0], pos[1], scale, scale, 0.0, c_white, 1.0);
	}
	
	function ScreenPosToWorldOrthography(pos_screen) {
		
		pos_screen = [pos_screen[0]-m_viewsize[0]/2.0, pos_screen[1]-m_viewsize[1]/2.0];
		pos_screen = [pos_screen[0], pos_screen[1]];
		var _world = m_vector_eye;
		
		_world = gMath3D.Vec3Add(_world, gMath3D.Vec3Multiply(m_vector_right, pos_screen[0]));
		_world = gMath3D.Vec3Add(_world, gMath3D.Vec3Multiply(m_vector_up, -pos_screen[1]));
		
		return _world;
		
	}
	
	function ScreenPosToWorldPerspective(pos_screen, distance = 1.0) {
		
		pos_screen = [(pos_screen[0]-m_viewsize[0]/2.0)/m_viewsize[0], (pos_screen[1]-m_viewsize[1]/2.0)/m_viewsize[1]];
		
		var _world = gMath3D.Vec3Add(m_vector_eye, gMath3D.Vec3Multiply(SurfGame.GetFacing(), distance));
		var _widthMax = tan(gMath3D.VFovToHFov(m_perspective_fov, m_viewsize[0], m_viewsize[1])/2.0)*2.0*distance;
		var _heightMax = tan(m_perspective_fov/2.0)*2.0*distance;
		
		pos_screen = [pos_screen[0]*_widthMax, pos_screen[1]*_heightMax];
		
		_world = gMath3D.Vec3Add(_world, gMath3D.Vec3Multiply(m_vector_right, pos_screen[0]));
		_world = gMath3D.Vec3Add(_world, gMath3D.Vec3Multiply(m_vector_up, -pos_screen[1]));
		
		return _world;
		
	}
	
	function WorldPosToScreen(pos_world) {
		
		var pos_screen = gMath3D.Vec4TransformCoord(m_matrix_lookat, [pos_world[0], pos_world[1], pos_world[2], 1.0]);
		pos_screen = gMath3D.Vec4TransformCoord(m_matrix_projection, pos_world);
		pos_screen = gMath3D.Vec4TransformCoord(gMath3D.MatrixViewportFlip(m_viewsize[0], m_viewsize[1], 0.0, 0.0, 0.0, 1.0), pos_world);
		
		return pos_screen;
	}
	
	// show variables
	function Debug(x, y) {
		var height = string_height("A")+3.0;
		var i = 0;
		draw_text(x, y+height*i++, "View Size: "+string(m_viewsize));
		draw_text(x, y+height*i++, "Surface ID: "+string(m_viewsurf));
		draw_text(x, y+height*i++, "Control Type: "+string(m_controltype));
		draw_text(x, y+height*i++, "Is Right Hand: "+string(m_is_righthand));
		draw_text(x, y+height*i++, "Eye: "+string(m_vector_eye));
		draw_text(x, y+height*i++, "Up: "+string(m_vector_up));
		draw_text(x, y+height*i++, "Right: "+string(m_vector_right));
		draw_text(x, y+height*i++, "Look: "+string(m_vector_lookat));
		draw_text(x, y+height*i++, "Fov: "+string(m_perspective_fov));
		draw_text(x, y+height*i++, "Aspect: "+string(m_perspective_aspect));
		draw_text(x, y+height*i++, "Znear: "+string(m_proj_len_znear));
		draw_text(x, y+height*i++, "Zfar: "+string(m_proj_len_zfar));	
	}
	
	// Movement - Eye vector 
	function Walk(units) { // Walk front
		var _vec_adder = GetFacing();
		_vec_adder = gMath3D.Vec3Normalize(_vec_adder);
		_vec_adder = gMath3D.Vec3Multiply(_vec_adder, units);
		m_vector_eye = gMath3D.Vec3Add(_vec_adder, m_vector_eye);
	}
	
	function Strafe(units) { // Crab walk
		var _vec_adder = m_vector_right;
		_vec_adder = gMath3D.Vec3Normalize(_vec_adder);
		_vec_adder = gMath3D.Vec3Multiply(_vec_adder, units);
		m_vector_eye = gMath3D.Vec3Add(_vec_adder, m_vector_eye);		
	}
	
	function Fly(units) { // Move up vector
		var _mat_transform = gMath3D.MatrixTranslation(m_vector_up[0]*units, m_vector_up[1]*units, m_vector_up[2]*units);
		m_vector_eye = gMath3D.Vec3TransformCoord(_mat_transform, m_vector_eye);		
	}

	function Move(vector) {
		var _mat_transform =  gMath3D.MatrixTranslation(vector[0], vector[1], vector[2]);
		m_vector_eye =  gMath3D.Vec3TransformCoord(_mat_transform, m_vector_eye);
	}

	// Rotation - Right, up, front vectors
	function Yaw(units) {
		var _mat_transform = gMath3D.MatrixRotationAxis(m_vector_up, units);
		m_vector_right = matrix_transform_vertex(_mat_transform, m_vector_right[0], m_vector_right[1], m_vector_right[2]);
		m_vector_up = matrix_transform_vertex(_mat_transform, m_vector_up[0], m_vector_up[1], m_vector_up[2]);
		GenerateLookatMatrix();
	}
	
	function Pitch(units) {
		var _mat_transform = gMath3D.MatrixRotationAxis(m_vector_right, units);
		m_vector_up = matrix_transform_vertex(_mat_transform, m_vector_up[0], m_vector_up[1], m_vector_up[2]);
		GenerateLookatMatrix();	
	}
	
	function Roll(units) {
		var _vec_face = GetFacing();
		var _mat_transform = gMath3D.MatrixRotationAxis(_vec_face, units);
		m_vector_up = matrix_transform_vertex(_mat_transform, m_vector_up[0], m_vector_up[1], m_vector_up[2]);
		m_vector_right = matrix_transform_vertex(_mat_transform, m_vector_right[0], m_vector_right[1], m_vector_right[2]);
		
	}
	
	function RotX(angle) {
		var _mat_transform = gMath3D.MatrixRotationX(angle);
		m_vector_right = matrix_transform_vertex(_mat_transform, m_vector_right[0], m_vector_right[1], m_vector_right[2]);
		m_vector_up = matrix_transform_vertex(_mat_transform, m_vector_up[0], m_vector_up[1], m_vector_up[2]);
	}
	
	function RotY(angle) {
		var _mat_transform = gMath3D.MatrixRotationY(angle);
		m_vector_right = matrix_transform_vertex(_mat_transform, m_vector_right[0], m_vector_right[1], m_vector_right[2]);
		m_vector_up = matrix_transform_vertex(_mat_transform, m_vector_up[0], m_vector_up[1], m_vector_up[2]);		
	}
	
	function RotZ(angle) {
		var _mat_transform = gMath3D.MatrixRotationZ(angle);
		m_vector_right = matrix_transform_vertex(_mat_transform, m_vector_right[0], m_vector_right[1], m_vector_right[2]);
		m_vector_up = matrix_transform_vertex(_mat_transform, m_vector_up[0], m_vector_up[1], m_vector_up[2]);		
	}

	// set vectors associated view matrix by controlling lookat vector
	function SetVectorLook(eye_vector, lookat_vector, up_vector) {
		SetControlType(D3DSURF_TYPE_LOOKAT);
		m_vector_eye = eye_vector;
		m_vector_lookat = lookat_vector;
		m_vector_up = up_vector;
	}
	
	//  set vectors associated view matrix by controlling right vector
	function SetVectorView(eye_vector, right_vector, up_vector) {
		SetControlType(D3DSURF_TYPE_RIGHT);
		m_vector_eye = eye_vector;
		m_vector_right = right_vector;
		m_vector_up = up_vector;		
	}
	
	function SetVectorViewDefault() {
		SetControlType(D3DSURF_TYPE_RIGHT);
		m_vector_eye = [m_viewsize[0]/2.0, m_viewsize[1]/2.0, 100.0];
		m_vector_right = [1.0, 0.0, 0.0];
		m_vector_up = [0.0, 1.0, 0.0];	
		if os_type == os_windows {
			m_vector_up = [0.0, -1.0, 0.0];	
		}	
	}
	
	// Set Perspective information
	function SetPerspectiveInfo(fov, width, height) {
		m_perspective_fov = fov;
		m_perspective_aspect = width/height;
	}

	// Set Projection Information
	function SetProjectionInfo(znear, zfar) {
		m_proj_len_znear = znear;
		m_proj_len_zfar = zfar;
	}

	// Set Control type
	function SetControlType(type) {
		m_controltype = type;
	}

	// Get facing vectors
	function GetFacing() {
		if m_controltype == D3DSURF_TYPE_RIGHT {
			return gMath3D.Vec3CrossProduct(m_vector_right, m_vector_up);
		}
		else {
			return gMath3D.Vec3Normalize(gMath3D.Vec3Substract(m_vector_lookat, m_vector_eye));
		}
		
		return [0.0, 0.0, 0.0];
	}
	
	// Z tea
	function DepthBufferAlgorithm(testenable = true, writeenable = true) {
		gpu_set_ztestenable(testenable);
		gpu_set_zwriteenable(writeenable);
	}

	function PaintersAlgorithm() {
		gpu_set_ztestenable(false);
		gpu_set_zwriteenable(false);
	}
	
	function Filter() {
		gpu_set_texfilter(true);
		gpu_set_tex_mip_filter(tf_linear);
	}
	
	// Surface Regenerate function you can use it but usually used like an private member
	function SurfaceRegenerate() {
		m_viewsurf = surface_create(m_viewsize[0], m_viewsize[1]);
	}
	
	// get surface id
	function Surface() {
		return m_viewsurf;
	}
	
	// getters and setters

	function GetControlType() {
		return m_controltype;
	}
	
	function SetControlType(type) {
		m_controltype = type;
	}
	
	function GetHand() {
		return m_is_righthand;
	}
	
	function SetHand(hand) {
		m_is_righthand = hand;
	}
	
	function SetVectorEye(eye_vector) {
		m_vector_eye = eye_vector;
	}
	
	function GetVectorEye() {
		return m_vector_eye;
	}
	
	function SetVectorUp(up_vector) {
		m_vector_up = up_vector;
	}
	
	function GetVectorUp() {
		return m_vector_up;
	}
	
	function SetVectorRight(right_vector) {
		m_vector_right = right_vector;
	}
	
	function GetVectorRight() {
		return m_vector_right;
	}
	
	function SetVectorLookAt(lookat_vector) {
		m_vector_lookat = lookat_vector;
	}
	
	function GetVectorLookAt() {
		return m_vector_lookat;
	}
	
	function SetPerspectiveFov(angle) {
		m_perspective_fov = angle;
	}
	
	function GetPerspectiveFov() {
		return m_perspective_fov;
	}
	
	function SetPerspectiveAspect(aspect) {
		m_perspective_aspect = aspect;
	}
	
	function GetPerspectiveAspect() {
		return m_perspective_aspect;
	}
	
	function SetProjectionZnear(znear) {
		m_proj_len_znear = znear;
	}
	
	function GetProjectionZnear() {
		return m_proj_len_znear;
	}
	
	function SetProjectionZfar(zfar) {
		m_proj_len_zfar = zfar;
	}
	
	function GetProjectionZfar() {
		return m_proj_len_zfar;
	}
	
	function SetViewsize(size) {
		m_viewsize = size;
	}
	
	function GetViewsize() {
		return m_viewsize;
	}

	
	// variables
	m_viewsize = [width, height];
	m_viewsurf = noone;
	m_controltype = D3DSURF_TYPE_RIGHT;	
	m_is_righthand = D3DSURF_RIGHTHAND;
	
	// vectors
	m_vector_eye = [0.0, 0.0, 0.0];
	m_vector_up = [0.0, 0.0, 1.0];
		// These following two vectors could be read-only by m_controltype
	m_vector_right = [0.0, 1.0, 0.0];	
	m_vector_lookat = [1.0, 0.0, 0.0];
	
	// proj info
	m_perspective_fov = degtorad(60.0);
	m_perspective_aspect = width/height;
	m_proj_len_znear = 0.1;
	m_proj_len_zfar = 32000.0;
	
	// matrixes
	m_matrix_lookat = matrix_build_identity();
	m_matrix_lookat_previous = m_matrix_lookat;
	m_matrix_projection = matrix_build_identity();
	m_matrix_projection_previous = m_matrix_projection;
	
	m_private_matrixes = [matrix_get(matrix_world), matrix_get(matrix_view), matrix_get(matrix_projection)];
	
	Initialize();

}