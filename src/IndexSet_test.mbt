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
