import SwiftyLLVM
import XCTest

final class CodeGenerationTests: XCTestCase {

  func testO0() throws {
    try Context.withNew { (llvm) in
      try llvm.withNewModule("math") { (llvm, m) -> Void in
        m.emitTest(in: &llvm)
        m.runDefaultModulePasses(optimization: .none)
        XCTAssertNoThrow(try m.verify())
      }
    }
  }

  func testO1() throws {
    try Context.withNew { (llvm) in
      try llvm.withNewModule("math") { (llvm, m) -> Void in
        m.emitTest(in: &llvm)
        m.runDefaultModulePasses(optimization: .less)
        XCTAssertNoThrow(try m.verify())
      }
    }
  }

  func testO2() throws {
    try Context.withNew { (llvm) in
      try llvm.withNewModule("math") { (llvm, m) -> Void in
        m.emitTest(in: &llvm)
        m.runDefaultModulePasses(optimization: .default)
        XCTAssertNoThrow(try m.verify())
      }
    }
  }

  func testO3() throws {
    try Context.withNew { (llvm) in
      try llvm.withNewModule("math") { (llvm, m) -> Void in
        m.emitTest(in: &llvm)
        m.runDefaultModulePasses(optimization: .aggressive)
        XCTAssertNoThrow(try m.verify())
      }
    }
  }

}

extension Module {

  /// Emits contents in `self` to prepare the tests in `CodeGenerationTests`.
  ///
  /// Two functions are emitted, implementing a program equivalent to the one below, which is
  /// written in Hylo:
  ///
  ///     subscript degrees(_ radians: inout Float64): Float64 {
  ///       inout {
  ///         var d = radians * 180.0 / Float64.pi()
  ///         yield &d
  ///         &radians = d * Float64.pi() / 180.0
  ///       }
  ///     }
  ///
  ///     public fun main() -> Int32 {
  ///       var r = Float64.pi()
  ///       &degrees[&r] -= 180.0
  ///       return if r == 0 { 0 } else { 1 }
  ///     }
  ///
  /// `self` is expected to be empty.
  fileprivate mutating func emitTest(in llvm: inout Context) {
    let r2d = emitProjectDegrees(in: &llvm)
    _ = emitMain(projectingDegreesWith: r2d, in: &llvm)
  }

  /// Defines a function `main` that calls the coroutine created by `emitProjectDegrees`.
  private mutating func emitMain(
    projectingDegreesWith projectDegrees: Function, in llvm: inout Context
  ) -> Function {
    let i1 = llvm.i1
    let i32 = llvm.i32
    let f64 = llvm.double
    let ptr = llvm.ptr

    let s = FunctionType(from: [], to: i32, in: &llvm)
    let f = declareFunction("main", s)

    let b0 = appendBlock(named: "b0", to: f)

    // %0 = alloca [16 x i8], align 8
    // %1 = alloca double, align 8
    let x0 = insertAlloca(ArrayType(16, llvm.i8, in: &llvm), at: endOf(b0))
    setAlignment(8, for: x0)
    let x1 = insertAlloca(f64, at: endOf(b0))

    // store double 0x400921FB54442D18, ptr %1, align 8
    insertStore(f64(.pi), to: x1, at: endOf(b0))

    // %2 = call ptr @llvm.coro.prepare.retcon(ptr @deg)
    // %3 = call { ptr, ptr } %2(ptr %0, ptr %1)
    let prepare = intrinsic(named: Intrinsic.llvm.coro.prepare.retcon)!
    let x2 = insertCall(Function(prepare)!, on: [projectDegrees], at: endOf(b0))
    let x3 = insertCall(x2, typed: projectDegrees.valueType, on: [x0, x1], at: endOf(b0))
    
    // %4 = extractvalue { ptr, ptr } %3, 1
    // %5 = load double, ptr %4, align 8
    // %6 = fsub double %5, 1.800000e+02
    // store double %6, ptr %4, align 8
    let x4 = insertExtractValue(from: x3, at: 1, at: endOf(b0))
    let x5 = insertLoad(f64, from: x4, at: endOf(b0))
    let x6 = insertFSub(x5, f64(180), at: endOf(b0))
    insertStore(x6, to: x4, at: endOf(b0))

    // %7 = extractvalue { ptr, ptr } %3, 0
    // call void %7(ptr %0, i1 false
    let x7 = insertExtractValue(from: x3, at: 0, at: endOf(b0))
    _ = insertCall(
      x7, typed: FunctionType(from: [ptr, i1], in: &llvm), on: [x0, i1(0)], at: endOf(b0))

    // %8 = load double, ptr %1, align 8
    // %9 = fcmp ueq double %8, 0.000000e+00
    // %10 = zext i1 %9 to i32
    let x8 = insertLoad(f64, from: x1, at: endOf(b0))
    let x9 = insertFloatingPointComparison(.ueq, x8, f64(0), at: endOf(b0))
    let xa = insertZeroExtend(x9, to: i32, at: endOf(b0))

    // ret i32 %10
    insertReturn(xa, at: endOf(b0))

    return f
  }

  /// Defines a coroutine that projects the value in degrees of an angle passed in radians.
  private mutating func emitProjectDegrees(in llvm: inout Context) -> Function {
    let i1 = llvm.i1
    let i32 = llvm.i32
    let f64 = llvm.double
    let ptr = llvm.ptr

    // declare void @slide(ptr, i1 zeroext)
    let slide = declareFunction("slide", .init(from: [ptr, i1], in: &llvm))
    addAttribute(.init(.zeroext, in: &llvm), to: slide.parameters[1])

    // declare noalias ptr @alloc(i32)
    let alloc = declareFunction("alloc", .init(from: [i32], to: ptr, in: &llvm))
    addAttribute(.init(.noalias, in: &llvm), to: alloc.returnValue)

    // declare void @dealloc(ptr)
    let dealloc = declareFunction("dealloc", .init(from: [ptr], in: &llvm))

    // define { ptr, ptr } @deg(ptr %0, ptr %1)
    let s = FunctionType(from: [ptr, ptr], to: StructType([ptr, ptr], in: &llvm), in: &llvm)
    let f = declareFunction("deg", s)
    let r = f.parameters.last!

    let b0 = appendBlock(named: "b0", to: f)
    
    // %2 = alloca double, align 8
    let x0 = insertAlloca(f64, at: endOf(b0))

    // %3 = call token @llvm.coro.id.retcon.once(
    //   i32 16, i32 8, ptr %0, ptr @slide, ptr @alloc, ptr @dealloc)
    let retconOnce = intrinsic(named: Intrinsic.llvm.coro.id.retcon.once)!
    let coroutineID = insertCall(
      Function(retconOnce)!,
      on: [
        i32(16),  // size of the frame buffer
        i32(8),  // alignment of the frame buffer
        f.parameters.first!,  // the frame buffer
        slide, alloc, dealloc
      ],
      at: endOf(b0))

    // %4 = call ptr @llvm.coro.begin(token %3, ptr null)
    let begin = intrinsic(named: Intrinsic.llvm.coro.begin)!
    let coroutineHandle = insertCall(
      Function(begin)!,
      on: [coroutineID, ptr.null],
      at: endOf(b0))

    // %5 = load double, ptr %1, align 8
    // %6 = fmul double %5, 1.800000e+02
    // %7 = fdiv double %6, 0x400921FB54442D18
    // store double %7, ptr %2, align 8
    let x1 = insertLoad(f64, from: r, at: endOf(b0))
    let x2 = insertFMul(x1, f64(180), at: endOf(b0))
    let x3 = insertFDiv(x2, f64(.pi), at: endOf(b0))
    insertStore(x3, to: x0, at: endOf(b0))

    // %8 = call i1 (...) @llvm.coro.suspend.retcon.i1(ptr %2)
    let suspend = intrinsic(named: Intrinsic.llvm.coro.suspend.retcon, for: [i1])!
    _ = insertCall(Function(suspend)!, on: [x0], at: endOf(b0))

    // %9 = load double, ptr %2, align 8
    // %10 = fmul double %9, 0x400921FB54442D18
    // %11 = fdiv double %10, 1.800000e+02
    // store double %11, ptr %1, align 8
    let x4 = insertLoad(f64, from: x0, at: endOf(b0))
    let x5 = insertFMul(x4, f64(.pi), at: endOf(b0))
    let x6 = insertFDiv(x5, f64(180), at: endOf(b0))
    insertStore(x6, to: r, at: endOf(b0))

    // %12 = call i1 @llvm.coro.end(ptr %4, i1 false)
    let end = intrinsic(named: Intrinsic.llvm.coro.end)!
    _ = insertCall(Function(end)!, on: [coroutineHandle, i1(0)], at: endOf(b0))

    // unreachable
    insertUnreachable(at: endOf(b0))

    return f
  }

}
