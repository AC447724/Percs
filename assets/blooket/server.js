const io = require('socket.io-client');

async function spawnBot(pin, name, proxy) {
    // This is the real 'engine'
    const socket = io('https://api.blooket.com', {
        proxy: proxy, // Hide your identity
        reconnection: false
    });

    socket.on('connect', () => {
        // Send the join packet Blooket expects
        socket.emit('join-game', { pin, name });
    });

    socket.on('joined', () => {
        console.log(`${name} is in the game!`);
    });
}
