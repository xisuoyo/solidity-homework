const { expect } = require('chai');
const { ethers } = require('hardhat'); // 使用ethers.js

describe('MyToken', function () {
    let myToken;
    let owner;
    let user1;
    let user2;
    let amount;
    let approveAmount;

    before(async function () {
        [owner, user1, user2] = await ethers.getSigners(); // 获取ethers.js的signer
        console.log("Accounts in Ganache:");
        console.log("Owner:", owner.address);
        console.log("User1:", user1.address);
        console.log("User2:", user2.address);
    });

    beforeEach(async function () {
        // 部署合约
        const MyToken = await ethers.getContractFactory('MyToken');
        myToken = await MyToken.deploy('MyToken', 'MTK');
        await myToken.deployed();
        console.log(`MyToken Contract deployed at: ${myToken.address}`);
        // 假设合约有一个owner()函数来获取所有者地址
        // 如果没有，请删除下面一行或根据合约实际情况修改
        try {
            const contractOwner = await myToken.owner();
            console.log(`MyToken Contract Owner: ${contractOwner}`);
        } catch (e) {
            console.log("Could not retrieve contract owner (owner() function might not exist or be public).");
        }

        // 初始化金额
        amount = ethers.utils.parseEther('100'); // 使用ethers.js的parseEther
        approveAmount = ethers.utils.parseEther('50');
    });

    describe('基本属性', function () {
        it('应该设置正确的名称和符号', async function () {
            const name = await myToken.name(); // ethers.js直接调用方法
            const symbol = await myToken.symbol(); // ethers.js直接调用方法
            expect(name).to.equal('MyToken');
            expect(symbol).to.equal('MTK');
        });

        it('应该设置正确的小数位数', async function () {
            const decimals = await myToken.decimals(); // ethers.js直接调用方法
            expect(decimals).to.equal(18); // 小数位数通常返回number类型
        });
    });

    describe('代币铸造', function () {
        it('只有所有者可以铸造代币', async function () {
            const mintAmount = ethers.utils.parseEther('1000');
            
            // 所有者铸造代币
            console.log(`Minting ${ethers.utils.formatEther(mintAmount)} to ${user1.address} from owner (${owner.address})...`);
            await myToken.mint(user1.address, mintAmount); // ethers.js直接调用方法，使用.address
            const balance = await myToken.balanceOf(user1.address); // ethers.js直接调用方法，使用.address
            console.log(`Balance of user1 after owner mint: ${ethers.utils.formatEther(balance)} MTK`);
            expect(balance).to.equal(mintAmount);

            // 非所有者尝试铸造代币
            console.log(`Attempting mint by non-owner (${user1.address}) to ${user2.address}...`);
            await expect(
                myToken.connect(user1).callStatic.mint(user2.address, mintAmount)
            ).to.be.reverted;
        });
    });

    describe('转账功能', function () {
        beforeEach(async function () {
            // 给 user1 铸造一些代币
            console.log(`Minting ${ethers.utils.formatEther(amount)} to ${user1.address} from owner (${owner.address}) before transfer test.`);
            await myToken.mint(user1.address, amount); // ethers.js直接调用方法，使用.address
        });

        it('应该正确转账代币', async function () {
            const transferAmount = ethers.utils.parseEther('50');
            
            // 转账
            console.log(`Attempting transfer of ${ethers.utils.formatEther(transferAmount)} from ${user1.address} to ${user2.address}...`);
            await myToken.connect(user1).transfer(user2.address, transferAmount); // ethers.js直接调用方法，使用.address
            console.log("Transfer successful.");
            
            // 检查余额
            const balance1 = await myToken.balanceOf(user1.address); // ethers.js直接调用方法，使用.address
            const balance2 = await myToken.balanceOf(user2.address); // ethers.js直接调用方法，使用.address
            
            expect(balance1).to.equal(ethers.utils.parseEther('50'));
            expect(balance2).to.equal(transferAmount);
        });

        it('余额不足时应该失败', async function () {
            const tooMuch = ethers.utils.parseEther('200');
            
            console.log(`Attempting transfer of ${ethers.utils.formatEther(tooMuch)} (too much) from ${user1.address} to ${user2.address}...`);
            await expect(
                myToken.connect(user1).callStatic.transfer(user2.address, tooMuch)
            ).to.be.reverted;
        });
    });

    describe('授权功能', function () {
        beforeEach(async function () {
            // 给 user1 铸造一些代币
            console.log(`Minting ${ethers.utils.formatEther(amount)} to ${user1.address} from owner (${owner.address}) before approve test.`);
            await myToken.mint(user1.address, amount); // ethers.js直接调用方法，使用.address
        });

        it('应该正确授权和转账', async function () {
            // 授权
            console.log(`Attempting to approve ${ethers.utils.formatEther(approveAmount)} for ${user2.address} by ${user1.address}...`);
            await myToken.connect(user1).approve(user2.address, approveAmount); // ethers.js直接调用方法，使用.address
            console.log("Approval successful.");
            
            // 检查授权额度
            const allowance = await myToken.allowance(user1.address, user2.address); // ethers.js直接调用方法，使用.address
            expect(allowance).to.equal(approveAmount);

            // 使用授权转账
            console.log(`Attempting transferFrom of ${ethers.utils.formatEther(approveAmount)} from ${user1.address} to ${user2.address} by ${user2.address}...`);
            await myToken.connect(user2).transferFrom(user1.address, user2.address, approveAmount); // ethers.js直接调用方法，使用.address
            console.log("TransferFrom successful.");
            
            // 检查余额
            const balance1 = await myToken.balanceOf(user1.address); // ethers.js直接调用方法，使用.address
            const balance2 = await myToken.balanceOf(user2.address); // ethers.js直接调用方法，使用.address
            
            expect(balance1).to.equal(ethers.utils.parseEther('50'));
            expect(balance2).to.equal(approveAmount);
        });

        it('超出授权额度时应该失败', async function () {
            const tooMuch = ethers.utils.parseEther('60');
            
            // 授权
            console.log(`Attempting to approve ${ethers.utils.formatEther(approveAmount)} for ${user2.address} by ${user1.address}...`);
            await myToken.connect(user1).approve(user2.address, approveAmount); // ethers.js直接调用方法，使用.address
            
            // 尝试超出授权额度转账
            console.log(`Attempting transferFrom of ${ethers.utils.formatEther(tooMuch)} (too much) from ${user1.address} to ${user2.address} by ${user2.address}...`);
            await expect(
                myToken.connect(user2).callStatic.transferFrom(user1.address, user2.address, tooMuch)
            ).to.be.reverted;
        });
    });
}); 