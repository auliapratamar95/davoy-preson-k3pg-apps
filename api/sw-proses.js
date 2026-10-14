const https = require('https');
const url = require('url');

module.exports = (req, res) => {
  const origin = req.headers.origin || '*';
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Cookie');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const parsedUrl = url.parse(req.url);
  const targetPath = '/sw-proses' + (parsedUrl.search || '');

  const headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Referer': 'https://preson.k3pg.co.id/',
    'X-Requested-With': 'XMLHttpRequest',
  };

  if (req.headers['content-type']) {
    headers['Content-Type'] = req.headers['content-type'];
  }
  if (req.headers['cookie']) {
    headers['Cookie'] = req.headers['cookie'];
  }

  const options = {
    hostname: 'preson.k3pg.co.id',
    port: 443,
    path: targetPath,
    method: req.method,
    headers: headers,
  };

  const proxyReq = https.request(options, (proxyRes) => {
    if (proxyRes.headers['set-cookie']) {
      res.setHeader('Set-Cookie', proxyRes.headers['set-cookie']);
    }
    res.writeHead(proxyRes.statusCode, {
      'Content-Type': proxyRes.headers['content-type'] || 'text/html; charset=utf-8'
    });
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    res.status(500).send('Proxy error: ' + err.message);
  });

  req.pipe(proxyReq);
};
