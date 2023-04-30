/// @description 
#macro gSurf3D global.g_surf_3d
global.g_surf_3d = new D3DSurface(640, 480);

#macro gSurfUI global.g_surf_ui
global.g_surf_ui = new D3DSurface(1920, 1080);
room_speed = 120;

Create = function() {
	
	// Init 3D Surface for Game
	gSurf3D.Initialize();
	gSurf3D.SetVectorView([0.0, 0.0, 240.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]);
	gSurf3D.SetPerspectiveInfo(gMath3D.HFovToVFov(90.0, 640.0, 480.0), 640.0, 480.0);
	gSurf3D.SetProjectionInfo(0.1, 32000.0);
	gSurf3D.SetHand(D3DSURF_RIGHTHAND);
	gSurf3D.Filter();
	
	// Init 2D Surface for UI
	gSurfUI.Initialize();
	gSurfUI.SetVectorLook([960.0, 540.0, 1000.0], [960.0, 540.0, 0.0], [0.0, -10.0, 0.0]);
	gSurfUI.SetPerspectiveInfo(degtorad(60.0), 640.0, 540.0);
	gSurfUI.SetProjectionInfo(0.01, 32000.0);
	gSurfUI.SetHand(D3DSURF_RIGHTHAND);
	gSurfUI.UpdateLookMatrix();
	gSurfUI.UpdateOrthographyMatrix();
	
	gpu_set_alphatestenable(true);
	gpu_set_alphatestref(128);
	
	gpu_set_ztestenable(true);
	gpu_set_zwriteenable(true);
	
	gpu_set_cullmode(cull_counterclockwise);
}

Step = function(deltaTime = delta_time/1000000.0) {
	
	// Input vectors
	var _move = gMath3D.Vec3Normalize([
		keyboard_check(ord("W")) - keyboard_check(ord("S")),
		keyboard_check(ord("D")) - keyboard_check(ord("A")),
		keyboard_check(ord("R")) - keyboard_check(ord("F")),
	]);
	
	var _look = gMath3D.Vec3Normalize([
		keyboard_check(vk_up) - keyboard_check(vk_down),
		keyboard_check(vk_right) - keyboard_check(vk_left),
		keyboard_check(ord("E")) - keyboard_check(ord("Q")),
	]);

	
	// Move and Look
	var _move_speed = 160;
	gSurf3D.Walk(_move_speed*_move[0]*deltaTime);
	gSurf3D.Strafe(_move_speed*_move[1]*deltaTime);
	gSurf3D.Fly(_move_speed*_move[2]*deltaTime);
	gSurf3D.Pitch(-_look[0]*deltaTime);
	gSurf3D.Yaw(_look[1]*deltaTime);
	gSurf3D.Roll(_look[2]*deltaTime);
	
	// Update Matrixes
	gSurf3D.UpdateLookMatrix();
	gSurf3D.UpdatePerspectiveMatrix();

}

DrawBegin = function() {
	gSurf3D.Clear(c_black, 0.0);
	gSurfUI.Clear(c_black, 0.0);
}

Draw = function() {

	draw_set_colour(c_white);
	gSurfUI.BeforeSubmit(gMath3D.MatrixTranslation(0.0, 0.0, 0.0));
	gSurf3D.Debug(0.0, 0.0);
	draw_text(512.0, 0.0, fps);
	gSurfUI.EndSubmit();

}

Present = function() {
	gSurf3D.PresentRatioFix();
	gSurfUI.PresentRatioFix();
}

Release = function() {
	// Rlease Game Surf
	gSurf3D.Release();
	delete gSurf3D;
	
	// Release UI surf constructor
	gSurfUI.Release();
	delete gSurfUI;
	
	// Release math
	delete gMath3D;
}

Create();