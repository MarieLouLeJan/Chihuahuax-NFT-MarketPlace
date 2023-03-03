const { assert } = require('chai');

const Chihuahuax = artifacts.require('./Chihuahuax')

// Check for chai
require('chai')
.use(require('chai-as-promised'))
.should()


contract('Chihuahuax', (accounts) => {

    let contract

    // Before tells our tests to run this first before anything else
    before( async () => {
        contract = await Chihuahuax.deployed();
    }
    )

    // Testing container - describe

    describe('deployment', async () => {

        // test samples with writing it
        it('deploys successfuly', async() => {
            const address = contract.address;
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
            assert.notEqual(address, 0x0)
        })

        // EXERCISE
        // Write 2 tests
        // 1. Test that the name matches on our contract using the assert.equal
        // 2. Test that the symbol matches with e

        it('has a name', async() => {
            const name = await contract.name();
            assert.equal(name, 'Chihuahuax')
        })

        it('has a symbol', async() => {
            const symbol = await contract.symbol()
            assert.equal(symbol, 'CHIX')
        })
    })

    describe('minting', async () => {

        it('creates a new token', async () => {
            const result = await contract.mint('https...1');
            const totalSupply = await contract.totalSupply()

            // Success
            assert.equal(totalSupply, 1);
            const event = result.logs[0].args;
            // The _from and _to come from the event `Transfer` that we've created in IERC721.sol
            assert.equal(event._from, '0x0000000000000000000000000000000000000000', 'from is the contract')
            // Here we check if the msg.sender is our ganache address that initiate the mint
            assert.equal(event._to, '0xeb37cB73de9fb31ee8Da72EE70e9339E715eBbB4', 'to is the msg.sender')

            // Failure
            await contract.mint('https...1').should.be.rejected;
        })
    })

    describe('indexing', async () => {
        it('lists Chihuahuax', async () => {
            // We mint 3 new tokens
            await contract.mint('https...2');
            await contract.mint('https...3');
            await contract.mint('https...4');

            const totalSupply = await contract.totalSupply()

            // Loop though list and grab Chihuahua from list
            let result = [];
            let Chihuahua;
            for(i = 1; i <= totalSupply; i ++) {
                Chihuahua = await contract.chihuahuax(i - 1);
                result.push(Chihuahua);
            }

            // Assert that our new array result will equal our expected result
            let expected = ['https...1', 'https...2', 'https...3', 'https...4']
            // We can't really compare two arrays in JS
            // To check if 2 arrays have the same value, we use the stringify method
            assert.equal(JSON.stringify(result), JSON.stringify(expected))
        })


    })

})
