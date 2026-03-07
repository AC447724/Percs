import { Redis } from '@upstash/redis';

const redis = new Redis({
  url: process.env.KV_REST_API_URL,
  token: process.env.KV_REST_API_TOKEN,
});

export default async function handler(req, res) {
  try {
    const data = await redis.get('bot_status');
    const botData = typeof data === 'string' ? JSON.parse(data) : data;

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', 'application/json');
    return res.status(200).json(botData);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}
