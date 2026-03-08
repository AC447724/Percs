const { Redis } = require('@upstash/redis');

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN,
});

module.exports = async (req, res) => {
    const forwarded = req.headers['x-forwarded-for'];
    const ip = forwarded ? forwarded.split(',')[0].trim() : req.socket.remoteAddress;

    if (req.method === 'GET') {
        try {
            const total = await redis.llen('petition:signatures');
            const recent = await redis.lrange('petition:signatures', 0, 14);
            const hasSigned = await redis.get(`has_signed:${ip}`);
            
            return res.status(200).json({ 
                total, 
                recent, 
                hasSigned: !!hasSigned 
            });
        } catch (err) {
            return res.status(500).json({ error: "Fetch failed" });
        }
    }

    if (req.method === 'POST') {
        const { name } = req.body;
        if (!name || name.trim().length < 2) return res.status(400).json({ error: "Name too short" });

        try {
            const alreadySigned = await redis.get(`has_signed:${ip}`);
            if (alreadySigned) {
                return res.status(403).json({ error: "You have already signed this petition." });
            }

            const city = req.headers['x-vercel-ip-city'] || 'Unknown';
            const country = req.headers['x-vercel-ip-country'] || 'Global';
            const location = `${city}, ${country}`;

            const signature = {
                name: name.trim().substring(0, 25),
                location: location,
                date: new Date().toISOString()
            };

            await redis.lpush('petition:signatures', JSON.stringify(signature));
            await redis.set(`has_signed:${ip}`, "true");

            return res.status(200).json({ success: true });
        } catch (err) {
            return res.status(500).json({ error: "Database error" });
        }
    }
};
