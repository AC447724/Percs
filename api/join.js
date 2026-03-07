// api/join.js
export default async function handler(req, res) {
    const { gameId, botName } = req.body;

    // This is where you would put the REAL connection logic
    // For a Vercel function, you'd likely use a fetch request 
    // to Blooket's join endpoint.
    
    try {
        const response = await fetch(`https://api.blooket.com/api/v1/join`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: gameId, name: botName })
        });

        if (response.ok) {
            res.status(200).json({ success: true });
        } else {
            res.status(400).json({ success: false });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}
