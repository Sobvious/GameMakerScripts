#macro gMath3D global.g_math3d

function Math3D() constructor {
		
	function Vec3Normalize(vec) {
		var _disp = sqrt(vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
		if _disp == 0 return [0.0, 0.0, 0.0];
		vec[0] = vec[0]/_disp;
		vec[1] = vec[1]/_disp;
		vec[2] = vec[2]/_disp;
		
		return vec;
	}

	function Vec2Normalize(vec) {
		var _disp = sqrt(vec[0]*vec[0] + vec[1]*vec[1]);
		if _disp == 0 return [0.0, 0.0];
		vec[0] = vec[0]/_disp;
		vec[1] = vec[1]/_disp;
		
		return vec;
	}
	
	function Vec3CrossProduct(vec1, vec2) {
		var _result = array_create(3);
		_result[0] = vec1[1] * vec2[2] - vec1[2] * vec2[1];
		_result[1] = vec1[2] * vec2[0] - vec1[0] * vec2[2];
		_result[2] = vec1[0] * vec2[1] - vec1[1] * vec2[0];
		return _result;
	}
	
	function Vec3DotProduct(vec1, vec2) {
		var _result ;
		_result = vec1[0]*vec2[0] + vec1[1]*vec2[1] + vec1[2]*vec2[2];
		return _result;
	}
	
	function Vec3Substract(vec1, vec2) {
		var _result = array_create(3);
		_result[0] = vec1[0] - vec2[0];
		_result[1] = vec1[1] - vec2[1];
		_result[2] = vec1[2] - vec2[2];
		
		return _result;
	}
	
	function Vec3Multiply(vec, number) {
		var _result = array_create(3);
		_result[0] = vec[0]*number;
		_result[1] = vec[1]*number;
		_result[2] = vec[2]*number;
		return _result;
	}
	
	function Vec3Add(vec1, vec2) {
		var _result = array_create(3);
		_result[0] = vec1[0] + vec2[0];
		_result[1] = vec1[1] + vec2[1];
		_result[2] = vec1[2] + vec2[2];
		return _result;
	}
	
	function MatrixLookatRH(vec_eye, vec_at, vec_up) {
		var _xaxis = array_create(3);
		var _yaxis = array_create(3);
		var _zaxis = array_create(3);
		var _result = matrix_build_identity();
		
		_zaxis = Vec3Normalize(Vec3Substract(vec_eye, vec_at));
		_xaxis = Vec3Normalize(Vec3CrossProduct(vec_up, _zaxis));
		_yaxis = Vec3CrossProduct(_zaxis, _xaxis);
		
		_result = 
		[_xaxis[0], _yaxis[0], _zaxis[0], 0.0,
		 _xaxis[1], _yaxis[1], _zaxis[1], 0.0,
		 _xaxis[2], _yaxis[2], _zaxis[2], 0.0,
		 -Vec3DotProduct(_xaxis, vec_eye), -Vec3DotProduct(_yaxis, vec_eye), -Vec3DotProduct(_zaxis, vec_eye), 1.0
		];
		
		return _result;
	}
	
	function MatrixLookatLH(vec_eye, vec_at, vec_up) {
		var _xaxis = array_create(3);
		var _yaxis = array_create(3);
		var _zaxis = array_create(3);
		var _result = matrix_build_identity();
		
		_zaxis = Vec3Normalize(Vec3Substract(vec_at, vec_eye));
		_xaxis = Vec3Normalize(Vec3CrossProduct(vec_up, _zaxis));
		_yaxis = Vec3CrossProduct(_zaxis, _xaxis);
		
		_result = 
		[_xaxis[0], _yaxis[0], _zaxis[0], 0.0,
		 _xaxis[1], _yaxis[1], _zaxis[1], 0.0,
		 _xaxis[2], _yaxis[2], _zaxis[2], 0.0,
		 -Vec3DotProduct(_xaxis, vec_eye), -Vec3DotProduct(_yaxis, vec_eye), -Vec3DotProduct(_zaxis, vec_eye), 1.0
		];
		
		return _result;
	}
	
	function MatrixPerspectiveFovRH(fovy, aspect, zn, zf) {
		var _result, _yScale, _xScale;
		_yScale = 1/tan(fovy/2.0);
		_xScale = _yScale/aspect;
		
		_result = [
			_xScale,		0.0,	0.0,			0.0,
			0.0,		_yScale,	0.0,			0.0,
			0.0,			0.0,	zf/(zn-zf),		-1.0,
			0.0,			0.0,	zn*zf/(zn-zf),	0.0
		];
		
		return _result;
	}
	
	function MatrixPerspectiveFovLH(fovy, aspect, zn, zf) {
		var _result, _yScale, _xScale;
		_yScale = 1/tan(fovy/2.0);
		_xScale = _yScale/aspect;
		
		_result = [
			_xScale,		0.0,	0.0,			0.0,
			0.0,		_yScale,	0.0,			0.0,
			0.0,			0.0,	zf/(zf-zn),		1.0,
			0.0,			0.0,	-zn*zf/(zf-zn),	0.0
		];
		
		return _result;
	}
	
	function MatrixOrthoRH(w, h, zn, zf) {
		return [
			2.0/w, 0.0, 0.0, 0.0,
			0.0, 2.0/h, 0.0, 0.0,
			0.0, 0.0, 1.0/(zn-zf), 0.0,
			0.0, 0.0, zn/(zn-zf), 1.0
		];
	}
	
	function MatrixOrthoLH(w, h, zn, zf) {
		return [
			2.0/w, 0.0, 0.0, 0.0,
			0.0, 2.0/h, 0.0, 0.0,
			0.0, 0.0, 1.0/(zf-zn), 0.0,
			0.0, 0.0, -zn/(zf-zn), 1.0
		];
	}
	
	function MatrixOrthoOffCenterLH(w, h, zn, zf) {
		var l = -w/2.0;
		var r = +w/2.0;
		var b = -h/2.0;
		var t = +h/2.0;
		
		return [
			2.0/(r-l)	,	0.0,			0.0,			0.0,
			0.0			,	2.0/(t-b),		0.0,			0.0,
			0.0,		,	0.0,			1.0/(zf-zn),	0.0,
			(l+r)/(l-r)	,	(t+b)/(b-t),	zn/(zn-zf),		1.0
		];
		
	}
	
	function MatrixOrthoOffCenterRH(w, h, zn, zf) {
		var l = -w/2.0;
		var r = +w/2.0;
		var b = -h/2.0;
		var t = +h/2.0;
		
		return [
			2.0/(r-l)	,	0.0,			0.0,			0.0,
			0.0			,	2.0/(t-b),		0.0,			0.0,
			0.0,		,	0.0,			1.0/(zn-zf),	0.0,
			(l+r)/(l-r)	,	(t+b)/(b-t),	zn/(zn-zf),		1.0
		];
		
	}

	function MatrixScaling(scale) {
		return [
		scale, 0.0, 0.0, 0.0,
		0.0, scale, 0.0, 0.0,
		0.0, 0.0, scale, 0.0,
		0.0, 0.0, 0.0, 1.0
		];
	}
	
	function MatrixScalingAxis(scale) {
		return [
		scale[0], 0.0, 0.0, 0.0,
		0.0, scale[1], 0.0, 0.0,
		0.0, 0.0, scale[2], 0.0,
		0.0, 0.0, 0.0, 1.0
		];
	}
	
	function MatrixRotationX(angle) {
		return [
		1.0, 0.0, 0.0, 0.0,
		0.0, cos(angle), -sin(angle), 0.0,
		0.0, sin(angle), cos(angle), 0.0,
		0.0, 0.0, 0.0, 1.0
		];
	}

	function MatrixRotationY(angle) {
		return [
		cos(angle), 0.0, sin(angle), 0.0,
		0.0, 1.0, 0.0, 0.0,
		-sin(angle), 0.0, cos(angle), 0.0,
		0.0, 0.0, 0.0, 1.0
		];
	}
	
	function MatrixRotationZ(angle) {
		return [
			cos(angle), -sin(angle), 0.0, 0.0,
			sin(angle), cos(angle), 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		];
	}
	
	function MatrixTranslation(x, y, z) {
		return [
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			x  , y	, z	 , 1.0
		];
	}
	
	function MatrixRotationAxis(vec, angle) {
		var nv = Vec3Normalize(vec);
		var sangle = sin(angle);
		var cangle = cos(angle);
		var cdiff = 1-cangle;
		
		return [
			cdiff*nv[0]*nv[0]+cangle,		cdiff*nv[1]*nv[0]+sangle*nv[2], cdiff*nv[2]*nv[0]-sangle*nv[1], 0.0,
			cdiff*nv[0]*nv[1]-sangle*nv[2], cdiff*nv[1]*nv[1]+cangle,		cdiff*nv[2]*nv[1]+sangle*nv[0], 0.0,
			cdiff*nv[0]*nv[2]+sangle*nv[1], cdiff*nv[1]*nv[2]-sangle*nv[0], cdiff*nv[2]*nv[2]+cangle,		0.0,
			0.0, 0.0, 0.0, 1.0
		];
	}
	
	function MatrixInverse(matrix) {
		
	var
      a00 = matrix[0][0], a01 = matrix[0][1], a02 = matrix[0][2], a03 = matrix[0][3],
      a10 = matrix[1][0], a11 = matrix[1][1], a12 = matrix[1][2], a13 = matrix[1][3],
      a20 = matrix[2][0], a21 = matrix[2][1], a22 = matrix[2][2], a23 = matrix[2][3],
      a30 = matrix[3][0], a31 = matrix[3][1], a32 = matrix[3][2], a33 = matrix[3][3],

      b00 = a00 * a11 - a01 * a10,
      b01 = a00 * a12 - a02 * a10,
      b02 = a00 * a13 - a03 * a10,
      b03 = a01 * a12 - a02 * a11,
      b04 = a01 * a13 - a03 * a11,
      b05 = a02 * a13 - a03 * a12,
      b06 = a20 * a31 - a21 * a30,
      b07 = a20 * a32 - a22 * a30,
      b08 = a20 * a33 - a23 * a30,
      b09 = a21 * a32 - a22 * a31,
      b10 = a21 * a33 - a23 * a31,
      b11 = a22 * a33 - a23 * a32,

      det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

	return [
      (a11 * b11 - a12 * b10 + a13 * b09)/ det,
      (a02 * b10 - a01 * b11 - a03 * b09)/ det,
      (a31 * b05 - a32 * b04 + a33 * b03)/ det,
      (a22 * b04 - a21 * b05 - a23 * b03)/ det,
      (a12 * b08 - a10 * b11 - a13 * b07)/ det,
      (a00 * b11 - a02 * b08 + a03 * b07)/ det,
      (a32 * b02 - a30 * b05 - a33 * b01)/ det,
      (a20 * b05 - a22 * b02 + a23 * b01)/ det,
      (a10 * b10 - a11 * b08 + a13 * b06)/ det,
      (a01 * b08 - a00 * b10 - a03 * b06)/ det,
      (a30 * b04 - a31 * b02 + a33 * b00)/ det,
      (a21 * b02 - a20 * b04 - a23 * b00)/ det,
      (a11 * b07 - a10 * b09 - a12 * b06)/ det,
      (a00 * b09 - a01 * b07 + a02 * b06)/ det,
      (a31 * b01 - a30 * b03 - a32 * b00)/ det,
      (a20 * b03 - a21 * b01 + a22 * b00)/ det] ;
	}
	
	function MatrixViewport(dwWidth, dwHeight, dwX, dwY, dvMinZ, dvMaxZ) {
		return [
			dwWidth/2.0,	0.0,				0.0,			0.0,
			0.0,			-dwHeight/2.0,		0.0,			0.0,
			0.0,			0.0,				dvMaxZ-dvMinZ,	0.0,
			dwX+dwWidth/2.0,dwY+dwHeight/2.0,	dvMinZ,			1.0
		];
	}
	
	function MatrixViewport2(dwWidth, dwHeight, dwX, dwY, dvMinZ, dvMaxZ) {
		return [
			dwWidth/2.0,	0.0,				0.0,			0.0,
			0.0,			-dwHeight/2.0,		0.0,			0.0,
			0.0,			0.0,				dvMaxZ-dvMinZ,	0.0,
			dwX+dwWidth/2.0,dwY+dwHeight/2.0,	(dvMaxZ+dvMinZ)/2.0, 1.0
		];
	}
	
	function HFovToVFov(horizontalFov, width, height) {
		return 2*arctan(tan(horizontalFov/2.0)*height/width);
	}
	
	function VFovToHFov(verticalFov, width, height) {
		return 2*arctan(tan(verticalFov/2.0)*width/height);
	}
	
	function Vec3TransformCoord(matrix, vector) {
		var _vector = [vector[0], vector[1], vector[2], 1.0];
		var _result_vector = [0.0, 0.0, 0.0, 0.0];
		for(var i = 0; i < 4; i ++) {
			_result_vector[i] = 
			_vector[0]*matrix[0*4+i]+
			_vector[1]*matrix[1*4+i]+
			_vector[2]*matrix[2*4+i]+
			_vector[3]*matrix[3*4+i];
		}
		return [_result_vector[0], _result_vector[1], _result_vector[2]];
	}
	
	function Vec4TransformCoord(matrix, vector) {
		var _vector = [vector[0], vector[1], vector[2], vector[3]];
		var _result_vector = [0.0, 0.0, 0.0, 0.0];
		for(var i = 0; i < 4; i ++) {
			_result_vector[i] = 
			_vector[0]*matrix[0*4+i]+
			_vector[1]*matrix[1*4+i]+
			_vector[2]*matrix[2*4+i]+
			_vector[3]*matrix[3*4+i];
		}
		return [_result_vector[0], _result_vector[1], _result_vector[2], _result_vector[3]];
	}
}

gMath3D = new Math3D();

