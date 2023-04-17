# Coverage

## Analysis

- [x] LLVMVerifyModule

  `Module.verify()`

- [x] LLVMVerifyFunction

  `Function.isWellFormed()`

- [ ] LLVMViewFunctionCFG
- [ ] LLVMViewFunctionCFGOnly

## Bit Writer

- [x] LLVMWriteBitcodeToFile

  `Module.writeBitcode()`

- [ ] LLVMWriteBitcodeToFD
- [ ] LLVMWriteBitcodeToMemoryBuffer

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
- [x] LLVMGetEnumAttributeKindForName

  `Function.AttributeName.id`

- [ ] LLVMGetLastEnumAttributeKind
- [x] LLVMCreateEnumAttribute

  `Attribute.init(_:_:in:)`

- [x] LLVMGetEnumAttributeKind

  Implemented by `Module.removeAttribute(_:from:)`.

- [x] LLVMGetEnumAttributeValue

  `Attribute.value`

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

### Modules

- [ ] LLVMModuleCreateWithName
- [ ] LLVMModuleCreateWithNameInContext
- [ ] LLVMCloneModule
- [ ] LLVMDisposeModule
- [x] LLVMGetModuleIdentifier

  `Module.name`

- [x] LLVMSetModuleIdentifier

  `Module.name`

- [ ] LLVMGetSourceFileName
- [ ] LLVMSetSourceFileName
- [x] LLVMGetDataLayoutStr

  `Module.layout`

- [ ] LLVMGetDataLayout
- [x] LLVMSetDataLayout

  `Module.layout`

- [ ] LLVMGetTarget
- [ ] Target
- [ ] LLVMCopyModuleFlagsMetadata
- [ ] LLVMDisposeModuleFlagsMetadata
- [ ] LLVMModuleFlagEntriesGetFlagBehavior
- [ ] LLVMModuleFlagEntriesGetKey
- [ ] LLVMModuleFlagEntriesGetMetadata
- [ ] LLVMGetModuleFlag
- [ ] LLVMAddModuleFlag
- [ ] LLVMDumpModule
- [ ] LLVMPrintModuleToFile
- [ ] LLVMPrintModuleToString
- [ ] LLVMGetModuleInlineAsm
- [ ] LLVMSetModuleInlineAsm2
- [ ] LLVMAppendModuleInlineAsm
- [ ] LLVMGetInlineAsm
- [ ] LLVMGetModuleContext
- [ ] LLVMGetTypeByName
- [ ] LLVMGetFirstNamedMetadata
- [ ] LLVMGetLastNamedMetadata
- [ ] LLVMGetNextNamedMetadata
- [ ] LLVMGetPreviousNamedMetadata
- [ ] LLVMGetNamedMetadata
- [ ] LLVMGetOrInsertNamedMetadata
- [ ] LLVMGetNamedMetadataName
- [ ] LLVMGetNamedMetadataNumOperands
- [ ] LLVMGetNamedMetadataOperands
- [ ] LLVMAddNamedMetadataOperand
- [ ] LLVMGetDebugLocDirectory
- [ ] LLVMGetDebugLocFilename
- [ ] LLVMGetDebugLocLine
- [ ] LLVMGetDebugLocColumn
- [ ] LLVMAddFunction
- [x] LLVMGetNamedFunction

  `Module.function(named:)`

- [ ] LLVMGetFirstFunction
- [ ] LLVMGetLastFunction
- [ ] LLVMGetNextFunction
- [ ] LLVMGetPreviousFunction
- [ ] LLVMSetModuleInlineAsm

### Basic Blocks

- [ ] LLVMBasicBlockAsValue
- [ ] LLVMValueIsBasicBlock
- [ ] LLVMValueAsBasicBlock
- [ ] LLVMGetBasicBlockName
- [ ] LLVMGetBasicBlockParent
- [ ] LLVMGetBasicBlockTerminator
- [x] LLVMCountBasicBlocks

  Implemented as the `count` property of `Function.basicBlocks`.

- [x] LLVMGetBasicBlocks

  `Function.basicBlocks`

- [ ] LLVMGetFirstBasicBlock
- [ ] LLVMGetLastBasicBlock
- [ ] LLVMGetNextBasicBlock
- [ ] LLVMGetPreviousBasicBlock
- [x] LLVMGetEntryBasicBlock

  `Function.entry`

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
- [x] LLVMGetValueName2

  `IRValue.name`

- [x] LLVMSetValueName2

  `IRValue.name`

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
- [x] LLVMConstArray

  `ArrayConstant.init(of:containing:in:)`

- [ ] LLVMConstArray2
- [ ] LLVMConstNamedStruct
- [ ] LLVMGetAggregateElement
- [ ] LLVMConstVector

##### Global Values

- [ ] LLVMGetGlobalParent
- [ ] LLVMIsDeclaration
- [ ] LLVMGetLinkage
- [ ] LLVMSetLinkage
- [ ] LLVMGetSection
- [ ] LLVMSetSection
- [ ] LLVMGetVisibility
- [ ] LLVMSetVisibility
- [ ] LLVMGetDLLStorageClass
- [ ] LLVMSetDLLStorageClass
- [ ] LLVMGetUnnamedAddress
- [ ] LLVMSetUnnamedAddress
- [x] LLVMGlobalGetValueType

  `Global.valueType`

- [ ] LLVMHasUnnamedAddr
- [ ] LLVMSetUnnamedAddr
- [ ] LLVMGetAlignment
- [ ] LLVMSetAlignment
- [ ] LLVMGlobalSetMetadata
- [ ] LLVMGlobalEraseMetadata
- [ ] LLVMGlobalClearMetadata
- [ ] LLVMGlobalCopyAllMetadata
- [ ] LLVMDisposeValueMetadataEntries
- [ ] LLVMValueMetadataEntriesGetKind
- [ ] LLVMValueMetadataEntriesGetMetadata

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

##### Function Values

- [ ] LLVMDeleteFunction
- [ ] LLVMHasPersonalityFn
- [ ] LLVMGetPersonalityFn
- [ ] LLVMSetPersonalityFn
- [ ] LLVMLookupIntrinsicID
- [ ] LLVMGetIntrinsicID
- [ ] LLVMGetIntrinsicDeclaration
- [ ] LLVMIntrinsicGetType
- [ ] LLVMIntrinsicGetName
- [ ] LLVMIntrinsicCopyOverloadedName
- [ ] LLVMIntrinsicCopyOverloadedName2
- [ ] LLVMIntrinsicIsOverloaded
- [ ] LLVMGetFunctionCallConv
- [ ] LLVMSetFunctionCallConv
- [ ] LLVMGetGC
- [ ] LLVMSetGC
- [x] LLVMAddAttributeAtIndex

  `Module.addAttribute(_:_:to:)`

- [x] LLVMGetAttributeCountAtIndex

  Implemented as the `count` property of `Function.attributes`.

- [x] LLVMGetAttributesAtIndex

  Implemented by `Function.attributes`.

- [ ] LLVMGetEnumAttributeAtIndex
- [ ] LLVMGetStringAttributeAtIndex
- [x] LLVMRemoveEnumAttributeAtIndex

  `Module.removeAttribute(_:from:)`

- [ ] LLVMRemoveStringAttributeAtIndex
- [ ] LLVMAddTargetDependentFunctionAttr

###### Function Parameters

- [x] LLVMCountParams

  `Function.Parameters.count`

- [ ] LLVMGetParams
- [x] LLVMGetParam

  `Function.Parameters[_:]`

- [x] LLVMGetParamParent

  `Parameter.parent`

- [ ] LLVMGetFirstParam
- [ ] LLVMGetLastParam
- [ ] LLVMGetNextParam
- [ ] LLVMGetPreviousParam
- [ ] LLVMSetParamAlignment

##### Global Variables

- [ ] LLVMAddGlobal
- [x] LLVMAddGlobalInAddressSpace

  `Module.declareGlobal(_:_:inAddressSpace:)`

- [x] LLVMGetNamedGlobal

  `Module.global(named:)`

- [ ] LLVMGetFirstGlobal
- [ ] LLVMGetLastGlobal
- [ ] LLVMGetNextGlobal
- [ ] LLVMGetPreviousGlobal
- [ ] LLVMDeleteGlobal
- [x] LLVMGetInitializer

  `GlobalVariable.initializer`

- [x] LLVMSetInitializer

  `Module.setInitializer(_:for:)`

- [ ] LLVMIsThreadLocal
- [ ] LLVMSetThreadLocal
- [x] LLVMIsGlobalConstant

  `GlobalVariable.isGlobalConstant`

- [x] LLVMSetGlobalConstant

  `Module.setGlobalConstant(_:for:)`

- [ ] LLVMGetThreadLocalMode
- [ ] LLVMSetThreadLocalMode
- [x] LLVMIsExternallyInitialized

  `GlobalVariable.isExternallyInitialized`

- [x] LLVMSetExternallyInitialized

  `Module.setExternallyInitialized(_:for:)`

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
- [x] LLVMBuildUnreachable

  `Module.insertUnreachable(at:)`

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

- [x] LLVMBuildGEP2

  `Module.insertGetElementPointer(of:typed:indices:at:)`

- [x] LLVMBuildInBoundsGEP2

  `Module.insertGetElementPointerInBounds(of:typed:indices:at:)`

- [x] LLVMBuildStructGEP2

  `Module.insertGetStructElementPointer(of:typed:index:at:)`

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
- [x] LLVMBuildTrunc

  `Module.insertTrunc(_:to:at:)`

- [x] LLVMBuildZExt

  `Module.insertZeroExtend(_:to:at:)`

- [x] LLVMBuildSExt

  `Module.insertSignedExtend(_:to:at:)`

- [ ] LLVMBuildFPToUI
- [ ] LLVMBuildFPToSI
- [ ] LLVMBuildUIToFP
- [ ] LLVMBuildSIToFP
- [x] LLVMBuildFPTrunc

  `Module.insertFPTrunc(_:to:at:)`

- [x] LLVMBuildFPExt

  `Module.insertFPExt(_:to:at:)`

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
- [x] LLVMBuildICmp

  `Module.insertIntegerComparison(_:_:_:at:)`

- [x] LLVMBuildFCmp

  `Module.insertFloatingPointComparison(_:_:_:at:)`

- [ ] LLVMBuildPhi
- [x] LLVMBuildCall2

  `Module.insertCall(_:typed:on:at:)`
  `Module.insertCall(_:on:at:)`

- [ ] LLVMBuildSelect
- [ ] LLVMBuildVAArg
- [ ] LLVMBuildExtractElement
- [ ] LLVMBuildInsertElement
- [ ] LLVMBuildShuffleVector
- [x] LLVMBuildExtractValue

  `Module.insertExtractValue(from:at:at:)`

- [x] LLVMBuildInsertValue

  `Module.insertInserValue(_:at:into:at:)`

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

## Memory Buffers

- [x] LLVMCreateMemoryBufferWithContentsOfFile

  `MemoryBuffer.init(contentsOf:)`

- [ ] LLVMCreateMemoryBufferWithSTDIN
- [x] LLVMCreateMemoryBufferWithMemoryRange

  `MemoryBuffer.withInstanceBorrowing(_:named:_:)`

- [x] LLVMCreateMemoryBufferWithMemoryRangeCopy

  `MemoryBuffer.init(copying:named:)`

- [x] LLVMGetBufferStart

  `MemoryBuffer.withUnsafeBytes`

- [x] LLVMGetBufferSize

  `MemoryBuffer.count`

- [x] LLVMDisposeMemoryBuffer

  Implemented by `MemoryBuffer.wrapped`.

## Target Information

- [ ] LLVMInitializeAllTargetInfos
- [ ] LLVMInitializeAllTargets
- [ ] LLVMInitializeAllTargetMCs
- [ ] LLVMInitializeAllAsmPrinters
- [ ] LLVMInitializeAllAsmParsers
- [ ] LLVMInitializeAllDisassemblers
- [x] LLVMInitializeNativeTarget

  `Target.host()`

- [x] LLVMInitializeNativeAsmParser

  `Target.host()`

- [x] LLVMInitializeNativeAsmPrinter

  `Target.host()`

- [x] LLVMInitializeNativeDisassembler

  `Target.host()`

- [ ] LLVMGetModuleDataLayout
- [ ] LLVMSetModuleDataLayout
- [ ] LLVMCreateTargetData
- [x] LLVMDisposeTargetData

  Implemented by `DataLayout.wrapped`

- [ ] LLVMAddTargetLibraryInfo
- [x] LLVMCopyStringRepOfTargetData

  `DataLayout.description`

- [ ] LLVMByteOrder
- [ ] LLVMPointerSize
- [ ] LLVMPointerSizeForAS
- [ ] LLVMIntPtrType
- [ ] LLVMIntPtrTypeForAS
- [ ] LLVMIntPtrTypeInContext
- [ ] LLVMIntPtrTypeForASInContext
- [ ] LLVMSizeOfTypeInBits
- [x] LLVMStoreSizeOfType

  `DataLayout.storageSize(of:)`

- [ ] LLVMABISizeOfType
- [x] LLVMABIAlignmentOfType

  `DataLayout.abiAlignment(of:)`

- [ ] LLVMCallFrameAlignmentOfType
- [x] LLVMPreferredAlignmentOfType

  `DataLayout.preferredAlignment(of:)`

- [ ] LLVMPreferredAlignmentOfGlobal
- [x] LLVMElementAtOffset

  `DataLayout.element(at:in:)`

- [x] LLVMOffsetOfElement

  `DataLayout.offset(of:in:)`

- [ ] LLVMGetFirstTarget
- [ ] LLVMGetNextTarget
- [ ] LLVMGetTargetFromName
- [x] LLVMGetTargetFromTriple

  `Target.host()`

- [x] LLVMGetTargetName

  `Target.name`

- [x] LLVMGetTargetDescription

  `Target.description`

- [x] LLVMTargetHasJIT

  `Target.hasJIT`

- [ ] LLVMTargetHasTargetMachine
- [x] LLVMTargetHasAsmBackend

  `Target.hasAssemblyBackEnd`

- [x] LLVMCreateTargetMachine

  `TargetMachine.init(for:cpu:features:optimization:relocation:code:)`

- [x] LLVMDisposeTargetMachine

  Implemented by `TargetMachine.wrapped`.

- [x] LLVMGetTargetMachineTarget

  `Target.init(of:)`

- [x] LLVMGetTargetMachineTriple

  `TargetMachine.triple`

- [x] LLVMGetTargetMachineCPU

  `TargetMachine.cpu`

- [x] LLVMGetTargetMachineFeatureString

  `TargetMachine.features`

- [x] LLVMCreateTargetDataLayout

  `DataLayout.init(of:)`

- [ ] LLVMSetTargetMachineAsmVerbosity
- [x] LLVMTargetMachineEmitToFile

  `Module.write(_:for:to:)`

- [ ] LLVMTargetMachineEmitToMemoryBuffer

  `Module.compile(_:for:)`

- [x] LLVMGetDefaultTargetTriple

  `Target.host()`

- [ ] LLVMNormalizeTargetTriple
- [ ] LLVMGetHostCPUName
- [ ] LLVMGetHostCPUFeatures
- [ ] LLVMAddAnalysisPasses
