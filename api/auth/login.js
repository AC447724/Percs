module.exports = async (req, res) => {
    const clientId = process.env.DISCORD_CLIENT_ID;
    const redirectUri = encodeURIComponent(`https://percs.fun/api/callback`);
    
    // We only need 'identify' to get their Discord ID
    const scope = 'identify';
    
    const discordUrl = `https://discord.com/api/oauth2/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=${scope}`;

    res.redirect(302, discordUrl);
};
