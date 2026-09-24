```markdown
# Combinational Logic — Digital Logic Foundation
*
---

## 1. Tổng quan

### 1.1. Combinational Logic là gì?
Mạch tổ hợp (Combinational Logic) là lớp mạch số cơ bản nhất, trong đó ngõ ra chỉ phụ thuộc vào trạng thái của ngõ vào tại thời điểm hiện tại. Nó thực hiện các hàm logic hoặc toán học ngay lập tức (bỏ qua trễ vật lý) mà không cần nhớ trạng thái cũ.

### 1.2. Đặc điểm cốt lõi
* **Không có memory (bộ nhớ):** Không lưu trữ thông tin về quá khứ.
* **Không có state (trạng thái):** Không có khái niệm trạng thái hiện tại hay trạng thái kế tiếp.
* **Output phụ thuộc hoàn toàn vào input hiện tại:** Tính xác định cao (Deterministic). Cùng một input luôn cho ra đúng một output.

### 1.3. So sánh ngắn: Combinational Logic vs Sequential Logic
| Tiêu chí | Combinational Logic | Sequential Logic |
| :--- | :--- | :--- |
| **Phụ thuộc ngõ ra** | Chỉ Input hiện tại. | Input hiện tại + State (Trạng thái) quá khứ. |
| **Phần tử đặc trưng**| Logic Gates, MUX, Adder, Decoder. | D Flip-Flop, Register, Latch. |
| **Xung nhịp (Clock)** | Không dùng (Asynchronous). | Hoạt động theo Clock (Synchronous). |

### 1.4. Tại sao Combinational Logic quan trọng đối với RTL Design?
Mọi con chip (CPU, GPU, FPGA) đều tuân theo mô hình: 
`[Register] -> (Đám mây Combinational Logic) -> [Register]`
Combinational Logic quyết định việc tính toán (ALU, so sánh, chọn kênh) và nó là nguyên nhân chính gây ra trễ đường truyền (Critical Path), trực tiếp quyết định tần số xung nhịp tối đa (Fmax) của mạch. Với DV, tính xác định của mạch tổ hợp giúp dễ dàng viết các assertion và tính toán coverage.

---

## 2. Logic Gates (Các cổng logic cơ bản)

Các cổng logic là viên gạch xây dựng nên toàn bộ mạch số.

*   **AND:** Output = 1 khi *tất cả* input = 1. (Biểu thức: `Y = A & B`). Ý nghĩa: Điều kiện bắt buộc đồng thời.
*   **OR:** Output = 1 khi *ít nhất một* input = 1. (Biểu thức: `Y = A | B`). Ý nghĩa: Một trong các điều kiện thỏa mãn.
*   **NOT:** Đảo ngược input. (Biểu thức: `Y = ~A`).
*   **NAND:** Đảo của AND. Output = 0 chỉ khi tất cả input = 1. (Biểu thức: `Y = ~(A & B)`).
*   **NOR:** Đảo của OR. Output = 0 khi có ít nhất một input = 1. (Biểu thức: `Y = ~(A | B)`).
*   **XOR:** Output = 1 khi các input *khác nhau* (số lẻ bit 1). (Biểu thức: `Y = A ^ B`). Rất quan trọng trong mạch cộng (Adder).
*   **XNOR:** Đảo của XOR. Output = 1 khi các input *giống nhau*. (Biểu thức: `Y = ~(A ^ B)`). Dùng làm bộ so sánh bằng (Equality Comparator).
*   **a NOT b (anotb):** Output = 1 khi `A = 1` VÀ `B = 0`. (Biểu thức: `Y = A & ~B`). Dùng nhiều trong mạch che (masking).

**Verilog Implementation (Bài `gatesv`):**
```verilog
assign out_and = a & b;
assign out_or  = a | b;
assign out_xor = a ^ b;
assign out_anotb = a & ~b;

```

---

## 3. Boolean Logic

Boolean logic là ngôn ngữ toán học của mạch tổ hợp.

* **Variables:** Nhận giá trị 0 hoặc 1.
* **Expressions:** Sự kết hợp của AND (`&`), OR (`|`), NOT (`~`).
* **De Morgan's Laws:** Định lý cốt lõi để chuyển đổi giữa AND và OR:
* `~(A & B) = ~A | ~B`
* `~(A | B) = ~A & ~B`


* **Simplification (Rút gọn):** Giúp giảm số lượng cổng logic (giảm diện tích silicon, giảm trễ).

**Mental Model:**

* **Expression -> Circuit:** Mỗi toán tử là một cổng logic. `Y = (A & B) | C` nghĩa là tín hiệu A, B đi qua cổng AND, rồi kết quả đi qua cổng OR với C.
* **Truth Table -> Expression:** Gom các trường hợp Output = 1 (hoặc 0) để tạo biểu thức.

---

## 4. Truth Table (Bảng chân trị)

Truth Table là "hợp đồng" mô tả chính xác mạch tổ hợp làm gì với mọi khả năng của input.

* **Input combinations:** Nếu có N inputs, sẽ có 2^N trường hợp (liệt kê đếm nhị phân từ 0 đến 2^N - 1).
* **Output determination:** Ghi rõ output tương ứng với mỗi dòng.

**Ví dụ mạch Half Adder:**

| A | B | Carry | Sum |
| --- | --- | --- | --- |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 0 |

Từ đây suy ra: `Sum = A ^ B`, `Carry = A & B`.

---

## 5. Minterm / Maxterm / Canonical Form

* **Minterm (Sum of Products - SOP):** Tập trung vào các ô **Output = 1**.
* Quy tắc: Input = 1 thì giữ nguyên (`A`), Input = 0 thì đảo (`~A`). Các biến nhân (AND) lại với nhau.
* Ví dụ: Dòng `A=0, B=1 -> Output=1` tạo ra minterm `~A & B`.


* **Maxterm (Product of Sums - POS):** Tập trung vào các ô **Output = 0**.
* Quy tắc ngược lại hoàn toàn: Input = 0 thì giữ nguyên (`A`), Input = 1 thì đảo (`~A`). Các biến cộng (OR) lại với nhau.
* Ví dụ: Dòng `A=0, B=1 -> Output=0` tạo ra maxterm `(A | ~B)`.


* **Canonical representation:** Viết đầy đủ tất cả các biến cho mọi số hạng (chưa rút gọn).

---

## 6. Karnaugh Map (K-map)

K-map là phiên bản đồ họa 2D của Truth Table, dùng để rút gọn biểu thức bằng mắt.

* **Mục tiêu:** Rút gọn biểu thức SOP hoặc POS xuống mức tối tiểu (minimal).
* **Mapping:** Trải các input theo mã Gray (00, 01, 11, 10) để đảm bảo 2 ô liền kề chỉ khác nhau đúng 1 bit.
* **Grouping (Gom nhóm):**
* Gom các ô số 1 (SOP) hoặc số 0 (POS) liền kề nhau thành các hình chữ nhật có kích thước là lũy thừa của 2 (1, 2, 4, 8, 16 ô).
* Được phép cuộn (adjacency) qua các cạnh đối diện của bảng.
* **Don't care (d):** Những trạng thái input không bao giờ xảy ra. Có thể tự do coi nó là 0 hoặc 1 để nhóm gom được lớn nhất.


* **TẠI SAO grouping lại giúp rút gọn?**
* Khi bạn gom 2 ô liền kề, chắc chắn có 1 biến thay đổi từ 0 sang 1, trong khi các biến khác giữ nguyên.
* Toán học: `(A & B) | (A & ~B) = A & (B | ~B) = A & 1 = A`. Biến B thay đổi nên tự triệt tiêu. Nhóm càng lớn, biến bị triệt tiêu càng nhiều.



---

## 7. Multiplexer (MUX)

MUX là một trong những mạch quan trọng nhất trong Digital Design.

### 7.1. MUX là gì?

**Mental Model:** MUX là "bộ chọn kênh dữ liệu". Có nhiều đường Data vào, nhưng chỉ 1 đường ra. Tín hiệu *Select* đóng vai trò như người bẻ ghi đường tàu, quyết định đường Data nào được thông ra Output.

### 7.2. 2-to-1 MUX

* **Inputs:** Data `D0`, Data `D1`, Select `S`.
* **Output:** `Y`
* **Truth Table / Suy luận:**
* S = 0 -> Chọn D0 (Y = D0).
* S = 1 -> Chọn D1 (Y = D1).


* **Boolean expression:** `Y = (~S & D0) | (S & D1)`

### 7.3. Cách suy luận MUX (Không học thuộc công thức)

Chỉ cần nhớ: `Output = (Enable Kênh 0 & Data 0) | (Enable Kênh 1 & Data 1)`.
Bất cứ khi nào dữ liệu D0 hoặc D1 thay đổi, nếu kênh đó đang được S chọn, Output lập tức thay đổi theo nó (kế thừa logic).

### 7.4. MUX nhiều input

* **Công thức tổng quát:** Nếu có `2^n` đường data input, bắt buộc phải có `n` đường select lines.
* Ví dụ: 4-to-1 MUX (4 data, 2 select). 256-to-1 MUX (256 data, 8 select).

### 7.5. MUX trong RTL

Trong Verilog, MUX hiếm khi viết bằng AND/OR, mà dùng toán tử điều kiện `? :` hoặc lệnh `case`.

```verilog
// 2-to-1 MUX (Data-flow / Continuous)
assign out = sel ? d1 : d0;

// K-map mapped to MUX logic (Bài ece241_2014_q3)
assign mux_in[0] = c | d;
assign mux_in[1] = 1'b0;

```

---

## 8. Decoder (Bộ giải mã)

**Mental Model Đừng Nhầm Lẫn:**

* **MUX:** Chọn *data* input để đi ra output.
* **Decoder:** Nhận một *binary code* (địa chỉ) và kích hoạt duy nhất một *output line* tương ứng (One-hot output).

| Tính chất | MUX | Decoder |
| --- | --- | --- |
| **Input** | Data input + Select input | Chỉ Binary Code input |
| **Output** | Luôn có 1 Output | Nhiều Output (chỉ 1 line active = 1) |
| **Chức năng** | Chọn tín hiệu dữ liệu đi qua. | Phiên dịch mã nhị phân thành địa chỉ vật lý. |

* **2-to-4 Decoder:** 2 input (00, 01, 10, 11) kích hoạt 4 output (Y0, Y1, Y2, Y3).
* Input = 10 -> `Y2 = 1`, các Y khác = 0.
* `Y2 = A[1] & ~A[0]`



---

## 9. Encoder (Bộ mã hóa)

* **Là gì?** Làm ngược lại với Decoder.
* **Hoạt động:** Nhận nhiều input lines (chỉ 1 line active), xuất ra mã nhị phân (binary code) đại diện cho line đó.
* **4-to-2 Encoder:** Nếu `D2 = 1` (các chân khác 0) -> Output Code = `10` (số 2).
* **Vấn đề:** Nếu vô tình `D2 = 1` VÀ `D3 = 1` cùng lúc thì sao? Mạch Encoder thông thường sẽ bị lỗi (cho ra kết quả sai rác).

---

## 10. Priority Encoder (Bộ mã hóa ưu tiên)

* **Giải quyết vấn đề của Encoder:** Khi nhiều input cùng active (=1) một lúc, mạch sẽ chọn output dựa trên **input có độ ưu tiên (priority) cao nhất**.
* **Priority:** Thường quy ước chân có chỉ số cao (MSB) hoặc thấp (LSB) có ưu tiên hơn.
* **Ví dụ:** Nếu D3 có ưu tiên cao nhất, D0 thấp nhất.
* Input: `D3 = 1`, `D2 = 1`, `D1 = 0`, `D0 = 1`.
* Vì `D3 = 1`, mạch phớt lờ hoàn toàn D2, D1, D0. Output sẽ là `11` (tương ứng với D3).


* **Suy luận từng bước:**
1. Check input ưu tiên 1: Có = 1 không? Có -> Xuất mã. Không -> Đi tiếp.
2. Check input ưu tiên 2...



---

## 11. Comparator (Bộ so sánh)

*(Đã chạm tới)*

* So sánh 2 vector A và B.
* **Equality:** `assign is_equal = (A == B);` (Bản chất phần cứng là mảng cổng XNOR).
* **Magnitude:** Lớn hơn (`>`), Nhỏ hơn (`<`).

---

## 12. Half Adder (Bộ cộng bán phần)

* **Nhiệm vụ:** Cộng 2 bit A và B.
* **Truth Table:** Đã giải thích ở phần 4.
* **Logic:**
* `Sum = A ^ B` (XOR vì 1+0=1, 0+1=1, nhưng 1+1=0 nhớ 1).
* `Carry = A & B` (Chỉ nhớ 1 khi cả A và B đều bằng 1).



---

## 13. Full Adder (Bộ cộng toàn phần)

* **Sự khác biệt so với Half Adder:** Có thêm chân `Cin` (Carry-in) nhận cờ nhớ từ tầng trước truyền lên.
* **Inputs:** `A`, `B`, `Cin`.
* **Outputs:** `Sum`, `Cout`.
* **Công thức:**
* `Sum = A ^ B ^ Cin` (Số lượng bit 1 lẻ thì Sum = 1).
* `Cout = (A & B) | (A & Cin) | (B & Cin)` (Có ít nhất hai biến = 1 thì sinh cờ nhớ Cout).



---

## 14. Ripple Carry Adder (Bộ cộng dồn)

* Ghép chuỗi nhiều khối Full Adder lại với nhau để cộng vector nhiều bit (vd 4-bit, 16-bit).
* `Cout` của bit thấp (LSB - bit 0) nối vào `Cin` của bit kế tiếp, cứ thế gợn sóng (ripple) lên bit cao nhất (MSB).
* **Trễ truyền lan (Carry propagation):** Chạy rất chậm vì tầng sau phải đợi tầng trước tính xong cờ nhớ.
* **RTL Insight:** Dùng `generate for` ép tool dùng kiến trúc RCA (chậm, nhỏ). Dùng toán tử `assign sum = a + b + cin;` giao quyền cho Synthesis Tool tự động chọn Parallel Prefix Adder siêu nhanh.

---

## 15. Subtractor & 2's Complement (Phép trừ và bù 2)

* Mạch điện số không thích làm phép trừ trực tiếp (trừ mượn / borrow).
* Thay vào đó, máy tính chuyển phép trừ thành phép cộng với số bù 2.
* **Công thức số bù 2:** `-B = ~B + 1` (Đảo toàn bộ bit rồi cộng 1).
* **Toán học phép trừ:**
`A - B = A + (-B) = A + (~B) + 1`
* **Tại sao:** Việc này giúp mạch điện tái sử dụng được hoàn toàn khối Adder đã thiết kế, tiết kiệm silicon.

---

## 16. Adder/Subtractor Circuit

Biến khối Full Adder thành khối Cộng/Trừ kết hợp qua 1 chân điều khiển `SUB`.

* **Logic:** Dùng cổng XOR để đóng vai trò "Inverter có điều kiện" và gán `Cin = SUB`.
* **Mạch:** `B` đi qua cổng XOR với `SUB`.
* **SUB = 0 (Phép cộng):** `B ^ 0 = B`. `Cin = 0`. Mạch thực hiện: `A + B + 0`.
* **SUB = 1 (Phép trừ):** `B ^ 1 = ~B`. `Cin = 1`. Mạch thực hiện: `A + (~B) + 1` (Chính là `A - B`).



---

## 17. Carry / Borrow / Overflow

Sự khác biệt cực kỳ quan trọng giữa Arithmetic Signed và Unsigned.

* **Carry out:** Nhớ tràn bit đối với số Không dấu (Unsigned). Xảy ra khi tổng vượt quá sức chứa vật lý của vector.
* **Overflow:** Tràn số đối với số Có dấu (Signed 2's complement).
* Xảy ra khi cộng 2 số CÙNG DẤU nhưng kết quả ra NGƯỢC DẤU.
* Ví dụ: Dương + Dương = Âm (Overflow!).


* **Carry cuối cùng trong phép trừ 2's complement:** Thường bị vứt bỏ (discarded) khi mạch thực hiện `A + (~B) + 1`. Nó KHÔNG đồng nghĩa với Overflow.

---

## 18. ALU (Arithmetic Logic Unit)

*(Đã chạm tới/Mô hình mental)*

* **Mental model:** ALU = Mạch tổng hợp đa chức năng (Add, Sub, AND, OR) kết hợp với một khối **MUX khổng lồ** ở đầu ra.
* Tín hiệu Control/Select của ALU thực chất là chân Select của MUX để chọn kết quả của phép toán nào được đưa ra ngoài.

---

## 19. Combinational Logic trong Verilog

### 19.1 Continuous Assignment (`assign`)

* Dùng để nối cứng dây phần cứng.
* Ví dụ: `assign sum = a ^ b;`

### 19.2 Procedural Block (`always @(*)`)

* Bắt buộc dùng `always @(*)` (hoặc `always_comb` trong SystemVerilog) cho mạch tổ hợp.
* `*` (Sensitivity list) đảm bảo mạch cập nhật ngay khi *bất kỳ* input nào thay đổi (đúng bản chất mạch tổ hợp).

### 19.3 if / else & case

* Chỉ dùng được bên trong khối `always`.
* `if / else`: Thường tổng hợp thành MUX có ưu tiên.
* `case`: Thường tổng hợp thành MUX ngang hàng hoặc Decoder. Rất thích hợp cho ALU hoặc State/Command decoding.

### 19.4 for loop & Indexed Part-Select (`[base +: width]`)

* `[base +: width]`: Cắt một vector với độ rộng không đổi. Vượt qua giới hạn không cho phép biến động ở cả 2 đầu mút của Verilog. Cực kỳ mạnh trong mạch slicing dữ liệu.
* `generate for`: Đúc (instantiate) phần cứng lặp đi lặp lại (như nối chuỗi RCA).

### 19.5 Blocking assignment (`=`)

* Trong `always @(*)`, mạch tổ hợp dùng `=`, gán lập tức và tuần tự (về mặt thuật toán) để tạo thành luồng data flow tổ hợp tĩnh.

---

## 20. Combinational RTL Coding Rules (Checklist)

* [x] Dùng `always @(*)` hoặc `assign` cho mạch tổ hợp. Không dùng `posedge clk`.
* [x] Dùng Blocking Assignment (`=`) trong khối tổ hợp.
* [x] **Output phải được assign trong mọi nhánh (if/else, case):** Thiếu nhánh sẽ sinh ra Latch (bộ nhớ ngoài ý muốn) -> Phá vỡ bản chất mạch tổ hợp.
* [x] Gán giá trị default ở đầu khối `always` để tránh Incomplete Assignment/Latch.
* [x] Biến được gán trong `assign` phải khai báo là `wire`.
* [x] Biến được gán trong `always` phải khai báo là `reg` (hoặc `logic` trong SV).

---

## 21. HDLBits — Những gì tôi đã làm

1. **`gatesv`:** Viết logic gate cho vector. Biết dùng toán tử `anotb` (`a & ~b`).
2. **`mux256to1` & `mux256to1v`:** Chọn 1 bit / 1 vector từ bus khổng lồ bằng index động. Khẳng định MUX là khái niệm trừu tượng, truy xuất mảng trong Verilog chính là đúc MUX ở hardware.
3. **`fadd` (Full Adder):** Xây dựng bộ cộng cơ bản.
4. **`bcdadd100`:** Ghép chuỗi bộ cộng BCD. Học được Indexed Part-Select `[4*i +: 4]` để lấy 4 bit gọn gàng thay vì `[4*i+3 : 4*i]`. Nhận thức sâu sắc sự khác biệt giữa RCA (`generate`) vs Synthesis PPA (`+`).
5. **`Kmap3` & Các bài K-map:** Rút gọn SOP triệt để. Tìm nhóm $2 \times 2$ để tiết kiệm cổng AND thay vì nhóm nhỏ.
6. **`ece241_2014_q3` (MUX implementation):** Ứng dụng K-map (các cột) để ánh xạ hàm logic vào các ngõ vào của một MUX 4-to-1 định sẵn.

---

## 22. Common Mistakes I Made (Lỗi từng gặp & Bài học)

1. **Viết sai logic POS (Product of Sums):**
* *Sai lầm:* Nghĩ POS chỉ là đảo kết quả SOP, dùng dấu `&` bên trong ngoặc `(~a & ~b)`.
* *Nguyên nhân:* Nhầm lẫn De Morgan và quy ước.
* *Cách đúng:* Lập Maxterm từ ô số 0. Input = 0 giữ nguyên, Input = 1 đảo. Bên trong các ngoặc là phép OR (`|`), nối các ngoặc bằng phép AND (`&`). Ví dụ: `(A | ~B) & (C | D)`.


2. **Sót nhóm lớn trên K-map (Bỏ lỡ nhóm $2 \times 2$):**
* *Sai lầm:* Chỉ ghép 2 ô thay vì lợi dụng Don't cares (`d`) và biên bảng để ghép 4 ô.
* *Cách đúng:* Luôn quét tìm nhóm 16 -> 8 -> 4 -> 2. Cuộn bảng và dùng tối đa `d`.


3. **Cú pháp Generate for sinh phần cứng:**
* *Sai lầm:* Để tên nhãn trước từ khóa `begin` (`for (...) :name begin`). Không đặt tên instance khi gọi module con. Quên không tạo vector wire trung gian cho Carry chain dẫn đến ngắn mạch (multiple drivers).
* *Cách đúng:* `for (...) begin : name`. Cần tạo mảng wire nội bộ để nối tín hiệu gợn sóng từ tầng `i-1` sang tầng `i`.


4. **Nhầm lẫn cắt vector `[i+3 : i]`:**
* *Cách đúng:* Dùng Indexed Part-Select `[i*4 +: 4]`. Trình biên dịch phần cứng phải biết chắc độ rộng vật lý của bó dây.



---

## 23. Mental Models — Cách nhớ nhanh

* **Combinational Logic:** Input ngay lúc này -> Tính toán ngay lập tức -> Output ngay lúc này (Không quá khứ, không tương lai).
* **MUX:** Nhiều Data vào -> 1 Data ra. "Kẻ bẻ ghi đường tàu" (Select).
* **Decoder:** 1 Mã địa chỉ vào -> Kích hoạt đúng 1 bóng đèn (Output line) sáng lên.
* **Encoder:** 1 Bóng đèn sáng -> Trả về mã địa chỉ của bóng đèn đó.
* **Priority Encoder:** Nhiều đèn sáng -> Chỉ báo mã của đèn VIP nhất.
* **Subtractor (Bù 2):** Đảo tất cả các bit của B, rồi cộng 1. (A - B = A + ~B + 1).

---

## 24. Problem-Solving Workflow (Giải bài Combinational RTL)

1. **Hiểu bài toán:** Xác định rõ đâu là Inputs, đâu là Outputs, độ rộng bus (bao nhiêu bit).
2. **Xây bảng chân trị (Truth Table):** Mô tả hành vi mạch muốn đạt được (nếu bài toán nhỏ).
3. **Lập K-map:** Nếu số lượng input < 5, vẽ K-map để tìm hàm Boolean SOP tối tiểu.
4. **Đưa ra hàm Boolean:** Viết dưới dạng `Y = (A & B) | (~C & D)`.
5. **Chuyển sang RTL:** Ánh xạ vào Verilog dùng `assign` hoặc `always @(*)`.
6. **Tối ưu (RTL vs Tool):** Xác định xem nên tự viết logic cấu trúc (`generate`) hay dùng toán tử hành vi (behavioral `+`) để giao cho Synthesis tool tối ưu.
7. **Review Latch:** Rà soát tất cả các lệnh `if/case` đảm bảo không bị thiếu ngõ ra, không sinh Latch.

---

## 25. Combinational Logic -> RTL Design

Những kiến thức số học map trực tiếp vào RTL như sau:

* **AND/OR/NOT Gates** -> `assign` kết hợp các toán tử bitwise `&, |, ~, ^`.
* **MUX** -> Lệnh `if/else` (MUX có độ ưu tiên) hoặc toán tử 3 ngôi `? :`.
* **Decoder / MUX ngang hàng** -> Lệnh `case`.
* **Adder** -> Toán tử `+` (RTL Compiler tự sinh mạch sinh cờ nhớ song song).
* **K-map / Truth Table** -> Không cần tự vẽ tay khi viết RTL phức tạp, trình tổng hợp tự động chạy thuật toán Quine-McCluskey thu gọn logic. Nhưng tư duy K-map giúp kỹ sư viết code Verilog bao phủ mọi trường hợp (corner cases) để không sinh Latch ngoài ý muốn.

---

## 26. Những gì tôi đã nắm được vs chưa nắm chắc

* **Đã hiểu cực kỳ chắc chắn:**
* Cắt vector, Indexed part-select, vòng lặp sinh phần cứng.
* Tối giản SOP trên K-map.
* Bản chất của MUX (Hardware) vs Array indexing (Software).
* Sự khác biệt giữa thiết kế Structural (`generate`) và Behavioral (`+` operator).


* **Hiểu nhưng cần chú ý thêm (Dễ mắc lỗi syntax/logic):**
* Khai báo và kết nối tín hiệu nội bộ qua các tầng module lồng nhau.
* Maxterm / Dạng POS / De Morgan ngược.


* **Chưa học sâu (Sẽ khai phá sau này):**
* So sánh Magnitude (Comparator chi tiết từng cổng).
* Thiết kế kiến trúc ngầm của ALU, các kiến trúc Adder song song (CLA, Kogge-Stone) ở mức cấu trúc vật lý.



---

## 27. Checklist trước khi chuyển sang Sequential Logic

* [x] Hiểu bản chất Combinational Logic (Không trạng thái, tính ngay lập tức).
* [x] Nắm vững Logic Gates & Truth Table.
* [x] Chuyển đổi mượt mà K-map -> Tối giản biểu thức SOP.
* [x] Hiểu sâu MUX (Multiplexer) và cách dùng MUX thực hiện logic (K-map column to MUX).
* [x] Hiểu khác biệt giữa Decoder và MUX.
* [x] Nắm nguyên lý Bù 2 (2's complement) và Full Adder / Ripple Carry.
* [x] Viết thành thạo `assign`, part-select, `generate` trong Verilog tổ hợp.
* [x] Sẵn sàng tư duy trạng thái (có nhớ) cho D Flip-Flop.

---

## 28. Mini Exercises (Tự kiểm tra nhanh)

**Level 1 — Basic Logic:**

1. Viết phương trình cho cổng NAND và XOR 2 input.

**Level 2 — K-map & Truth Table:**
2. Tìm SOP rút gọn từ: `m(0, 1, 2, 4)` trên bìa 3 biến. Nhóm lớn nhất bạn tìm được là nhóm bao nhiêu ô?

**Level 3 — MUX & Decoder:**
3. MUX 8-to-1 cần bao nhiêu bit Select?
4. Một Decoder 3-to-8 nếu đưa input code là `3'b101`, thì ngõ ra nào (từ Y0 đến Y7) sẽ ở mức 1?

**Level 4 — Adder & RTL:**
5. Xây dựng một Subtractor 8-bit thực hiện `Result = A - B` bằng cách dùng phép cộng `+` và toán tử bitwise trong 1 dòng `assign` duy nhất của Verilog.

### Answer Key (Chỉ xem sau khi tự làm)

1. NAND: `Y = ~(A & B)`. XOR: `Y = A ^ B` hoặc `(~A & B) | (A & ~B)`.
2. Bảng 3 biến (A, B, C). Nhóm `m(0,1)` và `m(0,2,4)`... Thực tế nhóm lớn nhất là nhóm 2 ô. Không có nhóm 4 do vị trí các minterm.
3. 3 bits (Vì $2^3 = 8$).
4. Ngõ ra `Y5` (vì `101` nhị phân = 5 thập phân).
5. `assign Result = A + (~B) + 1'b1;`

```

```