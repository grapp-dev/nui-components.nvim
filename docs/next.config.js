const nextra = require('nextra');
const { getNextraOptions, getWithNextraOptions } = require('@grapp/nextra-theme/config/nextra');

const withNextra = nextra(getNextraOptions());
module.exports = withNextra(getWithNextraOptions());
