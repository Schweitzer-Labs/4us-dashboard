import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const userPoolAppClientId = "5edttkv3teplb003a5ljhqe4lv"
const userPoolUrl = "https://4us-demo-committee-api-user.auth.us-east-1.amazoncognito.com"

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
  const firstTrim = url.split('?committeeId=')
  if (firstTrim.length > 1) {
    return firstTrim[1]
  } else {
    throw new Error('committeeId from url not found.')
  }
}

async function runApp() {
  let token;
  let committeeId;
  const host = window.location
  try {
    token = getTokenFromUrl(host.href)
    committeeId = getCommitteeIdFromUrlRedirect(host.href)
    localStorage.setItem('token', token)
    window.location = `${host.origin}?committeeId=${committeeId}`
  } catch (e) {
    token = localStorage.getItem('token')
    committeeId = getCommitteeIdFromUrlQueryString(host.href)
    if (token) {
      Elm.Main.init({
        node: document.getElementById('root'),
        flags: token
      });
    } else {
      window.location =
        `${userPoolUrl}/login?client_id=${userPoolAppClientId}&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=${host.origin}&state=${committeeId}`
    }
  }
}

runApp();


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
