// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinarySearch {
    /**
     * @dev 二分查找目标值
     * @param nums 有序数组
     * @param target 目标值
     * @return 目标值在数组中的索引，如果不存在则返回 -1
     */
    function search(uint256[] memory nums, uint256 target) public pure returns (int256) {
        // 处理空数组
        if (nums.length == 0) {
            return -1;
        }

        // 初始化左右边界
        uint256 left = 0;
        uint256 right = nums.length - 1;

        // 二分查找
        while (left <= right) {
            // 计算中间位置，避免溢出
            uint256 mid = left + (right - left) / 2;

            // 找到目标值
            if (nums[mid] == target) {
                return int256(mid);
            }
            
            // 目标值在右半部分
            if (nums[mid] < target) {
                left = mid + 1;
            }
            // 目标值在左半部分
            else {
                right = mid - 1;
            }
        }

        // 未找到目标值
        return -1;
    }

    /**
     * @dev 测试函数：测试二分查找
     * @return 测试结果数组
     */
    function testSearch() public pure returns (int256[4] memory) {
        // 测试用例1: 正常情况
        uint256[] memory nums1 = new uint256[](5);
        nums1[0] = 1;
        nums1[1] = 3;
        nums1[2] = 5;
        nums1[3] = 7;
        nums1[4] = 9;
        int256 result1 = search(nums1, 5);  // 应该返回 2

        // 测试用例2: 目标值不存在
        int256 result2 = search(nums1, 4);  // 应该返回 -1

        // 测试用例3: 目标值在边界
        int256 result3 = search(nums1, 1);  // 应该返回 0
        int256 result4 = search(nums1, 9);  // 应该返回 4

        return [result1, result2, result3, result4];
    }
} 