//test reflection from a surface with some distribution of normals, see how size of spot depends on angle of incidence.


function getSpotSize(angleOfIncidence, roughness){
    //angle of incidence 0=head on, PI/2 = 90deg = grazing

    var cos = Math.cos;
    var sin = Math.sin;

    var toViewer = [Math.sin(angleOfIncidence), 0, Math.cos(angleOfIncidence) ];

    var minVertAng = 10000;
    var maxVertAng = -10000;
    var minHorizAng = 10000;
    var maxHorizAng = -10000;
    
    for (var ii=0;ii<360;ii+=0.05){
        //quick and brainless just draw a circle
        var ang = Math.PI*ii/180;
        var normal = [cos(ang)*sin(roughness), sin(ang)*sin(roughness), cos(roughness)];
        var reflected = reflect(toViewer, normal);
        //calculate angles
        var vertAng = Math.atan2(reflected[0],reflected[2]);
        var horizAng = Math.asin(reflected[1]);
        minVertAng = Math.min(minVertAng, vertAng);
        maxVertAng = Math.max(maxVertAng, vertAng);
        minHorizAng = Math.min(minHorizAng, horizAng);
        maxHorizAng = Math.max(maxHorizAng, horizAng);
    }

    return [maxVertAng-minVertAng, maxHorizAng-minHorizAng];

    function reflect(toViewer, normal){
        var dotProd = toViewer[0]*normal[0] + toViewer[1]*normal[1] + toViewer[2]*normal[2];
        var reflected = [];
        for (var ii=0;ii<3;ii++){
            reflected.push(-toViewer[ii] + 2*dotProd*normal[ii]);
        }
        return reflected;
    }
}

for (var ang=0;ang<=90;ang+=15){
    var angRads = ang*Math.PI/180;

    var spotSize = getSpotSize(angRads, 0.001);
    console.log(ang, spotSize, spotSize[1]/spotSize[0] , Math.cos(angRads));

    //observe that "vertical" spot size is constant, and "horizontal" spot size is proportional to angle of incidence.
}