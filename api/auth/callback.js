const axios = require('axios');
const { serialize } = require('cookie');

const WHITELIST = ["1281996800340791452"]; // Your ID

module.exports = async (req, res) => {
    const { code } = req.query;
    if (!code) return res.redirect('/login');

    try {
        // 1. Exchange code for access token
        const tokenResponse = await axios.post('https://discord.com/api/oauth2/token', new URLSearchParams({
            client_id: process.env.DISCORD_CLIENT_ID,
            client_secret: process.env.DISCORD_CLIENT_SECRET,
            grant_type: 'authorization_code',
            code: code,
            redirect_uri: `https://percs.fun/api/callback`,
        }).toString(), { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } });

        // 2. Get User Info
        const userResponse = await axios.get('https://discord.com/api/users/@me', {
            headers: { Authorization: `Bearer ${tokenResponse.data.access_token}` }
        });

        const discordId = userResponse.data.id;

        // 3. Check Whitelist
        if (WHITELIST.includes(discordId)) {
            // Set a secure cookie that expires in 7 days
            const cookie = serialize('percs_auth', 'is_admin', {
                path: '/',
                httpOnly: true,
                secure: true,
                maxAge: 60 * 60 * 24 * 7
            });
            res.setHeader('Set-Cookie', cookie);
            return res.redirect('/admin/upload'); // Send to the upload page
        } else {
            return res.status(403).send("You are not whitelisted.");
        }
    } catch (err) {
        return res.status(500).send("Auth Failed");
    }
};
