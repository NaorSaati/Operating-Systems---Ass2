#define MAX_PETERSON_LOCKS 15

struct peterson_lock {
  int active;
  int flag[2];
  int turn;
};

void petersonlock_init();
int petersonlock_create();
int petersonlock_acquire(int lock_id, int role);
int petersonlock_release(int lock_id, int role);
int petersonlock_destroy(int lock_id);