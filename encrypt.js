'use strict';

const AWS = require('aws-sdk');
const KMS = new AWS.KMS();
const kmsKeyId = process.env.KMS_KEY_ARN;

exports.handler = (event, context, callback) => {
    const map = (event.value ? { result: event.value } : event.map) || {};
    const keys = Object.keys(map || {});

    if (event.list) {
        event.list.forEach(item => {
            const key = Object.keys(item).pop();
            map[key] = item[key];
            keys.push(key);
        });
    }

    if (!map || !keys.length) {
        callback(null, {});
        return;
    }

    const tasks = keys.map(item => KMS.encrypt({Plaintext: map[item], KeyId: kmsKeyId}).promise()
        .then(result => map[item] = result.CiphertextBlob.toString('base64'))
        .catch(err => {
            console.error(`Error during encryption of secret ${item}`, err);
            map[item] = null;
        }));

    Promise.all(tasks)
        .then(results => callback(null, map))
        .catch(err => {
            console.log('Could not resolve any encryption task for any of ' + keys.join(', '), err);
            callback(err, null);
        });
};
