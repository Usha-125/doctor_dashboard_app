// seedPatients.js
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

function resolveServiceAccountPath() {
  // 1) If env var set, use it
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return process.env.GOOGLE_APPLICATION_CREDENTIALS;
  }

  // 2) Otherwise, look for serviceAccountKey.json next to this script
  return path.join(__dirname, 'serviceAccountKey.json');
}

const serviceAccountPath = resolveServiceAccountPath();

if (!fs.existsSync(serviceAccountPath)) {
  console.error('ERROR: service account JSON not found.');
  console.error(`Tried path: ${serviceAccountPath}`);
  console.error('Fixes:');
  console.error('- Place your serviceAccountKey.json in the same folder as seedPatients.js');
  console.error('- OR set the environment variable GOOGLE_APPLICATION_CREDENTIALS to the absolute path of the JSON file');
  console.error('Example (Windows PowerShell): $env:GOOGLE_APPLICATION_CREDENTIALS="C:\\full\\path\\serviceAccountKey.json"');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seed() {
  const patients = [
    { name: 'Asha Kumar', age: 34 },
    { name: 'Ravi Patel', age: 42 },
    { name: 'Meera Das', age: 28 },
    { name: 'Suresh Nair', age: 55 },
    { name: 'Priya Menon', age: 19 },
  ];

  const batch = db.batch();
  const coll = db.collection('patients');

  patients.forEach(p => {
    const ref = coll.doc();
    batch.set(ref, { ...p, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  });

  await batch.commit();
  console.log('Seeded patients');
  process.exit(0);
}

seed().catch(err => {
  console.error('Seeding failed:', err);
  process.exit(1);
});
