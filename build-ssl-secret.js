'use strict';

const fs = require('fs');

const args = process.argv.slice(2);
const secretName = args[0];
const certFileName = args[1];
const keyFileName = args[2];

if (!secretName || !certFileName || !keyFileName) {
  console.error('Usage: node build-ssl-secret secret_name path_to_cert_file path_to_key_file');
  throw new Error('Incorrect usage')
}

const secret = {
  kind: 'Secret',
  apiVersion: 'v1',
  metadata: {
    name: secretName
  },
  data: {
    [`${secretName}.crt`]: fs.readFileSync(certFileName).toString('base64'),
    [`${secretName}.key`]: fs.readFileSync(keyFileName).toString('base64')
  }
}

fs.writeFileSync(`${secretName}-secret.json`, JSON.stringify(secret));
