
// create random TBN matrix.
// transform by cross products 
// check that this is equivalent to invert and transpose ?


function rand3vec(){
    return [1,1,1].map(Math.random);
}

function randTbn(){
    return [1,1,1].map(rand3vec);
}

function crossProd(vecA, vecB){
    return [
        vecA[1]*vecB[2] - vecA[2]*vecB[1],
        vecA[2]*vecB[0] - vecA[0]*vecB[2],
        vecA[0]*vecB[1] - vecA[1]*vecB[0]
    ];  
}

function multiply3Mats(matA, matB){
    var outputMat = [];
    for (var ii=0;ii<3;ii++){
        var row = [];
        for (var jj=0;jj<3;jj++){
            var sum = 0;
            for (var kk=0;kk<3;kk++){
                sum += matA[ii][kk] * matB[kk][jj]; 
            }
            row.push(sum);
        }
        outputMat.push(row);
    }
    return outputMat;
}


function multiply3MatsTransposed(matA, matB){   //like above but matB transposed
    var outputMat = [];
    for (var ii=0;ii<3;ii++){
        var row = [];
        for (var jj=0;jj<3;jj++){
            var sum = 0;
            for (var kk=0;kk<3;kk++){
                sum += matA[ii][kk] * matB[jj][kk]; 
            }
            row.push(sum);
        }
        outputMat.push(row);
    }
    return outputMat;
}


function crossProdsForTbn(tbn){
    var inputT = tbn[0];
    var inputB = tbn[1];
    var inputN = tbn[2];
    
    var newT = crossProd(inputB, inputN);
    var newB = crossProd(inputN, inputT);
    var newN = crossProd(inputT, inputB);

    return [newT,newB,newN];
}


var tbn = randTbn();
var crossProds = crossProdsForTbn(tbn);
var multiplied = multiply3Mats(tbn, crossProds);
var multipliedWithTranspose = multiply3MatsTransposed(tbn, crossProds);

console.log({
    tbn,
    crossProds,
    multiplied,
    multipliedWithTranspose
});

// does seem like mult with transpose is ~diagonal (constant * identity)




