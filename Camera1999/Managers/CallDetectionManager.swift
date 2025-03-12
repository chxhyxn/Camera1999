//
//  CallDetectionManager.swift
//  Camera1999
//
//  Created by SeanCho on 3/11/25.
//

import Foundation
import CallKit

class CallDetectionManager: NSObject, ObservableObject, CXCallObserverDelegate {
    static let shared = CallDetectionManager()
    @Published var isUserOnCall = false
    
    private let callObserver = CXCallObserver()
    
    override private init() {
        super.init()
    }
    
    func startCallDetection() {
        callObserver.setDelegate(self, queue: nil)
        
        // 초기 상태의 콜 목록을 확인
        let activeCalls = callObserver.calls.filter { !$0.hasEnded && $0.hasConnected }
        isUserOnCall = !activeCalls.isEmpty
    }
    
    func stopCallDetection() {
        // 필요한 경우 delegate나 다른 자원을 해제할 수 있으나,
        // 여기서는 별도 해제 과정이 필요 없음
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        // 진행 중인 통화(끝나지 않고 연결된 상태)가 하나라도 있으면 true
        let activeCalls = callObserver.calls.filter { !$0.hasEnded && $0.hasConnected }
        isUserOnCall = !activeCalls.isEmpty
    }
}
