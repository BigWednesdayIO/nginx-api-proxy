'use strict';

const fs = require('fs');

const args = process.argv.slice(2);
const certsDirectory = args[0];
const secretName = 'ssl-certificates';

if (!certsDirectory) {
  console.error('Usage: node build-ssl-secret certs_directory');
  throw new Error('Incorrect usage');
}
else {
  console.log(`Building ${secretName} secret from directory ${certsDirectory}`);
}

const secret = {
  kind: 'Secret',
  apiVersion: 'v1',
  metadata: {
    name: secretName
  },
  data: {}
}

secret.data['starbigwednesdayio.crt'] = fs.readFileSync(`${certsDirectory}/starbigwednesdayio.crt`).toString('base64');
secret.data['starbigwednesdayio.key'] = fs.readFileSync(`${certsDirectory}/starbigwednesdayio.key`).toString('base64');
secret.data['starorderableco.crt'] = fs.readFileSync(`${certsDirectory}/starorderableco.crt`).toString('base64');
secret.data['starorderableco.key'] = fs.readFileSync(`${certsDirectory}/starorderableco.key`).toString('base64');

fs.writeFileSync(`${secretName}-secret.json`, JSON.stringify(secret));
