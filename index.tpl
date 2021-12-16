
var AWS = require('aws-sdk');

function putObjectToS3(bucket, key, data) {

  var config = {
    accessKeyId: "",
    secretAccessKey: "",
    endpoint: "http://${HOST_IP_ADDRESS}:4566",
    sslEnabled: false,
    signatureVersion: 'v4',
    s3ForcePathStyle: true
  };

  AWS.config.update(config);

  var s3 = new AWS.S3();

  var params = {
      Bucket : bucket,
      Key : key,
      Body : data
  }

  s3.putObject(params, function(err, data) {
    if (err)
      console.log(err)
    else   
      console.log("Successfully uploaded data to " + bucket + "/" + key);
  });

}

exports.handler = function() {
  putObjectToS3("mybucket","file.txt","Hello from Localstack!!");
}

