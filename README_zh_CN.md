# IndexSet

[English](https://github.com/moonbit-community/IndexSet/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/IndexSet/blob/master/README_zh_CN.md)

[![构建状态](https://img.shields.io/github/actions/workflow/status/moonbit-community/IndexSet/ci.yml)](https://github.com/moonbit-community/IndexSet/actions)  [![许可证](https://img.shields.io/github/license/moonbit-community/IndexSet)](LICENSE)  [![代码覆盖率](https://codecov.io/gh/moonbit-community/IndexSet/branch/main/graph/badge.svg)](https://codecov.io/gh/moonbit-community/IndexSet)  

类似于Rust中的`IndexSet`，这是一个与MoonBit核心`hashset`库所有操作兼容的数据结构实现。

## 🚀 核心特性
• 🔄 集合创建 - 支持多种方式创建`IndexSet`  
• ➕ 添加与查询 - 轻松添加元素并检查是否存在  
• ❌ 移除元素 - 从集合中删除特定元素  
• 📏 大小与容量 - 获取元素数量或当前容量  
• 🧹 清空集合 - 清除所有元素  
• 🔄 迭代遍历 - 按插入顺序遍历元素  
• ➗ 集合运算 - 执行并集、交集、差集和对称差集运算  
• 🧹 弹出元素 - 移除并返回首尾元素  
• 🔄 排序功能 - 对集合元素进行排序  
• 🔍 索引访问 - 通过索引获取元素或查找元素索引

## 📥 安装方式
```bash
moon add kesmeey/IndexSet
```

## 🚀 使用指南

### 🔨 创建集合
可使用`new()`或`from_array()`方法创建集合

```moonbit
let set1 = @IndexSet.of([3, 1, 2])
let set2 = @IndexSet.new()
```

### ➕ 添加与查询
使用`add()`添加元素，`contains()`检查存在性

```moonbit
let s = @IndexSet.new()
s.add("a")
assert_true!(s.contains("a"))
```

### ❌ 移除元素
使用`remove()`方法移除元素

```moonbit
let s = @IndexSet.of(["a", "b", "c"])
s.remove("a")
assert_false!(s.contains("a"))
```

### 📏 集合大小
`size()`获取元素数量，`capacity()`获取容量

```moonbit
let set = @IndexSet.of([("a"), ("b"), ("c")])
assert_eq!(set.size(), 3)
assert_eq!(set.capacity(), 8)
```

`is_empty()`检查是否为空集合

```moonbit
let set : @hashset.T[Int] = @hashset.new()
assert_eq!(set.is_empty(), true)
```

### 🧹 清空集合
`clear()`方法清空所有元素

```moonbit
let set = @IndexSet.of(["a", "b", "c"])
set.clear()
assert_eq!(set.is_empty(), true)
```

### 🔄 迭代遍历
`each()`和`eachi()`按插入顺序迭代

```moonbit
let set = @IndexSet.of([("a"), ("b"), ("c")])
let arr = []
set.each(fn(k) { arr.push(k) }) // arr: ["a", "b", "c"]
let arr2 = []
set.eachi(fn(i, k) { arr2.push((i, k)) }) // arr2: [(0, "a"), (1, "b"), (2, "c")]
```

### ➗ 集合运算
支持并集、交集、差集和对称差集

```moonbit
let m1 = @IndexSet.of(["a", "b", "c"])
let m2 = @IndexSet.of(["b", "c", "d"])
assert_eq!(m1.union(m2).to_array()..sort(), ["a", "b", "c", "d"])
assert_eq!(m1.intersection(m2).to_array()..sort(), ["b", "c"])
assert_eq!(m1.difference(m2).to_array()..sort(), ["a"])
assert_eq!(m1.symmetric_difference(m2).to_array()..sort(), ["a", "d"])
```

### 🧹 弹出元素
`pop()`移除末尾元素，`shift()`移除首部元素

```moonbit
let m = @IndexSet.new()
m.add("a")
m.add("b")
m.add("c")
assert_eq!(m.shift().unwrap(), "a")
assert_eq!(m.shift().unwrap(), "b")
m.add("d")
m.add("e")
assert_eq!(m.pop().unwrap(), "e")
assert_eq!(m.pop().unwrap(), "d")
```

`peek_last()`和`peek_first()`查看首尾元素

```moonbit
let m = @IndexSet.new()
m.add("a")
m.add("b")
m.add("c")
assert_eq!(m.peek_last().unwrap(), "c")
assert_eq!(m.peek_first().unwrap(), "a")
```

### 🔄 排序功能
`sorted()`返回排序后的新集合

```moonbit
let set = @IndexSet.of([5, 2, 4, 1, 3])
let sorted_set = set.sorted(fn(a, b) { a - b })
assert_eq!(set.to_array(), [5, 2, 4, 1, 3])
assert_eq!(sorted_set.to_array(), [1, 2, 3, 4, 5])
```

`sort()`原地排序

```moonbit
let set = @IndexSet.of([5, 2, 4, 1, 3])
set.sort(fn(a, b) { a - b })
assert_eq!(set.to_array(), [1, 2, 3, 4, 5])
```

### 🔍 索引访问
`get_at()`获取指定位置元素，`index_of()`查找元素索引

```moonbit
let set = @IndexSet.of([100, 200, 300, 400, 500])
assert_eq!(set.get_at(0), Some(100))
assert_eq!(set.index_of(300), Some(2))
```

## 📜 开源协议
本项目采用Apache-2.0许可证，详见LICENSE文件。

## 📢 联系支持
• Moonbit社区: moonbit-community  
• GitHub问题区: 提交问题  

👋 如果喜欢这个项目，请点亮⭐！祝编码愉快！🚀