const S3 = require ('aws-sdk/clients/s3');
const s3Instance = new S3 ();

const listDirectories = params => {
    return new Promise ((resolve, reject) => {
      const s3params = {
        Bucket: 'carolgilabert-object-finder-store',
        MaxKeys: 20,
        Delimiter: '/',
      };
      s3Instance.listObjectsV2 (s3params, (err, data) => {
        if (err) {
          reject (err);
        }
        resolve (data);
      });
    });
  };

exports.handler = async (event) => {

    const objects = await listDirectories();

    // TODO implement
    const response = {
        statusCode: 200,
        statusDescription: '200 OK',
        isBase64Encoded: false,
        headers: {
          "Content-Type": "text/json; charset=utf-8"
        },
        body: JSON.stringify(objects),
    };

    return response;
};
