// eslint-disable-next-line no-undef
const KryptoBird = artifacts.require("KryptoBird");

module.exports = function (deployer) {
    deployer.deploy(KryptoBird);
};