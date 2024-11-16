import http from 'http';
import assert from 'assert';

async function send_request(method, data = {}, session_cookie = '') {
  const headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'de,en-US;q=0.7,en;q=0.3',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'same-origin',
    'Sec-Fetch-User': '?1',
    Priority: 'u=0, i',
    Pragma: 'no-cache',
    'Cache-Control': 'no-cache',
    'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0',
  };
  if (session_cookie !== '') {
    headers['Cookie'] = session_cookie;
  }
  let body = '';
  for (const key of Object.keys(data)) {
    if (body.length > 0) {
      body += '&';
    }
    if (data[key].startsWith('+%2B+')) {
      data[key] = encodeURIComponent(data[key].replace('+%2B+', '')).replace(
        /%20/g,
        '+'
      );
    } else {
      data[key] = encodeURIComponent(data[key]);
    }
    body += key + '=' + data[key];
  }
  const options = {
    method,
    headers,
    referrer: 'http://localhost:8080/index.html?lang=en',
  };
  return new Promise((resolve, reject) => {
    const req = http.request(
      'http://localhost:8080/index.html?lang=en',
      options,
      (res) => {
        assert(typeof res.statusCode === 'number');
        assert(res.statusCode >= 200 && res.statusCode < 400);
        res['text'] = async () => {
          return new Promise((resolve_text) => {
            let data = '';
            res.on('data', (chunk) => {
              data += chunk;
            });
            res.on('end', () => {
              resolve_text(data);
            });
          });
        };
        resolve(res);
      }
    );
    req.on('error', (err) => {
      reject(err);
    });
    if (method === 'POST') {
      req.write(body);
    }
    req.end();
  });
}

async function login(username, password) {
  const res = await send_request('GET');
  const cookies = res.headers['set-cookie'];
  assert(Array.isArray(cookies));
  let session_cookie_result = null;

  for (const cookie of cookies) {
    session_cookie_result = /(SessionID=[^;]+)/i.exec(cookie);
    if (session_cookie_result !== null) break;
  }
  assert(session_cookie_result !== null);

  const request = {
    username: username,
    password: password,
    login: 'Login',
  };
  await send_request('POST', request, session_cookie_result[1]);
  return session_cookie_result[1];
}

function get_regex(text, regex) {
  const reg = new RegExp(regex, 'igsu');
  const results = {};
  let match;
  while ((match = reg.exec(text)) !== null) {
    results[match[1]] = match[2];
  }
  return results;
}

async function main() {
  const session_cookie = await login(
    process.env.WEB_USERNAME,
    process.env.WEB_PASSWORD
  );

  const res = await send_request('GET', {}, session_cookie);

  const html = await res.text();

  await send_request(
    'POST',
    {
      ...get_regex(html, '<input type="[^"]*" name="([^"]*)" value="([^"]*)"'),
      ...get_regex(
        html,
        '<select name\\s*=\\s*"([^"]*)".*?<option value="([^"]*)" selected="selected"'
      ),
      start_server: 'Start',
    },
    session_cookie
  );
}

setTimeout(main, 10000);
