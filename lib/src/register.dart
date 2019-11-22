import 'dart:typed_data';

extension Byte on int {
  /// Operator override for [] allows us to access each bit as a boolean.
  bool operator [](int i) => (this & 0x01 << i) != 0;

  /// Operator override for []= allows us to set each bit.
  void operator []=(int i, bool set) => this & ~((set ? 0x1 : 0x0) << i);

  /// Returns the value of the bit at [index] as a [bool].
  bool getBit(int index) => this[index];

  /// Sets the bit at [index] to 1 or 0 based on the value in [set].
  /// If a value is not provided, the bit is set to true.
  void setBit(int index, [bool set]) => this[index] = set ?? true;
}

/// A base class used to represent registers that will hold [size] bytes
/// using a [Uint8List] implementation to be memory efficient.
class Register {
  /// Size of the register in bytes.
  final int size;

  /// A [Uint8List] that's [size] bytes long, that hold the data in the [Register].
  final Uint8List _bytes;

  /// Returns the value in the register.
  get value => _bytes;

  /// Sets the [value] of a given [size] in the register at the [byteOffset].
  setValue(int value, {int byteOffset = 0, int size = 1}) {
    if (size == 1) {
      ByteData.view(_bytes.buffer).setUint8(byteOffset, value);
    } else if (size == 2) {
      ByteData.view(_bytes.buffer).setUint16(byteOffset, value);
    } else if (size == 4) {
      ByteData.view(_bytes.buffer).setUint32(byteOffset, value);
    } else if (size == 8) {
      ByteData.view(_bytes.buffer).setUint64(byteOffset, value);
    } else {
      throw Exception("Size must be 1, 2, 4, or 8");
    }
  }

  /// Converts the value in the [Register] to an [int]. You may optionally
  /// provide a [byteSize] to specify how many bytes you'd like. You can also
  /// specify an [byteOffset] to get an int from that location.
  int toInt({byteOffset = 0, byteSize = 1}) {
    if (byteSize == 1) {
      return ByteData.view(_bytes.buffer).getUint8(byteOffset);
    } else if (byteSize == 2) {
      return ByteData.view(_bytes.buffer).getUint16(byteOffset);
    } else if (byteSize == 4) {
      return ByteData.view(_bytes.buffer).getUint32(byteOffset);
    } else if (byteSize == 8) {
      return ByteData.view(_bytes.buffer).getUint64(byteOffset);
    } else {
      throw Exception("Size must be 1, 2, 4, or 8");
    }
  }

  /// Gets the byte at a given [index], given that it's valid.
  int getByte(int index) => _bytes[index];

  /// Set the byte at a given [index] to [value], given that it's valid.
  void setByte(int index, int value) => _bytes[index] = value;

  /// Creates a [Register] of that is [size] bytes.
  Register({int size = 1})
      : size = size,
        _bytes = Uint8List(size);
}

/// The program counter is a 16 bit register which points to the next
/// instruction to be executed. The value of program counter is modified
/// automatically as instructions are executed.
///
/// The value of the program counter can be modified by executing a jump, a
/// relative branch or a subroutine call to another memory address or by
/// returning from a subroutine or interrupt.
class ProgramCounter extends Register {
  ProgramCounter() : super(size: 2);

  int toInt({byteOffset = 0, byteSize = 1}) => super.toInt(byteSize: this.size);
}

/// The processor supports a 256 byte stack located between $0100 and $01FF.
/// The stack pointer is an 8 bit register and holds the low 8 bits of the next
/// free location on the stack. The location of the stack is fixed and cannot
/// be moved.
///
/// Pushing bytes to the stack causes the stack pointer to be decremented.
/// Conversely pulling bytes causes it to be incremented.
///
/// The CPU does not detect if the stack is overflowed by excessive pushing or
/// pulling operations and will most likely result in the program crashing.
class StackPointer extends Register {
  int toInt({byteOffset = 0, byteSize = 1}) => super.toInt(byteSize: this.size);
}

/// The 8 bit accumulator is used all arithmetic and logical operations
/// (with the exception of increments and decrements). The contents of the
/// accumulator can be stored and retrieved either from memory or the stack.
///
/// Most complex operations will need to use the accumulator for arithmetic
/// and efficient optimization of its use is a key feature of time critical
/// routines.
class Accumulator extends Register {}

/// The 8 bit index register is most commonly used to hold counters or offsets
/// for accessing memory. The value of the X register can be loaded and saved in
/// memory, compared with values held in memory or incremented and decremented.
///
/// The X register has one special function. It can be used to get a copy of
/// the stack pointer or change its value.
class IndexRegisterX extends Register {}

/// The Y register is similar to the X register in that it is available for
/// holding counter or offsets memory access and supports the same set of
/// memory load, save and compare operations as wells as increments and
/// decrements. It has no special functions.
class IndexRegisterY extends Register {}

class StatusRegister extends Register {
  int get _byte => _bytes[0];

  get carryFlag => _byte.getBit(7);

  set carryFlag(bool set) => _byte.setBit(7, set);

  get zeroFlag => _byte.getBit(6);

  set zeroFlag(bool set) => _byte.setBit(6, set);

  get interruptFlag => _byte.getBit(5);

  set interruptFlag(bool set) => _byte.setBit(5, set);

  get decimalFlag => _byte.getBit(4);

  set decimalFlag(bool set) => _byte.setBit(4, set);

  get noEffectMsbFlag => _byte.getBit(3);

  set noEffectMsbFlag(bool set) => _byte.setBit(3, set);

  get noEffectLsbFlag => _byte.getBit(2);

  set noEffectLsbFlag(bool set) => _byte.setBit(2, set);

  get overflowFlag => _byte.getBit(1);

  set overflowFlag(bool set) => _byte.setBit(1, set);

  get negativeFlag => _byte.getBit(0);

  set negativeFlag(bool set) => _byte.setBit(0, set);

  get C => carryFlag;

  set C(bool set) => carryFlag = set;

  get Z => zeroFlag;

  set Z(bool set) => zeroFlag = set;

  get I => interruptFlag;

  set I(bool set) => interruptFlag = set;

  get D => decimalFlag;

  set D(bool set) => decimalFlag = set;

  get V => overflowFlag;

  set V(bool set) => overflowFlag = set;

  get N => negativeFlag;

  set N(bool set) => negativeFlag = set;
}
