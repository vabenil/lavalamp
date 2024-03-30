require('dotenv').config();
// Require the necessary discord.js classes
const { Client, Events, GatewayIntentBits } = require('discord.js');
const WebSocket = require('ws');
const TOKEN = process.env.TOKEN;
const channelID = "1223575768320446515"

// Create a new client instance
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.MessageContent, GatewayIntentBits.GuildMessages] });

// Create websocket
const ws = new WebSocket("ws://localhost:12345")

ws.addEventListener("message", (event) => {
    var channel = client.channels.cache.find(channel => channel.id == channelID)
    channel.send(event.data)
});

ws.on('open', function open() {
    console.log('Connected to Godot WebSocket server');
});

ws.on('error', function error(error) {
    console.error('WebSocket error:', error);
});

client.once(Events.ClientReady, readyClient => {
    console.log(`Ready! Logged in as ${readyClient.user.tag}`);
});

// Function to send message to Godot game server
function sendToGodot(data) {
    ws.send(JSON.stringify(data), (err) => {
        if (err) console.error('WebSocket error sending data:', err);
    });
}

// Log in to Discord with your client's token
client.login(TOKEN);


client.on('messageCreate', (msg) => {
    if (!msg.content.startsWith('!') || msg.author.bot) return;
    
    if (msg.content === '!join') {
        const username = msg.author.username;
        sendToGodot({action: 'join', user: username});
        msg.delete()
    }
});