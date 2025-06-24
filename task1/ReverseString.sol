// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReverseString {
    // 反转字符串函数
    function reverse(string memory _str) private pure returns (string memory) {
        // 将字符串转换为字节数组
        bytes memory strBytes = bytes(_str);
        // 获取字符串长度
        uint256 length = strBytes.length;
        
        // 创建新的字节数组用于存储反转后的结果
        bytes memory reversed = new bytes(length);
        
        // 反转字符串
        for(uint256 i = 0; i < length; i++) {
            reversed[i] = strBytes[length - 1 - i];
        }
        
        // 将字节数组转换回字符串
        return string(reversed);
    }
    
    // 测试函数
    function testReverse() private pure returns (string[] memory results) {
        // 创建结果数组
        results = new string[](7);
        
        // 测试用例1：普通字符串
        results[0] = reverse("abcde");  // 应该返回 "edcba"
        
        // 测试用例2：空字符串
        results[1] = reverse("");  // 应该返回 ""
        
        // 测试用例3：单个字符
        results[2] = reverse("a");  // 应该返回 "a"
        
        // 测试用例4：回文字符串
        results[3] = reverse("level");  // 应该返回 "level"
        
        // 测试用例5：包含空格的字符串
        results[4] = reverse("hello world");  // 应该返回 "dlrow olleh"
        
        // 测试用例6：包含特殊字符
        results[5] = reverse("!@#$%");  // 应该返回 "%$#@!"
        
        // 测试用例7：包含数字
        results[6] = reverse("12345");  // 应该返回 "54321"
    }
    
    // 添加测试结果验证函数
    function verifyTestResults() external pure returns (bool[] memory) {
        string[] memory results = testReverse();
        bool[] memory verifications = new bool[](7);
        
        // 验证每个测试用例
        verifications[0] = keccak256(bytes(results[0])) == keccak256(bytes("edcba"));
        verifications[1] = keccak256(bytes(results[1])) == keccak256(bytes(""));
        verifications[2] = keccak256(bytes(results[2])) == keccak256(bytes("a"));
        verifications[3] = keccak256(bytes(results[3])) == keccak256(bytes("level"));
        verifications[4] = keccak256(bytes(results[4])) == keccak256(bytes("dlrow olleh"));
        verifications[5] = keccak256(bytes(results[5])) == keccak256(bytes("%$#@!"));
        verifications[6] = keccak256(bytes(results[6])) == keccak256(bytes("54321"));
        
        return verifications;
    }
} 