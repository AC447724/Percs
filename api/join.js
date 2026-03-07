export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    // --- NEW PARSING LOGIC ---
    let body = req.body;
    if (typeof body === 'string') {
        try {
            body = JSON.parse(body);
        } catch (e) {
            return res.status(400).json({ error: 'Invalid JSON body' });
        }
    }

    const { gameId, botName } = body; // No longer undefined!

    if (!gameId || !botName) {
        return res.status(400).json({ success: false, error: 'Missing ID or Name' });
    }

    try {
        const response = await fetch(`https://api.blooket.com/api/v1/join`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Referer': 'https://www.blooket.com/',
                'Origin': 'https://www.blooket.com/',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            },
            body: JSON.stringify({ id: gameId, name: botName })
        });

        const data = await response.json();
        return res.status(200).json({ success: response.ok, data });
    } catch (error) {
        return res.status(500).json({ success: false, error: 'Blooket API Unreachable' });
    }
}
