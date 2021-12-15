# 4US Dashboard

## Dependencies
These instructions require [npm](https://nodejs.org/en/) to be installed on local.

## Install
Build web dependencies

```npm install```

Install elm app runner and SCSS preprocessor.

```npm install node-sass-chokidar create-elm-app -g```

## Start Developing

Run elm app

```elm-app start```

Run SCSS file watch

```npm run watch-css```


## Deploy
```make clean deploy```

## Testing

Make a Cypress Env Config file inside the root directory to store your Cognito credentials

```touch cypress.env.json```

Afterwards provide the following JSON for the test suite to run

```
{
  "cognito_email": "email@schweitzerlabs.com",
  "cognito_password": "password"
}
```

Finally run the test suite

```npm run test```


