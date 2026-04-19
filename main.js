
var shaderPrograms={};
var cubeBuffers={};

var cameraMat = mat4.identity();


var mvMatrix = mat4.create();
var mMatrix = mat4.create();
var pMatrix = mat4.create();


var testCubePosition = [0,-2,-6];    //[0,0,2] with vFov 90 degrees makes cube fill view

var mouseInfo = {
	x:0,
	y:0,
	pendingMovement:[0,0],
};

var pointerLocked=false;


function init(){

    //escape escapes pointer lock and exit fullscreen
	// - browsers seem to have this already, but electron apparently doesn't!
	//todo also cancel the logic that does a 1s delayed pointer lock on pressing F to fullscreen!
	document.addEventListener('keydown', function(event) {
	  if (event.key === 'Escape' || event.code === 'Escape') {
		console.log('Escape key was pressed!!');
		document.exitPointerLock();
		if (window.electronAPI){
			console.log("exiting fullscreen");
			window.electronAPI.exitFullscreen();
		}
	  }
	});
	
	window.addEventListener("keydown",function(evt){
		//console.log("key pressed : " + evt);
		var willPreventDefault=true;

		//number key to select special weapon
		var n = parseInt(evt.key);
		if (!isNaN(n)){
			console.log("number entered: " + n);
		}else{
			switch (evt.keyCode){	
				case 70:	//F
					goFullscreen(canvascontainer);
					break;
				default:
                    //console.log(evt.keyCode);
					willPreventDefault=false;
					break;
			}
		}
		if (willPreventDefault){evt.preventDefault()};
	});

	canvas = document.getElementById("bottom-canvas");
	canvascontainer = document.getElementById("canvas-container");

    overlaycanvas = document.getElementById("top-canvas");
    overlaycanvas.width = 1280;
    overlaycanvas.height = 720;
    overlaycontext = overlaycanvas.getContext("2d");

	document.addEventListener('pointerlockchange', function lockChangeCb() {
	  if (document.pointerLockElement === canvascontainer ) {
			console.log('The pointer lock status is now locked');
			pointerLocked=true;
		} else {
			console.log('The pointer lock status is now unlocked');  
			pointerLocked=false;
	  }
	}, false);

    canvascontainer.addEventListener("mousemove", function(evt){
		if (pointerLocked){
			mouseInfo.pendingMovement[0]+=-0.001* evt.movementX;	//TODO screen resolution dependent sensitivity.
			mouseInfo.pendingMovement[1]+=-0.001* evt.movementY;
		}
	});
    canvascontainer.addEventListener("mousedown", function(evt){
		mouseInfo.buttons = evt.buttons;
		evt.preventDefault();
        //return false;
	});
	canvascontainer.addEventListener("mouseup", function(evt){
		mouseInfo.buttons = evt.buttons;
	});
	canvascontainer.addEventListener("mouseout", function(evt){
		mouseInfo.buttons = 0;
	});


    initGL();
    initShaders(shaderPrograms);initShaders=null;
    initTextures();

    initBuffers();
	getLocationsForShadersUsingPromises(
		()=>{
			requestAnimationFrame(drawScene);	//in callback because need to wait until shaders loaded
		}
	);

    gl.enable(gl.DEPTH_TEST);
	gl.enable(gl.CULL_FACE);

    gl.depthFunc(gl.LEQUAL);    //if don't do this on linux brave, can't see background, though it is in range! seems like precision of depth buffer is less.

    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
}

function initTextures(){
}


function initBuffers(){
    loadBufferData(cubeBuffers, levelCubeData);
}


var bind2dTextureIfRequired = (function createBind2dTextureIfRequiredFunction(){
	var currentlyBoundTextures=[];
	var currentBoundTex;
	return function(texToBind, texId = gl.TEXTURE0){	//TODO use different texture indices to keep textures loaded?
								//curently just assuming using tex 0, already set as active texture (is set active texture a fast gl call?)
		
		//workaround wierd bug
		// if (texId == gl.TEXTURE3){
		// 	currentlyBoundTextures[texId] = null;
		// }

		currentBoundTex = currentlyBoundTextures[texId];	//note that ids typically high numbers. gl.TEXTURE0 and so on. seem to be consecutive numbers but don't know if guaranteed.
		
		//if (texToBind != currentBoundTex){
		if (true){
			gl.activeTexture(texId);
			gl.bindTexture(gl.TEXTURE_2D, texToBind);
			currentlyBoundTextures[texId] = texToBind;
		}
	}
})();

function texImage2DWithLogs(mssg, target, level, internalformat, width, height, border, format, type, offsetOrSource){
	console.log({"mssg":"called texImage2D "+mssg, "parameters":{target, level, internalformat, width, height, border, format, type, offsetOrSource}});
	gl.texImage2D(target, level, internalformat, width, height, border, format, type, offsetOrSource);
}

function drawObjectFromBuffers(bufferObj, shaderProg){
	prepBuffersForDrawing(bufferObj, shaderProg);
	drawObjectFromPreppedBuffers(bufferObj, shaderProg);
}
function prepBuffersForDrawing(bufferObj, shaderProg){

	gl.bindBuffer(gl.ARRAY_BUFFER, bufferObj.vertexPositionBuffer);

    if (shaderProg.attributes.aVertexColor){
		//assume vertex coloured object has 3 pos, 3 colour (expect vertexPositionBuffer.itemSize = 6)
		//TODO use byte for colour instead of float?
		var iSize = bufferObj.vertexPositionBuffer.itemSize;
		var numColors = iSize - 3;
		gl.vertexAttribPointer(shaderProg.attributes.aVertexPosition, 3, gl.FLOAT, false, 4*iSize, 0);
		gl.vertexAttribPointer(shaderProg.attributes.aVertexColor, numColors, gl.FLOAT, false, 4*iSize, 4*3);
	}else{
		//assume want to skip over colour if present.
		var iSize = bufferObj.vertexPositionBuffer.itemSize;
		gl.vertexAttribPointer(shaderProg.attributes.aVertexPosition, 3, gl.FLOAT, false, 4*iSize, 0);
	}

    if (bufferObj.vertexNormalBuffer && shaderProg.attributes.aVertexNormal){
        gl.bindBuffer(gl.ARRAY_BUFFER, bufferObj.vertexNormalBuffer);
        gl.vertexAttribPointer(shaderProg.attributes.aVertexNormal, bufferObj.vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);
    }

	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, bufferObj.vertexIndexBuffer);
	
	if (bufferObj.vertexTextureCoordBuffer && shaderProg.uniforms.uSampler){    
		gl.bindBuffer(gl.ARRAY_BUFFER, bufferObj.vertexTextureCoordBuffer);
		gl.vertexAttribPointer(shaderProg.attributes.aTextureCoord, bufferObj.vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);
    }
    if (shaderProg.uniforms.uSampler){
		gl.activeTexture(gl.TEXTURE0);
		gl.uniform1i(shaderProg.uniforms.uSampler, 0);
	}
    if (bufferObj.vertexTextureCoordBuffer && shaderProg.uniforms.uSampler2){    
		gl.activeTexture(gl.TEXTURE1);
		gl.uniform1i(shaderProg.uniforms.uSampler2, 1);
	}

    if (shaderProg.uniforms.uPMatrix){
	    gl.uniformMatrix4fv(shaderProg.uniforms.uPMatrix, false, pMatrix);
    }

    if (shaderProg.uniforms.uSamplerCube){
		gl.activeTexture(gl.TEXTURE4);
		gl.uniform1i(shaderProg.uniforms.uSamplerCube, 4);	//??
		gl.bindTexture(gl.TEXTURE_CUBE_MAP, cubemapTexture);
		//bind2dTextureIfRequired(cubemapTexture, gl.TEXTURE_CUBE_MAP);
	}

    if (shaderProg.uniforms.uSamplerCubeFisheye){
        gl.activeTexture(gl.TEXTURE1);
        gl.uniform1i(shaderProg.uniforms.uSamplerCubeFisheye, 1);
        gl.bindTexture(gl.TEXTURE_CUBE_MAP, cubemapView.cubemapTexture);
//        		gl.bindTexture(gl.TEXTURE_CUBE_MAP, cubemapTexture);

    }

}
function drawObjectFromPreppedBuffers(bufferObj, shaderProg){
    if (shaderProg.uniforms.uMVMatrix){
	    gl.uniformMatrix4fv(shaderProg.uniforms.uMVMatrix, false, mvMatrix);
    }else if (shaderProg.uniforms.uMMatrix){
        gl.uniformMatrix4fv(shaderProg.uniforms.uMMatrix, false, mMatrix);
        gl.uniformMatrix4fv(shaderProg.uniforms.uVMatrix, false, cameraMat);  //TODO set less frequently
    }
	gl.drawElements(gl.TRIANGLES, bufferObj.vertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
}

var enableDisableAttributes = (function generateEnableDisableAttributesFunc(){
	
	var maxNum = 16;
	var isEnabled = new Array(maxNum);
	var shouldBeEnabled = new Array(maxNum);

	for (var ii=0;ii<maxNum;ii++){
		isEnabled[ii] = false;
	}

	var swapArr;

	return function(shaderProg){
		//in webgl2, seems attributes don't necessarily take numbers from 0 to shaderProg.numActiveAttribs - 1
		
		for (var ii=0;ii<maxNum;ii++){
			shouldBeEnabled[ii] = false;
		}
		for (var attr of Object.values(shaderProg.attributes)){
			shouldBeEnabled[attr] = true;
		}

		for (var ii=0;ii<maxNum;ii++){
			if (shouldBeEnabled[ii]){
			//	if (!isEnabled[ii]){
					gl.enableVertexAttribArray(ii);
			//	}
			}else{
			//	if (isEnabled[ii]){
					gl.disableVertexAttribArray(ii);
			//	}
			}
		}

		swapArr = isEnabled;
		isEnabled = shouldBeEnabled;
		shouldBeEnabled = swapArr;	//now contains junk, but avoids memory churn
	};
})();


var camParams = {
    near:0.1,
    far:20000
};



function drawScene(frameTime){
	requestAnimationFrame(drawScene);
    

    gl.clearColor(0,1,1,1); //cyan

    gl.disable(gl.BLEND);
	gl.enable(gl.DEPTH_TEST);

    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    var vFov = 90;   //degrees!!!
    mat4.perspective(vFov, gl.viewportWidth/ gl.viewportHeight, camParams.near, camParams.far, pMatrix); 

    var activeProg = shaderPrograms.flat;
    gl.useProgram(activeProg);
    enableDisableAttributes(activeProg);

    setupDrawMatrixForObjectAtPosition(testCubePosition);

    gl.uniform3fv(activeProg.uniforms.uFlatColor, [0.25,0.25,0.25]);

    drawObjectFromBuffers(cubeBuffers, activeProg);
}

function setupDrawMatrixForObjectAtPosition(objPos){
    mat4.identity(mMatrix);
    mat4.translate(mMatrix, objPos);
}