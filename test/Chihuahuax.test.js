const { assert } = require('chai');

const Chihuahuax = artifacts.require('./Chihuahuax')

// Check for chai
require('chai')
.use(require('chai-as-promised'))
.should()

