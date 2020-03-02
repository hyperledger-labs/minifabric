{"number":.header.number,
 "block_hash": $CBHASH,
 "data_hash":.header.data_hash,
 "previous_hash":.header.previous_hash,
 "txs": [.data.data[].payload]|[ .[]|
   {"tx_id":.header.channel_header.tx_id,
    "chaincode_id":.data.actions[0].payload.chaincode_proposal_payload.input.chaincode_spec.chaincode_id.name,
    "args":.data.actions[0].payload.chaincode_proposal_payload.input.chaincode_spec.input.args }]}