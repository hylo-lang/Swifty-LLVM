# Coverage

## Analysis

- [x] LLVMVerifyModule

  `Module.verify()`

- [x] LLVMVerifyFunction

  `Function.isWellFormed()`

- [ ] LLVMViewFunctionCFG
- [ ] LLVMViewFunctionCFGOnly

## Core

### Comdats

- [ ] LLVMGetOrInsertComdat
- [ ] LLVMGetComdat
- [ ] LLVMSetComdat
- [ ] LLVMGetComdatSelectionKind
- [ ] LLVMSetComdatSelectionKind

### Contexts

- [x] LLVMContextCreate

  `Module.init(_:)`

- [ ] LLVMGetGlobalContext
- [ ] LLVMContextSetDiagnosticHandler
- [ ] LLVMContextGetDiagnosticHandler
- [ ] LLVMContextGetDiagnosticContext
- [ ] LLVMContextSetYieldCallback
- [ ] LLVMContextShouldDiscardValueNames
- [ ] LLVMContextSetDiscardValueNames
- [ ] LLVMContextRef
- [ ] LLVMGetDiagInfoDescription
- [ ] LLVMGetDiagInfoSeverity
- [ ] LLVMGetMDKindIDInContext
- [ ] LLVMGetMDKindID
- [ ] LLVMGetEnumAttributeKindForName
- [ ] LLVMGetLastEnumAttributeKind
- [ ] LLVMCreateEnumAttribute
- [ ] LLVMGetEnumAttributeKind
- [ ] LLVMGetEnumAttributeValue
- [ ] LLVMCreateTypeAttribute
- [ ] LLVMGetTypeAttributeValue
- [ ] LLVMCreateStringAttribute
- [ ] LLVMGetStringAttributeKind
- [ ] LLVMGetStringAttributeValue
- [ ] LLVMIsEnumAttribute
- [ ] LLVMIsStringAttribute
- [ ] LLVMIsTypeAttribute
- [x] LLVMGetTypeByName2

  `Module.type(named:)`

### Linker

- [ ] LLVMLinkModules2

### Basic Blocks

- [ ] LLVMBasicBlockAsValue
- [ ] LLVMValueIsBasicBlock
- [ ] LLVMValueAsBasicBlock
- [ ] LLVMGetBasicBlockName
- [ ] LLVMGetBasicBlockParent
- [ ] LLVMGetBasicBlockTerminator
- [ ] LLVMCountBasicBlocks
- [ ] LLVMGetBasicBlocks
- [ ] LLVMGetFirstBasicBlock
- [ ] LLVMGetLastBasicBlock
- [ ] LLVMGetNextBasicBlock
- [ ] LLVMGetPreviousBasicBlock
- [ ] LLVMGetEntryBasicBlock
- [ ] LLVMInsertExistingBasicBlockAfterInsertBlock
- [ ] LLVMAppendExistingBasicBlock
- [ ] LLVMCreateBasicBlockInContext
- [x] LLVMAppendBasicBlockInContext

  `Module.appendBlock(named:to:)`

- [ ] LLVMAppendBasicBlock
- [ ] LLVMInsertBasicBlockInContext
- [ ] LLVMInsertBasicBlock
- [ ] LLVMDeleteBasicBlock
- [ ] LLVMRemoveBasicBlockFromParent
- [ ] LLVMMoveBasicBlockBefore
- [ ] LLVMMoveBasicBlockAfter
- [ ] LLVMGetFirstInstruction
- [ ] LLVMGetLastInstruction

### Instructions

- [ ] LLVMHasMetadata
- [ ] LLVMGetMetadata
- [ ] LLVMSetMetadata
- [ ] LLVMInstructionGetAllMetadataOtherThanDebugLoc
- [ ] LLVMGetInstructionParent
- [ ] LLVMGetNextInstruction
- [ ] LLVMGetPreviousInstruction
- [ ] LLVMInstructionRemoveFromParent
- [ ] LLVMInstructionEraseFromParent
- [ ] LLVMDeleteInstruction
- [ ] LLVMGetInstructionOpcode
- [ ] LLVMGetICmpPredicate
- [ ] LLVMGetFCmpPredicate
- [ ] LLVMInstructionClone
- [x] LLVMIsATerminatorInst

  `IRValue.isTerminator`

#### Call Sites and Invocations

- [ ] LLVMGetNumArgOperands
- [ ] LLVMSetInstructionCallConv
- [ ] LLVMGetInstructionCallConv
- [ ] LLVMSetInstrParamAlignment
- [ ] LLVMAddCallSiteAttribute
- [ ] LLVMGetCallSiteAttributeCount
- [ ] LLVMGetCallSiteAttributes
- [ ] LLVMGetCallSiteEnumAttribute
- [ ] LLVMGetCallSiteStringAttribute
- [ ] LLVMRemoveCallSiteEnumAttribute
- [ ] LLVMRemoveCallSiteStringAttribute
- [ ] LLVMGetCalledFunctionType
- [ ] LLVMGetCalledValue
- [ ] LLVMIsTailCall
- [ ] LLVMSetTailCall
- [ ] LLVMGetNormalDest
- [ ] LLVMGetUnwindDest
- [ ] LLVMSetNormalDest
- [ ] LLVMSetUnwindDest

#### Allocas

- [x] LLVMGetAllocatedType

  `Alloca.allocatedType`

#### GEPs

- [ ] LLVMIsInBounds
- [ ] LLVMSetIsInBounds
- [ ] LLVMGetGEPSourceElementType (LLVMValueRef GEP)

#### InsertValue

- [ ] LLVMGetNumIndices
- [ ] LLVMGetIndices

#### PHI Nodes

- [ ] LLVMAddIncoming
- [ ] LLVMCountIncoming
- [ ] LLVMGetIncomingValue
- [ ] LLVMGetIncomingBlock (LLVMValueRef PhiNode, unsigned Index)

### Values

- [x] LLVMTypeOf

  `IRValue.type`

- [ ] LLVMGetValueKind
- [ ] LLVMGetValueName2
- [ ] LLVMSetValueName2
- [ ] LLVMDumpValue
- [x] LLVMPrintValueToString

  `IRValue.description`

- [ ] LLVMReplaceAllUsesWith
- [x] LLVMIsConstant

  `IRValue.isConstant`

- [x] LLVMIsUndef

  `Undefined.init?(_:)`

- [x] LLVMIsPoison

  `Poison.init?(_:)`

- [ ] LLVMIsAMDNode
- [ ] LLVMIsAValueAsMetadata
- [ ] LLVMIsAMDString

#### Usage 

- [ ] LLVMGetFirstUse
- [ ] LLVMGetNextUse
- [ ] LLVMGetUser
- [ ] LLVMGetUsedValue

#### Constants

- [x] LLVMConstNull

  `IRType.null`

  `FloatingPointType.zero`

  `IntegerType.zero`

- [ ] LLVMConstAllOnes
- [x] LLVMGetUndef

  `Undefined.init()`

- [x] LLVMGetPoison

  `Poison.init()`

- [x] LLVMIsNull

  `IRValue.isNull`

- [ ] LLVMConstPointerNull

##### Composite Constants

- [x] LLVMConstStringInContext

  `StringConstant.init()`

- [ ] LLVMConstString
- [x] LLVMIsConstantString

  `StringConstant.init?()`

- [x] LLVMGetAsString

  `StringConstant.value`

- [ ] LLVMConstStructInContext
- [ ] LLVMConstStruct
- [ ] LLVMConstArray
- [ ] LLVMConstArray2
- [ ] LLVMConstNamedStruct
- [ ] LLVMGetAggregateElement
- [ ] LLVMConstVector

##### Scalar Constants

- [x] LLVMConstInt 

  `IntegerType.constant(_:extendingSign:)`
 
- [x] LLVMConstIntOfArbitraryPrecision

  `IntegerType.constant(words:)`

- [ ] LLVMConstIntOfString
- [x] LLVMConstIntOfStringAndSize 

  `IntegerType.constant(_:radix:)`

- [x] LLVMConstIntGetZExtValue

  `IntegerConstant.zext`

- [x] LLVMConstIntGetSExtValue

  `IntegerConstant.sext`

- [x] LLVMConstReal

  `FloatingPointType.constant(_:)`

- [ ] LLVMConstRealOfString
- [x] LLVMConstRealOfStringAndSize

  `FloatingPointType.constant(_:)`

- [x] LLVMConstRealGetDouble

  `FloatingPointConstant.value()`

### Types

- [x] LLVMGetTypeKind

  Implemented as a fallible initializer on all wrapped types.

- [x] LLVMTypeIsSized

  `IRType.isSized`

- [ ] LLVMGetTypeContext
- [ ] LLVMDumpType
- [x] LLVMPrintTypeToString

  `IRType.description`

#### Integer Types

- [ ] LLVMInt1TypeInContext
- [ ] LLVMInt8TypeInContext
- [ ] LLVMInt16TypeInContext
- [ ] LLVMInt32TypeInContext
- [ ] LLVMInt64TypeInContext
- [ ] LLVMInt128TypeInContext
- [x] LLVMIntTypeInContext

  `IntegerType.init(_:in:)`

- [ ] LLVMInt1Type
- [ ] LLVMInt8Type
- [ ] LLVMInt16Type
- [ ] LLVMInt32Type
- [ ] LLVMInt64Type
- [ ] LLVMInt128Type
- [ ] LLVMIntType
- [x] LLVMGetIntTypeWidth

  `IntegerType.bitWidth`

#### Floating-point Types

- [x] LLVMHalfTypeInContext

  `FloatingPointType.half(in:)`

- [ ] LLVMBFloatTypeInContext
- [x] LLVMFloatTypeInContext

  `FloatingPointType.float(in:)`

- [x] LLVMDoubleTypeInContext

  `FloatingPointType.double(in:)`

- [ ] LLVMX86FP80TypeInContext
- [x] LLVMFP128TypeInContext

  `FloatingPointType.fp128(in:)`

- [ ] LLVMPPCFP128TypeInContext
- [ ] LLVMHalfType
- [ ] LLVMBFloatType
- [ ] LLVMFloatType
- [ ] LLVMDoubleType
- [ ] LLVMX86FP80Type
- [ ] LLVMFP128Type
- [ ] LLVMPPCFP128Type

#### Function Types

- [x] LLVMFunctionType

  `FunctionType.init(from:to:in:)`

- [ ] LLVMIsFunctionVarArg
- [x] LLVMGetReturnType

  `FunctionType.returnType`

- [x] LLVMCountParamTypes

  Implemented as the `count` property of `FunctionType.parameters`.

- [x] LLVMGetParamTypes

  `FunctionType.parameters`

#### Structure Types

- [x] LLVMStructTypeInContext

  `StructType.init(_:packed:in:)`

- [ ] LLVMStructType
- [x] LLVMStructCreateNamed

  `StructType.init(named:_:packed:in:)`

- [x] LLVMGetStructName

  `StructType.name`

- [x] LLVMStructSetBody

  `StructType.init(_:packed:in:)`

- [x] LLVMCountStructElementTypes

  `StructType.Fields.count`

- [ ] LLVMGetStructElementTypes
- [x] LLVMStructGetTypeAtIndex

  `StructType.Fields[_:]`

- [x] LLVMIsPackedStruct

  `StructType.isPacked`

- [x] LLVMIsOpaqueStruct

  `StructType.isOpaque`

- [x] LLVMIsLiteralStruct

  `StructType.isLiteral`

#### Sequential Types

- [ ] LLVMGetElementType
- [ ] LLVMGetSubtypes
- [ ] LLVMGetNumContainedTypes
- [ ] LLVMArrayType
- [ ] LLVMArrayType2
- [ ] LLVMGetArrayLength
- [ ] LLVMGetArrayLength2
- [ ] LLVMPointerType
- [ ] LLVMPointerTypeIsOpaque
- [x] LLVMPointerTypeInContext

  `PointerType.init(inAddressSpace:in:)`

- [x] LLVMGetPointerAddressSpace

  `PointerType.addressSpace`

- [ ] LLVMVectorType
- [ ] LLVMScalableVectorType
- [ ] LLVMGetVectorSize

#### Other Types

- [x] LLVMVoidTypeInContext

  `VoidType.init(in:)`

- [ ] LLVMLabelTypeInContext
- [ ] LLVMX86MMXTypeInContext
- [ ] LLVMX86AMXTypeInContext
- [ ] LLVMTokenTypeInContext
- [ ] LLVMMetadataTypeInContext
- [ ] LLVMVoidType
- [ ] LLVMLabelType
- [ ] LLVMX86MMXType
- [ ] LLVMX86AMXType
- [ ] LLVMTargetExtTypeInContext

### Metadata

- [ ] LLVMMDStringInContext2
- [ ] LLVMMDNodeInContext2
- [ ] LLVMMetadataAsValue
- [ ] LLVMValueAsMetadata
- [ ] LLVMGetMDString
- [ ] LLVMGetMDNodeNumOperands
- [ ] LLVMGetMDNodeOperands
- [ ] LLVMReplaceMDNodeOperandWith

## Instruction Builders

- [x] LLVMCreateBuilderInContext

  `Module.endOf(_:in:)`

- [ ] LLVMCreateBuilder
- [ ] LLVMPositionBuilder
- [x] LLVMPositionBuilderBefore

  `Module.before(_:in:)`

- [x] LLVMPositionBuilderAtEnd

  `InsertionPoint.atEndOf(_:in:)`

- [ ] LLVMGetInsertBlock
- [ ] LLVMClearInsertionPosition
- [ ] LLVMInsertIntoBuilder
- [ ] LLVMInsertIntoBuilderWithName
- [x] LLVMDisposeBuilder

  Implemented by `InsertionPoint.wrapped`.

- [ ] LLVMGetCurrentDebugLocation2
- [ ] LLVMSetCurrentDebugLocation2
- [ ] LLVMSetInstDebugLocation
- [ ] LLVMAddMetadataToInst
- [ ] LLVMBuilderGetDefaultFPMathTag
- [ ] LLVMBuilderSetDefaultFPMathTag
- [ ] LLVMSetCurrentDebugLocation
- [ ] LLVMGetCurrentDebugLocation
- [x] LLVMBuildRetVoid

`Module.insertReturn(at:)`

- [x] LLVMBuildRet

`Module.insertReturn(_:at:)`

- [ ] LLVMBuildAggregateRet
- [x] LLVMBuildBr

  `Module.insertBr(to:at:)`

- [x] LLVMBuildCondBr

  `Module.insertConBr(if:then:else:at:)`

- [ ] LLVMBuildSwitch
- [ ] LLVMBuildIndirectBr
- [ ] LLVMBuildInvoke2
- [ ] LLVMBuildUnreachable
- [ ] LLVMBuildResume
- [ ] LLVMBuildLandingPad
- [ ] LLVMBuildCleanupRet
- [ ] LLVMBuildCatchRet
- [ ] LLVMBuildCatchPad
- [ ] LLVMBuildCleanupPad
- [ ] LLVMBuildCatchSwitch
- [ ] LLVMAddCase
- [ ] LLVMAddDestination
- [ ] LLVMGetNumClauses
- [ ] LLVMGetClause
- [ ] LLVMAddClause
- [ ] LLVMIsCleanup
- [ ] LLVMSetCleanup
- [ ] LLVMAddHandler
- [ ] LLVMGetNumHandlers
- [ ] LLVMGetHandlers
- [ ] LLVMGetArgOperand
- [ ] LLVMSetArgOperand
- [ ] LLVMGetParentCatchSwitch
- [ ] LLVMSetParentCatchSwitch
- [x] LLVMBuildAdd

  `Module.insertAdd(overflow:_:_:at:)`

- [x] LLVMBuildNSWAdd

  `Module.insertAdd(overflow:_:_:at:)`

- [x] LLVMBuildNUWAdd

  `Module.insertAdd(overflow:_:_:at:)`

- [x] LLVMBuildFAdd

  `Module.insertFAdd(_:_:at:)`

- [x] LLVMBuildSub

  `Module.insertSub(overflow:_:_:at:)`

- [x] LLVMBuildNSWSub

  `Module.insertSub(overflow:_:_:at:)`

- [x] LLVMBuildNUWSub

  `Module.insertSub(overflow:_:_:at:)`

- [x] LLVMBuildFSub

  `Module.insertFSub(_:_:at:)`

- [x] LLVMBuildMul

  `Module.insertMul(overflow:_:_:at:)`

- [x] LLVMBuildNSWMul

  `Module.insertMul(overflow:_:_:at:)`

- [x] LLVMBuildNUWMul

  `Module.insertMul(overflow:_:_:at:)`

- [x] LLVMBuildFMul

  `Module.insertFMul(_:_:at:)`

- [x] LLVMBuildUDiv

  `Module.insertUnsignedDiv(exact:_:_:at:)`

- [x] LLVMBuildExactUDiv

  `Module.insertUnsignedDiv(exact:_:_:at:)`

- [x] LLVMBuildSDiv

  `Module.insertSignedDiv(exact:_:_:at:)`

- [x] LLVMBuildExactSDiv

  `Module.insertSignedDiv(exact:_:_:at:)`

- [x] LLVMBuildFDiv

  `Module.insertFDiv(_:_:at:)`

- [ ] LLVMBuildURem
- [ ] LLVMBuildSRem
- [ ] LLVMBuildFRem
- [ ] LLVMBuildShl
- [ ] LLVMBuildLShr
- [ ] LLVMBuildAShr
- [ ] LLVMBuildAnd
- [ ] LLVMBuildOr
- [ ] LLVMBuildXor
- [ ] LLVMBuildBinOp
- [ ] LLVMBuildNeg
- [ ] LLVMBuildNSWNeg
- [ ] LLVMBuildNUWNeg
- [ ] LLVMBuildFNeg
- [ ] LLVMBuildNot
- [ ] LLVMBuildMalloc
- [ ] LLVMBuildArrayMalloc
- [ ] LLVMBuildMemSet
- [ ] LLVMBuildMemCpy
- [ ] LLVMBuildMemMove
- [x] LLVMBuildAlloca

  `Module.insertAlloca(_:at:)`

- [ ] LLVMBuildArrayAlloca
- [ ] LLVMBuildFree
- [x] LLVMBuildLoad2

  `Module.insertLoad(_:_:at:)`

- [x] LLVMBuildStore

  `Module.insertStore(_:_:at:)`

- [ ] LLVMBuildGEP2
- [ ] LLVMBuildInBoundsGEP2
- [ ] LLVMBuildStructGEP2
- [ ] LLVMBuildGlobalString
- [ ] LLVMBuildGlobalStringPtr
- [ ] LLVMGetVolatile
- [ ] LLVMSetVolatile
- [ ] LLVMGetWeak
- [ ] LLVMSetWeak
- [ ] LLVMGetOrdering
- [ ] LLVMSetOrdering
- [ ] LLVMGetAtomicRMWBinOp
- [ ] LLVMSetAtomicRMWBinOp
- [ ] LLVMBuildTrunc
- [ ] LLVMBuildZExt
- [ ] LLVMBuildSExt
- [ ] LLVMBuildFPToUI
- [ ] LLVMBuildFPToSI
- [ ] LLVMBuildUIToFP
- [ ] LLVMBuildSIToFP
- [ ] LLVMBuildFPTrunc
- [ ] LLVMBuildFPExt
- [ ] LLVMBuildPtrToInt
- [ ] LLVMBuildIntToPtr
- [ ] LLVMBuildBitCast
- [ ] LLVMBuildAddrSpaceCast
- [ ] LLVMBuildZExtOrBitCast
- [ ] LLVMBuildSExtOrBitCast
- [ ] LLVMBuildTruncOrBitCast
- [ ] LLVMBuildCast
- [ ] LLVMBuildPointerCast
- [ ] LLVMBuildIntCast2
- [ ] LLVMBuildFPCast
- [ ] LLVMBuildIntCast
- [ ] LLVMGetCastOpcode
- [ ] LLVMBuildICmp
- [ ] LLVMBuildFCmp
- [ ] LLVMBuildPhi
- [ ] LLVMBuildCall2
- [ ] LLVMBuildSelect
- [ ] LLVMBuildVAArg
- [ ] LLVMBuildExtractElement
- [ ] LLVMBuildInsertElement
- [ ] LLVMBuildShuffleVector
- [ ] LLVMBuildExtractValue
- [ ] LLVMBuildInsertValue
- [ ] LLVMBuildFreeze
- [ ] LLVMBuildIsNull
- [ ] LLVMBuildIsNotNull
- [ ] LLVMBuildPtrDiff2
- [ ] LLVMBuildFence
- [ ] LLVMBuildAtomicRMW
- [ ] LLVMBuildAtomicCmpXchg
- [ ] LLVMGetNumMaskElements
- [ ] LLVMGetUndefMaskElem
- [ ] LLVMGetMaskValue
- [ ] LLVMIsAtomicSingleThread
- [ ] LLVMSetAtomicSingleThread
- [ ] LLVMGetCmpXchgSuccessOrdering
- [ ] LLVMSetCmpXchgSuccessOrdering
- [ ] LLVMGetCmpXchgFailureOrdering
- [ ] LLVMSetCmpXchgFailureOrdering
