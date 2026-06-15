#!/bin/sh
#
# Script16.sh — 可复用的 while 循环计数工具
#
# 用法: ./Script16.sh [选项] [起始值 结束值 [步长]]
#
# 选项:
#   -s, --start N       起始值 (默认: 0)
#   -e, --end N         结束值 (默认: 9)
#   -t, --step N        步长   (默认: 自动判断 +1 或 -1)
#   -p, --prefix STR    输出前缀标签，如 "步骤"
#   -i, --index         显示当前是第几步 (从1开始)
#   -h, --help          显示帮助信息
#
# 示例:
#   ./Script16.sh                    # 默认: 0 到 9，步长 1
#   ./Script16.sh 5 15              # 5 到 15，步长 1
#   ./Script16.sh 10 1 -2           # 降序，步长 -2
#   ./Script16.sh -s 0 -e 20 -t 5  # 使用长选项
#   ./Script16.sh -p "步骤" 1 5     # 带前缀输出
#   ./Script16.sh -i 1 5            # 显示步数索引

usage() {
    echo "用法: $0 [选项] [起始值 结束值 [步长]]"
    echo ""
    echo "选项:"
    echo "  -s, --start N       起始值 (默认: 0)"
    echo "  -e, --end N         结束值 (默认: 9)"
    echo "  -t, --step N        步长   (默认: 自动判断)"
    echo "  -p, --prefix STR    输出前缀标签"
    echo "  -i, --index         显示当前是第几步 (从1开始)"
    echo "  -h, --help          显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                       # 默认: 0 到 9"
    echo "  $0 5 15                  # 5 到 15"
    echo "  $0 10 1 -2               # 降序，步长 -2"
    echo "  $0 -s 0 -e 20 -t 5       # 长选项"
    echo "  $0 -p \"步骤\" 1 5          # 带前缀"
    echo "  $0 -i 1 5                # 显示步数"
    exit 0
}

# 判断字符串是否为合法整数 (支持负数，如 -3)
is_integer() {
    case "$1" in
        ''|*[!0-9-]*) return 1 ;;
        *-*)
            # 负号只能出现在首位，且后面至少有一位数字
            case "$1" in
                -[0-9]*) return 0 ;;
                *) return 1 ;;
            esac
            ;;
        *) return 0 ;;
    esac
}

# 默认值
start=0
end=9
step=""
prefix=""
show_index=0

# ---------- 解析参数 ----------
positional=""
pos_count=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -s|--start)
            start="$2"
            shift 2
            ;;
        -e|--end)
            end="$2"
            shift 2
            ;;
        -t|--step)
            step="$2"
            shift 2
            ;;
        -p|--prefix)
            prefix="$2"
            shift 2
            ;;
        -i|--index)
            show_index=1
            shift
            ;;
        --)
            shift
            # -- 之后的全部作为位置参数
            while [ $# -gt 0 ]; do
                pos_count=$((pos_count + 1))
                case $pos_count in
                    1) start="$1" ;;
                    2) end="$1" ;;
                    3) step="$1" ;;
                    *) echo "错误: 多余的参数 '$1'" >&2; exit 1 ;;
                esac
                shift
            done
            ;;
        -[0-9]*)
            # 负数当作位置参数处理
            pos_count=$((pos_count + 1))
            case $pos_count in
                1) start="$1" ;;
                2) end="$1" ;;
                3) step="$1" ;;
                *) echo "错误: 多余的参数 '$1'" >&2; exit 1 ;;
            esac
            shift
            ;;
        -*)
            echo "错误: 未知选项 '$1'" >&2
            echo "使用 -h 查看帮助" >&2
            exit 1
            ;;
        *)
            pos_count=$((pos_count + 1))
            case $pos_count in
                1) start="$1" ;;
                2) end="$1" ;;
                3) step="$1" ;;
                *) echo "错误: 多余的参数 '$1'" >&2; exit 1 ;;
            esac
            shift
            ;;
    esac
done

# ---------- 输入校验 ----------
if ! is_integer "$start"; then
    echo "错误: 起始值 '$start' 不是合法整数" >&2
    exit 1
fi

if ! is_integer "$end"; then
    echo "错误: 结束值 '$end' 不是合法整数" >&2
    exit 1
fi

# 如果未指定步长，根据起始和结束自动推断方向
if [ -z "$step" ]; then
    if [ "$start" -le "$end" ]; then
        step=1
    else
        step=-1
    fi
fi

if ! is_integer "$step"; then
    echo "错误: 步长 '$step' 不是合法整数" >&2
    exit 1
fi

if [ "$step" -eq 0 ]; then
    echo "错误: 步长不能为 0，否则循环无法终止" >&2
    exit 1
fi

# 步长方向与区间方向一致性检查
if [ "$start" -lt "$end" ] && [ "$step" -lt 0 ]; then
    echo "错误: 起始值($start)小于结束值($end)，但步长为负($step)，无法到达目标" >&2
    exit 1
fi

if [ "$start" -gt "$end" ] && [ "$step" -gt 0 ]; then
    echo "错误: 起始值($start)大于结束值($end)，但步长为正($step)，无法到达目标" >&2
    exit 1
fi

# ---------- 计数循环 ----------
a=$start
index=1

while true; do
    # 升序: a <= end; 降序: a >= end
    if [ "$step" -gt 0 ] && [ "$a" -gt "$end" ]; then
        break
    fi
    if [ "$step" -lt 0 ] && [ "$a" -lt "$end" ]; then
        break
    fi

    # 构建输出行
    line=""
    if [ -n "$prefix" ] && [ "$show_index" -eq 1 ]; then
        line="${prefix}#${index}: ${a}"
    elif [ -n "$prefix" ]; then
        line="${prefix}: ${a}"
    elif [ "$show_index" -eq 1 ]; then
        line="#${index}: ${a}"
    else
        line="${a}"
    fi

    echo "$line"

    a=$((a + step))
    index=$((index + 1))
done
