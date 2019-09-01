'use strict';

const AWS = require('aws-sdk');
const KMS = new AWS.KMS();

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

    const tasks = keys.map(item => KMS.decrypt({CiphertextBlob: Buffer.from(map[item], 'base64')}).promise()
        .then(result => map[item] = result.Plaintext.toString('utf-8'))
        .catch(err => {
            console.error(`Error during decryption of secret ${item}`, err);
            map[item] = null;
        }));

    Promise.all(tasks)
        .then(results => callback(null, map))
        .catch(err => {
            console.log('Could not resolve any decryption task for any of ' + keys.join(', '), err);
            callback(err, null);
        });
};
