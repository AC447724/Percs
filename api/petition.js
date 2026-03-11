const _0x5a1 = require('@upstash/redis');
const _0x4f2 = ['llen', 'lrange', 'get', 'lpush', 'set', 'status', 'json', 'method', 'body', 'headers', 'x-forwarded-for', 'x-vercel-ip-country', 'toISOString', 'includes', 'toLowerCase', 'trim', 'substring', 'petition:signatures', 'has_signed:', 'POST', 'GET'];
const _0x2b9 = (i) => _0x4f2[i];

const _0x3e1 = new _0x5a1['Redis']({
    url: process.env['UPSTASH_REDIS_REST_URL'] || process.env['KV_REST_API_URL'],
    token: process.env['UPSTASH_REDIS_REST_TOKEN'] || process.env['KV_REST_API_TOKEN']
});

const _0x7c2 = (s) => Buffer['from'](s, 'base64')['toString']('ascii');

const _0x1a9 = (t) => {
    if (!t) return false;
    const m = {'0':'o','1':'i','3':'e','4':'a','5':'s','7':'t','8':'b','@':'a','$':'s','!':'i','|':'i'};
    const n = t[_0x2b9(14)]().split('').map(c => m[c] || c).join('');
    const s = n.replace(/[^a-z]/g, '');
    
    const b = [
        'ZnVjaw==','bmlnZ2Vy','bmlnZ2E=','YmFzdGFyZA==','Y3VudA==','cHVzc3k=','ZGljaw==',
        'Y29jaw==','cmFwZQ==','cmFwaXN0','cGVkb3BoaWxl','cmV0YXJk','ZmFnZ290','c2x1dA==',
        'd2hvcmU=','a2lrZQ==','Y2hpbms=','YXNzaG9sZQ==','Ym9vYnM=','dGl0cw==','aml6eg=='
    ].map(_0x7c2);
    
    return b.some(w => s[_0x2b9(13)](w) || n[_0x2b9(13)](w));
};

module.exports = async (_0x11a, _0x55b) => {
    const _0x33d = _0x11a[_0x2b9(9)][_0x2b9(10)];
    const _0x1a2 = _0x33d ? _0x33d['split'](',')[0][_0x2b9(15)]() : _0x11a['socket']['remoteAddress'];

    if (_0x11a[_0x2b9(7)] === _0x2b9(20)) {
        try {
            const _0xef1 = await _0x3e1[_0x2b9(0)](_0x2b9(17));
            const _0x882 = await _0x3e1[_0x2b9(1)](_0x2b9(17), 0, 14);
            const _0xbc3 = _0x882['map'](_0xac => typeof _0xac === 'string' ? JSON['parse'](_0xac) : _0xac);
            const _0xda4 = await _0x3e1[_0x2b9(2)](_0x2b9(18) + _0x1a2);
            return _0x55b[_0x2b9(5)](200)[_0x2b9(6)]({ total: _0xef1, recent: _0xbc3, hasSigned: !!_0xda4 });
        } catch (_0xee) {
            return _0x55b[_0x2b9(5)](500)[_0x2b9(6)]({ error: _0x7c2('RmV0Y2ggZmFpbGVk') });
        }
    }

    if (_0x11a[_0x2b9(7)] === _0x2b9(19)) {
        const { name: _0x44c, bot_check: _0x12b } = _0x11a[_0x2b9(8)];
        if (_0x12b) return _0x55b[_0x2b9(5)](400)[_0x2b9(6)]({ error: _0x7c2('Qm90IGRldGVjdGVk') });
        
        const _0x221 = (_0x44c || '')[_0x2b9(15)]()[_0x2b9(16)](0, 25);
        if (_0x221['length'] < 2) return _0x55b[_0x2b9(5)](400)[_0x2b9(6)]({ error: _0x7c2('TmFtZSB0b28gc2hvcnQ=') });
        if (_0x1a9(_0x221)) {
            return _0x55b[_0x2b9(5)](400)[_0x2b9(6)]({ error: _0x7c2('UGxlYXNlIHVzZSBhbiBhcHByb3ByaWF0ZSBuYW1lLg==') });
        }

        try {
            const _0x47d = await _0x3e1[_0x2b9(2)](_0x2b9(18) + _0x1a2);
            if (_0x47d) return _0x55b[_0x2b9(5)](403)[_0x2b9(6)]({ error: _0x7c2('WW91IGhhdmUgYWxyZWFkeSBzaWduZWQu') });

            const _0xbb2 = _0x11a[_0x2b9(9)][_0x2b9(11)] || 'Global';
            const _0xcc1 = { name: _0x221, location: _0xbb2, date: new Date()[_0x2b9(12)]() };

            await _0x3e1[_0x2b9(3)](_0x2b9(17), JSON['stringify'](_0xcc1));
            await _0x3e1[_0x2b9(4)](_0x2b9(18) + _0x1a2, "true", { ex: 604800 });

            return _0x55b[_0x2b9(5)](200)[_0x2b9(6)]({ success: true });
        } catch (_0x8e) {
            return _0x55b[_0x2b9(5)](500)[_0x2b9(6)]({ error: _0x7c2('RGF0YWJhc2UgZXJyb3I=') });
        }
    }
};
