'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }

    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
    }

    async submitTransaction() {
        const randomId = Math.floor(Math.random()*this.roundArguments.randomSeed);
        const myArgs = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'invoke',
            invokerIdentity: this.roundArguments.userID,
            contractArguments: ['put', `${this.workerIndex}_${this.roundIndex}_${randomId}`, `${this.workerIndex}_${randomId}_${randomId}`],
            readOnly: false
        };

        await this.sutAdapter.sendRequests(myArgs);
    }

    async cleanupWorkloadModule() {
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;
