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
pub fn new[K](capacity~ : Int = default_init_capacity) -> T[K] {
  {
    core: {
      hash_indices: FixedArray::make(capacity, None),
      entries: [],
      head: -1,
      tail: -1,
    },
    size: 0,
    capacity,
    growAt: calc_grow_threshold(capacity),
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
  let idx = self.index(hash)

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

  // 更新大小
  self.size += 1
}

///|
/// Get element at specific index
pub fn get_at[K](self : T[K], index : Int) -> K? {
  if index < 0 || index >= self.size {
    return None
  }

  // 从头节点开始遍历
  let mut current = self.core.head
  let mut current_index = 0
  while current != -1 && current_index < index {
    current = self.core.entries[current].next
    current_index += 1
  }
  if current == -1 {
    None
  } else {
    Some(self.core.entries[current].key)
  }
}

///|
/// Get the index of a key
pub fn index_of[K : Eq](self : T[K], key : K) -> Int? {
  // 从头节点开始遍历
  let mut current = self.core.head
  let mut index = 0
  while current != -1 {
    if self.core.entries[current].key == key {
      return Some(index)
    }
    current = self.core.entries[current].next
    index += 1
  }
  None
}

///|
/// Check if the hash set contains a key.
pub fn contains[K : Hash + Eq](self : T[K], key : K) -> Bool {
  if self.size == 0 {
    return false
  }
  let hash = key.hash()
  let idx = self.index(hash)

  // 在哈希表中查找
  let mut i = 0
  let mut curr_idx = idx
  while i < self.capacity {
    match self.core.hash_indices[curr_idx] {
      Some(entry_idx) =>
        // 确保索引有效且在entries数组范围内
        if entry_idx >= 0 && entry_idx < self.core.entries.length() {
          let entry = self.core.entries[entry_idx]
          if entry.hash == hash && entry.key == key {
            return true
          }
        }
      None =>
        // 在初始位置找不到且遇到空槽，表示键不存在
        if curr_idx == idx || i > 0 {
          return false
        }
    }
    curr_idx = self.next_index(curr_idx)
    i += 1
  }
  false
}

///|
/// Remove a key from hash set.
/// Remove a key from hash set.
pub fn remove[K : Hash + Eq](self : T[K], key : K) -> Unit {
  if self.size == 0 {
    return
  }
  let hash = key.hash()
  let idx = self.index(hash)

  // 在哈希表中查找元素
  let mut i = 0
  let mut curr_idx = idx
  let mut entry_idx : Int? = None
  while i < self.capacity {
    match self.core.hash_indices[curr_idx] {
      Some(bucket_idx) => {
        let entry = self.core.entries[bucket_idx]
        if entry.hash == hash && entry.key == key {
          entry_idx = Some(bucket_idx)
          // 从哈希表中移除
          self.core.hash_indices[curr_idx] = None
          self.shift_back(curr_idx)
          break
        }
      }
      None => break
    }
    curr_idx = self.next_index(curr_idx)
    i += 1
  }

  // 如果找到了元素，从链表中移除
  match entry_idx {
    Some(idx) => {
      let entry = self.core.entries[idx]

      // 更新前驱节点的后继
      if entry.prev != -1 {
        self.core.entries[entry.prev].next = entry.next
      } else {
        // 如果是头节点，更新头节点
        self.core.head = entry.next
      }

      // 更新后继节点的前驱
      if entry.next != -1 {
        self.core.entries[entry.next].prev = entry.prev
      } else {
        // 如果是尾节点，更新尾节点
        self.core.tail = entry.prev
      }
      self.size -= 1
    }
    None => ...
  } // 键不存在，不执行任何操作
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
  self.core.hash_indices = FixedArray::make(self.capacity, None)
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.size = 0
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
/// Private helper methods
///|

///|
/// Insert an entry into the hash table
fn insert_into_table[K : Hash](
  self : T[K],
  hash : Int,
  bucket_idx : Int
) -> Unit {
  let mut i = 0
  let mut idx = self.index(hash)
  while i < self.capacity {
    match self.core.hash_indices[idx] {
      None => {
        self.core.hash_indices[idx] = Some(bucket_idx)
        return
      }
      Some(_) => {
        // 找下一个位置
        idx = self.next_index(idx)
        i += 1
      }
    }
  }
}

///|
fn shift_back[K](self : T[K], start_index : Int) -> Unit {
  let mut prev = start_index
  let mut curr = self.next_index(start_index)
  let mut i = 0

  // 标记已处理过的节点，防止循环
  let visited = FixedArray::make(self.capacity, false)
  while i < self.capacity {
    // 避免无限循环
    if visited[curr] {
      break
    }
    visited[curr] = true
    match self.core.hash_indices[curr] {
      Some(entry_idx) => {
        let ideal_pos = self.index(self.core.entries[entry_idx].hash)

        // 计算理想位置到当前位置的距离
        let ideal_dist = (curr - ideal_pos + self.capacity) % self.capacity
        let prev_dist = (prev - ideal_pos + self.capacity) % self.capacity

        // 如果移动到prev位置会让元素更接近其理想位置
        if ideal_dist > prev_dist {
          // 将元素向前移动
          self.core.hash_indices[prev] = Some(entry_idx)
          self.core.hash_indices[curr] = None
          prev = curr
        } else {
          // 否则保持当前位置，但更新prev指针
          prev = curr
        }
      }
      None =>
        // 遇到空槽，停止移动
        break
    }
    curr = self.next_index(curr)
    i += 1
  }
}

///|
fn grow[K : Hash + Eq](self : T[K]) -> Unit {
  // 处理零容量情况
  if self.capacity == 0 {
    self.capacity = default_init_capacity
    self.growAt = calc_grow_threshold(self.capacity)
    self.size = 0
    self.core.hash_indices = FixedArray::make(self.capacity, None)
    return
  }

  // 保存旧数据
  let old_entries = self.core.entries
  let old_head = self.core.head

  // 创建新的存储
  self.capacity = self.capacity * 2
  self.growAt = calc_grow_threshold(self.capacity)
  self.core.hash_indices = FixedArray::make(self.capacity, None)
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.size = 0

  // 重新添加所有元素，保持原顺序
  let mut current = old_head
  while current != -1 {
    let entry = old_entries[current]
    self.add(entry.key)
    current = entry.next
  }
}

///|
fn index[K](self : T[K], hash : Int) -> Int {
  abs(hash) & (self.capacity - 1)
}

///|
fn abs(n : Int) -> Int {
  if n < 0 {
    -n
  } else {
    n
  }
}

///|
fn next_index[K](self : T[K], index : Int) -> Int {
  (index + 1) & (self.capacity - 1)
}

///|
fn calc_grow_threshold(capacity : Int) -> Int {
  capacity * 13 / 16
}

///|
pub impl[K : Show] Show for T[K] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@indexset.of([", suffix="])")
}
