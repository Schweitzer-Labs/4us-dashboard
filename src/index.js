import "./main.css";
import { Elm } from "./Main.elm";
import { verifyEmail } from "./js/email-validator";
import { verifyPhone } from "./js/phone";
import { Auth } from "@aws-amplify/auth";
import Recaptcha from "./js/components/recaptcha";

const storageKey = "token";

const cognitoDomain = process.env.ELM_APP_COGNITO_DOMAIN;
const cognitoClientId = process.env.ELM_APP_COGNITO_CLIENT_ID;
const cognitoUserPoolId = process.env.ELM_APP_COGNITO_USER_POOL_ID;
const redirectUri = window.location.origin;
const donorUrl = process.env.ELM_APP_DONOR_URL;
const apiEndpoint = process.env.ELM_APP_API_ENDPOINT;
const environment = process.env.ELM_APP_ENV;

Auth.configure({
  userPoolId: cognitoUserPoolId,
  userPoolWebClientId: cognitoClientId,
});

function runApp() {
  window.customElements.define("g-recaptcha", Recaptcha);
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
      environment,
    },
  });

  app.ports.sendEmail.subscribe((email) => {
    app.ports.isValidEmailReceiver.send(verifyEmail(email));
  });
  app.ports.sendPhone.subscribe((phoneNum) => {
    app.ports.isValidNumReceiver.send(verifyPhone(phoneNum).isValid);
  });

  app.ports.sendCredsForLogIn.subscribe(({ email, password }) => {
    Auth.signIn({
      username: email,
      password: password,
    })
      .then((res) => {
        const token = res.getSignInUserSession().getIdToken().getJwtToken();

        localStorage.setItem(storageKey, token);
        setTimeout(() => {
          app.ports.loginSuccessful.send(token);
        }, 1000);
      })
      .catch((err) => {
        app.ports.loginFailed.send(err.message);
      });
  });
}

runApp();
