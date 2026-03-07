const { Redis } = require('@upstash/redis');

// This checks for BOTH the standard Upstash names and the Vercel KV names
const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN,
});

module.exports = async (req, res) => {
    // 1. Basic check to prevent the 500 crash
    if (!process.env.KV_REST_API_URL && !process.env.UPSTASH_REDIS_REST_URL) {
        return res.status(500).json({ error: "Environment variables missing on Vercel" });
    }

    const { url, filename } = req.body;

    try {
        await redis.set(`asset:${filename}`, url);
        return res.status(200).json({ 
            success: true, 
            link: `https://percs.fun/assets/u/${filename}` 
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Failed to save to database" });
    }
};
