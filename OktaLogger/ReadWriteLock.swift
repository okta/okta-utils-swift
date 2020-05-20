import Foundation

/**
 Internal helper class to wrap readwrite locks
 */
@objc
class ReadWriteLock: NSObject {
    
    func writeLock() {
        pthread_rwlock_wrlock(&self.lock)
    }
    
    func readLock() {
        pthread_rwlock_rdlock(&self.lock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(&self.lock)
    }
    
    deinit {
        pthread_rwlock_destroy(&self.lock)
    }
    
    override init() {
        self.lock = pthread_rwlock_t()
        pthread_rwlock_init(&self.lock, nil)
    }
    private var lock: pthread_rwlock_t
}
