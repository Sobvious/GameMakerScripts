/// @description 

Create = function() {
	
}

Step = function() {
	
}

Draw = function() {

	// Draw plane
	gSurf3D.BeforeSubmit(gMath3D.MatrixTranslation(0.0, 0.0, 0.0));
	draw_sprite(spr_texture, 0.0, 0.0, 0.0);
	gSurf3D.EndSubmit();
	
}

Release = function() {
	
}

Create();