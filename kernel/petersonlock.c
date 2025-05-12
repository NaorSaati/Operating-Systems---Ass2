#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "petersonlock.h"
#include "proc.h" // בשביל yield()

struct peterson_lock peterson_locks[MAX_PETERSON_LOCKS];

void
petersonlock_init() {
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
        peterson_locks[i].active = 0;
    }
}

int
petersonlock_create() {
    for (int i = 0; i < MAX_PETERSON_LOCKS; i++) {
        if (peterson_locks[i].active == 0) {
            peterson_locks[i].active = 1;
            peterson_locks[i].flag[0] = 0;
            peterson_locks[i].flag[1] = 0;
            peterson_locks[i].turn = 0;
            return i;
        }
    }
    return -1;
}

int
petersonlock_acquire(int lock_id, int role) {
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
        return -1;

    struct peterson_lock *lock = &peterson_locks[lock_id];
    int other = 1 - role;

    lock->flag[role] = 1;
    __sync_synchronize();
    lock->turn = other;
    __sync_synchronize();

    while (lock->flag[other] && lock->turn == other) {
        yield();
    }

    return 0;
}

int
petersonlock_release(int lock_id, int role) {
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
        return -1;

    struct peterson_lock *lock = &peterson_locks[lock_id];

    __sync_synchronize();
    lock->flag[role] = 0;
    __sync_synchronize();

    return 0;
}

int
petersonlock_destroy(int lock_id) {
    if (lock_id < 0 || lock_id >= MAX_PETERSON_LOCKS || peterson_locks[lock_id].active == 0)
        return -1;

    peterson_locks[lock_id].active = 0;
    return 0;
}
