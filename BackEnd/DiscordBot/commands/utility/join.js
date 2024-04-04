const { SlashCommandBuilder } = require('discord.js');
const util = require("../../utilities")



module.exports = {
    data: new SlashCommandBuilder()
        .setName('create_character')
        .setDescription('Joins the active game of Lavalamp'),
    async execute(interaction) {
        await interaction.deferReply({ ephemeral: true })
        util.storeInteraction(interaction.user.displayName, interaction)
        util.sendToGodot({
            action: 'create_character',
            username: interaction.user.displayName,
            discord_id: interaction.user.id
        })
    },
};



