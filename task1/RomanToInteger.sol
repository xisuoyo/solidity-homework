// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanToInteger {
    // 定义罗马数字到整数的映射
    mapping(bytes1 => uint16) private romanValues;

    constructor() {
        // 初始化罗马数字映射
        romanValues['I'] = 1;
        romanValues['V'] = 5;
        romanValues['X'] = 10;
        romanValues['L'] = 50;
        romanValues['C'] = 100;
        romanValues['D'] = 500;
        romanValues['M'] = 1000;
    }

    /**
     * @dev 将罗马数字转换为整数
     * @param s 罗马数字字符串
     * @return 转换后的整数值
     */
    function romanToInt(string memory s) public view returns (uint16) {
        bytes memory roman = bytes(s);
        require(roman.length > 0, "Empty string");
        
        uint16 result = 0;
        uint16 prevValue = 0;

        for (uint256 i = roman.length; i > 0; i--) {
            bytes1 currentChar = roman[i - 1];
            uint16 currentValue = romanValues[currentChar];
            
            // 检查字符是否有效
            require(currentValue > 0, string(abi.encodePacked("Invalid Roman numeral: ", currentChar)));
            
            // 如果当前值大于或等于前一个值，则加上当前值
            // 否则减去当前值（处理特殊情况如 IV, IX 等）
            if (currentValue >= prevValue) {
                result += currentValue;
            } else {
                result -= currentValue;
            }
            
            prevValue = currentValue;
        }

        return result;
    }

    /**
     * @dev 测试函数：转换一些示例罗马数字
     * @return r 测试结果数组
     */
    function testConversion() public view returns (uint16[5] memory r) {
        r[0] = romanToInt("III");     // 应该返回 3
        r[1] = romanToInt("IV");      // 应该返回 4
        r[2] = romanToInt("IX");      // 应该返回 9
        r[3] = romanToInt("LVIII");   // 应该返回 58
        r[4] = romanToInt("MCMXCIV"); // 应该返回 1994
    }
} 