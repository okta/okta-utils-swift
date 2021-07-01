/*
 * Copyright (c) 2020-Present, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */
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
