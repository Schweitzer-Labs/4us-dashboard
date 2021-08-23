import './main.css';
import { Elm } from './Main.elm';

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
  const firstTrim = url.split('?committeeId=')
  if (firstTrim.length > 1) {
    return firstTrim[1]
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
    localStorage.setItem('token', token)
    window.location = `${host.origin}?committeeId=${committeeId}`
  } catch (e) {
    token = localStorage.getItem('token')
    committeeId = getCommitteeIdFromUrlQueryString(host.href)
    if (token) {
      Elm.Main.init({
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
    } else {
      window.location =
        `${cognitoDomain}/login?client_id=${cognitoClientId}&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=${host.origin}&state=${committeeId}`
    }
  }
}

runApp();
