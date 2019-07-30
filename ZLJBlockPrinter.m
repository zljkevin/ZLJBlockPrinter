//
//  ZLJBlockPrinter.m
//
//  Created by ZLJKevin on 2019/7/30.
//
//GitHub:https://github.com/zljkevin/ZLJBlockPrinter
//文章：http://iosre.com/t/zljblockprinter-block/15231

#import "ZLJBlockPrinter.h"

@implementation ZLJBlockPrinter

+ (NSString *)printBlock:(id)aBlock{

    if (!([aBlock isKindOfClass:NSClassFromString(@"__NSGlobalBlock__")] ||
          [aBlock isKindOfClass:NSClassFromString(@"__NSMallocBlock__")] ||
          [aBlock isKindOfClass:NSClassFromString(@"__NSStackBlock__")]    )) {
        return @"ZLJBlockPrinter Error: Not A Block!";
    }

    uint64_t blockInMemory[4];      //block 在内存中的前4个uint64_t
    uint64_t descriptor[5];         //block的descriptor 在内存中的前5个uint64_t
    char *signatureCStr;
    NSMethodSignature *blockSignature;

    void *aBlockPtr = (__bridge void *)(aBlock);
    memcpy(blockInMemory, (void *)aBlockPtr, sizeof(blockInMemory));
    memcpy(descriptor, (void *)blockInMemory[3], sizeof(descriptor));

    BOOL hasSignature = ((blockInMemory[1] & 0x00000000FFFFFFFF)  & (1 << 30)) != 0;
    if (!hasSignature) {
        return @"ZLJBlockPrinter: Block Do Not Have Signature!";
    }

    BOOL hasCopyDisposeHelper = ((blockInMemory[1] & 0x00000000FFFFFFFF)  & (1 << 25)) != 0;

    if (hasCopyDisposeHelper) {
        signatureCStr = (char *)descriptor[4];
    }else{
        signatureCStr = (char *)descriptor[2];
    }
    blockSignature = [NSMethodSignature signatureWithObjCTypes:signatureCStr];

    return [NSString stringWithFormat:@"\n%@\nBlockVmaddrSlide:0x%llx\nBlockSignature:%@",
            aBlock,
            blockInMemory[2],
            blockSignature.debugDescription];
}


@end
