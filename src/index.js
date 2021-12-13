import "./main.css";
import { Elm } from "./Main.elm";
import { verifyEmail } from "./js/email-validator";
import { verifyPhone } from "./js/phone";
import { Auth } from "@aws-amplify/auth";

const storageKey = "token";

const cognitoDomain = process.env.ELM_APP_COGNITO_DOMAIN;
const cognitoClientId = process.env.ELM_APP_COGNITO_CLIENT_ID;
const cognitoUserPoolId = process.env.ELM_APP_COGNITO_CLIENT_ID;
const redirectUri = window.location.origin;
const donorUrl = process.env.ELM_APP_DONOR_URL;
const apiEndpoint = process.env.ELM_APP_API_ENDPOINT;

Auth.configure({
  userPoolId: "us-west-2_9XWswzIhi",
  userPoolWebClientId: cognitoClientId,
});

function runApp() {
  const token = localStorage.getItem(storageKey);
  const app = Elm.Main.init({
    node: document.getElementById("root"),
    flags: {
      token,
      cognitoDomain,
      cognitoClientId,
      redirectUri,
      donorUrl,
      apiEndpoint,
    },
  });
  app.ports.sendEmail.subscribe((email) => {
    app.ports.isValidEmailReceiver.send(verifyEmail(email));
  });
  app.ports.sendPhone.subscribe((phoneNum) => {
    app.ports.isValidNumReceiver.send(verifyPhone(phoneNum).isValid);
  });

  app.ports.sendCredsForLogIn.subscribe(({ email, password }) => {
    console.log(email);
    console.log(password);
    Auth.signIn({
      username: email,
      password: password,
    })
      .then((res) => {
        const token = res.getSignInUserSession().getIdToken().getJwtToken();
        console.log(token);
        // res.user.
        app.ports.loginSuccessful.send(token);
      })
      .catch((err) => {
        app.ports.loginFailed.send(err.message);
      });
  });

  // Auth.signIn({
  //   username: "dev.evanpiro@gmail.com",
  //   password: "Guid12321!12!",
  // }).then((res) => {
  //   console.log("success");
  //   console.log(res);
  // });

  // app.ports.putTokenInLocalStorage.subscribe((token) => {
  //   localStorage.setItem(storageKey, token);
  //   app.ports.tokenHasBeenSet.send("ok");
  // });
}

runApp();
