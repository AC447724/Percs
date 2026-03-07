const { Redis } = require('@upstash/redis');

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN,
});

module.exports = async (req, res) => {
    // Get the slug from the URL
    const { slug } = req.query;

    if (!slug) {
        return res.status(400).send("No filename provided.");
    }

    try {
        // Look up the URL in Redis
        const originalUrl = await redis.get(`asset:${slug}`);

        if (originalUrl) {
            // Found it! Redirect to the GIF/Image
            return res.redirect(301, originalUrl);
        } else {
            // Not found in database
            return res.status(404).send(`Asset "${slug}" not found in Percs database.`);
        }
    } catch (err) {
        console.error("Redirect Error:", err);
        return res.status(500).send("Database connection failed. Check Vercel Env Vars.");
    }
};
