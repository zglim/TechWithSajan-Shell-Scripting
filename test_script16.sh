#!/bin/sh
#
# test_script16.sh — Script16.sh 最小回归测试
#
# 每个测试用例输出 PASS / FAIL 并在最后汇总结果
#

SCRIPT="./Script16.sh"
PASS=0
FAIL=0

assert_output() {
    label="$1"
    expected="$2"
    actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  期望: $(echo "$expected" | head -5)"
        echo "  实际: $(echo "$actual" | head -5)"
        FAIL=$((FAIL + 1))
    fi
}

assert_exit_code() {
    label="$1"
    expected="$2"
    actual="$3"
    if [ "$expected" -eq "$actual" ]; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        echo "  期望退出码: $expected"
        echo "  实际退出码: $actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    label="$1"
    needle="$2"
    haystack="$3"
    case "$haystack" in
        *"$needle"*)
            echo "PASS: $label"
            PASS=$((PASS + 1))
            ;;
        *)
            echo "FAIL: $label"
            echo "  未找到: '$needle'"
            echo "  实际输出: $(echo "$haystack" | head -5)"
            FAIL=$((FAIL + 1))
            ;;
    esac
}

echo "===== Script16.sh 回归测试 ====="
echo ""

# ---- T1: 默认行为 (0-9) ----
echo "--- T1: 默认行为 ---"
output=$($SCRIPT)
expected="0
1
2
3
4
5
6
7
8
9"
assert_output "默认参数输出 0..9" "$expected" "$output"

# ---- T2: 升序计数 (自定义起止) ----
echo "--- T2: 升序计数 ---"
output=$($SCRIPT 3 7)
expected="3
4
5
6
7"
assert_output "升序 3..7" "$expected" "$output"

# ---- T3: 自定义步长 ----
echo "--- T3: 自定义步长 ---"
output=$($SCRIPT 0 10 3)
expected="0
3
6
9"
assert_output "步长 3: 0..10" "$expected" "$output"

# ---- T4: 降序计数 ----
echo "--- T4: 降序计数 ---"
output=$($SCRIPT 5 1)
expected="5
4
3
2
1"
assert_output "降序 5..1" "$expected" "$output"

# ---- T5: 降序 + 自定义步长 ----
echo "--- T5: 降序自定义步长 ---"
output=$($SCRIPT 10 0 -3)
expected="10
7
4
1"
assert_output "降序步长 -3: 10..0" "$expected" "$output"

# ---- T6: 步长为 0 报错 ----
echo "--- T6: 步长为 0 ---"
output=$($SCRIPT 1 5 0 2>&1)
rc=$?
assert_exit_code "步长0应非零退出" 1 "$rc"
assert_contains "步长0提示错误" "步长不能为 0" "$output"

# ---- T7: 非法整数输入报错 ----
echo "--- T7: 非法整数 ---"
output=$($SCRIPT abc 5 2>&1)
rc=$?
assert_exit_code "非法起始值应非零退出" 1 "$rc"
assert_contains "非法起始值提示" "不是合法整数" "$output"

output=$($SCRIPT 1 xyz 2>&1)
rc=$?
assert_exit_code "非法结束值应非零退出" 1 "$rc"
assert_contains "非法结束值提示" "不是合法整数" "$output"

# ---- T8: 步长方向矛盾 ----
echo "--- T8: 步长方向矛盾 ---"
output=$($SCRIPT 1 10 -1 2>&1)
rc=$?
assert_exit_code "方向矛盾应非零退出" 1 "$rc"
assert_contains "方向矛盾提示" "无法到达目标" "$output"

output=$($SCRIPT 10 1 2 2>&1)
rc=$?
assert_exit_code "方向矛盾(反向)应非零退出" 1 "$rc"
assert_contains "方向矛盾(反向)提示" "无法到达目标" "$output"

# ---- T9: 长选项 ----
echo "--- T9: 长选项 ---"
output=$($SCRIPT -s 2 -e 8 -t 2)
expected="2
4
6
8"
assert_output "长选项 -s 2 -e 8 -t 2" "$expected" "$output"

# ---- T10: 前缀标签 ----
echo "--- T10: 前缀标签 ---"
output=$($SCRIPT -p "步骤" 1 3)
expected="步骤: 1
步骤: 2
步骤: 3"
assert_output "前缀输出" "$expected" "$output"

# ---- T11: 索引模式 ----
echo "--- T11: 索引模式 ---"
output=$($SCRIPT -i 10 13)
expected="#1: 10
#2: 11
#3: 12
#4: 13"
assert_output "索引模式输出" "$expected" "$output"

# ---- T12: 前缀 + 索引 ----
echo "--- T12: 前缀 + 索引 ---"
output=$($SCRIPT -p "计数" -i 5 7)
expected="计数#1: 5
计数#2: 6
计数#3: 7"
assert_output "前缀+索引输出" "$expected" "$output"

# ---- T13: 负数支持 ----
echo "--- T13: 负数 ---"
output=$($SCRIPT -2 2)
expected="-2
-1
0
1
2"
assert_output "负数范围 -2..2" "$expected" "$output"

# ---- T14: 单值输出 (start == end) ----
echo "--- T14: 单值 ---"
output=$($SCRIPT 5 5)
expected="5"
assert_output "起始等于结束" "$expected" "$output"

# ========== 汇总 ==========
echo ""
echo "==============================="
echo "总计: $((PASS + FAIL))  通过: $PASS  失败: $FAIL"
echo "==============================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
