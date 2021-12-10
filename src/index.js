import "./main.css";
import { Elm } from "./Main.elm";
import { verifyEmail } from "./js/email-validator";
import { verifyPhone } from "./js/phone";

const storageKey = "token";

const cognitoDomain = process.env.ELM_APP_COGNITO_DOMAIN;
const cognitoClientId = process.env.ELM_APP_COGNITO_CLIENT_ID;
const redirectUri = window.location.origin;
const donorUrl = process.env.ELM_APP_DONOR_URL;
const apiEndpoint = process.env.ELM_APP_API_ENDPOINT;

console.log("cognito domain", cognitoDomain);

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

  app.ports.putTokenInLocalStorage.subscribe((token) => {
    localStorage.setItem(storageKey, token);
    app.ports.tokenHasBeenSet.send("ok");
  });
}

runApp();
