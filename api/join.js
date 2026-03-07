export default async function handler(req, res) {
    // Only allow POST requests
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const { gameId, botName } = req.body;

    // Validate inputs to prevent 400 errors
    if (!gameId || !botName) {
        return res.status(400).json({ success: false, error: 'Missing ID or Name' });
    }

    try {
        // We use a real Blooket join endpoint. 
        // Note: Blooket often requires a 'referrer' header to work.
        const response = await fetch(`https://api.blooket.com/api/v1/join`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Referer': 'https://www.blooket.com/',
                'Origin': 'https://www.blooket.com/',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            },
            body: JSON.stringify({ 
                id: gameId, 
                name: botName 
            })
        });

        const data = await response.json();

        if (response.ok) {
            return res.status(200).json({ success: true, data });
        } else {
            // Log the actual error from Blooket to Vercel logs
            console.error('Blooket Error:', data);
            return res.status(400).json({ success: false, message: data.msg || 'Blooket rejected join' });
        }
    } catch (error) {
        console.error('Function Crash:', error);
        return res.status(500).json({ success: false, error: 'Internal Server Crash' });
    }
}
