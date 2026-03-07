export default async function handler(req, res) {
    if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');
    const { target } = req.body;
    if (!target) return res.status(400).json({ error: 'Missing Target' });

    try {
        // Fetching the advanced status (includes protocol, SRV, and player samples)
        const response = await fetch(`https://api.mcstatus.io/v2/status/java/${target}`);
        const data = await response.json();
        
        if (!data.online) return res.status(200).json({ online: false });

        return res.status(200).json({
            online: true,
            ip: data.host,
            port: data.port,
            version: data.version?.name_clean || "Unknown",
            protocol: data.version?.protocol || "N/A",
            players: {
                online: data.players.online,
                max: data.players.max,
                list: data.players.list || [] // Returns [{name, uuid}] if available
            },
            motd: data.motd.clean,
            icon: data.icon,
            software: data.software || "Unknown",
            srv: data.srv_record || null
        });
    } catch (error) {
        return res.status(500).json({ error: 'Scan Failed' });
    }
}
