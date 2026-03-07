export default async function handler(req, res) {
    if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');

    const { target } = req.body;

    if (!target) return res.status(400).json({ error: 'No target IP provided' });

    try {
        // Fetching from a public Minecraft status API
        const response = await fetch(`https://api.mcstatus.io/v2/status/java/${target}`);
        
        if (!response.ok) throw new Error('Server not found');

        const data = await response.json();
        
        // Return only the clean data we need for our dashboard
        return res.status(200).json({
            online: data.online,
            players: data.players?.online || 0,
            maxPlayers: data.players?.max || 0,
            version: data.version?.name_clean || 'Unknown',
            motd: data.motd?.clean || 'No MOTD',
            icon: data.icon || null
        });
    } catch (error) {
        return res.status(500).json({ error: 'Failed to scan target' });
    }
}
