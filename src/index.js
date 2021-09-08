import './main.css';
import { Elm } from './Main.elm';
import {verifyEmail} from "./js/email-validator";
import {verifyPhone} from "./js/phone";

const storageKey = 'token'

const cognitoDomain = process.env.ELM_APP_COGNITO_DOMAIN
const cognitoClientId = process.env.ELM_APP_COGNITO_CLIENT_ID
const redirectUri = window.location.origin
const donorUrl = process.env.ELM_APP_DONOR_URL
const apiEndpoint = process.env.ELM_APP_API_ENDPOINT

const getTokenFromUrl = (url) => {
  const firstTrim = url.split('id_token=')
  if (firstTrim.length > 1) {
    return firstTrim[1].split('&')[0]
  } else {
    throw new Error('token from url not found')
  }
}

const getCommitteeIdFromUrlRedirect = (url) => {
  const firstTrim = url.split('state=')
  if (firstTrim.length > 1) {
    return firstTrim[1].split('&')[0]
  } else {
    throw new Error('token from url not found')
  }
}

const getCommitteeIdFromUrlQueryString = (url) => {
  const firstTrim = url.split('/committee/')
  if (firstTrim.length > 1) {
    const secondTrim = firstTrim[1].split('/')
    if (firstTrim.length > 0) {
      return secondTrim[0]
    } else {
      throw new Error('committeeId from url not found.')
    }
  } else {
    throw new Error('committeeId from url not found.')
  }
}

function runApp() {
  let token;
  let committeeId;
  const host = window.location
  try {
    token = getTokenFromUrl(host.href)
    committeeId = getCommitteeIdFromUrlRedirect(host.href)
    localStorage.setItem(storageKey, token)
    window.location = `${host.origin}/committee/${committeeId}`
  } catch (e) {
    token = localStorage.getItem(storageKey)
    committeeId = getCommitteeIdFromUrlQueryString(host.href)
    if (token) {
    const app =  Elm.Main.init({
        node: document.getElementById('root'),
        flags: {
          token,
          cognitoDomain,
          cognitoClientId,
          redirectUri,
          donorUrl,
          apiEndpoint
        }
      });
    app.ports.sendEmail.subscribe((email)=> {
      app.ports.isValidEmailReceiver.send(verifyEmail(email))
    })
    app.ports.sendPhone.subscribe((phoneNum) => {
      app.ports.isValidNumReceiver.send(verifyPhone(phoneNum).isValid)
    })
    } else {
      window.location =
        `${cognitoDomain}/login?client_id=${cognitoClientId}&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=${host.origin}&state=${committeeId}`
    }
  }
}

runApp();



