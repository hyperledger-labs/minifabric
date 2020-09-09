'use strict';

module.exports.info  = 'Template callback';

const contractID = 'samplecc';
const version = '1.0';

let bc, ctx, clientArgs, clientIdx;

module.exports.init = async function(blockchain, context, args) {
    bc = blockchain;
    ctx = context;
    clientArgs = args;
    clientIdx = context.clientIdx.toString();
};

module.exports.run = function() {
    const randomId = Math.floor(Math.random()*clientArgs.assets);
    const myArgs = {
        chaincodeFunction: 'invoke',
        invokerIdentity: 'Admin@org0.example.com',
        chaincodeArguments: ['put', `${clientIdx}_${randomId}`, `${clientIdx}_${randomId}`]
    };
    return bc.bcObj.invokeSmartContract(ctx, contractID, version, myArgs);
};

module.exports.end = async function() {
};
