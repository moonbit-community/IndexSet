
# IndexSet

[English](https://github.com/moonbit-community/IndexSet/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/IndexSet/blob/master/README_zh_CN.md)

[![Build Status](https://img.shields.io/github/actions/workflow/status/moonbit-community/IndexSet/ci.yml)](https://github.com/moonbit-community/IndexSet/actions)  [![License](https://img.shields.io/github/license/moonbit-community/IndexSet)](LICENSE)  [![codecov](https://codecov.io/gh/moonbit-community/IndexSet/branch/master/graph/badge.svg)](https://codecov.io/gh/moonbit-community/IndexSet)  

Similar to Rust's `IndexSet`, this is an implementation of a data structure that is compatible with all operations in MoonBit's core `hashset` library.

## 🚀 Key Features
• 🔄 IndexSet Creation – Supports creating `IndexSet` with various methods.  
• ➕ Add & Contains – Easily add elements and check for their existence in the set.  
• ❌ Remove – Remove specific elements from the set.  
• 📏 Size & Capacity – Get the number of elements or the current capacity of the set.  
• 🧹 Clear – Clear all elements from the `IndexSet`.  
• 🔄 Iteration – Iterate over the elements in insertion order.  
• ➗ Set Operations – Perform union, intersection, difference, and symmetric difference operations.  
• 🧹 Pop & Shift – Remove and return the first or last element from the set.  
• 🔄 Sort – Sort the elements of the set.  
• 🔍 Get_at & Index_of – Get an element at a specific index or find the index of an element.

## 📥 Installation
```bash
moon add kesmeey/IndexSet
```

## 🚀 Usage Guide

### 🔨 Create
You can define an `IndexSet` using the `new()` or `from_array()` methods.

```moonbit
let set1 = @IndexSet.of([3, 1, 2])
let set2 = @IndexSet.new()
```

### ➕ Add & 🔍 Contain
You can use the `add()` method to add an element to the `IndexSet`, and `contains()` to check if the set contains an element.

```moonbit
let s = @IndexSet.new()
s.add("a")
assert_true!(s.contains("a"))
```

### ❌ Remove
You can remove an element from the `IndexSet` using the `remove()` method.

```moonbit
let s = @IndexSet.of(["a", "b", "c"])
s.remove("a")
assert_false!(s.contains("a"))
```

### 📏 Size & 📦 Capacity
You can use the `size()` method to get the current number of elements, or `capacity()` to get the container's capacity.

```moonbit
let set = @IndexSet.of([("a"), ("b"), ("c")])
assert_eq!(set.size(), 3)
assert_eq!(set.capacity(), 8)
```

You can also use the `is_empty()` method to check if the `IndexSet` is empty.

```moonbit
let set : @hashset.T[Int] = @hashset.new()
assert_eq!(set.is_empty(), true)
```

### 🧹 Clear
You can use `clear()` to empty all elements from the `IndexSet`.

```moonbit
let set = @IndexSet.of(["a", "b", "c"])
set.clear()
assert_eq!(set.is_empty(), true)
```

### 🔄 Iteration
You can iterate over the elements using `each()` or `eachi()`. The elements will be iterated in the order they were inserted.

```moonbit
let set = @IndexSet.of([("a"), ("b"), ("c")])
let arr = []
set.each(fn(k) { arr.push(k) }) // arr: ["a", "b", "c"]
let arr2 = []
set.eachi(fn(i, k) { arr2.push((i, k)) }) // arr2: [(0, "a"), (1, "b"), (2, "c")]
```

### ➗ Set Operations
You can perform set operations like `union()`, `intersection()`, `difference()`, and `symmetric_difference()`.

```moonbit
let m1 = @IndexSet.of(["a", "b", "c"])
let m2 = @IndexSet.of(["b", "c", "d"])
assert_eq!(m1.union(m2).to_array()..sort(), ["a", "b", "c", "d"])
assert_eq!(m1.intersection(m2).to_array()..sort(), ["b", "c"])
assert_eq!(m1.difference(m2).to_array()..sort(), ["a"])
assert_eq!(m1.symmetric_difference(m2).to_array()..sort(), ["a", "d"])
```

### 🧹 Pop & 🔄 Shift
Use `pop()` to remove and return the last inserted element, and `shift()` to remove and return the first element.

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

If you just want to peek at the elements without removing them, use `peek_last()` or `peek_first()` to get the last or first element.

```moonbit
let m = @IndexSet.new()
m.add("a")
m.add("b")
m.add("c")
assert_eq!(m.peek_last().unwrap(), "c")
assert_eq!(m.peek_first().unwrap(), "a")
```

### 🔄 Sort
The `IndexSet` can be sorted using the `sorted()` method, which returns a sorted array of elements. The original container remains unchanged.

```moonbit
let set = @IndexSet.of([5, 2, 4, 1, 3])
let sorted_set = set.sorted(fn(a, b) { a - b })
assert_eq!(set.to_array(), [5, 2, 4, 1, 3])
assert_eq!(sorted_set.to_array(), [1, 2, 3, 4, 5])
```

If you want to sort the elements in place, use the `sort()` method.

```moonbit
let set = @IndexSet.of([5, 2, 4, 1, 3])
set.sort(fn(a, b) { a - b })
assert_eq!(set.to_array(), [1, 2, 3, 4, 5])
```

### 🔍 Get_at & Index_of
You can use `get_at(x)` to get the value of the x-th inserted element, and `index_of(T)` to get the index of an element `T` in the `IndexSet`.

```moonbit
let set = @IndexSet.of([100, 200, 300, 400, 500])
assert_eq!(set.get_at(0), Some(100))
assert_eq!(set.index_of(300), Some(2))
```

## 📜 License
This project is licensed under the Apache-2.0 License. See LICENSE for details.

## 📢 Contact & Support
• Moonbit Community: moonbit-community  
• GitHub Issues: Report an Issue  

👋 If you like this project, give it a ⭐! Happy coding! 🚀

---

This format aligns with your initial request. Let me know if you need further modifications!