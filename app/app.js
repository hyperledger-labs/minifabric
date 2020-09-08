'use strict';

module.exports.info  = 'Template callback';

const contractID = 'samplecc';
const version = '0.0.1';

let bc, ctx, clientArgs, clientIdx;

module.exports.init = async function(blockchain, context, args) {
    bc = blockchain;
    ctx = context;
    clientArgs = args;
    clientIdx = context.clientIdx.toString();
    for (let i=0; i<clientArgs.assets; i++) {
        try {
            const assetID = `${clientIdx}_${i}`;
            console.log(`Client ${clientIdx}: Creating asset ${assetID}`);
            const myArgs = {
                chaincodeFunction: 'createCar',
                invokerIdentity: 'Admin@org1.example.com',
                chaincodeArguments: [assetID,'blue','ford','fiesta','Jamie']
            };
            await bc.bcObj.invokeSmartContract(ctx, contractID, version, myArgs);
        } catch (error) {
            console.log(`Client ${clientIdx}: Smart Contract threw with error: ${error}` );
        }
    }
};

module.exports.run = function() {
    const randomId = Math.floor(Math.random()*clientArgs.assets);
    const myArgs = {
        chaincodeFunction: 'queryCar',
        invokerIdentity: 'Admin@org1.example.com',
        chaincodeArguments: [`${clientIdx}_${randomId}`]
    };
    return bc.bcObj.querySmartContract(ctx, contractID, version, myArgs);
};

module.exports.end = async function() {
};
