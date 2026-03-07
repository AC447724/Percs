import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
})

export default async function handler(req, res) {
    const { slug } = req.query

    try {
        const originalUrl = await redis.get(`asset:${slug}`)
        
        if (originalUrl) {
            return res.redirect(301, originalUrl)
        } else {
            return res.status(404).send('Asset not found')
        }
    } catch (e) {
        return res.status(500).send('Server error')
    }
}
