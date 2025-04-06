// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// 桶结构，包含键信息和链表指针
priv struct Bucket[K] {
  hash : Int // 键的哈希值（缓存以避免重复计算）
  key : K // 键
  mut next : Int // 链表后继索引，-1表示没有后继
  mut prev : Int // 链表前驱索引，-1表示没有前驱
} derive(Show)

/// A mutable indexed hash set implements with Robin Hood hashing.
///
/// reference:
/// - <https://programming.guide/robin-hood-hashing.html>
/// - <https://cs.uwaterloo.ca/research/tr/1986/CS-86-14.pdf>

///|
/// IndexSet核心结构，包含所有数据组织功能
priv struct IndexSetCore[K] {
  mut hash_indices : FixedArray[Int?] // 哈希表：存储哈希到桶索引的映射，None表示空槽
  mut entries : Array[Bucket[K]] // 数组：存储实际的键及其链表信息
  mut head : Int // 链表头节点索引，-1表示空链表
  mut tail : Int // 链表尾节点索引，-1表示空链表
} derive(Show)

///|
/// Mutable indexed hash set, not thread safe.
/// Maintains insertion order and allows access by index.
///
/// # Example
///
/// ```
/// let set = @indexset.of([3, 8, 1])
/// set.add(4)
/// assert_eq!(set.contains(4), true)
/// assert_eq!(set.get_at(3), 4)  // Access by index
/// ```
struct T[K] {
   core : IndexSetCore[K] // 包含核心数据结构
  mut size : Int // 元素数量
  mut capacity : Int // 当前哈希表容量
  mut growAt : Int // 扩容阈值
}
