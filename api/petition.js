const { Redis } = require('@upstash/redis');

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN,
});

module.exports = async (req, res) => {
    if (!process.env.KV_REST_API_URL && !process.env.UPSTASH_REDIS_REST_URL) {
        return res.status(500).json({ error: "Environment variables missing" });
    }

    // Vercel uses 'x-forwarded-for'. It can be a comma-separated list, so we take the first one.
    const forwarded = req.headers['x-forwarded-for'];
    const ip = forwarded ? forwarded.split(',')[0] : req.socket.remoteAddress;

    if (req.method === 'GET') {
        try {
            const total = await redis.llen('petition:signatures');
            const recent = await redis.lrange('petition:signatures', 0, 9);
            
            // Check if THIS specific user has already signed so the frontend can hide the button
            const hasSigned = await redis.get(`has_signed:${ip}`);
            
            return res.status(200).json({ 
                total, 
                recent, 
                hasSigned: !!hasSigned // Returns true or false
            });
        } catch (err) {
            return res.status(500).json({ error: "Failed to fetch" });
        }
    }

    if (req.method === 'POST') {
        const { name } = req.body;
        
        if (!name || name.trim().length < 2) {
            return res.status(400).json({ error: "Name is too short" });
        }

        try {
            const hasSigned = await redis.get(`has_signed:${ip}`);
            if (hasSigned) {
                return res.status(403).json({ error: "You have already signed this petition." });
            }

            const signature = {
                name: name.trim().substring(0, 25), // Limit length for safety
                date: new Date().toISOString()
            };

            // Atomic operation: Save signature and mark IP as signed
            await redis.lpush('petition:signatures', JSON.stringify(signature));
            
            // Setting 'ex: 86400' makes this expire in 24 hours. 
            // If you want it to be permanent, remove the { ex: 86400 } part.
            await redis.set(`has_signed:${ip}`, "true", { ex: 86400 });

            const newTotal = await redis.llen('petition:signatures');
            return res.status(200).json({ success: true, total: newTotal });
        } catch (err) {
            return res.status(500).json({ error: "Failed to save" });
        }
    }

    return res.status(405).json({ error: "Method not allowed" });
};
