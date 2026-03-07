export default async function handler(req, res) {
    if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');

    let body = req.body;
    if (typeof body === 'string') {
        try { body = JSON.parse(body); } catch (e) { return res.status(400).json({ error: 'Invalid JSON' }); }
    }

    const { gameId, botName } = body;

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

        // --- SAFE PARSE CHECK ---
        const contentType = response.headers.get("content-type");
        if (contentType && contentType.includes("application/json")) {
            const data = await response.json();
            return res.status(200).json({ success: response.ok, data });
        } else {
            // It sent back HTML (likely a Cloudflare block)
            const textOutput = await response.text();
            console.error("Blooket blocked us with an HTML page.");
            return res.status(403).json({ 
                success: false, 
                error: 'Blooket Security Block', 
                details: 'The server sent HTML instead of JSON (Cloudflare challenge).' 
            });
        }
    } catch (error) {
        return res.status(500).json({ success: false, error: 'Server Crash' });
    }
}
