const AWS = require("aws-sdk");
const fs = require("fs");
const path = require("path");

const config = {
    s3BucketName: 'carolgilabert-object-finder-frontend',
    folderPath: 'frontend/public'
};

const s3 = new AWS.S3({ signatureVersion: 'v4' });
const distFolderPath = path.join(__dirname, config.folderPath);

const deleteObject = (deleteParams) => {
    s3.deleteObject(deleteParams, function (err, data) {
        if (err) {
            console.log("delete err " + deleteParams.Key);
        } else {
            console.log("deleted " + deleteParams.Key);
        }
    });
};

const emptyBucket = () => {
    s3.listObjects({ Bucket: config.s3BucketName }, function (err, data) {
        if (err) {
            console.log("error listing bucket objects " + err);
            return;
        }
        var items = data.Contents;
        for (var i = 0; i < items.length; i += 1) {
            var deleteParams = { Bucket: config.s3BucketName, Key: items[i].Key };
            deleteObject(deleteParams);
        }
    });
};

const getFileContentType = (extension) => ({
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.css': 'text/css',
    '.webmanifest': 'text/plain',
    '.map': 'text/plain',
    '.html': 'text/html',
    '.png': 'image/png'
}[extension] || 'text/plain');

const uploadFiles = (folderPath, prefix) => {
    fs.readdir(folderPath, (err, files) => {
        if (err) { throw err; }

        if (!files || files.length === 0) {
            console.log(`provided folder '${distFolderPath}' is empty or does not exist.`);
            console.log('Make sure your project was compiled!');
            return;
        }

        for (const fileName of files) {

            const filePath = path.join(folderPath, fileName);

            if (fs.lstatSync(filePath).isDirectory()) {
                uploadFiles(filePath, prefix + '/' + fileName);
                continue;
            }

            fs.readFile(filePath, (error, fileContent) => {
                if (error) { throw error; }

                const s3Key = prefix ? `${prefix.substr(1)}/${fileName}` : fileName;

                s3.putObject({
                    Bucket: config.s3BucketName,
                    Key: s3Key,
                    Body: fileContent,
                    ContentType: getFileContentType(path.extname(fileName))
                }, (err, data) => {

                    console.log(`Uploading '${fileName}'!`);
                    console.log(err, data);

                });

            });
        }
    });
};

emptyBucket();
uploadFiles(distFolderPath, '');
console.log('Uploaded! :)');

