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
// Default initial capacity
let default_init_capacity = 8

///|
/// Create new indexed hash set.
///|
/// Create new indexed hash set.
pub fn new[K](capacity~ : Int = default_init_capacity) -> T[K] {
  {
    core: {
      hash_to_idx: @hashmap.new(),
      entries: [],
      head: -1,
      tail: -1,
      position_to_idx: [], // 初始化为空数组
      idx_to_position: @hashmap.new(), // 初始化为空映射
    },
    size: 0,
    capacity,
    growAt: calc_grow_threshold(capacity),
    key_to_idx: @hashmap.new(),
  }
}

///|
/// Create new indexed hash set from array.
pub fn from_array[K : Hash + Eq](arr : Array[K]) -> T[K] {
  let set = new()
  arr.each(fn(e) { set.add(e) })
  set
}

///|
pub fn of[K : Hash + Eq](arr : FixedArray[K]) -> T[K] {
  let set = new()
  arr.each(fn(e) { set.add(e) })
  set
}

///|
/// Insert a key into hash set.
/// @alert unsafe "Panic if the hash set is full."
#deprecated("Use `add` instead.")
#coverage.skip
pub fn insert[K : Hash + Eq](self : T[K], key : K) -> Unit {
  self.add(key)
}

///|
/// Add a key to the hash set.
pub fn add[K : Hash + Eq](self : T[K], key : K) -> Unit {
  // 检查是否需要扩容
  if self.capacity == 0 || self.size >= self.growAt {
    self.grow()
  }

  // 计算哈希值
  let hash = key.hash()

  // 检查键是否已存在
  if self.contains(key) {
    return
  }

  // 创建新的桶
  let bucket_idx = self.core.entries.length()
  let new_bucket = {
    hash,
    key,
    next: -1, // 无后继
    prev: self.core.tail,
  } // 前驱为当前尾节点

  // 添加到桶数组
  self.core.entries.push(new_bucket)

  // 在映射中记录键到索引的映射
  self.key_to_idx.set(key, bucket_idx)

  // 更新链表结构
  if self.core.tail != -1 {
    // 更新原尾节点的后继为新节点
    self.core.entries[self.core.tail].next = bucket_idx
  }

  // 更新尾节点
  self.core.tail = bucket_idx

  // 如果这是第一个元素，也更新头节点
  if self.core.head == -1 {
    self.core.head = bucket_idx
  }

  // 在哈希表中记录
  self.insert_into_table(hash, bucket_idx)

  // 更新位置到索引的映射
  self.core.position_to_idx.push(bucket_idx)

  // 更新索引到位置的映射
  self.core.idx_to_position.set(bucket_idx, self.size)

  // 更新大小
  self.size += 1
}

///|
/// Get element at specific index
pub fn get_at[K](self : T[K], index : Int) -> K? {
  if index < 0 || index >= self.size {
    return None
  }

  // 直接从位置映射获取索引
  let bucket_idx = self.core.position_to_idx[index]

  // 返回对应的元素
  Some(self.core.entries[bucket_idx].key)
}

///|
/// Get the index of a key
pub fn index_of[K : Hash + Eq](self : T[K], key : K) -> Int? {
  // 先检查键是否存在
  // 从桶索引到位置的映射获取位置索引
  match self.key_to_idx.get(key) {
    Some(bucket_idx) => Some(self.core.idx_to_position.get(bucket_idx).unwrap())
    None => None // 键不存在
  }
}

///|
/// Check if the hash set contains a key.
pub fn contains[K : Hash + Eq](self : T[K], key : K) -> Bool {
  if self.size == 0 {
    return false
  }

  // 直接检查 key_to_idx 中是否存在该键
  self.key_to_idx.contains(key)
}

///|

///| Remove a key from hash set with O(1) complexity.
pub fn remove[K : Hash + Eq](self : T[K], key : K) -> Unit {
  if self.size == 0 {
    return
  }

  // 直接从映射中获取索引，O(1)操作
  match self.key_to_idx.get(key) {
    Some(idx) => {
      // 获取被删除元素的链表信息
      let entry = self.core.entries[idx]
      let hash = entry.hash

      // 从索引到位置的映射中获取位置（idx是从key_to_idx获取的有效索引）
      let position = self.core.idx_to_position.get(idx).unwrap()

      // 如果要删除的不是最后一个元素，则进行交换
      if position < self.size - 1 {
        // 获取最后一个元素的索引
        let last_idx = self.core.position_to_idx[self.size - 1]
        ignore(self.core.entries[last_idx].key)

        // 将最后一个元素移动到被删除元素的位置
        self.core.position_to_idx[position] = last_idx
        self.core.idx_to_position.set(last_idx, position)
      }

      // 从位置映射中移除最后一个位置
      ignore(self.core.position_to_idx.pop())

      // 从索引到位置的映射中移除被删除元素
      self.core.idx_to_position.remove(idx)

      // 从哈希表中移除
      self.core.hash_to_idx.remove(hash)

      // 修复链表指针
      // 如果有前一个元素，更新它的next指针
      if entry.prev != -1 {
        self.core.entries[entry.prev].next = entry.next
      } else {
        // 如果是头节点，更新head指针
        self.core.head = entry.next
      }

      // 如果有后一个元素，更新它的prev指针
      if entry.next != -1 {
        self.core.entries[entry.next].prev = entry.prev
      } else {
        // 如果是尾节点，更新tail指针
        self.core.tail = entry.prev
      }

      // 从映射中移除被删除的键
      self.key_to_idx.remove(key)

      // 更新大小
      self.size -= 1
    }
    None => return // 键不存在，不执行任何操作
  }
}

///|
/// Get the number of keys in the set.
pub fn size[K](self : T[K]) -> Int {
  self.size
}

///|
/// Get the capacity of the set.
pub fn capacity[K](self : T[K]) -> Int {
  self.capacity
}

///|
/// Check if the hash set is empty.
pub fn is_empty[K](self : T[K]) -> Bool {
  self.size == 0
}

///|
/// Iterate over all keys of the set.
pub fn each[K](self : T[K], f : (K) -> Unit) -> Unit {
  self.eachi(fn(_i, k) { f(k) })
}

///|
/// Iterate over all keys of the set, with index.
pub fn eachi[K](self : T[K], f : (Int, K) -> Unit) -> Unit {
  let mut current = self.core.head
  let mut index = 0
  while current != -1 {
    f(index, self.core.entries[current].key)
    current = self.core.entries[current].next
    index += 1
  }
}

///|
/// Clears the set, removing all keys. Keeps the allocated space.
pub fn clear[K](self : T[K]) -> Unit {
  self.core.hash_to_idx = @hashmap.new() // 重置为新的哈希表
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.core.position_to_idx = [] // 清空位置映射
  self.core.idx_to_position = @hashmap.new() // 清空索引到位置的映射
  self.size = 0
  self.key_to_idx = @hashmap.new()
}

///|
/// Union of two hash sets.
/// @alert unsafe "Panic if the hash set is full."
pub fn union[K : Hash + Eq](self : T[K], other : T[K]) -> T[K] {
  let result = new()
  self.each(fn(k) { result.add(k) })
  other.each(fn(k) { result.add(k) })
  result
}

///|
/// Intersection of two hash sets.
pub fn intersection[K : Hash + Eq](self : T[K], other : T[K]) -> T[K] {
  let result = new()
  self.each(fn(k) { if other.contains(k) { result.add(k) } })
  result
}

///|
/// Difference of two hash sets.
pub fn difference[K : Hash + Eq](self : T[K], other : T[K]) -> T[K] {
  let result = new()
  self.each(fn(k) { if not(other.contains(k)) { result.add(k) } })
  result
}

///|
/// Symmetric difference of two hash sets.
pub fn symmetric_difference[K : Hash + Eq](self : T[K], other : T[K]) -> T[K] {
  let result = new()
  self.each(fn(k) { if not(other.contains(k)) { result.add(k) } })
  other.each(fn(k) { if not(self.contains(k)) { result.add(k) } })
  result
}

///|
pub fn iter[K](self : T[K]) -> Iter[K] {
  Iter::new(fn(yield_) {
    let mut current = self.core.head
    while current != -1 {
      let key = self.core.entries[current].key
      if yield_(key) == IterEnd {
        break
      }
      current = self.core.entries[current].next
    }
    IterContinue
  })
}

///|
pub fn from_iter[K : Hash + Eq](iter : Iter[K]) -> T[K] {
  let s = new()
  iter.each(fn(e) { s.add(e) })
  s
}

///|
/// Convert set to array, preserving insertion order.
pub fn to_array[K](self : T[K]) -> Array[K] {
  if self.size == 0 || self.core.head == -1 {
    return []
  }
  let result = Array::make(self.size, self.core.entries[self.core.head].key)
  let mut current = self.core.head
  let mut index = 0
  while current != -1 && index < self.size {
    result[index] = self.core.entries[current].key
    current = self.core.entries[current].next
    index += 1
  }
  result
}

///|
/// Insert an entry into the hash table
fn insert_into_table[K : Hash](
  self : T[K],
  hash : Int,
  bucket_idx : Int
) -> Unit {
  // 直接在哈希表中设置键值对，无需线性探测
  self.core.hash_to_idx.set(hash, bucket_idx)
}

///|
///|
///|
fn grow[K : Hash + Eq](self : T[K]) -> Unit {
  // 保存旧数据
  let old_entries = self.core.entries
  let old_head = self.core.head

  // 创建新的存储
  self.capacity = self.capacity * 2
  self.growAt = calc_grow_threshold(self.capacity)
  self.core.hash_to_idx = @hashmap.new() // 使用新的哈希表
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.core.position_to_idx = [] // 重置位置映射
  self.core.idx_to_position = @hashmap.new() // 重置索引到位置的映射
  self.size = 0
  self.key_to_idx = @hashmap.new()

  // 重新添加所有元素，保持原顺序
  let mut current = old_head
  while current != -1 {
    let entry = old_entries[current]
    self.add(entry.key)
    current = entry.next
  }
}

///|
fn calc_grow_threshold(capacity : Int) -> Int {
  capacity * 13 / 16
}

///|
pub impl[K : Show] Show for T[K] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@IndexSet.of([", suffix="])")
}

///|
/// 移除并返回最后一个插入的元素（尾部元素）
/// 如果集合为空，返回 None
pub fn pop[K : Hash + Eq](self : T[K]) -> K? {
  if self.size == 0 {
    return None
  }

  // 获取尾部元素
  let tail_idx = self.core.tail
  let tail_element = self.core.entries[tail_idx]
  let key = tail_element.key

  // 从哈希表中移除映射 - 直接操作
  self.core.hash_to_idx.remove(tail_element.hash)

  // 调整链表
  if tail_element.prev != -1 {
    self.core.entries[tail_element.prev].next = -1
    self.core.tail = tail_element.prev
  } else {
    // 集合中只有一个元素，清空链表
    self.core.head = -1
    self.core.tail = -1
  }

  // 从映射中移除
  self.key_to_idx.remove(key)

  // 从索引到位置的映射中移除
  self.core.idx_to_position.remove(tail_idx)

  // 从位置映射中移除最后一个元素
  ignore(self.core.position_to_idx.pop())

  // 更新大小
  self.size -= 1

  // 返回移除的元素
  Some(key)
}

///|
/// 移除并返回第一个插入的元素（头部元素）
/// 时间复杂度：O(1)
pub fn shift[K : Hash + Eq](self : T[K]) -> K? {
  if self.size == 0 {
    return None
  }

  // 获取头部元素
  let head_idx = self.core.head
  let head_element = self.core.entries[head_idx]
  let key = head_element.key

  // 从哈希表中移除映射
  self.core.hash_to_idx.remove(head_element.hash)

  // 调整链表
  if head_element.next != -1 {
    self.core.entries[head_element.next].prev = -1
    self.core.head = head_element.next
  } else {
    // 集合中只有一个元素，清空链表
    self.core.head = -1
    self.core.tail = -1
  }

  // 从键到索引的映射中移除
  self.key_to_idx.remove(key)

  // 从索引到位置的映射中移除
  self.core.idx_to_position.remove(head_idx)

  // 使用交换策略：将最后一个元素移动到第一个位置
  if self.size > 1 {
    // 获取最后一个元素的索引
    let last_idx = self.core.position_to_idx[self.size - 1]

    // 将最后一个元素移动到第一个位置
    self.core.position_to_idx[0] = last_idx
    self.core.idx_to_position.set(last_idx, 0)
  }

  // 移除最后一个位置的映射（现在已经被移动或者是被删除的元素）
  ignore(self.core.position_to_idx.pop())

  // 更新大小
  self.size -= 1

  // 返回移除的元素
  Some(key)
}

///| 返回集合中第一个插入的元素，但不移除它
/// 如果集合为空，返回 None
pub fn peek_first[K](self : T[K]) -> K? {
  if self.size == 0 || self.core.head == -1 {
    return None
  }

  // 获取头部元素
  let head_idx = self.core.head
  let head_element = self.core.entries[head_idx]

  // 返回元素，但不修改集合
  Some(head_element.key)
}

///| 返回集合中最后一个插入的元素，但不移除它
/// 如果集合为空，返回 None
pub fn peek_last[K](self : T[K]) -> K? {
  if self.size == 0 || self.core.tail == -1 {
    return None
  }

  // 获取尾部元素
  let tail_idx = self.core.tail
  let tail_element = self.core.entries[tail_idx]

  // 返回元素，但不修改集合
  Some(tail_element.key)
}

///|
pub impl[X : @quickcheck.Arbitrary + Eq + Hash] @quickcheck.Arbitrary for T[X] with arbitrary(
  size,
  rs
) {
  @quickcheck.Arbitrary::arbitrary(size, rs) |> from_iter
}

///| 返回一个按照指定比较函数排序的新集合
/// 原集合不会被修改
pub fn sorted[K : Hash + Eq](self : T[K], compare : (K, K) -> Int) -> T[K] {
  // 将集合转换为数组
  let arr = self.to_array()

  // 对数组进行排序
  arr.sort_by(compare)

  // 创建新的有序集合
  from_array(arr)
}

///|
pub fn sorted_by_key[K : Hash + Eq + Compare](self : T[K]) -> T[K] {
  self.sorted(fn(a, b) { a.compare(b) })
}

///| 返回一个按照键映射函数排序的新集合
/// 原集合不会被修改
pub fn sorted_by[K : Hash + Eq, B : Compare](
  self : T[K],
  key_fn : (K) -> B
) -> T[K] {
  // 将集合转换为数组
  let arr = self.to_array()

  // 对数组进行排序
  arr.sort_by(fn(a, b) { key_fn(a).compare(key_fn(b)) })

  // 创建新的有序集合
  from_array(arr)
}

///|
/// 就地排序集合元素
/// 时间复杂度: O(n log n)，其中n是集合大小
pub fn sort[K : Hash + Eq](self : T[K], compare : (K, K) -> Int) -> Unit {
  if self.size <= 1 {
    return
  }

  // 将集合转换为数组
  let arr = self.to_array()

  // 对数组进行排序
  arr.sort_by(compare)

  // 清空当前集合
  self.clear()

  // 重新添加排序后的元素
  for i in 0..<arr.length() {
    self.add(arr[i])
  }

  // position_to_idx 和 idx_to_position 已经在 add 和 clear 中更新
}

///|
/// 就地按照自然顺序排序集合
/// 要求元素类型实现了 Compare trait
pub fn sort_by_key[K : Hash + Eq + Compare](self : T[K]) -> Unit {
  self.sort(fn(a, b) { a.compare(b) })
}

///|
/// 就地按照键映射函数排序集合
pub fn sort_by[K : Hash + Eq, B : Compare](
  self : T[K],
  key_fn : (K) -> B
) -> Unit {
  self.sort(fn(a, b) { key_fn(a).compare(key_fn(b)) })
}

///|
/// 返回一个按照指定比较函数反向排序的新集合
pub fn sorted_desc[K : Hash + Eq](self : T[K], compare : (K, K) -> Int) -> T[K] {
  self.sorted(fn(a, b) { compare(b, a) })
}

///|
/// 返回一个按照自然顺序反向排序的新集合
pub fn sorted_by_key_desc[K : Hash + Eq + Compare](self : T[K]) -> T[K] {
  self.sorted(fn(a, b) { b.compare(a) })
}

///|
/// 就地按照指定比较函数反向排序集合
pub fn sort_desc[K : Hash + Eq](self : T[K], compare : (K, K) -> Int) -> Unit {
  self.sort(fn(a, b) { compare(b, a) })
}

///|
/// 就地按照自然顺序反向排序集合
pub fn sort_by_key_desc[K : Hash + Eq + Compare](self : T[K]) -> Unit {
  self.sort(fn(a, b) { b.compare(a) })
}
