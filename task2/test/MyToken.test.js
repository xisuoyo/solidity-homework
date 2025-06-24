const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('MyToken', function () {
    let myToken;
    let owner;
    let user1;
    let user2;
    let amount;
    let approveAmount;

    before(async function () {
        [owner, user1, user2] = await ethers.getSigners();
    });

    beforeEach(async function () {
        // 部署合约
        const MyToken = await ethers.getContractFactory('MyToken');
        myToken = await MyToken.deploy('MyToken', 'MTK');
        await myToken.deployed();

        // 初始化金额
        amount = ethers.utils.parseEther('100');
        approveAmount = ethers.utils.parseEther('50');
    });

    describe('基本属性', function () {
        it('应该设置正确的名称和符号', async function () {
            const name = await myToken.name();
            const symbol = await myToken.symbol();
            expect(name).to.equal('MyToken');
            expect(symbol).to.equal('MTK');
        });

        it('应该设置正确的小数位数', async function () {
            const decimals = await myToken.decimals();
            expect(decimals).to.equal(18);
        });
    });

    describe('代币铸造', function () {
        it('只有所有者可以铸造代币', async function () {
            const mintAmount = ethers.utils.parseEther('1000');
            
            // 所有者铸造代币并检测事件
            // mint 函数触发 Transfer 事件，from 地址为 address(0)
            await expect(myToken.mint(user1.address, mintAmount))
                .to.emit(myToken, 'Transfer')
                .withArgs(ethers.constants.AddressZero, user1.address, mintAmount);
            
            const balance = await myToken.balanceOf(user1.address);
            expect(balance).to.equal(mintAmount);

            // 非所有者尝试铸造代币，应该回滚并触发 NotOwner 错误
            await expect(
                myToken.connect(user1).mint(user2.address, mintAmount)
            ).to.be.revertedWithCustomError(myToken, 'NotOwner');
        });
    });

    describe('转账功能', function () {
        beforeEach(async function () {
            // 给 user1 铸造一些代币，确保有余额进行转账测试
            await myToken.mint(user1.address, amount);
        });

        it('应该正确转账代币', async function () {
            const transferAmount = ethers.utils.parseEther('50');
            
            // 执行转账并检测 Transfer 事件
            await expect(myToken.connect(user1).transfer(user2.address, transferAmount))
                .to.emit(myToken, 'Transfer')
                .withArgs(user1.address, user2.address, transferAmount);
            
            // 检查转账后的余额
            const balance1 = await myToken.balanceOf(user1.address);
            const balance2 = await myToken.balanceOf(user2.address);
            
            expect(balance1).to.equal(ethers.utils.parseEther('50'));
            expect(balance2).to.equal(transferAmount);
        });

        it('余额不足时应该失败', async function () {
            const tooMuch = ethers.utils.parseEther('200');
            
            // 尝试转账超出余额，应该回滚并触发 InsufficientBalance 错误
            await expect(
                myToken.connect(user1).transfer(user2.address, tooMuch)
            ).to.be.revertedWithCustomError(myToken, 'InsufficientBalance');
        });
    });

    describe('授权功能', function () {
        beforeEach(async function () {
            // 给 user1 铸造一些代币，确保有余额进行授权测试
            await myToken.mint(user1.address, amount);
        });

        it('应该正确授权和转账', async function () {
            // 执行授权并检测 Approval 事件
            await expect(myToken.connect(user1).approve(user2.address, approveAmount))
                .to.emit(myToken, 'Approval')
                .withArgs(user1.address, user2.address, approveAmount);
            
            // 检查授权额度
            const allowance = await myToken.allowance(user1.address, user2.address);
            expect(allowance).to.equal(approveAmount);

            // 使用授权转账并检测 Transfer 事件 (transferFrom 也触发 Transfer 事件)
            await expect(myToken.connect(user2).transferFrom(user1.address, user2.address, approveAmount))
                .to.emit(myToken, 'Transfer')
                .withArgs(user1.address, user2.address, approveAmount);
            
            // 检查转账后的余额
            const balance1 = await myToken.balanceOf(user1.address);
            const balance2 = await myToken.balanceOf(user2.address);
            
            expect(balance1).to.equal(ethers.utils.parseEther('50'));
            expect(balance2).to.equal(approveAmount);
        });

        it('超出授权额度时应该失败', async function () {
            const tooMuch = ethers.utils.parseEther('60');
            
            // 授权
            await myToken.connect(user1).approve(user2.address, approveAmount);
            
            // 尝试超出授权额度转账，应该回滚并触发 InsufficientAllowance 错误
            await expect(
                myToken.connect(user2).transferFrom(user1.address, user2.address, tooMuch)
            ).to.be.revertedWithCustomError(myToken, 'InsufficientAllowance');
        });
    });
}); 