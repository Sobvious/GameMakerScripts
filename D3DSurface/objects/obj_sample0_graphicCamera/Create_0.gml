/// @description Graphic Camera

Create = function() {
	
	// Disable surface depth buffer because this is 2D graphic
	surface_depth_disable(true);
	
	// Create D3DSurface and Initialize
	m_surf_game = new D3DSurface();
	
	// Set Eye position (middle pos of the room)
	// You can use this function like a camera
	m_surf_game.SetVectorEye([window_get_width()/2.0, window_get_height()/2.0, 1.0]);
	
}

DrawBegin = function() {
	
	// Resize
	if keyboard_check_pressed(vk_space) {
		m_surf_game.Resize(window_get_width(), window_get_height());
		m_surf_game.SetVectorEye([window_get_width()/2.0, window_get_height()/2.0, 1.0]);
	}
	
	// Update View and Proj Matrix
	m_surf_game.UpdateLookMatrix();
	
	// Update projection matrix in orthography type for 2D graphics
	// When you try 3D graphic, try UpdatePerspectiveMatrix
	m_surf_game.UpdateOrthographyMatrix();
	
	// Clear surface
	m_surf_game.Clear($FFFFFF, 1.0);
	
	// Before you draw something, this targets the surface and set all the matrixes(world, view, proj)
	m_surf_game.BeforeSubmit(gMath3D.MatrixTranslation(0.0, 0.0, 0.0));

}

PostDraw = function() {
	
	// End drawing
	m_surf_game.EndSubmit();
	
	// Present surface(final result). This phrase is completely same with "draw_surface(m_surf_game.Surface(), 0, 0);"
	m_surf_game.Present();
	
}

Cleanup = function() {
	
	// Release and delete D3DSurface constructor instance
	m_surf_game.Release();
	delete m_surf_game;
	
}

Create();