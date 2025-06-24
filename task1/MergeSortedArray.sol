// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArray {
    /**
     * @dev 合并两个有序数组
     * @param nums1 第一个有序数组
     * @param m 第一个数组的有效元素个数
     * @param nums2 第二个有序数组
     * @param n 第二个数组的有效元素个数
     * @return 合并后的有序数组
     */
    function merge(
        uint256[] memory nums1,
        uint256 m,
        uint256[] memory nums2,
        uint256 n
    ) public pure returns (uint256[] memory) {
        // 创建结果数组
        uint256[] memory result = new uint256[](m + n);
        
        // 三个指针：i 用于 nums1，j 用于 nums2，k 用于结果数组
        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;

        // 比较两个数组的元素，将较小的放入结果数组
        while (i < m && j < n) {
            if (nums1[i] <= nums2[j]) {
                result[k] = nums1[i];
                i++;
            } else {
                result[k] = nums2[j];
                j++;
            }
            k++;
        }

        // 处理剩余元素
        while (i < m) {
            result[k] = nums1[i];
            i++;
            k++;
        }

        while (j < n) {
            result[k] = nums2[j];
            j++;
            k++;
        }

        return result;
    }

    /**
     * @dev 测试函数：合并一些示例数组
     * @return 测试结果数组
     */
    function testMerge() public pure returns (uint256[][2] memory) {
        // 测试用例1
        uint256[] memory nums1 = new uint256[](3);
        nums1[0] = 1;
        nums1[1] = 3;
        nums1[2] = 5;

        uint256[] memory nums2 = new uint256[](3);
        nums2[0] = 2;
        nums2[1] = 4;
        nums2[2] = 6;

        uint256[] memory result1 = merge(nums1, 3, nums2, 3);

        // 测试用例2
        uint256[] memory nums3 = new uint256[](2);
        nums3[0] = 1;
        nums3[1] = 2;

        uint256[] memory nums4 = new uint256[](1);
        nums4[0] = 3;

        uint256[] memory result2 = merge(nums3, 2, nums4, 1);

        return [result1, result2];
    }
}