# IndexSet

类似于 Rust 中 `IndexSet` 的数据结构实现，同时兼容 MoonBit 核心库中 `hashset` 的所有操作。

## Create

你可以通过 `new()` 或者  `from_array()` 方法 定义IndexSet

```moonbit
 let set1 = @IndexSet.of([3, 1, 2])
 let set2 = @IndexSet.new()
```

## Add & Contain

你可以通过` add` 方法，向 `IndexSet`  中增加元素，使用 ` conatin` 来查看`IndexSet` 中是否有该元素

```moonbit
 let s = @IndexSet.new()
 s.add("a")
 assert_true!(s.contains("a"))
```

## Remove

 你可以通过`remove()` 方法，移除`IndexSet`  中的元素

```moonbit
  let s = @IndexSet.of(["a", "b", "c"])
  s.remove("a")
  assert_false!(s.contains("a"))
```

## Size & Capacity

你可以使用`size()` 方法获取当前  `IndexSet`   里的元素个数，或者使用 `capacity()` 方法获取当前容器的容量

```moonbit
let set = @IndexSet.of([("a"), ("b"), ("c")])
assert_eq!(set.size(), 3)
assert_eq!(set.capacity(), 8)
```

你也可以使用 `is_empty()` 方法判断  `IndexSet`   是否为空

```moonbit
let set : @hashset.T[Int] = @hashset.new()
assert_eq!(set.is_empty(), true)
```

## Clear

你可以使用 `clear` 清空 `IndexSet`  容器中的所有元素。

```moonbit
let set = @IndexSet.of(["a", "b", "c"])
set.clear()
assert_eq!(set.is_empty(), true)
```

## Iteration

您可以使用 `each()`  或`eachi()` 来遍历所有键。键将按照插入的先后顺序进行遍历。

```moonbit
let set = @IndexSet.of([("a"), ("b"), ("c")])
let arr = []
set.each(fn(k) { arr.push(k) })// arr:["a", "b", "c"]
let arr2 = []
set.eachi(fn(i, k) { arr2.push((i, k)) })//arr2:[(0, "a"), (1, "b"), (2, "c")]
```

## Set Operations

可以使用 `union()`、`intersection()`、`difference()` 和 `symmetric_difference()` 来执行集合操作。

```moonbit
  let m1 = @IndexSet.of(["a", "b", "c"])
  let m2 = @IndexSet.of(["b", "c", "d"])
  assert_eq!(m1.union(m2).to_array()..sort(), ["a", "b", "c", "d"])
  assert_eq!(m1.intersection(m2).to_array()..sort(), ["b", "c"])
  assert_eq!(m1.difference(m2).to_array()..sort(), ["a"])
  assert_eq!(m1.symmetric_difference(m2).to_array()..sort(), ["a", "d"])
```

## Pop & shift

你可以使用 `pop()`  方法，移除最后一个插入  `IndexSet`  容器中的元素并返回。 `shift()`  方法则是移除第一个元素并返回。

```
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

如果你只是想获取元素而并不想移除，可以使用 `peek_last`  和`peek_first` ，来分别获取最后一个 元素或者第一个元素

```
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.add("c")
  assert_eq!(m.peek_last().unwrap(), "c")
  assert_eq!(m.peek_first().unwrap(), "a")

```

## Sort

  `IndexSet`  可以使用`sorted`方法对元素进行排序，返回排序后 键的数组。`sorted` 排序并不会改变原来容器的元素

````moonbit
  let set = @IndexSet.of([5, 2, 4, 1, 3])
  let sorted_set = set.sorted(fn(a, b) { a - b })
  assert_eq!(set.to_array(), [5, 2, 4, 1, 3])
  assert_eq!(sorted_set.to_array(), [1, 2, 3, 4, 5])
````

如果你想使用原地算法进行排序，可以采用`sort`方法

```moonbit
  let set = @IndexSet.of([5, 2, 4, 1, 3])
  set.sort(fn(a, b) { a - b })
  assert_eq!(set.to_array(), [1, 2, 3, 4, 5])
```







