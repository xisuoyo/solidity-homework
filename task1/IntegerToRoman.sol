// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntegerToRoman {
    // 定义罗马数字的基本映射
    struct RomanNumeral {
        uint16 value;
        string symbol;
    }

    // 罗马数字的基本映射数组
    RomanNumeral[] private romanNumerals;

    constructor() {
        // 初始化罗马数字映射
        romanNumerals.push(RomanNumeral(1000, "M"));
        romanNumerals.push(RomanNumeral(900, "CM"));
        romanNumerals.push(RomanNumeral(500, "D"));
        romanNumerals.push(RomanNumeral(400, "CD"));
        romanNumerals.push(RomanNumeral(100, "C"));
        romanNumerals.push(RomanNumeral(90, "XC"));
        romanNumerals.push(RomanNumeral(50, "L"));
        romanNumerals.push(RomanNumeral(40, "XL"));
        romanNumerals.push(RomanNumeral(10, "X"));
        romanNumerals.push(RomanNumeral(9, "IX"));
        romanNumerals.push(RomanNumeral(5, "V"));
        romanNumerals.push(RomanNumeral(4, "IV"));
        romanNumerals.push(RomanNumeral(1, "I"));
    }

    /**
     * @dev 将整数转换为罗马数字
     * @param num 要转换的整数（1-3999）
     * @return 罗马数字字符串
     */
    function intToRoman(uint16 num) public view returns (string memory) {
        // require(num > 0 && num < 4000, "Number must be between 1 and 3999");
        
        string memory result = "";
        uint16 remaining = num;

        for (uint8 i = 0; i < romanNumerals.length; i++) {
            while (remaining >= romanNumerals[i].value) {
                result = string(abi.encodePacked(result, romanNumerals[i].symbol));
                remaining -= romanNumerals[i].value;
            }
        }

        return result;
    }

    /**
     * @dev 测试函数：转换一些示例数字
     * @return 测试结果数组
     */
    function testConversion() public view returns (string[5] memory) {
        string[5] memory results;
        results[0] = intToRoman(3);    // 应该返回 "III"
        results[1] = intToRoman(4);    // 应该返回 "IV"
        results[2] = intToRoman(9);    // 应该返回 "IX"
        results[3] = intToRoman(58);   // 应该返回 "LVIII"
        results[4] = intToRoman(1994); // 应该返回 "MCMXCIV"
        return results;
    }
} 