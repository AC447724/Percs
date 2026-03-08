const { Redis } = require('@upstash/redis');

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN,
});

module.exports = async (req, res) => {
    if (!process.env.KV_REST_API_URL && !process.env.UPSTASH_REDIS_REST_URL) {
        return res.status(500).json({ error: "Environment variables missing" });
    }

    const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

    if (req.method === 'GET') {
        try {
            const total = await redis.llen('petition:signatures');
            const recent = await redis.lrange('petition:signatures', 0, 9);
            return res.status(200).json({ total, recent });
        } catch (err) {
            return res.status(500).json({ error: "Failed to fetch" });
        }
    }

    if (req.method === 'POST') {
        const { name } = req.body;
        
        if (!name || name.trim().length < 2) {
            return res.status(400).json({ error: "Name is required" });
        }

        try {
            const hasSigned = await redis.get(`has_signed:${ip}`);
            if (hasSigned) {
                return res.status(429).json({ error: "You have already signed today!" });
            }

            const signature = {
                name: name.trim(),
                date: new Date().toISOString()
            };

            await redis.lpush('petition:signatures', JSON.stringify(signature));
            await redis.set(`has_signed:${ip}`, "true", { ex: 86400 });

            const newTotal = await redis.llen('petition:signatures');
            return res.status(200).json({ success: true, total: newTotal });
        } catch (err) {
            return res.status(500).json({ error: "Failed to save" });
        }
    }

    return res.status(405).json({ error: "Method not allowed" });
};
