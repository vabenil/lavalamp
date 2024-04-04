const { SlashCommandBuilder } = require('discord.js');
const util = require("../../utilities")



module.exports = {
    data: new SlashCommandBuilder()
        .setName('join')
        .setDescription('Joins an active room of the lavalamp game')
        .addStringOption(option =>
            option
                .setName('room')
                .setDescription('The room you you would like to join')
                .setRequired(true)
                .addChoices(
                    {name: 'Forest', value: 'Forest'}
                )),
    async execute(interaction) {
        await interaction.deferReply({ ephemeral: true })
        util.storeInteraction(interaction.user.displayName, interaction)
        util.sendToGodot({
            action: 'join_room',
            discord_id: interaction.user.id,
            username: interaction.user.displayName,
            room: interaction.options.getString('room') })
    },
};