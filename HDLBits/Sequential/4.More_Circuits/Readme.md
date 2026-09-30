# HDLBits — More Circuit

## 📚 Tổng quan

Branch **More Circuit** là giai đoạn bắt đầu chuyển từ những mạch Verilog đơn giản sang các bài toán có **state, vector manipulation, cellular automata, indexing và next-state logic phức tạp hơn**.

Qua các bài trong branch này, tư duy được nâng dần:

```text
Simple Sequential Logic
        ↓
Vector-based Logic
        ↓
Cellular Automaton 1D
        ↓
Truth Table → Boolean Logic
        ↓
2D State Representation
        ↓
Neighbour / Index Calculation
        ↓
Complex Next-State Logic
```

Mục tiêu không phải chỉ giải được HDLBits, mà là hiểu cách biến **specification → hardware logic → Verilog RTL**.

---

# 1. Rule 90

## 🧩 Bài toán

Rule 90 là một **1D Cellular Automaton**.

Mỗi cell mới được xác định bởi hai cell hàng xóm:

```text
        Left       Right
          ↓          ↓
        q[i-1] XOR q[i+1]
```

Quy tắc có thể biểu diễn:

```text
next[i] = q[i-1] ^ q[i+1]
```

Các cell ở biên được xem như có giá trị `0` ở bên ngoài.

Ngoài ra:

* `load = 1` → nạp `data`
* `load = 0` → tính timestep tiếp theo
* cập nhật tại cạnh clock

---

## 💡 Ý nghĩa

Bài này là bước chuyển quan trọng từ:

```text
Logic trên từng tín hiệu
```

sang:

```text
Logic tác động lên cả một vector trạng thái
```

Thay vì viết từng cell riêng lẻ, có thể tận dụng phép shift:

```verilog
q << 1
q >> 1
```

để lấy hai phía của toàn bộ vector.

Từ đó:

```text
Left/Right neighbours
        ↓
      XOR
        ↓
    next state
```

có thể viết rất gọn bằng vector operation.

---

## 🧠 Kiến thức rút ra

* Cellular Automaton 1D
* Bit-vector manipulation
* Logical shift
* XOR
* Boundary handling
* Sequential state update
* Non-blocking assignment `<=`
* Current State → Next State → Clock → New State

---

# 2. Rule 110

## 🧩 Bài toán

Rule 110 cũng là Cellular Automaton 1D nhưng phức tạp hơn Rule 90.

Mỗi cell phụ thuộc vào:

```text
Left - Center - Right
```

Truth table:

| Left | Center | Right | Next |
| ---: | -----: | ----: | ---: |
|    1 |      1 |     1 |    0 |
|    1 |      1 |     0 |    1 |
|    1 |      0 |     1 |    1 |
|    1 |      0 |     0 |    0 |
|    0 |      1 |     1 |    1 |
|    0 |      1 |     0 |    1 |
|    0 |      0 |     1 |    1 |
|    0 |      0 |     0 |    0 |

---

## 💡 Cách tư duy

Không nên nhìn truth table như một bảng để học thuộc.

Ta chia theo giá trị của `Center`.

### Khi Center = 0

```text
Next = Right
```

### Khi Center = 1

```text
Next = ~(Left & Right)
```

Sau đó ghép hai trường hợp bằng tư duy **MUX**:

```text
Center = 0 → chọn Right

Center = 1 → chọn ~(Left & Right)
```

Từ đó hình thành:

```text
Truth Table
     ↓
Case Analysis
     ↓
Boolean Expression
     ↓
MUX / Logic Gates
     ↓
Vector Operation
     ↓
RTL
```

---

## 🧠 Kiến thức rút ra

* Đọc truth table
* Phân tích theo trường hợp
* Boolean algebra
* MUX thinking
* NAND logic
* Vector shift
* Kết hợp combinational logic với sequential logic

---

## 🔥 Bài học quan trọng

Rule110 cho thấy:

> Không phải cứ thấy một truth table là phải viết từng trường hợp trong Verilog.

Có thể đi theo hướng:

```text
Specification
    ↓
Truth Table
    ↓
Tìm cấu trúc logic
    ↓
Boolean expression
    ↓
Tối ưu / vector hóa
    ↓
RTL
```

Đây là tư duy rất quan trọng khi thiết kế RTL.

---

# 3. Conway's Game of Life

## 🧩 Bài toán

Game of Life nâng Cellular Automaton từ **1D lên 2D**.

Grid:

```text
16 × 16 = 256 cells
```

Mỗi cell:

```text
0 → Dead
1 → Alive
```

Mỗi cell nhìn **8 neighbours**:

```text
↖  ↑  ↗
←  C  →
↙  ↓  ↘
```

Rule:

| Số neighbour sống | Cell tiếp theo |
| ----------------: | -------------: |
|               0–1 |              0 |
|                 2 |     Giữ nguyên |
|                 3 |              1 |
|                4+ |              0 |

---

# 4. Mapping 2D → 1D

Đây là phần rất quan trọng của bài.

Phần cứng không lưu một ma trận 16×16 theo đúng cách ta nhìn trên giấy.

Thay vào đó:

```verilog
q[255:0]
```

được dùng để lưu toàn bộ grid.

Mỗi row có 16 bit:

```text
row 0  → q[15:0]
row 1  → q[31:16]
row 2  → q[47:32]
...
row 15 → q[255:240]
```

Công thức:

```text
index = row * 16 + column
```

Ví dụ:

```text
(0,0)   → q[0]
(0,1)   → q[1]

(1,0)   → q[16]
(1,1)   → q[17]
(1,2)   → q[18]

(15,0)  → q[240]
(15,1)  → q[241]
(15,15) → q[255]
```

---

## 💡 Ý nghĩa

Đây là lần đầu bài toán buộc phải suy nghĩ rõ về:

```text
Logical representation
        ↓
Physical representation
```

Trên giấy:

```text
(row, column)
```

Trong Verilog:

```text
q[index]
```

và phải tự xây dựng phép ánh xạ:

```text
(row, column)
        ↓
row * 16 + column
```

Đây là tư duy sẽ xuất hiện rất nhiều khi làm:

* Memory
* Register file
* FIFO
* Cache
* Image processing
* Matrix hardware
* Bus/address mapping

---

# 5. 8-Neighbour & Indexing

Với cell:

```text
(row, col)
```

8 neighbours là:

```text
(row-1, col-1)   (row-1, col)   (row-1, col+1)

(row,   col-1)                  (row,   col+1)

(row+1, col-1)   (row+1, col)   (row+1, col+1)
```

Sau đó từng tọa độ được chuyển thành:

```text
q[row * 16 + col]
```

Như vậy bài toán thực chất trở thành:

```text
Current Cell
      ↓
Calculate 8 neighbour addresses
      ↓
Read 8 bits
      ↓
Count alive neighbours
      ↓
Apply Game of Life rule
      ↓
Generate next state
```

---

# 6. Toroidal Grid

Grid trong bài không có biên thông thường.

Nó **wrap-around**:

```text
row 0  ↔ row 15
col 0  ↔ col 15
```

Ví dụ cell `(0,0)` có neighbour ở phía trên chính là row `15`.

Các neighbour của `(0,0)` là:

```text
(15,15) (15,0) (15,1)

(0,15)         (0,1)

(1,15)  (1,0) (1,1)
```

Mapping sang `q`:

```text
q[255] q[240] q[241]

q[15]          q[1]

q[31]  q[16]   q[17]
```

Điểm quan trọng:

> Wrap-around không phải một loại logic mới. Nó là vấn đề xử lý **index/address ở boundary**.

---

# 7. Next-State Logic

Game of Life tiếp tục củng cố pattern:

```text
Current State
      ↓
Combinational Logic
      ↓
Next State
      ↓
Clock Edge
      ↓
New Current State
```

Trong bài:

```text
q
 ↓
8-neighbour calculation
 ↓
neighbour count
 ↓
Game of Life rule
 ↓
next_q
 ↓
posedge clk
 ↓
q
```

Nếu:

```text
load = 1
```

thì:

```text
q <= data
```

Nếu:

```text
load = 0
```

thì:

```text
q <= next_q
```

---

# 8. For-loop trong RTL

Game of Life cũng giúp hiểu đúng bản chất của `for`.

Trong code có thể duyệt:

```verilog
for (row = 0; row < 16; row = row + 1)
    for (col = 0; col < 16; col = col + 1)
```

Nhưng cần nhớ:

> `for` trong RTL không có nghĩa phần cứng sẽ thực hiện từng cell một theo thời gian như chương trình C.

Trong quá trình synthesis, loop có thể được **unroll** thành phần cứng tương ứng.

Vì vậy tư duy đúng là:

```text
for-loop
   ↓
mô tả một cấu trúc lặp
   ↓
synthesis tạo hardware
```

chứ không nên hiểu đơn giản là:

```text
cell 0 chạy
→ cell 1 chạy
→ cell 2 chạy
```

---

# 9. Tổng hợp kiến thức của Branch

Qua các bài từ đầu branch đến hiện tại:

| Bài              | Kiến thức chính                                                                  |
| ---------------- | -------------------------------------------------------------------------------- |
| **Rule90**       | 1D cellular automaton, XOR, vector shift, sequential update                      |
| **Rule110**      | Truth table, Boolean logic, case analysis, MUX thinking, vector RTL              |
| **Game of Life** | 2D state, 8-neighbour, indexing, wrap-around, counting, complex next-state logic |

---

# 10. Sự phát triển về tư duy

Có thể nhìn progression của branch như sau:

```text
Rule90
│
├── Hiểu Cellular Automaton
├── Hiểu neighbour-based logic
├── Vector shift
└── Sequential update
        ↓
Rule110
│
├── Đọc specification
├── Truth table
├── Boolean simplification
├── MUX / gate thinking
└── Vectorized RTL
        ↓
Game of Life
│
├── 2D representation
├── 2D → 1D mapping
├── Address calculation
├── 8-neighbour calculation
├── Boundary / wrap-around
├── Counting
├── Complex next-state logic
└── Sequential state update
```

---

# 🧠 Những thứ đã thực sự học được

## 1. Specification → Hardware

Không bắt đầu bằng code.

Bắt đầu bằng:

```text
Đề bài
 ↓
Input / Output
 ↓
State
 ↓
Rule
 ↓
Logic
 ↓
Next State
 ↓
Clock
 ↓
Verilog
```

---

## 2. Current State → Next State

Đây là pattern quan trọng xuyên suốt các bài sequential:

```text
        ┌─────────────────┐
q ─────►│ Next-State Logic│
        └────────┬────────┘
                 │
               next_q
                 │
                 ▼
              ┌─────┐
clk ─────────►│ DFF │
              └──┬──┘
                 │
                 └──────► q
```

Cần hình thành phản xạ:

> **State hiện tại → tính state tiếp theo → clock chốt state mới.**

---

## 3. Vector không chỉ là "một đống bit"

Các bài Rule90/Rule110 cho thấy vector có thể được xử lý như một cấu trúc:

```text
q << 1
q >> 1
q ^ ...
```

Thay vì luôn suy nghĩ từng bit riêng lẻ.

---

## 4. Indexing là kỹ năng RTL quan trọng

Game of Life cho thấy:

```text
(row, column)
```

có thể phải chuyển thành:

```text
index
```

Thông qua:

```text
index = row * width + column
```

Đây là kỹ năng nền tảng cho những phần sau như:

```text
Memory
FIFO
Register File
Cache
Bus
Array
Matrix
```

---

# 🔥 Những bài đáng nhớ trong Branch

### Rule90

Đáng nhớ vì lần đầu thấy cách **vector operation** có thể mô tả cả một hệ thống cell thay vì xử lý từng bit.

### Rule110

Đáng nhớ vì phải học cách đi từ:

```text
Truth Table
→ Boolean Logic
→ MUX
→ Vector RTL
```

thay vì viết code một cách máy móc.

### Game of Life ⭐

Đây là bài đặc biệt đáng nhớ vì nó kết hợp rất nhiều kỹ năng:

```text
2D → 1D mapping
+ indexing
+ 8 neighbours
+ wrap-around
+ counting
+ next-state logic
+ sequential RTL
```

Nó đánh dấu bước chuyển từ các bài RTL tương đối đơn giản sang những bài có **cấu trúc dữ liệu và logic phức tạp hơn**.

---

# 🚀 Kết luận

Sau branch **More Circuit**, mục tiêu không phải là nhớ code của từng bài.

Điều quan trọng hơn là hình thành tư duy:

```text
        SPECIFICATION
              ↓
        UNDERSTAND STATE
              ↓
       IDENTIFY RELATIONSHIP
              ↓
        DESIGN NEXT STATE
              ↓
      COMBINATIONAL LOGIC
              ↓
        SEQUENTIAL LOGIC
              ↓
           VERILOG
              ↓
          SIMULATION
              ↓
         SYNTHESIS
```

Đặc biệt cần nhớ:

> **Verilog không phải ngôn ngữ để "viết chương trình chạy từng dòng". Nó là cách mô tả cấu trúc và hành vi của phần cứng.**

Các bài trong More Circuit bắt đầu buộc phải suy nghĩ theo hướng đó rõ ràng hơn.

---

## 📌 Current Progress

```text
HDLBits
│
├── Digital Logic
├── Verilog
├── Combinational Logic
├── Sequential Logic
│
└── More Circuit
     ├── Rule90        ✅
     ├── Rule110       ✅
     └── Game of Life  ✅
```

**Key mental model hiện tại:**

```text
Combinational:
Input → Logic → Output

Sequential:
Current State → Next-State Logic → Clock → New State

More Complex RTL:
State / Data Structure
        ↓
Index / Address
        ↓
Neighbour / Dependency
        ↓
Combinational Logic
        ↓
Next State
        ↓
Clock
```
