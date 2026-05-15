// want to save rough specular reflections of sphereical lights - like sun in sky.
// suspect something like tanh(r+const)-tanh(r-const) should work reasonably, where const = unblurred circle radius, adjust this for different blur amount eg
// tanh(bluramount*(r+const))-tanh(bluramount(r-const))
// trying this in desmos looks ok for 1d, and can show that integral conserves something...
// would like to check whether 2d integral appears reasonable...

function calcBlurredVal(ringrad, bluramount, circlerad){
    var sharpness = 1/bluramount;
    return Math.tanh(sharpness*(ringrad + circlerad)) - Math.tanh(sharpness*(ringrad - circlerad));
}

for (var bluramount = 0.07; bluramount<15; bluramount*=1.2){

    var guessedCorrectiveFactor = Math.exp(-0.5*bluramount);    //seems fairly consistent result after correction

    //calculate integral from 0 to large number for rings.
    var total=0;
    for (var ringrad=0.01;ringrad<10;ringrad+=0.01){
        total+=ringrad*calcBlurredVal(ringrad, bluramount, 1);
    }

    //another option - adjust radius of circle
    var total2=0;
    for (var ringrad=0.01;ringrad<10;ringrad+=0.01){
        var adjustedCircleRad = 1/(1+0.5*bluramount);   //guess. seems to get reasonable results. might wish to choose different const depending on range of blur amounts care about (eg if using different approximation for high blur)
        total2+=ringrad*calcBlurredVal(ringrad, bluramount, adjustedCircleRad);
    }

    console.log({
        bluramount,
        //total,
        //corrected:total*guessedCorrectiveFactor,
        total2
    });
}

//seems reasonable - integral goes up with blur since spreads cross section wider.
// TODO analytic corrective factor?