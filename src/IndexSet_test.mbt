// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
let default_init_capacity = 8

///|
test "doc" {
  let set1 = @IndexSet.of([3, 8, 1])
  set1.add(3)
  set1.add(4)
  inspect!(set1, content="@IndexSet.of([3, 8, 1, 4])")
}

///|
test "123" {
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.add("c")
  assert_eq!(m.peek_last().unwrap(), "c")
  assert_eq!(m.peek_first().unwrap(), "a")
}

///|
test "new" {
  let m : @IndexSet.T[Int] = @IndexSet.new()
  assert_eq!(m.capacity(), default_init_capacity)
  assert_eq!(m.size(), 0)
}

///|
test "insert" {
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.add("c")
  assert_true!(m.contains("a"))
  assert_true!(m.contains("b"))
  assert_true!(m.contains("c"))
  assert_false!(m.contains("d"))
}

///|
test "from_array" {
  let m = @IndexSet.of(["a", "b", "c"])
  assert_true!(m.contains("a"))
  assert_true!(m.contains("b"))
  assert_true!(m.contains("c"))
  assert_false!(m.contains("d"))
}

///|
test "size" {
  let m = @IndexSet.new()
  assert_eq!(m.size(), 0)
  m.add("a")
  assert_eq!(m.size(), 1)
}

///|
test "is_empty" {
  let m = @IndexSet.new()
  assert_eq!(m.is_empty(), true)
  m.add("a")
  assert_eq!(m.is_empty(), false)
  m.remove("a")
  assert_eq!(m.is_empty(), true)
}

///|
test "iter" {
  let m = @IndexSet.of(["a", "b", "c"])
  let mut sum = ""
  m.each(fn(k) { sum += k })
  inspect!(sum, content="abc")
}

///|
test "iteri" {
  let m = @IndexSet.of(["1", "2", "3"])
  let mut s = ""
  let mut sum = 0
  m.eachi(fn(i, k) {
    s += k
    sum += i
  })
  inspect!(s, content="123")
  inspect!(sum, content="3")
}

///|
test "union" {
  let m1 = @IndexSet.of(["a", "b", "c"])
  let m2 = @IndexSet.of(["b", "c", "d"])
  let m = m1.union(m2)
  assert_eq!(m.size(), 4)
  assert_true!(m.contains("a"))
  assert_true!(m.contains("b"))
  assert_true!(m.contains("c"))
  assert_true!(m.contains("d"))
}

///|
test "intersection" {
  let m1 = @IndexSet.of(["a", "b", "c"])
  let m2 = @IndexSet.of(["b", "c", "d"])
  let m = m1.intersection(m2)
  assert_eq!(m.size(), 2)
  assert_false!(m.contains("a"))
  assert_true!(m.contains("b"))
  assert_true!(m.contains("c"))
  assert_false!(m.contains("d"))
}

///|
test "difference" {
  let m1 = @IndexSet.of(["a", "b", "c"])
  let m2 = @IndexSet.of(["b", "c", "d"])
  let m = m1.difference(m2)
  assert_eq!(m.size(), 1)
  assert_true!(m.contains("a"))
  assert_false!(m.contains("b"))
  assert_false!(m.contains("c"))
  assert_false!(m.contains("d"))
}

///|
test "symmetric_difference" {
  let m1 = @IndexSet.of(["a", "b", "c"])
  let m2 = @IndexSet.of(["b", "c", "d"])
  let m = m1.symmetric_difference(m2)
  assert_eq!(m.size(), 2)
  assert_true!(m.contains("a"))
  assert_false!(m.contains("b"))
  assert_false!(m.contains("c"))
  assert_true!(m.contains("d"))
}

///|
test "iter" {
  let buf = StringBuilder::new(size_hint=20)
  let map = @IndexSet.of(["a", "b", "c"])
  map.iter().each(fn(e) { buf.write_string("[\{e}]") })
  inspect!(buf, content="[a][b][c]")
  buf.reset()
  map.iter().take(2).each(fn(e) { buf.write_string("[\{e}]") })
  inspect!(buf, content="[a][b]")
}

///|
test "from_array" {
  let arr = ["a", "b", "c"]
  let m = @IndexSet.from_array(arr)
  assert_true!(m.contains("a"))
  assert_true!(m.contains("b"))
  assert_true!(m.contains("c"))
  assert_false!(m.contains("d"))
}

///|
test "insert_and_grow" {
  let m = @IndexSet.new()
  for i in 0..<10 {
    m.add(i.to_string())
  }
  assert_eq!(m.size(), 10)
  assert_eq!(m.capacity(), 16)
}

///|
test "remove_and_shift_back" {
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.add("c")
  m.add("d")
  m.remove("b")
  assert_false!(m.contains("b"))
  assert_true!(m.contains("a"))
  assert_true!(m.contains("c"))
  assert_true!(m.contains("d"))
}

///|
test "capacity_and_size" {
  let m = @IndexSet.new()
  assert_eq!(m.capacity(), default_init_capacity)
  assert_eq!(m.size(), 0)
  m.add("a")
  assert_eq!(m.size(), 1)
}

///|
test "clear_and_reinsert" {
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.clear()
  assert_eq!(m.size(), 0)
  m.add("c")
  assert_eq!(m.size(), 1)
  assert_true!(m.contains("c"))
}

///|
test "insert_and_grow" {
  let m = @IndexSet.new()
  for i in 0..<10 {
    m.add(i.to_string())
  }
  assert_eq!(m.size(), 10)
  assert_eq!(m.capacity(), 16)
}

///|
test "remove_and_shift_back" {
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.add("c")
  m.add("d")
  m.remove("b")
  assert_false!(m.contains("b"))
  assert_true!(m.contains("a"))
  assert_true!(m.contains("c"))
  assert_true!(m.contains("d"))
}

///|
test "capacity_and_size" {
  let m = @IndexSet.new()
  assert_eq!(m.capacity(), default_init_capacity)
  assert_eq!(m.size(), 0)
  m.add("a")
  assert_eq!(m.size(), 1)
}

///|
test "clear_and_reinsert" {
  let m = @IndexSet.new()
  m.add("a")
  m.add("b")
  m.clear()
  assert_eq!(m.size(), 0)
  m.add("c")
  assert_eq!(m.size(), 1)
  assert_true!(m.contains("c"))
}

///|
test "from_iter multiple elements iter" {
  inspect!(
    @IndexSet.from_iter([1, 2, 3].iter()),
    content="@IndexSet.of([1, 2, 3])",
  )
}

///|
test "from_iter single element iter" {
  inspect!(@IndexSet.from_iter([1].iter()), content="@IndexSet.of([1])")
}

///|
test "from_iter empty iter" {
  let map : @IndexSet.T[Int] = @IndexSet.from_iter(Iter::empty())
  inspect!(map, content="@IndexSet.of([])")
}

///|
test "IndexSet arbitrary" {
  let samples : Array[@IndexSet.T[Int]] = @quickcheck.samples(20)
  inspect!(
    samples[5:10],
    content="[@IndexSet.of([0]), @IndexSet.of([0]), @IndexSet.of([0]), @IndexSet.of([0]), @IndexSet.of([0, 3])]",
  )
  inspect!(
    samples[11:15],
    content="[@IndexSet.of([0, 1]), @IndexSet.of([0, -1, 4]), @IndexSet.of([0]), @IndexSet.of([0, -1, 2])]",
  )
}

///|
test "@IndexSet.to_array/empty" {
  let set : @IndexSet.T[Int] = @IndexSet.new()
  inspect!(@IndexSet.to_array(set), content="[]")
}

///|
test "@IndexSet.to_array/single" {
  let set = @IndexSet.new()
  set.add(42)
  inspect!(@IndexSet.to_array(set), content="[42]")
}

///|
test "@IndexSet.to_array/multiple" {
  let set = @IndexSet.new()
  set.add(1)
  set.add(2)
  set.add(3)
  set.add(4)
  inspect!(@IndexSet.to_array(set), content="[1, 2, 3, 4]")
}

///|
test "peek_first" {
  let m = @IndexSet.new()
  assert_eq!(m.peek_first(), None)
  m.add("a")
  m.add("b")
  m.add("c")
  assert_eq!(m.peek_first(), Some("a"))
  m.remove("a")
  assert_eq!(m.peek_first(), Some("b"))
  m.clear()
  assert_eq!(m.peek_first(), None)
}

///|
test "peek_last" {
  let m = @IndexSet.new()
  assert_eq!(m.peek_last(), None)
  m.add("a")
  m.add("b")
  m.add("c")
  assert_eq!(m.peek_last(), Some("c"))
  m.remove("c")
  assert_eq!(m.peek_last(), Some("b"))
  m.clear()
  assert_eq!(m.peek_last(), None)
}

///|
test "pop" {
  let m = @IndexSet.new()
  assert_eq!(m.pop(), None)
  m.add("a")
  m.add("b")
  m.add("c")
  assert_eq!(m.pop(), Some("c"))
  assert_eq!(m.size(), 2)
  assert_eq!(m.contains("c"), false)
  assert_eq!(m.pop(), Some("b"))
  assert_eq!(m.pop(), Some("a"))
  assert_eq!(m.pop(), None)
  assert_eq!(m.is_empty(), true)
}

///|
test "shift" {
  let m = @IndexSet.new()
  assert_eq!(m.shift(), None)
  m.add("a")
  m.add("b")
  m.add("c")
  assert_eq!(m.shift(), Some("a"))
  assert_eq!(m.size(), 2)
  assert_eq!(m.contains("a"), false)
  assert_eq!(m.shift(), Some("b"))
  assert_eq!(m.shift(), Some("c"))
  assert_eq!(m.shift(), None)
  assert_eq!(m.is_empty(), true)
}

///|
test "pop_and_peek" {
  let m = @IndexSet.new()
  m.add(1)
  m.add(2)
  m.add(3)
  assert_eq!(m.peek_last(), Some(3))
  assert_eq!(m.pop(), Some(3))
  assert_eq!(m.peek_last(), Some(2))
  assert_eq!(m.size(), 2)
}

///|
test "shift_and_peek" {
  let m = @IndexSet.new()
  m.add(1)
  m.add(2)
  m.add(3)
  assert_eq!(m.peek_first(), Some(1))
  assert_eq!(m.shift(), Some(1))
  assert_eq!(m.peek_first(), Some(2))
  assert_eq!(m.size(), 2)
}

///|
test "sorted" {
  let set = @IndexSet.of([5, 2, 4, 1, 3])
  let sorted_set = set.sorted(fn(a, b) { a - b })

  // 原集合保持不变
  assert_eq!(set.to_array(), [5, 2, 4, 1, 3])

  // 新集合已排序
  assert_eq!(sorted_set.to_array(), [1, 2, 3, 4, 5])
}

///|
test "sorted_by_key" {
  let set = @IndexSet.of([5, 2, 4, 1, 3])
  let sorted_set = set.sorted_by_key()

  // 原集合保持不变
  assert_eq!(set.to_array(), [5, 2, 4, 1, 3])

  // 新集合已按自然顺序排序
  assert_eq!(sorted_set.to_array(), [1, 2, 3, 4, 5])
}

///|
test "sorted_by" {
  // 按元素对10的余数排序
  let set = @IndexSet.of([12, 5, 8, 3, 16, 7])
  let sorted_set = set.sorted_by(fn(n) { n % 10 })

  // 原集合保持不变
  assert_eq!(set.to_array(), [12, 5, 8, 3, 16, 7])

  // 新集合按余数排序：12(2), 3(3), 5(5), 16(6), 7(7), 8(8)
  assert_eq!(sorted_set.to_array(), [12, 3, 5, 16, 7, 8])
}

///|
test "sort" {
  let set = @IndexSet.of([5, 2, 4, 1, 3])
  set.sort(fn(a, b) { a - b })

  // 集合已排序
  assert_eq!(set.to_array(), [1, 2, 3, 4, 5])
}

///|
test "sort_by_key" {
  let set = @IndexSet.of([5, 2, 4, 1, 3])
  set.sort_by_key()

  // 集合已按自然顺序排序
  assert_eq!(set.to_array(), [1, 2, 3, 4, 5])
}

///|
test "sort_by" {
  // 创建一个字符串集合
  let set = @IndexSet.of(["apple", "banana", "kiwi", "orange", "grape"])

  // 按字符串长度排序
  set.sort_by(fn(s) { s.length() })

  // 集合已按字符串长度排序: kiwi(4), apple(5), grape(5), banana(6), orange(6)
  assert_eq!(set.to_array(), ["kiwi", "apple", "grape", "banana", "orange"])
}

///|
test "sorted_desc" {
  let set = @IndexSet.of([1, 4, 2, 5, 3])
  let sorted_set = set.sorted_desc(fn(a, b) { a - b })

  // 原集合保持不变
  assert_eq!(set.to_array(), [1, 4, 2, 5, 3])

  // 新集合已降序排序
  assert_eq!(sorted_set.to_array(), [5, 4, 3, 2, 1])
}

///|
test "sorted_by_key_desc" {
  let set = @IndexSet.of([1, 4, 2, 5, 3])
  let sorted_set = set.sorted_by_key_desc()

  // 原集合保持不变
  assert_eq!(set.to_array(), [1, 4, 2, 5, 3])

  // 新集合已按自然顺序降序排序
  assert_eq!(sorted_set.to_array(), [5, 4, 3, 2, 1])
}

///|
test "sort_desc" {
  let set = @IndexSet.of([1, 4, 2, 5, 3])
  set.sort_desc(fn(a, b) { a - b })

  // 集合已降序排序
  assert_eq!(set.to_array(), [5, 4, 3, 2, 1])
}

///|
test "sort_by_key_desc" {
  let set = @IndexSet.of([1, 4, 2, 5, 3])
  set.sort_by_key_desc()

  // 集合已按自然顺序降序排序
  assert_eq!(set.to_array(), [5, 4, 3, 2, 1])
}
