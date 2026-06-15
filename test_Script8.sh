#!/bin/bash
# ============================================================
# test_Script8.sh — Script8.sh 最小回归验证
#
# 覆盖:
#   1. 默认参数（无参）正常运行
#   2. a > b 比较路径
#   3. a < b 比较路径
#   4. a == b 比较路径
#   5. 除数为 0 错误分支
#   6. 非法输入报错
#   7. 缺少参数（只传一个）提示正确
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/Script8.sh"

PASS=0
FAIL=0

assert_contains() {
    local test_name="$1"
    local output="$2"
    local expected="$3"

    if echo "$output" | grep -qF "$expected"; then
        echo "  PASS: $test_name"
        ((PASS++))
    else
        echo "  FAIL: $test_name"
        echo "    期望包含: '$expected'"
        echo "    实际输出: '$output'"
        ((FAIL++))
    fi
}

assert_exit_code() {
    local test_name="$1"
    local actual="$2"
    local expected="$3"

    if [[ "$actual" -eq "$expected" ]]; then
        echo "  PASS: $test_name"
        ((PASS++))
    else
        echo "  FAIL: $test_name"
        echo "    期望退出码: $expected, 实际: $actual"
        ((FAIL++))
    fi
}

echo "========================================"
echo " Script8.sh 回归测试"
echo "========================================"

# ------ 测试 1: 默认参数（无参）------
echo ""
echo "[测试 1] 默认参数 (无参) 正常运行"
output=$(bash "$SCRIPT" 2>&1)
rc=$?
assert_exit_code "退出码为 0" "$rc" 0
assert_contains "使用默认值 a=10" "$output" "a=10"
assert_contains "使用默认值 b=20" "$output" "b=20"
assert_contains "a + b = 30" "$output" "a + b = 30"
assert_contains "a - b = -10" "$output" "a - b = -10"
assert_contains "a * b = 200" "$output" "a * b = 200"
assert_contains "a / b = 0" "$output" "a / b = 0"
assert_contains "a % b = 10" "$output" "a % b = 10"
assert_contains "a 小于 b" "$output" "a 小于 b"

# ------ 测试 2: a > b 路径 ------
echo ""
echo "[测试 2] a > b 比较路径 (30 5)"
output=$(bash "$SCRIPT" 30 5 2>&1)
rc=$?
assert_exit_code "退出码为 0" "$rc" 0
assert_contains "a + b = 35" "$output" "a + b = 35"
assert_contains "a - b = 25" "$output" "a - b = 25"
assert_contains "a * b = 150" "$output" "a * b = 150"
assert_contains "a / b = 6" "$output" "a / b = 6"
assert_contains "a % b = 0" "$output" "a % b = 0"
assert_contains "a 大于 b" "$output" "a 大于 b"

# ------ 测试 3: a < b 路径 ------
echo ""
echo "[测试 3] a < b 比较路径 (3 7)"
output=$(bash "$SCRIPT" 3 7 2>&1)
rc=$?
assert_exit_code "退出码为 0" "$rc" 0
assert_contains "a + b = 10" "$output" "a + b = 10"
assert_contains "a - b = -4" "$output" "a - b = -4"
assert_contains "a * b = 21" "$output" "a * b = 21"
assert_contains "a 小于 b" "$output" "a 小于 b"

# ------ 测试 4: a == b 路径 ------
echo ""
echo "[测试 4] a == b 比较路径 (5 5)"
output=$(bash "$SCRIPT" 5 5 2>&1)
rc=$?
assert_exit_code "退出码为 0" "$rc" 0
assert_contains "a 等于 b" "$output" "a 等于 b"

# ------ 测试 5: 除数为 0 ------
echo ""
echo "[测试 5] 除数为 0 (8 0)"
output=$(bash "$SCRIPT" 8 0 2>&1)
rc=$?
assert_exit_code "退出码为 0" "$rc" 0
assert_contains "除数不能为 0 (除法)" "$output" "除数不能为 0"
# 确认没有产生错误的数值结果
if echo "$output" | grep -qE 'a / b = [0-9]'; then
    echo "  FAIL: 不应输出数值除法结果"
    ((FAIL++))
else
    echo "  PASS: 未输出数值除法结果"
    ((PASS++))
fi

# ------ 测试 6: 非法输入 ------
echo ""
echo "[测试 6] 非法输入 (abc 5)"
output=$(bash "$SCRIPT" abc 5 2>&1)
rc=$?
assert_exit_code "退出码非 0" "$rc" 1
assert_contains "错误提示包含 '不是有效的整数'" "$output" "不是有效的整数"

echo ""
echo "[测试 6b] 非法输入 (10 3.14)"
output=$(bash "$SCRIPT" 10 3.14 2>&1)
rc=$?
assert_exit_code "退出码非 0" "$rc" 1
assert_contains "错误提示包含 '不是有效的整数'" "$output" "不是有效的整数"

# ------ 测试 7: 缺少参数（只传一个）------
echo ""
echo "[测试 7] 缺少参数 (只传一个: 10)"
output=$(bash "$SCRIPT" 10 2>&1)
rc=$?
assert_exit_code "退出码非 0" "$rc" 1
assert_contains "参数数量不正确" "$output" "参数数量不正确"
assert_contains "用法提示" "$output" "用法"

# ------ 测试 8: 负数输入 ------
echo ""
echo "[测试 8] 负数输入 (-3 7)"
output=$(bash "$SCRIPT" -3 7 2>&1)
rc=$?
assert_exit_code "退出码为 0" "$rc" 0
assert_contains "a + b = 4" "$output" "a + b = 4"
assert_contains "a - b = -10" "$output" "a - b = -10"
assert_contains "a * b = -21" "$output" "a * b = -21"
assert_contains "a 小于 b" "$output" "a 小于 b"

# ------ 汇总 ------
echo ""
echo "========================================"
echo " 测试结果汇总"
echo "========================================"
echo "  通过: $PASS"
echo "  失败: $FAIL"
echo "========================================"

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
else
    echo "  全部通过!"
    exit 0
fi
