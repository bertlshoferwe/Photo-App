const awsmobile = {
    Auth: {
      region: "us-east-1", // Change to your region
      userPoolId: "<COGNITO_USER_POOL_ID>",
      userPoolWebClientId: "<COGNITO_APP_CLIENT_ID>",
    },
    Storage: {
      bucket: "<S3_BUCKET_NAME>",
      region: "us-east-1", // Change to your region
    },
    API: {
      endpoints: [
        {
          name: "PhotoAPI",
          endpoint: "https://xyz123.execute-api.us-east-1.amazonaws.com",
        },
      ],
    },
  };
  
  export default awsmobile;