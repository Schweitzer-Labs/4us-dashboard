const app = require('express')();

const HOST = "http://localhost:3000"
const PORT = 3030

app.get('/login', (req, res) => {
  const committeeId = req.query.state
  res.redirect(`${HOST}?id_token=abc&state=${committeeId}`);
});

const run = async () => {
  await app.listen(PORT);
}

run();
