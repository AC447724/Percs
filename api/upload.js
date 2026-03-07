import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
})

export default async function handler(req, res) {
    if (req.method !== 'POST') return res.status(405).send('Method Not Allowed')

    const { url, filename } = req.body
    if (!url || !filename) return res.status(400).json({ error: 'Missing data' })

    try {
        await redis.set(`asset:${filename}`, url)
        return res.status(200).json({ 
            success: true, 
            link: `https://percs.fun/assets/u/${filename}` 
        })
    } catch (e) {
        return res.status(500).json({ error: 'Database error' })
    }
}
