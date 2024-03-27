const nextra = require('nextra')
const { nextraOptions, withNextraOptions } = require('@grapp/nextra-theme/config/nextra')

const withNextra = nextra(nextraOptions)
module.exports = withNextra(withNextraOptions)
