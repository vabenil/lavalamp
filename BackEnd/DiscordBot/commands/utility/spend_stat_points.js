const { SlashCommandBuilder } = require('discord.js');
const util = require("../../utilities")



module.exports = {
    data: new SlashCommandBuilder()
        .setName('spend_stat_point')
        .setDescription('Increments a stat')
        .addStringOption(option =>
            option
                .setName('stat_name')
                .setDescription('The name of the stat you want to increase')
                .setRequired(true)
                .addChoices(
                    {name: 'Power', value: 'Power'},
                    {name: 'Dexterity', value: 'Dexterity'},
                    {name: 'Defense', value: 'Defense'},
                    {name: 'Wisdom', value: 'Wisdom'},
                ))
        .addIntegerOption(option =>
            option
                .setName('amount')
                .setDescription('Amount to increment the stat by')
                .setRequired(true)),
    async execute(interaction) {
        await interaction.deferReply({ ephemeral: true })
        util.storeInteraction(interaction.user.displayName, interaction)
        util.sendToGodot({
            action: 'spend_stat_points',
            discord_id: interaction.user.id,
            username: interaction.user.displayName,
            stat_name: interaction.options.getString('stat_name'),
            stat_point_amount: interaction.options.getInteger('amount')
        })
    },
};