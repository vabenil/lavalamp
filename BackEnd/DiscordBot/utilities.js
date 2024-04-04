const WebSocket = require('ws');
const { Client, Events, GatewayIntentBits, SlashCommandBuilder, Collection} = require('discord.js');
const channelID = "1223575768320446515"
const TOKEN = process.env.TOKEN;

// Create a new client instance
const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.MessageContent, GatewayIntentBits.GuildMessages] });
client.login(TOKEN);

// Create websocket
const ws = new WebSocket("ws://localhost:12345")

ws.on('open', function open() {
    console.log('Connected to Godot WebSocket server');
});

ws.on('error', function error(error) {
    console.error('WebSocket error:', error);
});

ws.addEventListener("message", (event) => {
    let data = JSON.parse(event.data)

    if (data.hasOwnProperty("discord_id")) {
        // Sends direct message
        const channel = client.channels.cache.get(channelID);
        channel.send(`<@${data.discord_id}> ${data.message}`);

    } else {
        // Send from last interaction
        let interaction = getInteraction(data.username)
        interaction.editReply(data.message)
    }
});

function sendToGodot(data) {
    ws.send(JSON.stringify(data), (err) => {
        if (err) console.error('WebSocket error sending data:', err);
    });
}



let stored_interactions = {}


function storeInteraction(username, interaction) {
    if(username in stored_interactions){
        stored_interactions[username].push(interaction)
    } else {
        stored_interactions[username] = [interaction]
    }
}

function getInteraction(username){
    if(username in stored_interactions){
        return stored_interactions[username].pop()
    }
}



module.exports = {
    sendToGodot,
    storeInteraction,
    getInteraction
}