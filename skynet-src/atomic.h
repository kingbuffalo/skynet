#ifndef SKYNET_ATOMIC_H
#define SKYNET_ATOMIC_H

#define ATOM_CAS(ptr, oval, nval) __sync_bool_compare_and_swap(ptr, oval, nval)
#define ATOM_CAS_POINTER(ptr, oval, nval) __sync_bool_compare_and_swap(ptr, oval, nval)
#define ATOM_INC(ptr) __sync_add_and_fetch(ptr, 1)
#define ATOM_FINC(ptr) __sync_fetch_and_add(ptr, 1)
#define ATOM_DEC(ptr) __sync_sub_and_fetch(ptr, 1)
#define ATOM_FDEC(ptr) __sync_fetch_and_sub(ptr, 1)
#define ATOM_ADD(ptr,n) __sync_add_and_fetch(ptr, n)
#define ATOM_SUB(ptr,n) __sync_sub_and_fetch(ptr, n)
#define ATOM_AND(ptr,n) __sync_and_and_fetch(ptr, n)

/*
 * 这里有用的知识点是
 * atomic 做的事情：原子指令修改内存，内存栅栏保障修改可见，必要时锁总线。
 * --------------------------
 * mutex 大致做的事情：短暂原子 compare and set 自旋如果未成功上锁，
 * futex(&lock, FUTEX_WAIT... ) 退避进入阻塞等待直到 lock 值变化时唤醒。
 * futex 在设计上期望做到如果无争用，则可以不进内核态，不进内核态的
 * fast path 的开销等价于 atomic 判断。内核里维护按地址维护一张
 * wait queue 的哈希表，发现锁变量值的变化（解锁）时，
 * 唤醒对应的 wait queue 中的一个 task。wait queue 这个哈希表的槽在更新时也会遭遇争用，
 * 这时继续通过 spin lock 保护。
 */

#endif
